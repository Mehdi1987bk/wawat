package az.buking.buking

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ContentResolver
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build

/**
 * Custom Application so the high-importance notification channel is created —
 * with the airplane sound — BEFORE FirebaseMessagingService can handle any push.
 *
 * Why native and not just from Flutter: a notification-type FCM push that arrives
 * while the app is killed or freshly installed is displayed by Firebase's native
 * service. If the target channel does not exist yet, Android auto-creates it with
 * the DEFAULT sound — and a channel's sound is immutable once created. Creating it
 * here, in onCreate() (which runs before the messaging service), guarantees the
 * custom sound on every device, every time. The Flutter side creates the same
 * channel too, so either path is correct; this one just always wins the race.
 */
class WawatApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        createAirplaneChannel()
    }

    private fun createAirplaneChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java) ?: return

        // Delete channels that may have been auto-created with the default sound
        // by older builds / by Firebase before Flutter ran. Their sound can never
        // be changed in place — only escaped by moving to a fresh channel id.
        for (legacy in LEGACY_CHANNEL_IDS) {
            manager.deleteNotificationChannel(legacy)
        }

        // Already created correctly (e.g. app relaunch) → leave it untouched.
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return

        val soundUri = Uri.parse(
            "${ContentResolver.SCHEME_ANDROID_RESOURCE}://$packageName/raw/$SOUND",
        )
        val attributes = AudioAttributes.Builder()
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
            .build()

        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = CHANNEL_DESC
            setSound(soundUri, attributes)
            enableVibration(true)
            setShowBadge(true)
        }
        manager.createNotificationChannel(channel)
    }

    private companion object {
        // Keep in sync with _androidChannelId in push_notification_service.dart
        // and default_notification_channel_id in AndroidManifest.xml.
        const val CHANNEL_ID = "wawat_airplane_v3"
        const val CHANNEL_NAME = "Wawat Air"
        const val CHANNEL_DESC = "Wawat Air bildirişləri"
        const val SOUND = "airplane"

        val LEGACY_CHANNEL_IDS = listOf(
            "high_importance_channel",
            "wawat_high_importance",
            "wawat_alerts",
            "wawat_airplane_v2",
        )
    }
}
