import UIKit
import Flutter
import Firebase
import FirebaseMessaging
import QuickLook
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
  /// QLPreviewController keeps its dataSource weakly — hold it while shown.
  private var receiptPreviewSource: ReceiptPreviewSource?
  // Обновление Shorebird включается только в новом движке Flutter. iOS не даёт приложению
  // открыть себя заново, поэтому Flutter пересоздаётся внутри процесса. Shorebird загружает
  // код обновления один раз за процесс, поэтому так можно сделать только один раз.
  private var restartedIntoPatch: Int?
  // Чат, открытый сейчас на экране (lib/services/push_notification_service.dart): его пуши без звука
  private var openChatId: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    Messaging.messaging().delegate = self
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)
    registerReceiptFilesChannel(in: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      listenForRestart(on: controller.binaryMessenger)
      listenForOpenChat(on: controller.binaryMessenger)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Обновление «по воздуху» (lib/ota_update_prompt.dart): по кнопке Dart просит перезапуск.
  private func listenForRestart(on messenger: FlutterBinaryMessenger) {
    FlutterMethodChannel(name: "az.buking.buking/app_restart", binaryMessenger: messenger)
      .setMethodCallHandler { [weak self] call, result in
        guard let self else { return result(false) }
        switch call.method {
        case "canRestart":
          result(self.restartedIntoPatch == nil)
        case "restartedIntoPatch":
          result(self.restartedIntoPatch)
        case "restart":
          guard self.restartedIntoPatch == nil, let patch = call.arguments as? Int else {
            return result(false)
          }
          self.restartedIntoPatch = patch
          result(true)
          // Старый движок останавливаем на следующем витке, чтобы Dart успел получить ответ
          DispatchQueue.main.async { self.restartFlutter() }
        default:
          result(FlutterMethodNotImplemented)
        }
      }
  }

  private func listenForOpenChat(on messenger: FlutterBinaryMessenger) {
    FlutterMethodChannel(name: "az.buking.buking/open_chat", binaryMessenger: messenger)
      .setMethodCallHandler { [weak self] call, result in
        guard call.method == "set" else { return result(FlutterMethodNotImplemented) }
        self?.openChatId = call.arguments as? String
        result(nil)
      }
  }

  private func isFromOpenChat(_ info: [AnyHashable: Any]) -> Bool {
    guard let chat = openChatId else { return false }
    guard (info["target_type"] ?? info["type"]).map({ "\($0)" }) == "conversation" else {
      return false
    }
    let id = [info["conversation_id"], info["target_id"]]
      .compactMap { $0.map { "\($0)" } }
      .first { !$0.isEmpty }
    return id == chat
  }

  private func restartFlutter() {
    guard let window, let oldController = window.rootViewController as? FlutterViewController
    else { return }
    // Старый Dart-код должен полностью остановиться до старта нового
    let oldEngine: FlutterEngine? = oldController.engine
    if let oldEngine { shutDown(oldEngine, shownIn: oldController) }
    // Новый движок стартует уже с обновлением, до первого кадра видна заставка
    let controller = FlutterViewController(project: nil, nibName: nil, bundle: nil)
    GeneratedPluginRegistrant.register(with: controller.pluginRegistry())
    registerReceiptFilesChannel(in: controller.pluginRegistry())
    connectPushNotifications(in: controller.pluginRegistry())
    listenForRestart(on: controller.binaryMessenger)
    openChatId = nil
    listenForOpenChat(on: controller.binaryMessenger)
    window.rootViewController = controller
  }

  // Любое обращение к остановленному движку роняет приложение. Поэтому сначала отцепляем всё,
  // что может к нему обратиться: старый экран (iOS позже присылает ему «экран скрыт»),
  // уведомления iOS и сообщения старых плагинов.
  private func shutDown(_ engine: FlutterEngine, shownIn controller: FlutterViewController) {
    NotificationCenter.default.removeObserver(controller)
    NotificationCenter.default.removeObserver(engine)
    engine.viewController = nil
    var relays: [Any?] = [engine.binaryMessenger]
    if engine.responds(to: NSSelectorFromString("textureRegistry")) {
      relays.append(engine.value(forKey: "textureRegistry"))
    }
    // Через эти посредники сообщения плагинов идут в движок; после отключения они просто теряются
    for case let relay as NSObject in relays
    where relay.responds(to: NSSelectorFromString("setParent:")) {
      relay.setValue(nil, forKey: "parent")
    }
    engine.destroyContext()
  }

  // firebase_messaging подключается к уведомлениям только в момент запуска приложения. Его
  // экземпляр в новом движке этот момент не видит, поэтому вызываем этот шаг сами: иначе до
  // следующего запуска пуш не виден в открытом приложении и нажатие на пуш не срабатывает.
  private func connectPushNotifications(in registry: FlutterPluginRegistry) {
    let selector = NSSelectorFromString("application_onDidFinishLaunchingNotification:")
    guard let plugin = registry.valuePublished(byPlugin: "FLTFirebaseMessagingPlugin"),
      plugin.responds(to: selector)
    else { return }
    plugin.perform(
      selector,
      with: NSNotification(name: UIApplication.didFinishLaunchingNotification, object: nil))
  }

  // Receipt PDFs (lib/screens/payments/receipt_pdf.dart): the Dart side saves
  // the server PDF into Documents, then asks for the system preview — from
  // there the user saves it to «Files» or sends it on.
  private func registerReceiptFilesChannel(in registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "WawatReceiptFiles") else { return }
    let channel = FlutterMethodChannel(
      name: "az.buking.buking/receipt_files",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "preview" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let args = call.arguments as? [String: Any],
            let path = args["path"] as? String,
            FileManager.default.fileExists(atPath: path) else {
        result(FlutterError(code: "bad_args", message: "missing file", details: nil))
        return
      }
      result(self?.presentReceiptPreview(URL(fileURLWithPath: path)) ?? false)
    }
  }

  private func presentReceiptPreview(_ url: URL) -> Bool {
    guard var top = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .flatMap({ $0.windows })
      .first(where: { $0.isKeyWindow })?.rootViewController else { return false }
    while let presented = top.presentedViewController { top = presented }
    let source = ReceiptPreviewSource(url: url)
    receiptPreviewSource = source
    let preview = QLPreviewController()
    preview.dataSource = source
    top.present(preview, animated: true)
    return true
  }

  // Required when FirebaseAppDelegateProxyEnabled is false.
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    NSLog("APNs registration failed: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable : Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    Messaging.messaging().appDidReceiveMessage(userInfo)
    super.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
  }

  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    NSLog("FCM registration token refreshed on iOS: \(fcmToken != nil ? "ok" : "nil")")
  }

  // Foreground (app open): play the push SOUND but do NOT show the OS banner —
  // the app renders its own in-app banner. Returning only [.badge, .sound]
  // (no .banner/.list/.alert) matches the Android foreground behaviour.
  // willPresent fires ONLY in foreground, so background/killed are unaffected.
  // A message from the chat that is open on screen arrives silently.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if isFromOpenChat(notification.request.content.userInfo) {
      return completionHandler([.badge])
    }
    completionHandler([.badge, .sound])
  }

  // Handle notification tap from background / terminated.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }
}

/// Single-file data source for the receipt preview.
final class ReceiptPreviewSource: NSObject, QLPreviewControllerDataSource {
  private let url: URL

  init(url: URL) {
    self.url = url
  }

  func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }

  func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
    url as NSURL
  }
}
