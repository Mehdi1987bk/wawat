# Backend contract — Store review reward (Tətbiqi qiymətləndir)

This is the API the mobile "Tətbiqi qiymətləndir" page (v2, Store-first) expects.

## What the page does (so the API matches)

1. The page is **informational + one button**. There is **no in-app star rating**.
2. User taps **"Store-da qiymətləndir"** → the app opens the **native Store review sheet**
   (iOS `SKStoreReviewController` / Android In-App Review). The store never tells the app the
   star value, so the app only reports that the review flow ran.
3. The app then calls `POST /me/app-review-prompt/rated`. **The backend decides the reward.**
   On the user's **first** completed review it credits **one** promo code and returns it.
4. The returned code is shown inline on the same page **with its validity window** (days left +
   expiry date). A 5-second "təşəkkür" toast is shown. There is no separate thank-you page.

Key rule: **reward is granted at most once per user** (idempotent on `prompt_token`). Re-taps,
re-opens, or a second device must NOT mint a new code.

Base path: `/api/v1`. All endpoints require the auth bearer token. `Accept-Language` is sent by the
app and drives the localized `*_label` / `content` texts.

---

## 1. `GET /me/app-review-prompt`

Returns the prompt state + the reward the user currently holds (if any). The **app** decides nothing
about timing — `should_show` is 100% backend-driven (used by the auto-popup on app start; the
standalone page ignores it and always renders).

```json
{
  "data": {
    "should_show": true,
    "already_rated": false,
    "prompt_id": "prm_01HZY...",
    "prompt_token": "eyJhbGciOi...",       // opaque; echo it back on shown/dismissed/rated
    "reward": {
      "amount": 5,
      "currency": "AZN",                    // "AZN" → app renders "₼"
      "code": null,                          // null until granted; the active code once granted
      "expires_at": "2026-08-09T23:59:59Z",  // null when no code / no expiry
      "min_order_amount": null
    },
    "store_url": {
      "ios": "https://apps.apple.com/app/id000000000?action=write-review",
      "android": "market://details?id=com.wawatair.app"
    },
    "content": {
      "title": "Wawatair-i bəyənirsən?",
      "subtitle": "1 dəqiqəni ayır, Store-da bizi qiymətləndir — və hədiyyə promokod qazan.",
      "cta": "Store-da qiymətləndir"
    }
  }
}
```

Field notes:

| Field | Type | Meaning |
| --- | --- | --- |
| `should_show` | bool | Whether the auto-popup is due now (frequency/cool-down is your call). |
| `already_rated` | bool | User already completed a review before. Drives the page's "artıq qiymətləndirmisən" state. |
| `prompt_token` | string | Opaque idempotency token. The app echoes it on every follow-up call. |
| `reward.code` | string \| null | The user's **active** review code. `null` if never granted OR already spent/expired. |
| `reward.expires_at` | ISO-8601 \| null | Used-by deadline for the code. Shown as "N gün qalıb · son tarix …". |
| `reward.min_order_amount` | number \| null | Optional minimum order for the code (informational). |
| `store_url.*` | string | Deep link to write a review, per platform. Fallback if native sheet is unavailable. |
| `content.*` | map | Optional CMS overrides for the page/dialog copy. App has AZ fallbacks for every key. |

**Missing endpoint is safe:** if this returns `404`/`204`/`501` the app hides the prompt and the
page runs in native-only mode (no fake reward is ever shown).

### `already_rated` × `reward.code` matrix (drives the page state)

| `already_rated` | `reward.code` | Page shows |
| --- | --- | --- |
| `false` | `null` | **Intro** — button + "5 ₼ hədiyyə" (state 1). |
| `true` | non-null, not expired | **Rated + coupon** — code + validity inline (state 2). |
| `true` | `null` (spent/expired) | **Thanks-only ("13b")** — green check, no coupon (state 6). |

---

## 2. `POST /me/app-review-prompt/shown` and `.../dismissed`

Fire-and-forget telemetry. Body echoes the token; response body is ignored by the app.

```
POST /me/app-review-prompt/shown       { "prompt_token": "eyJ..." }
POST /me/app-review-prompt/dismissed   { "prompt_token": "eyJ..." }
```

Return `200`/`204`. Failures are swallowed client-side and never block the UI.

---

## 3. `POST /me/app-review-prompt/rated`  ← the important one

Called after the native review sheet closes. **This is where the reward is minted (once).**

Request:

```json
{ "prompt_token": "eyJhbGciOi...", "rating": null }
```

- `prompt_token` — from the prompt payload. Use it as the **idempotency key** for granting.
- `rating` — usually `null` (the store never exposes the chosen stars). Treat as optional/advisory.

### Response — first completed review (grant a code)

```json
{
  "data": {
    "granted": true,
    "code": "WAWA5",
    "amount": 5,
    "currency": "AZN",
    "expires_at": "2026-08-09T23:59:59Z",
    "min_order_amount": null
  }
}
```

