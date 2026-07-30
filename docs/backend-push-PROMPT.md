# PROMPT FOR THE BACKEND (custom push sound)

You maintain the backend that sends Firebase Cloud Messaging (FCM) push notifications for the
**Wawatair** mobile app (Flutter; Android package **`az.buking.buking`**, iOS bundle `wawat.app`,
Firebase project `wawatair-b212f`).

## The bug

On Android, notifications play the **system default sound** instead of the app's custom
**`airplane`** tone. The **mobile app is verified correct** — it bundles `airplane.mp3` in
`res/raw/`, creates its own high-importance channel **`wawat_airplane_v4`** with that sound, and
declares it as the app's default FCM channel. The problem is in the **payload your backend sends**.
You must fix the payload.

## Why (the Android rule you must respect)

- On **Android 8+, a notification's sound is a property of its notification _channel_ and is
  immutable** — it is fixed when the channel is first created and can never be changed. The
  per-message `sound` field is **ignored** on Android 8+.
- So the sound is decided **entirely by which channel the notification lands in.**
- The app already created the correct channel **`wawat_airplane_v4`** (airplane sound) and set it as
  the manifest default:
  `com.google.firebase.messaging.default_notification_channel_id = wawat_airplane_v4`.
- **If your payload sets `channel_id` to any other id**, the push lands in that other channel — which
  has the default sound and can never be fixed. This is the current bug. Also, posting to a **deleted**
  old id makes Android **resurrect it with the default sound**, so old ids must never be sent.

Diagnostic proof (optional): the app logs every incoming push. `adb logcat -s flutter | grep 'FCM\['`
prints `android.channelId=…` — that shows exactly which channel id your backend is currently sending.
It is almost certainly one of the old ids listed below (or `sound:"default"`).

## Required fix

Whichever FCM API you use:

### FCM HTTP v1 (recommended API)

1. **Remove `android.notification.channel_id` from the payload entirely** (best) → the app's default
   channel `wawat_airplane_v4` is used automatically and you never depend on the app's channel id
   again. *(Alternatively set it to exactly `"wawat_airplane_v4"` — nothing else.)*
2. **Never** send these ids: `high_importance_channel`, `wawat_high_importance`, `wawat_alerts`,
   `wawat_airplane_v2`, `wawat_airplane_v3`.
3. **Remove `android.notification.sound`** if it is `"default"` (ignored on Android 8+; never force
   `"default"`).
4. Set `android.priority = "high"`.
5. **iOS:** `apns.payload.aps.sound = "airplane.caf"` — **not** `"default"`, and **not** `"airplane.mp3"`
   (iOS does not support `.mp3` for notification sounds). *(If `airplane.caf` is not yet bundled in the
   iOS app, that is a separate app-side task; for Android nothing else is needed.)*

Correct payload:

```json
{
  "message": {
    "token": "<device_fcm_token>",
    "notification": { "title": "Wawat Air", "body": "Yeni mesaj" },
    "android": {
      "priority": "high",
      "notification": {
        // NO "channel_id" here → app default channel wawat_airplane_v4 (airplane sound) is used.
        // NO "sound": "default".
      }
    },
    "apns": {
      "headers": { "apns-priority": "10" },
      "payload": { "aps": { "sound": "airplane.caf" } }
    },
    "data": { "target_type": "conversation", "target_id": "01J...", "title": "Wawat Air", "body": "Yeni mesaj" }
  }
}
```

### Legacy FCM API (if you still use `/fcm/send`)

- **Remove `notification.android_channel_id`** (or set it to `"wawat_airplane_v4"`), never an old id.
- **Remove `notification.sound: "default"`.**
- Set `"priority": "high"`.

## Before → after

| Field | Now (broken) | Fix |
| --- | --- | --- |
| `android.notification.channel_id` (v1) / `notification.android_channel_id` (legacy) | an old id (`high_importance_channel` / `wawat_high_importance` / `wawat_airplane_v2` / `v3` …) | **remove it** (or `wawat_airplane_v4`) |
| `android.notification.sound` / `notification.sound` | `"default"` | remove it |
| `android.priority` | (missing/normal) | `"high"` |
| `apns.payload.aps.sound` | `"default"` | `"airplane.caf"` |

## Where to change it (firebase-admin SDK)

Find where you build the Android notification and delete the channel-id / sound-default lines:

- **Node.js:** in the `android.notification` object, remove `channelId: '...'` and any
  `sound: 'default'`. Keep `android: { priority: 'high' }`.
- **PHP (kreait/firebase-php):** on `AndroidConfig`, do **not** call `->withDefaultSound()` and do not
  set a channel id; if you build `AndroidNotification`, omit `channelId(...)`.
- **Python (firebase-admin):** in `messaging.AndroidNotification(...)`, omit `channel_id=` and
  `sound='default'`; set `messaging.AndroidConfig(priority='high')`.

The single most important change is: **stop sending any `channel_id` and stop sending
`sound:"default"` for Android.**

## Verify (Android, on a real device)

```bash
# what channel the delivered push actually used:
adb shell dumpsys notification --noredact | grep -A25 'az.buking.buking'
#   effectiveNotificationChannel=wawat_airplane_v4
#   mSound=android.resource://az.buking.buking/raw/airplane
```

**Done when** a background/killed push plays `airplane.mp3`, and `effectiveNotificationChannel` is
`wawat_airplane_v4` with `mSound=…/raw/airplane`.
