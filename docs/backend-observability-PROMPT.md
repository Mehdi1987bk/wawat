# PROMPT FOR THE BACKEND — one panel that shows every app problem

> Self-contained. Everything you need is in this file — no other document is required.

You maintain the backend for the **Wawat Air** mobile app (Flutter; Android package
`az.buking.buking`, iOS bundle `wawat.app`, Firebase project `wawatair-b212f`, API base
`https://api.wawatair.com/api/v1`).

**Task:** build **one Observability panel** in the admin area — a single screen with a single
ranked list that mixes **crashes**, **product events**, **client-side API failures** and **your own
server errors**, and answers "what is broken right now, for how many users, since when".
Today those live in four different places and nobody looks at any of them.

**The mobile side is already done and shipped.** The app collects everything described below,
redacts personal data on the device, batches it, survives being offline, and posts it to the
endpoint in §3. Your job is to (a) accept it, (b) enrich it with Crashlytics + server-side data,
(c) render the panel.

---

## 1. What the panel must look like

**One screen. One ranked list. One row per problem.** Not four tabs, not four widgets.

```
┌───────────────────────────────────────────────────────────────────────────────────┐
│  Health  ● 99.1% crash-free   ● 2.3% API error rate   ● 41 users affected (24h)   │
├───────────────────────────────────────────────────────────────────────────────────┤
│  [All] [Crashes] [API] [Server] [Product]      last 24h ▾    platform: all ▾      │
├────┬──────────────────────────────────────┬────────┬───────┬──────────┬───────────┤
│ ▲  │ Problem                              │ Events │ Users │ Version  │ Last seen │
├────┼──────────────────────────────────────┼────────┼───────┼──────────┼───────────┤
│ 🔴 │ NoSuchMethodError · listing_card.dart│  412   │  87   │ 1.0.48   │ 2 min ago │
│ 🔴 │ 500 POST /listings/{id}/proposals    │  198   │  63   │ all      │ 5 min ago │
│ 🟠 │ chat_message_failed ↑ 340% vs 7d     │  120   │  44   │ 1.0.48   │ 8 min ago │
│ 🟠 │ Slow: GET /listings 4.8s p95         │  2100  │ 310   │ all      │ 1 min ago │
│ 🟡 │ Funnel drop: create_post 62% → 31%   │   —    │ 210   │ 1.0.48   │ 1 h ago   │
└────┴──────────────────────────────────────┴────────┴───────┴──────────┴───────────┘
```

Every row expands into: timeline sparkline, affected app versions / OS / devices, the **last 25
breadcrumbs** before the failure, the stack trace, the affected users (ids, clickable through to
the user admin page), and a link out to Crashlytics for the raw source.

### Ranking — sort by impact, not by recency

```
score = users_affected × severity_weight × recency_factor × regression_factor
```

| factor              | value                                                           |
|---------------------|-----------------------------------------------------------------|
| `severity_weight`   | fatal 10 · error 5 · warning 2 · info 1                          |
| `recency_factor`    | `1 / (1 + hours_since_last_seen / 6)`                            |
| `regression_factor` | ×3 if `first_seen` falls inside the current app version, else ×1 |

A crash hitting 3 users must never outrank a 500 hitting 300 users.

---

## 2. Privacy rules — read before you write any code

The app **redacts on the device before sending**: Bearer tokens, JWTs, e-mail addresses, phone
numbers, passwords, OTP codes, card/IBAN fields and chat message bodies are stripped or replaced
with `***`; path ids are collapsed (`/listings/8123` → `/listings/{id}`). This is exactly what is
declared in the App Store privacy manifest and in the Google Play Data safety form, so it is a
compliance boundary, not a preference.

Therefore:

1. **Never store raw request/response bodies** in telemetry tables. If you add server-side
   enrichment, redact to the same standard.
2. **Retention: 90 days** for raw records; aggregated issues may live indefinitely provided they
   contain no personal data. Add a nightly purge job.
3. **GDPR delete**: when a user is deleted, their `user_id` must be nulled across telemetry
   (`ON DELETE SET NULL` below), and no user id may remain inside `params`.