The app reads `data.code` (+ `amount`, `expires_at`, `min_order_amount`) and renders the coupon
inline with the validity window. It also appears in `GET /me/promo-codes?status=active`
(`source: "rate_review"`) so "Promokodlarım" stays consistent.

### Response — already rated / no new grant

Return the same envelope with **no usable `code`** (either of these is fine):

```json
{ "data": { "granted": false } }
```

or, if the earlier code is still valid and you want to re-surface it:

```json
{ "data": { "granted": false, "code": "WAWA5", "expires_at": "2026-08-09T23:59:59Z", "amount": 5, "currency": "AZN" } }
```

The app treats **missing `code`** as "no coupon" → shows the thanks-only ("13b") state. A non-empty
`code` → shows the coupon. **Never mint a second code** for the same user.

### Granting rules (backend)

- Grant **at most one** review code per user, ever. Idempotent on `prompt_token` — repeated POSTs with
  the same token return the same result, never a new code.
- Set a validity window on the code (`expires_at`). The app surfaces "N gün qalıb". Recommended: 14 days.
- Code `source` must be `rate_review` so it groups correctly under Promokodlarım.
- The code is a normal promo code — usable on the same surfaces as other promo codes
  (VİP / önə çəkmə boost). `min_order_amount` optional.
- Errors: on `4xx/5xx` the app shows the thanks-only state (it still marks the review as done locally).
  It never retries automatically, so make the grant idempotent rather than relying on retries.

---

## 4. Promo code surfacing — `GET /me/promo-codes`

Already defined for the Promokodlarım screen; listed here for completeness. The review code must
appear here once granted:

```
GET /me/promo-codes?status=active|used|expired
```

```json
{
  "data": [
    {
      "id": "pc_01HZ...",
      "code": "WAWA5",
      "amount": 5,
      "currency": "AZN",
      "status": "active",
      "source": "rate_review",
      "source_label": "Rəy hədiyyəsi",
      "min_order_amount": null,
      "expires_at": "2026-08-09T23:59:59Z",
      "used_at": null,
      "used_context": null
    }
  ],
  "meta": { "active_count": 1 }
}
```

`meta.active_count` powers the badge on the profile-menu "Promokodlarım" row.

---

## 5. Content keys (optional CMS overrides)

The app ships AZ fallbacks for all of these; provide them via `content` (in the prompt payload) or the
`content` group only if you want to override without an app release. Placeholders stay verbatim.

| Key | Fallback (AZ) |
| --- | --- |
| `rate.title` | `Wawatair-i bəyənirsən?` |
| `rate.subtitle` | `1 dəqiqəni ayır, Store-da bizi qiymətləndir — və hədiyyə promokod qazan.` |
| `rate.reward_pill` | `{amount} promokod hədiyyə` |
| `rate.cta` | `Store-da qiymətləndir` |
| `rate.cta_hint` | `Bir dəqiqədən az çəkir` |
| `rate.step_1` | `Düyməyə bas — Store-un qiymətləndirmə pəncərəsi açılır` |
| `rate.step_2` | `{amount} promokod avtomatik hesabına gəlir` |
| `rate.step_3` | `Elanı VİP/önə çəkərkən tətbiq et` |
| `rate.rated_title` | `Hədiyyə promokodun hazırdır 🎁` |
| `rate.rated_subtitle` | `Rəyin üçün təşəkkür! Bu promokodu VİP/önə çəkərkən tətbiq et:` |
| `rate.coupon_label` | `PROMOKODUN` |
| `rate.coupon_valid` | `{days} gün qalıb · son tarix {date}` |
| `rate.coupon_footer` | `{amount} endirim · VİP/önə çəkmə` |
| `rate.view_codes` | `Promokodlarıma bax` |
| `rate.toast_title` | `Təşəkkür edirik! ⭐️` |
| `rate.toast_body` | `Rəyin bizə çox kömək edir.` |
| `rate.already_title` | `Təşəkkür edirik! ⭐️` |
| `rate.already_body` | `Bu tətbiqi artıq qiymətləndirmisən. Dəstəyin bizə çox kömək edir.` |

---

## 6. Summary of what to build

- [ ] `GET /me/app-review-prompt` returns `already_rated` + `reward{amount,currency,code,expires_at,min_order_amount}` + `prompt_token`.
- [ ] `POST /me/app-review-prompt/rated` mints **one** `rate_review` code on first review, idempotent on `prompt_token`, returns `data{granted,code,amount,currency,expires_at,min_order_amount}`.
- [ ] Re-taps / already-rated → return without a new `code` (`granted:false`), never a second code.
- [ ] Set `expires_at` on the code (≈14 days) so the app can show the validity window.
- [ ] Code shows up in `GET /me/promo-codes` with `source: "rate_review"` and counts toward `meta.active_count`.
- [ ] `shown` / `dismissed` telemetry endpoints accept `{prompt_token}` and return 200/204.
