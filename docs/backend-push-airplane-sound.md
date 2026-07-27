# Backend contract — push notifications (sound + tap routing)

Two things must be right in the FCM payload for pushes to work on this app:

1. **Sound** — the custom `airplane` tone must play (not the system default, not silent).
2. **Tap routing** — tapping the push must open the *right* screen (chat, deal, listing…), not
   nothing and not the generic notifications feed.

Both are payload-driven. The app side has been hardened (see "Client changes" below), but the backend
**must** send the fields documented here.

---

## TL;DR — send this

FCM HTTP v1, per push. Values in `data` **must be strings**.

```jsonc
{
  "message": {
    "token": "<device_fcm_token>",
    "notification": { "title": "Wawat Air", "body": "Yeni mesaj" },
    "android": {
      "priority": "high",
      "notification": {
        "channel_id": "wawat_airplane_v4",   // best: OMIT this line → manifest default (v4) is used
        "sound": "airplane"                    // Android < 8 only; on 8+ the channel sound wins
      }
    },
    "apns": {
      "headers": { "apns-priority": "10" },
      "payload": { "aps": { "sound": "airplane.caf" } }   // see iOS note
    },
    "data": {
      "target_type": "conversation",   // REQUIRED — canonical value, see table
      "target_id": "01J...ULID",       // entity id (conversation/shipment/listing/username)
      "conversation_id": "01J...ULID", // chat: send here too (or in target_id)
      "title": "Wawat Air",            // include in data too (needed if you ever go data-only)
      "body": "Yeni mesaj"
    }
  }
}
```

The **two fields that fix the reported bugs**: `data.target_type` (routing) and
`android.notification.channel_id = wawat_airplane_v4` (or omit) / correct `data` for sound.

---

## Bug 1 — tap opens nothing / opens the wrong screen

The app routes **strictly** by `data.target_type` (falling back to `data.type`). On tap,
`onMessageOpenedApp` / `getInitialMessage` **skip routing entirely when `data` is empty**, and route to
the generic notifications feed when `target_type` is missing or unknown.

Two failure modes seen today:

- **Empty `data`** (a bare `notification:{title,body}` push) → tap opens the app but navigates nowhere.
- **Wrong vocabulary** → e.g. sending `type: "chat"`. `chat` is not a known `target_type`, so it falls
  through to the default and opens the notifications list instead of the chat.

**Fix:** every push carries a non-empty `data` with a **canonical** `target_type`:

| `target_type` | opens | id to send |
| --- | --- | --- |
| `conversation` | chat thread | `target_id` = conversation id, or flat `conversation_id` |
| `shipment` | deal detail | `target_id` = shipment id |
| `review_compose` | deal detail (review) | `target_id` = shipment id |
| `listing` | listing detail | `target_id` = listing id (optional `saved_search_id`) |
| `review` | my profile → reviews tab | — |
| `profile` | a user's profile | `target_id` = username (omit → my profile) |
| `report` | reports screen | — |
| `verification` | verification screen | — |
| `security` / `account` | support screen | — |
| `announcement` / `app_update` | notifications feed | — |
| `home` | home | — |
| `none` / anything else | notifications feed (fallback) | — |

Secondary ids (`conversation_id`, `saved_search_id`) live **flat** in `data`, not nested under a
`target`/`params` object. If your REST notifications model nests them, **flatten** for push.

> Client-side fix already shipped: a cold-start tap used to be destroyed by the splash screen (it
> replaced the routed screen on its way to Home). The app now defers routing until Home is mounted, so
> the target survives. Warm/foreground taps already worked.

---

## Bug 2 — custom sound is silent or default (Android)

On **Android 8+ a notification's sound belongs to its _channel_ and is immutable** — fixed when the
channel is first created, forever. The trap: if a **notification-type** push arrives while the app is
killed/freshly-installed and the channel doesn't exist yet, `FirebaseMessagingService` **auto-creates
it with the default sound**, which then can never be changed → default/silent forever.

