# Store compliance checklist — Wawat Air

What changed when analytics/crash reporting was added, what you must fill in **by hand** in the two
consoles, and what will get the build rejected if you skip it.

Android package `az.buking.buking` · iOS bundle `wawat.app` · Firebase `wawatair-b212f`

---

## A. Already done in the repo

| # | Item | Where |
|---|---|---|
| 1 | App-level privacy manifest (`NSPrivacyTracking=false`, collected data types, 4 required-reason APIs) | `ios/Runner/PrivacyInfo.xcprivacy`, registered in `Runner.xcodeproj` → *Copy Bundle Resources* |
| 2 | Crashlytics dSYM upload build phase (guarded so it cannot break a build before `pod install`) | `ios/Runner.xcodeproj/project.pbxproj` → *Upload Crashlytics dSYMs* |
| 3 | Advertising ID permissions removed at manifest-merge time (`AD_ID` **and** `ACCESS_ADSERVICES_AD_ID`) | `android/app/src/main/AndroidManifest.xml` |
| 4 | Ad-ID / SSAID / ad-personalisation collection disabled in Analytics | same file, `google_analytics_*` meta-data |
| 5 | User-facing opt-out for analytics and crash reports | Profile → Privacy → *Diaqnostika və analitika* |
| 6 | On-device PII redaction before anything leaves the phone | `lib/services/telemetry/telemetry_redactor.dart` |
| 7 | Verbose HTTP logging (bodies, tokens) restricted to debug builds | `lib/main.dart` — was leaking into `logcat`/`os_log` in release |
| 8 | `setUserId` receives the internal id only, never phone/e-mail | `lib/main.dart` `_bindUserIdentity()` |
| 9 | Crashlytics + Performance Gradle plugins actually applied (were declared but never applied — Crashlytics collected nothing) | `android/app/build.gradle` |
| 10 | Kotlin Gradle plugin 1.9.24 → 2.1.0 (required by `play-services-measurement`) | `android/settings.gradle` |

---

## B. You must do this by hand — Apple

### B1. App Privacy answers (App Store Connect → App Privacy)

**They must match `PrivacyInfo.xcprivacy` exactly.** A mismatch is a common reason for removal
after the app is already live.

Declare **collected, linked to the user, NOT used for tracking**:

- Contact Info → Name, Email Address, Phone Number → *App Functionality*
- User Content → Photos or Videos, Other User Content → *App Functionality*
- Identifiers → User ID, Device ID → *App Functionality*, *Analytics*
- Usage Data → Product Interaction → *Analytics*, *App Functionality*
- Diagnostics → Crash Data, Performance Data, Other Diagnostic Data → *App Functionality*
- Location → Coarse Location → *App Functionality*
- Purchases → Purchase History → *App Functionality*

Answer **No** to "Do you use data for tracking?" — there is no ad identifier and no data sharing
with data brokers, so **no ATT prompt is needed**. Do not add `NSUserTrackingUsageDescription`:
adding it without an actual `requestTrackingAuthorization` call is itself a rejection reason.

### B2. Before uploading a build

- [ ] `pod install` in `ios/` after `flutter pub get` (pulls `FirebaseCrashlytics`,
      `FirebaseAnalytics`, `FirebasePerformance`).
- [ ] Archive with **Debug Information Format = DWARF with dSYM File** for Release
      (Flutter's default; verify if the scheme was customised) — without dSYMs Crashlytics shows
      raw addresses.
- [ ] Confirm the *Upload Crashlytics dSYMs* phase ran (build log) — if it printed
      `FirebaseCrashlytics pod not found`, `pod install` was skipped.
- [ ] `ITSAppUsesNonExemptEncryption = false` is already in `Info.plist`. Still true — HTTPS only.
- [ ] Bump `CFBundleShortVersionString` / `version:` in `pubspec.yaml` together.
      ⚠️ **They currently disagree**: `pubspec.yaml` says `1.0.48+29`, `ios/Runner/Info.plist`
      hardcodes `1.0.49`. Flutter overwrites it at build time, but fix the plist so the repo does
      not lie.

### B3. Known review snags for this app

- `NSLocationAlwaysAndWhenInUseUsageDescription` is declared but the app only needs location while
  in use. Reviewers ask why. Either remove the *Always* key or justify it in review notes.
- The purpose strings mention "scanning QR codes in stores to receive discounts" and "nearby
  stores" — leftovers from another app. **Rewrite them to describe Wawat Air** (parcel delivery
  between cities). Mismatched purpose strings are a standard Guideline 5.1.1 rejection.
