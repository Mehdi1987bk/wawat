# Analytics & telemetry reference — Wawat Air

Everything the app measures, where it goes, and how to add more.
Implementation lives in `lib/services/telemetry/`.

> **Audience: the mobile team.** The backend gets its own self-contained brief —
> `docs/backend-observability-PROMPT.md` — which already inlines the event catalogue it needs.
> Hand that one file over; nothing here is required on their side.

---

## 1. Where data goes

| Sink | What | Latency | Console |
|---|---|---|---|
| **Firebase Analytics** | events, screens, user properties | 4–24 h | Firebase → Analytics (GA4) |
| **Firebase Crashlytics** | fatal + non-fatal errors, breadcrumbs, custom keys | ~minutes | Firebase → Crashlytics |
| **Firebase Performance** | app start, screen render, HTTP metrics, custom traces | ~hours | Firebase → Performance |
| **Own backend** | *all of the above*, mirrored | seconds | admin Observability panel |

The backend mirror is the one that matters day to day — it is live, it sits next to server-side
errors, and it is what `docs/backend-observability-PROMPT.md` specifies.

---

## 2. What is automatic (do not re-instrument by hand)

| Source | Produces |
|---|---|
| `TelemetryInterceptor` (Dio) | funnel events from successful API calls, `api_failure`, `api_slow`, HTTP breadcrumbs, `HttpMetric` |
| `BaseState.initState` | `screen_view` for every screen extending `BaseScreen` |
| `TelemetryRouteObserver` | navigation breadcrumbs incl. dialogs & bottom sheets |
| `BaseBloc.run` | non-fatal report for any non-Dio exception reaching a bloc |
| `FlutterError.onError` | `render_error` + Crashlytics |
| `PlatformDispatcher.onError`, `runZonedGuarded`, isolate listener | fatal errors |
| `Telemetry` lifecycle observer | `app_started`, `app_foreground`, `app_background` |
| `CacheManager.userDetails` subscription | `setUserId` + user properties on every login / `/auth/me` |

The endpoint → event table is `lib/services/telemetry/api_event_map.dart`. **Adding a new API call
to that table is the preferred way to add a funnel event** — it cannot drift from reality.

---

## 3. Event catalogue

GA4-recommended names are marked ★ — those light up built-in Firebase reports for free.

### Lifecycle
| Event | Params | Notes |
|---|---|---|
| `app_started` | `source` = `firebase` \| `degraded` | `degraded` = no Play Services |
| `app_foreground` / `app_background` | — | |
| `offline_gate_shown` | — | spike ⇒ API unreachable |
| `back_online` | `source` | |
| `feature_unavailable` | `reason` | `firebase_init_failed`, `push_init_failed` |

### Auth
| Event | Params |
|---|---|
| ★ `login` | `method` = `password` \| `otp` |
| `login_failed` | `method`, `status_code`, `reason` |
| ★ `sign_up` | `method` = `form` \| `otp` |
| `sign_up_failed` | `method`, `status_code` |
| `otp_requested` / `otp_verified` / `otp_failed` | |
| `password_reset_requested` / `password_reset_completed` | |
| `session_expired` | `endpoint` |

### Listings
| Event | Params |
|---|---|
| ★ `view_item` | `item_id`, `item_category`, `from_city`, `to_city`, `listing_type` |
| `listing_created` / `listing_create_failed` | `endpoint`, `duration_ms` |
| `listing_updated` / `listing_paused` / `listing_resumed` / `listing_reposted` / `listing_deleted` | `listing_id` |
| ★ `add_to_wishlist` / ★ `remove_from_wishlist` | `listing_id` |
| `proposal_sent` | `listing_id` |
| `listing_reported` | |
| ★ `share` | `source` |

### Search
| Event | Params |
|---|---|
| ★ `search` | `search_term` (`Bakı → İstanbul`), `from_city`, `to_city`, `filter_count`, `sort`, `source` |
| `trending_route_tapped` | `from_city`, `to_city` |
| `saved_search_created` / `saved_search_deleted` | |

`source` values: `search_form`, `inline_form`, `popular_route`.

### Chat
| Event | Params |
|---|---|
| `chat_opened` | |
| `chat_message_sent` / `chat_message_failed` | `duration_ms`, `status_code` |

