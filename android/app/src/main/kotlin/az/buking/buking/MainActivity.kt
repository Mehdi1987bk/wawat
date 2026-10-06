package az.buking.buking

import android.content.ActivityNotFoundException
import android.content.ContentUris
import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.provider.Settings
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.IOException

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            WindowCompat.setDecorFitsSystemWindows(window, false)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Receipt PDFs (lib/screens/payments/receipt_pdf.dart): save into the
        // public «Downloads» folder and open them in the user's PDF viewer.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, RECEIPT_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveToDownloads" -> {
                        val name = call.argument<String>("name")
                        val bytes = call.argument<ByteArray>("bytes")
                        if (name.isNullOrEmpty() || bytes == null) {
                            result.error("bad_args", "name and bytes are required", null)
                            return@setMethodCallHandler
                        }
                        val main = Handler(Looper.getMainLooper())
                        Thread {
                            try {
                                val uri = saveToDownloads(name, bytes)
                                main.post { result.success(uri) }
                            } catch (e: Exception) {
                                main.post { result.error("save_failed", e.toString(), null) }
                            }
                        }.start()
                    }
                    "openUri" -> {
                        val uri = call.argument<String>("uri")
                        if (uri.isNullOrEmpty()) {
                            result.error("bad_args", "uri is required", null)
                        } else {
                            result.success(openPdf(Uri.parse(uri)))
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        // Экран настроек уведомлений (lib/services/push_permission_prompt.dart)
        // предлагает открыть системные настройки, если пользователь отказал в
        // разрешении: системный диалог второй раз уже не покажется.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            NOTIFICATION_SETTINGS_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "open" -> result.success(openNotificationSettings())
                else -> result.notImplemented()
            }
        }
    }

    /// Opens this app's notification settings (Android 8+), falling back to the
    /// app-details screen. False when the device has neither.
    private fun openNotificationSettings(): Boolean {
        val candidates = mutableListOf<Intent>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            candidates.add(
                Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                    .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
            )
        }
        candidates.add(
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                .setData(Uri.fromParts("package", packageName, null))
        )
        for (intent in candidates) {
            try {
                startActivity(intent)
                return true
            } catch (e: ActivityNotFoundException) {
                // Нет такого экрана — пробуем следующий.
            }
        }
        return false
    }

    /// Writes [bytes] to Downloads/[name] through MediaStore (Android 10+, no
    /// storage permission). Re-saving the same receipt overwrites our own
    /// earlier copy instead of piling up "name (1).pdf". Returns the content
    /// uri, or null below Android 10 (the Dart side then falls back to share).
    private fun saveToDownloads(name: String, bytes: ByteArray): String? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return null
        val resolver = contentResolver
        val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI
        val relativePath = Environment.DIRECTORY_DOWNLOADS + "/"
        val existing = resolver.query(
            collection,
            arrayOf(MediaStore.Downloads._ID),
            "${MediaStore.Downloads.DISPLAY_NAME}=? AND ${MediaStore.Downloads.RELATIVE_PATH}=?",
            arrayOf(name, relativePath),
            null,
        )?.use { c ->
            if (c.moveToFirst()) ContentUris.withAppendedId(collection, c.getLong(0)) else null
        }
        val uri = existing ?: resolver.insert(collection, ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, name)
            put(MediaStore.Downloads.MIME_TYPE, "application/pdf")
            put(MediaStore.Downloads.RELATIVE_PATH, relativePath)
            put(MediaStore.Downloads.IS_PENDING, 1)
        }) ?: throw IOException("MediaStore insert returned null")
        try {
            val out = resolver.openOutputStream(uri, "wt")
                ?: throw IOException("no output stream for $uri")
            out.use { it.write(bytes) }
        } catch (e: Exception) {
            if (existing == null) resolver.delete(uri, null, null)
            throw e
        }
        if (existing == null) {
            resolver.update(uri, ContentValues().apply {
                put(MediaStore.Downloads.IS_PENDING, 0)
            }, null, null)
        }
        return uri.toString()
    }

    /// False when no installed app can show a PDF — the file stays saved.
    private fun openPdf(uri: Uri): Boolean {
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/pdf")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        return try {
            startActivity(intent)
            true
        } catch (e: ActivityNotFoundException) {
            false
        }
    }

    companion object {
        private const val RECEIPT_CHANNEL = "az.buking.buking/receipt_files"
        private const val NOTIFICATION_SETTINGS_CHANNEL =
            "az.buking.buking/notification_settings"
    }
}