- `NSAppTransportSecurity` has an insecure-HTTP exception for the bare IP `62.84.176.158`.
  Remove it if it is no longer used; ATS exceptions get questioned.

---

## C. You must do this by hand — Google

### C1. Data safety form (Play Console → App content → Data safety)

Declare **collected + shared-with-nobody**, encrypted in transit, deletable on request:

| Category | Types | Purpose | Optional? |
|---|---|---|---|
| Personal info | Name, Email address, Phone number, User IDs | Account management, App functionality | required |
| Photos and videos | Photos | App functionality | required |
| Messages | Other in-app messages | App functionality | required |
| Location | Approximate location | App functionality | required |
| App activity | App interactions, Other user-generated content | Analytics, App functionality | **optional** ✅ |
| App info and performance | Crash logs, Diagnostics, Other performance data | Analytics, App functionality | **optional** ✅ |
| Financial info | Purchase history | App functionality | required |

- Mark the last two **optional** — that is exactly what the in-app switch buys you.
- Answer **No** to "Does your app collect or share the Advertising ID?" — the permission is removed
  at merge time (verified in `build/app/intermediates/merged_manifest/.../AndroidManifest.xml`).
- "Is all user data encrypted in transit?" → **Yes** (HTTPS only; ATS/cleartext not enabled).
- "Do you provide a way for users to request data deletion?" → point at the in-app account deletion
  flow and the support form.

### C2. Other Play requirements

- [ ] Target API 35 ✅ (already set).
- [ ] Privacy policy URL must be reachable and must mention Firebase
      Analytics/Crashlytics/Performance by name, what is collected, and the opt-out.
      **This is the single most-missed item.**
- [ ] Upload the native debug symbols with the AAB (`debugSymbolLevel 'FULL'` ✅) so Play Console
      can symbolicate ANRs.
- [ ] `POST_NOTIFICATIONS` is declared ✅ and requested at runtime ✅.

---

## D. Privacy-policy text you still need

Whoever maintains the policy page must add, in every supported language:

> The app uses Google Firebase (Analytics, Crashlytics, Performance Monitoring) to detect faults
> and understand which features are used. It collects: an internal user identifier, device model,
> OS version, app version, app-interaction events, and crash diagnostics. It does **not** collect
> the advertising identifier, does not use data for advertising, and does not sell or share data
> with third parties for their own purposes. Diagnostics can be turned off at any time in
> **Profile → Privacy → Diagnostics and analytics**. Diagnostic records are kept for 90 days.

Add the Firebase data-processing links: <https://firebase.google.com/support/privacy>.

---

## E. Verification before release

```bash
# Android — no advertising-ID permission survives the merge
flutter build apk --release
grep -c "AD_ID" build/app/intermediates/merged_manifest/release/*/AndroidManifest.xml   # → 0
```

```bash
# iOS — privacy manifest ships inside the app bundle
flutter build ios --release --no-codesign
ls build/ios/Release-iphoneos/Runner.app/PrivacyInfo.xcprivacy
```

- [ ] Force a test crash on a real device, relaunch, confirm it appears in Crashlytics within
      ~5 minutes with a readable Dart stack trace.
- [ ] Turn both switches off in Profile → Privacy, use the app, confirm **nothing** reaches
      `telemetry_records` or DebugView.
- [ ] `SELECT` the backend telemetry table for `@`, `+994` and `Bearer` — must return nothing.