**Client fix already shipped (this is the definitive one):** the app creates the channel **natively in
`Application.onCreate()`** — before the messaging service can handle anything — with the airplane sound
and proper audio attributes. The id is now **`wawat_airplane_v4`**: a channel's sound is immutable, so
any device that ended up with a poisoned `wawat_airplane_v2`/`v3` (default sound baked in by an earlier
build) can only be escaped by a fresh id. Those old ids are deleted on startup.

```
id:    wawat_airplane_v4
sound: android.resource://az.buking.buking/raw/airplane   (airplane.mp3)
importance: high
```

Manifest default (used when a notification push omits `channel_id`):

```xml
<meta-data android:name="com.google.firebase.messaging.default_notification_channel_id"
           android:value="wawat_airplane_v4" />
```

**Backend requirement — the simplest, future-proof option is to OMIT `channel_id` entirely** so the
manifest default (`wawat_airplane_v4`) always wins and the backend never has to track the app's channel
id again:

- **Preferred:** do **not** send `android.notification.channel_id` at all → the app's default channel
  (v4, airplane sound) is used.
- If you must send it, send exactly `"wawat_airplane_v4"` — nothing else.
- **Never** send the old ids: `high_importance_channel`, `wawat_high_importance`, `wawat_alerts`,
  `wawat_airplane_v2`, `wawat_airplane_v3` (posting to a deleted id makes Android resurrect it with the
  **default** sound → the exact bug).
- **Never** force `android.notification.sound: "default"`.
- Always `android.priority: "high"`.

Either message shape works for sound now that the channel is created natively:

- **notification + data** (recommended) — the OS shows the tray notification even when force-killed
  (most reliable delivery); the channel guarantees the airplane sound; `data` drives routing.
- **data-only** — the app renders the notification itself. Full client control, but high-priority
  data-only messages can be throttled/dropped by aggressive OEM battery managers (Xiaomi/Huawei/Oppo/
  Samsung) when the app is force-stopped. If you use it, still send `android.priority:"high"` and put
  `title`/`body` inside `data`.

---

## iOS

iOS has no channels — the sound comes straight from `aps.sound`, which must be a **bundled file name
with a supported extension**. **iOS does not support `.mp3` for notification sounds** (only
`aiff`/`wav`/`caf`), so `airplane.mp3` silently falls back to the default. Ship a Core Audio `.caf`
(≤30 s) and reference it:

- `apns.payload.aps.sound = "airplane.caf"`  (never `"default"`)
- iOS pushes must include an **alert** (`notification` / `aps.alert`) — a data-only push renders
  nothing on iOS (the app's background handler is Android-only).
- Put `target_type`/`target_id` in the **top-level `data` map** (not only inside the alert) so iOS
  routing matches Android.

> App-side follow-up for iOS sound: convert `ios/Runner/airplane.mp3` → `airplane.caf`, add it to the
> Runner target, and set `DarwinNotificationDetails.sound = 'airplane.caf'`. Tracked separately; the
> reported bug is the Android APK.

---

## Behavior by app state

| State | Renders | Sound source | Routing |
| --- | --- | --- | --- |
| **Foreground** (Android/iOS) | client | `wawat_airplane_v4` channel / `aps.sound` | local-notif payload |
| **Background/warm** | OS | channel / `aps.sound` | `onMessageOpenedApp` reads `data` |
| **Killed/cold** | OS | channel / `aps.sound` | `getInitialMessage` → deferred to Home |

---

## Verify on a real device

Android:

```bash
adb shell dumpsys notification --noredact | grep -A25 'az.buking.buking'
#   effectiveNotificationChannel=wawat_airplane_v4
#   mSound=android.resource://az.buking.buking/raw/airplane
```

**Done when:** a background/**killed** push (a) plays airplane.mp3, (b) shows on channel
`wawat_airplane_v4`, and (c) tapping it opens the exact target screen (chat/deal/listing), not the
generic notifications feed. Test from a **fully swiped-away** app — that is the state where both bugs
reproduced. If notifications never arrive at all on a specific phone, first confirm the tester granted
the notification permission (Android 13+) and disabled battery optimization for the app.
