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

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    Messaging.messaging().delegate = self
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)
    registerReceiptFilesChannel()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Receipt PDFs (lib/screens/payments/receipt_pdf.dart): the Dart side saves
  // the server PDF into Documents, then asks for the system preview — from
  // there the user saves it to «Files» or sends it on.
  private func registerReceiptFilesChannel() {
    guard let registrar = self.registrar(forPlugin: "WawatReceiptFiles") else { return }
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
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
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