### Monetization
| Event | Params |
|---|---|
| ★ `begin_checkout` | `value`, `currency`, `item_category`, `duration_days`, `method` |
| ★ `purchase` | `value`, `currency`, `transaction_id`, `item_category`, `duration_days`, `method`, `result`, `listing_id` |
| `purchase_failed` | `value`, `currency`, `transaction_id`, `method`, `error_type` |
| `promotion_started` | fired by the interceptor when the promotion is created server-side |
| `quota_limit_hit` | |

> `value` + `currency` together are what make Firebase count revenue. Never send one without the other.

### Profile / verification / notifications
`profile_updated` (`source`), `avatar_uploaded`, `verification_submitted`, `review_submitted`,
`support_request_sent`, `push_permission_result` (`result`), `push_received_fg` (`source` = push type),
`push_opened` (`source` = push type).

### Health (these create issues in the panel)
| Event | Params |
|---|---|
| `api_failure` | `endpoint`, `http_method`, `status_code`, `duration_ms`, `error_type`, `error_message`, `is_offline` |
| `api_slow` | `endpoint`, `http_method`, `duration_ms`, `status_code` — fires above 3 s |
| `app_error` | `error_type`, `error_message`, `reason`, `screen` |
| `render_error` | `error_type`, `library` |

`endpoint` is always normalised (`/listings/8123/favorite` → `/listings/{id}/favorite`) so it groups.

---

## 4. User properties

| Property | Values |
|---|---|
| `user_type` | `guest` \| `user` \| `courier` |
| `is_verified` | `true` \| `false` |
| `tier_level` | from `/auth/me` |
| `has_listings` | `true` \| `false` |
| `app_locale` | `az` `en` `ru` `tr` `uk` `es` |
| `theme_mode` | `light` \| `dark` |
| `push_enabled` | `true` \| `false` |

`setUserId` receives the **internal user id only** — never a phone number or e-mail. Firebase
forbids PII there, and it is checked during store review.

---

## 5. Adding a new event

**If it corresponds to an API call** — add a row to `api_event_map.dart`. Done.

**Otherwise:**

```dart
import 'package:buking/services/telemetry/telemetry.dart';
import 'package:buking/services/telemetry/telemetry_events.dart';

Telemetry.instance.event(TelemetryEvents.share, params: {
  TelemetryParams.itemId: listing.id,
  TelemetryParams.source: 'details_screen',
});
```

Rules:
1. **Add the name to `TelemetryEvents`** — never pass a raw string literal, or the name drifts.
2. **Reuse `TelemetryParams` keys.** `listing_id` and `listingId` become two uncorrelatable columns
   in GA4.
3. Names and values are normalised automatically (`TelemetrySchema`) — you do not need to worry
   about Firebase's 40/100-char limits, but you *do* need to keep names under 40 chars to stay
   readable after truncation.
4. **Never put PII in params.** `TelemetryRedactor` strips the obvious cases, but do not rely on it:
   pass ids, not names; counts, not contents.

### Timing something

```dart
final result = await Telemetry.instance.trace('receipt_pdf_render', () async {
  return buildReceiptPdf(receipt);
});
```

### Reporting a handled error explicitly

```dart
try {
  ...
} catch (e, st) {
  Telemetry.instance.error(e, st, reason: 'deal_accept', context: {'deal_id': id});
}
```

Blocs already do this for you via `BaseBloc.run` — only add it where you swallow an exception
yourself.

---

## 6. Consent

`TelemetryConsent` (Profile → Privacy → *Diaqnostika və analitika*) holds two switches:
`analyticsEnabled` and `crashReportsEnabled`. Turning either off calls
`setAnalyticsCollectionEnabled` / `setCrashlyticsCollectionEnabled` /
`setPerformanceCollectionEnabled` **and** stops the backend mirror for that class of record.

Both default to on. This switch is what allows us to declare optional data collection in Play Data
safety and App Store App Privacy — do not remove it.

---

## 7. Verifying it works

**Analytics DebugView** (events appear within seconds instead of 24 h):

```bash
adb shell setprop debug.firebase.analytics.app az.buking.buking
```

iOS: add `-FIRAnalyticsDebugEnabled` to the scheme's launch arguments.
Then watch Firebase → Analytics → DebugView.

**Crashlytics** — force a test crash from a debug build, then relaunch the app (reports upload on
the *next* start, never during the crash itself):

```dart
Telemetry.instance.forceCrashForTesting();
```

**Backend mirror** — it batches; force a flush by backgrounding the app, then check
`telemetry_records` for the session.

**Note:** debug builds send `context.is_debug = true`. Filter them out of the panel.