4. **The panel is staff-only** — gate behind an admin role and audit who opens it.
5. Users can switch diagnostics off in the app (Profile → Privacy). When they do, nothing is sent —
   a silent device is not a bug.

---

## 3. Ingest endpoint — build this first

```
POST /api/v1/telemetry/batch
Authorization: Bearer <token>      # optional — absent for logged-out users
Content-Type: application/json
```

The app posts this exact shape, batched (20 records / 30 s / on app background), with an offline
outbox that survives restarts. **Batches may be replayed** after a failed flush — see idempotency.

```json
{
  "session_id": "m1v0k3n2-1f9x",
  "sent_at": "2026-08-16T09:41:02.113Z",
  "context": {
    "platform": "android",
    "is_debug": false,
    "app_version": "1.0.48",
    "build_number": "29",
    "package_name": "az.buking.buking",
    "device_model": "Samsung SM-A536B",
    "os_version": "Android 14",
    "sdk_int": 34,
    "is_physical": true,
    "user_id": "8412",
    "user_type": "courier",
    "is_verified": "true",
    "tier_level": "gold",
    "app_locale": "az",
    "theme_mode": "dark",
    "push_enabled": "true"
  },
  "records": [
    {
      "type": "event",
      "name": "listing_created",
      "severity": "info",
      "occurred_at": "2026-08-16T09:40:58.004Z",
      "screen": "create_post_screen",
      "params": { "endpoint": "/listings", "duration_ms": 812, "listing_id": "9931" }
    },
    {
      "type": "error",
      "name": "app_error",
      "severity": "error",
      "occurred_at": "2026-08-16T09:41:01.550Z",
      "screen": "listing_details_screen",
      "fingerprint": "3f2a91bc",
      "params": {
        "error_type": "NoSuchMethodError",
        "error_message": "The getter 'price' was called on null",
        "reason": "bloc.run",
        "endpoint": "/listings/{id}",
        "status_code": 200
      },
      "stack": "#0  ListingCard.build (package:buking/…/listing_card.dart)\n#1  …",
      "breadcrumbs": [
        "2026-08-16T09:40:55.100Z nav push ListingDetailsScreen",
        "2026-08-16T09:40:55.900Z http GET /listings/{id} 200 640ms",
        "2026-08-16T09:41:01.400Z screen: listing_details_screen"
      ]
    }
  ]
}
```

### Field contract

| field | notes |
|---|---|
| `type` | `event` · `error` · `screen` · `http`. One stream — filter by this, do not split into separate tables. |
| `severity` | `info` · `warning` · `error` · `fatal`. Drives `severity_weight`. The app already assigns it correctly (5xx → `error`, network/4xx → `warning`). |
| `fingerprint` | **8-char hex computed on the device** from error type + top 3 non-framework stack frames. Group by it — that is what turns 412 rows into one problem. Present only on `type=error`. |
| `occurred_at` | Device clock, UTC. **May be skewed or old** (offline outbox). Store it, but also store `received_at` and use `received_at` for "last seen". |
| `params` | Free-form, already redacted. Store as JSONB. |
| `breadcrumbs` | Last ≤25 user actions before the error. Errors only. This is what makes a bug reproducible. |
| `context.user_id` | Internal id. Join to `users`. `null` for guests. |
| `context.is_debug` | `true` on developer builds — **filter these out of the panel by default** or the numbers are nonsense. |

### Required behaviour

1. **Respond fast, process async.** Return `202 Accepted` immediately and push to a queue. The app
   uses a 20 s receive timeout; never block it on writes.
2. **Idempotency.** Deduplicate on `(session_id, occurred_at, name, fingerprint)`. A batch the app
   could not confirm is retried, so the same record can legitimately arrive twice.
3. **Status codes matter — the client reacts to them:**
   - `2xx` → drops the batch from its outbox;
   - `404` / `405` / `501` → **permanently disables telemetry for that app session** (intended
     before you deploy — do not return these once you are live);
   - `401` / `403` → drops the batch silently;
   - anything else / timeout → keeps it and retries with backoff.
4. **Rate limit per device**, e.g. 60 batches / 5 min, excess → `429` (the app backs off).
5. **Accept unauthenticated batches.** Crashes during login/registration are the ones you most need,
   and there is no token yet at that point.
6. **Cap the payload** at ~1 MB, reject larger with `413`.

### Schema

```sql
CREATE TABLE telemetry_records (
  id             BIGSERIAL PRIMARY KEY,
  session_id     TEXT        NOT NULL,
  user_id        BIGINT      NULL REFERENCES users(id) ON DELETE SET NULL,
  type           TEXT        NOT NULL,
  name           TEXT        NOT NULL,
  severity       TEXT        NOT NULL,
  fingerprint    CHAR(8)     NULL,
  screen         TEXT        NULL,
  platform       TEXT        NOT NULL,
  app_version    TEXT        NOT NULL,
  build_number   TEXT        NULL,
  os_version     TEXT        NULL,
  device_model   TEXT        NULL,
  is_debug       BOOLEAN     NOT NULL DEFAULT false,
  params         JSONB       NOT NULL DEFAULT '{}',
  stack          TEXT        NULL,
  breadcrumbs    JSONB       NULL,
  occurred_at    TIMESTAMPTZ NOT NULL,
  received_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX ON telemetry_records (received_at DESC);
CREATE INDEX ON telemetry_records (fingerprint, received_at DESC);
CREATE INDEX ON telemetry_records (name, received_at DESC);
CREATE INDEX ON telemetry_records (user_id, received_at DESC);
CREATE UNIQUE INDEX telemetry_dedup
  ON telemetry_records (session_id, occurred_at, name, COALESCE(fingerprint, ''));

-- One row per distinct problem — this is what the panel actually reads.
CREATE TABLE telemetry_issues (
  id                 BIGSERIAL PRIMARY KEY,
  source             TEXT NOT NULL,        -- app | crashlytics | api | server | analytics
  fingerprint        TEXT NOT NULL,
  title              TEXT NOT NULL,
  severity           TEXT NOT NULL,
  status             TEXT NOT NULL DEFAULT 'open',  -- open|acknowledged|resolved|ignored
  first_seen         TIMESTAMPTZ NOT NULL,
  last_seen          TIMESTAMPTZ NOT NULL,
  first_seen_version TEXT,
  events_count       BIGINT NOT NULL DEFAULT 0,
  users_count        BIGINT NOT NULL DEFAULT 0,
  score              DOUBLE PRECISION NOT NULL DEFAULT 0,
  assignee_id        BIGINT NULL,
  external_url       TEXT NULL,            -- deep link into Crashlytics
  UNIQUE (source, fingerprint)
);
```

Roll `telemetry_records` up into `telemetry_issues` on a 1-minute job: counts, `users_count` as
`COUNT(DISTINCT user_id)`, recomputed `score`.

---

## 4. What the app sends — full catalogue

Events marked ★ are GA4-recommended names.

### Lifecycle
`app_started` (`source` = `firebase` \| `degraded`) · `app_foreground` · `app_background` ·
`offline_gate_shown` · `back_online` · `feature_unavailable` (`reason` = `firebase_init_failed` \|
`push_init_failed`)

### Auth
★`login` (`method` = `password`\|`otp`) · `login_failed` · ★`sign_up` (`method` = `form`\|`otp`) ·
`sign_up_failed` · `otp_requested` · `otp_verified` · `otp_failed` · `logout` ·
`password_reset_requested` · `password_reset_completed` · `session_expired` ·
`email_verification_resent`

### Listings
★`view_item` (`item_id`, `item_category`, `from_city`, `to_city`, `listing_type`) ·
`listing_created` · `listing_create_failed` · `listing_updated` · `listing_paused` ·
`listing_resumed` · `listing_reposted` · `listing_deleted` · ★`add_to_wishlist` ·
★`remove_from_wishlist` · `proposal_sent` · `listing_reported` · `offer_created` · ★`share`

### Search
★`search` (`search_term` = `"Bakı → İstanbul"`, `from_city`, `to_city`, `filter_count`, `sort`,
`source` = `search_form`\|`inline_form`\|`popular_route`) · `trending_route_tapped` ·
`saved_search_created` · `saved_search_deleted`

### Chat
`chat_opened` · `chat_message_sent` · `chat_message_failed`

### Deals
`deal_action` · `deal_action_failed`

### Monetization
★`begin_checkout` (`value`, `currency`, `item_category`, `duration_days`, `method`) ·
★`purchase` (`value`, `currency`, `transaction_id`, `item_category`, `duration_days`, `method`,
`result`, `listing_id`) · `purchase_failed` · `promotion_started` · `quota_order_created` ·
`quota_order_failed` · `quota_order_paid` · `quota_limit_hit`

### Profile / notifications
`profile_updated` (`source` = `personal`\|`privacy`\|`notifications`\|`professional`\|`password`) ·
`avatar_uploaded` · `verification_submitted` · `review_submitted` · `support_request_sent` ·
`push_permission_result` (`result`) · `push_received_fg` (`source` = push type) ·
`push_opened` (`source` = push type)

### Health — these become issues
| Event | Params |
|---|---|
| `api_failure` | `endpoint`, `http_method`, `status_code`, `duration_ms`, `error_type`, `error_message`, `is_offline` |
| `api_slow` | `endpoint`, `http_method`, `duration_ms`, `status_code` — fires above 3 s |
| `app_error` | `error_type`, `error_message`, `reason`, `screen` — a handled exception |
| `uncaught_error` | same — an unhandled async error, sent immediately |
| `fatal_error` | same — a genuine crash |
| `render_error` | `error_type`, `library` — thrown from the widget tree |

`endpoint` always arrives normalised (`/listings/8123/favorite` → `/listings/{id}/favorite`), so it
groups without any work on your side.

### Issue-creation rules

| Signal | Rule |
|---|---|
| `fatal_error`, `uncaught_error`, `app_error`, `render_error` | group by `fingerprint` |
| `api_failure` | group by `params.endpoint` + `params.status_code`; open at `error` for 5xx, or when the endpoint's error rate exceeds 5 % over 15 min |
| `api_slow` | group by `params.endpoint`; open at `warning` when p95 > 3 s over 15 min |
| `offline_gate_shown` spike | your API is down or unreachable from a region — open at `warning` at 3× the 7-day baseline |
| `session_expired` spike | token/refresh bug — open at `error` at 3× baseline |
| `feature_unavailable` | `params.reason` says what failed |

### Funnels to chart

| Funnel | Steps |
|---|---|
| Registration | `otp_requested` → `otp_verified` → `sign_up` |
| Login | `login` vs `login_failed` |
| Create listing | `screen_view(create_post_screen)` → `listing_created` |
| Contact | `view_item` → `chat_opened` → `chat_message_sent` |
| Proposal | `view_item` → `proposal_sent` |
| Monetization | `quota_limit_hit` → `begin_checkout` → `purchase` |
| Verification | `verification_submitted` → `verification_result` |

Open a `warning` issue when a funnel's conversion drops more than 25 % relative to its trailing
7-day median.

---

## 5. Pull Crashlytics in — `source = 'crashlytics'`

Crashlytics has **no public REST read API**. Use one of:

- **Preferred — BigQuery export.** Firebase console → Crashlytics → *Integrations* → BigQuery,
  enable daily export (+ streaming for live data). Query
  `firebase_crashlytics.<package>_ANDROID_REALTIME` / `_IOS_REALTIME` and upsert into
  `telemetry_issues` using `issue_id` as `fingerprint` with `source='crashlytics'`.
  Useful columns: `issue_id`, `issue_title`, `issue_subtitle`, `event_timestamp`,
  `application.display_version`, `device.model`, `operating_system.display_version`, `user.id`,
  `is_fatal`, `blame_frame`.
- **Fallback — Crashlytics alert webhooks** parsed into issues. Cheaper, much coarser.

Also enable Firebase → Project settings → Integrations → **Slack/webhook alerts** for *new fatal
issue*, *regression* and *velocity alert*.

Deep link per issue (store in `telemetry_issues.external_url`):
`https://console.firebase.google.com/project/wawatair-b212f/crashlytics/app/<platform>:<bundle>/issues/<issue_id>`

### Google Analytics (GA4)

**You probably do not need it.** The app mirrors every analytics event to `/telemetry/batch`, so you
can compute all funnels above straight from `telemetry_records` (`type='event'`) — same numbers, no
4–24 h GA4 lag, no extra integration. **Recommended: do that.** Keep GA4 as the historical /
marketing console. If you do want it, use the GA4 Data API
(`analyticsdata.googleapis.com/v1beta/properties/<id>:runReport`) with a service account, and pull
`crash_free_users` for the header strip.

---

## 6. Your own server errors — `source = 'server'`

Feed your existing exception handler (Sentry / Laravel log / whatever) into the same
`telemetry_issues` table. The whole value of this panel is putting a client-side
`api_failure 500 POST /listings/{id}/proposals` **next to** the server-side stack trace that caused
it. Correlate on endpoint + time window, or — better — return an `X-Request-Id` header and ask the
mobile team to echo it back in `params`.

---

## 7. Alerts

Push to the team Slack/Telegram channel, **deduplicated per issue** — one message per issue, edited
on change, never re-posted per occurrence.

| Condition | Priority |
|---|---|
| New `fatal` issue in the current app version | 🔴 immediate |
| Any issue crossing 50 affected users in 1 h | 🔴 immediate |
| Endpoint error rate > 5 % for 15 min | 🔴 immediate |
| Crash-free users below 99 % | 🟠 hourly digest |
| Funnel conversion −25 % vs 7-day median | 🟠 hourly digest |
| New non-fatal issue | 🟡 daily digest |

---

## 8. Admin API for the panel frontend

```
GET  /api/v1/admin/observability/summary?range=24h
     → { crash_free_users, api_error_rate, users_affected, total_issues, by_source: {...} }

GET  /api/v1/admin/observability/issues
       ?range=24h&source=all&severity=&platform=&app_version=&status=open
       &sort=score&page=1&per_page=50
     → { data: [ { id, source, title, severity, status, events_count, users_count,
                   first_seen, last_seen, first_seen_version, score, external_url } ], meta }

GET  /api/v1/admin/observability/issues/{id}
     → issue + timeline[] + versions[] + devices[] + sample_records[10]
       (each with stack + breadcrumbs) + affected_users[]

PATCH /api/v1/admin/observability/issues/{id}
     { status: open|acknowledged|resolved|ignored, assignee_id }

GET  /api/v1/admin/observability/funnels?range=7d
     → per-funnel step counts + conversion + delta vs previous period
```

---

## 9. Acceptance criteria

- [ ] `POST /api/v1/telemetry/batch` returns `202` in < 200 ms p95 and is idempotent on replay.
- [ ] A crash forced on a test device appears in the panel within 2 minutes, with its stack trace
      and the breadcrumbs that preceded it.
- [ ] 412 occurrences of the same crash render as **one** row with `events_count = 412`.
- [ ] Forcing an endpoint to 500 raises an `api_failure` issue within 5 minutes, and the row shows
      both the client-side failure and the matching server-side exception.
- [ ] The list is sorted by impact — a 300-user issue outranks a 3-user issue regardless of age.
- [ ] Crashlytics issues and server errors appear in the **same** list as app events, filterable by
      `source`, never in separate tabs.
- [ ] `is_debug = true` records are excluded from the panel by default.
- [ ] No e-mail, phone number, token or message body is findable anywhere in `telemetry_records` —
      run `SELECT` for `@`, `+994` and `Bearer` and prove it.
- [ ] Records older than 90 days are purged nightly.
- [ ] Deleting a user nulls their `user_id` across the table.

---

## 10. Gotchas

- **Clock skew is real.** Devices with a wrong clock post `occurred_at` years off. Clamp to
  `[received_at - 7d, received_at + 1h]` when charting.
- **Arrival order ≠ event order.** The offline outbox flushes old records first: bucket charts on
  `occurred_at`, compute "last seen" from `received_at`.
- **`fingerprint` is stable across app versions** (it excludes line numbers), so a bug that
  reappears after a "fix" reopens the same issue instead of creating a new one. Keep that property —
  do **not** add version to the grouping key; use `first_seen_version` for regression detection.
- **The panel reads `telemetry_issues`, never `telemetry_records`.** If it ever queries raw records
  directly it will fall over the first time a crash loop ships.
- **Do not "fix" missing data from a device that went quiet.** It may simply be a user who turned
  diagnostics off, or a device with no Google Play Services (the app then sends only to you, with
  `context.source = degraded` on `app_started`).
