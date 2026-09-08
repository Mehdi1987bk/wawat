# Apple Pay / Google Pay readiness

Audit date: 2026-09-08

Validation environment: Flutter 3.35.6 / Dart 3.9.2.

## Verdict

Apple Pay and Google Pay are **not ready for production** in the mobile app.
The app currently supports a hosted provider checkout in a WebView and the
existing backend contract supports `card` and `balance`. Wallet method tiles
exist only as disabled UI scaffolding.

## Evidence in this repository

| Area | Current state | Ready |
| --- | --- | --- |
| Wallet UI | `kWalletPayEnabled` is `false` in `promotion_screens.dart`; Apple Pay and Google Pay tiles are therefore never displayed. | No |
| Payment API | The documented app/backend contract accepts only `method: card \| balance`; `apple_pay` and `google_pay` would return HTTP 422. | No |
| Flutter integration | `pubspec.yaml` contains no Apple Pay / Google Pay SDK or payment-wallet package. | No |
| Apple capability | `ios/Runner/Runner.entitlements` contains push notifications only; there is no `com.apple.developer.in-app-payments` merchant entitlement. | No |
| Google Pay setup | Android configuration contains no Google Pay API integration or wallet metadata. | No |
| Hosted checkout | `ProviderCheckoutScreen` can display a provider-owned checkout URL and then poll the backend. Wallet buttons will work there only if the selected payment provider enables and certifies them; this repository does not establish that. | Partial |
| Other paid flows | Listing quota always sends `card`; verification is explicitly marked as mock. Wallet payments are not wired into these flows. | No |

## What is required before enabling the UI

1. Choose/configure the payment provider and enable Apple Pay and Google Pay in
   its merchant account, including production-domain verification where the
   provider requires it.
2. Extend the backend `/pay` endpoints to accept wallet methods, create the
   correct provider session/payment intent, verify provider webhooks, and return
   a `checkout_url` or a native client secret/token. Keep final payment status
   server-authoritative and idempotent.
3. Decide on one integration model:
   - hosted checkout: certify that Apple Pay/Google Pay work in the app's
     embedded WebView on real devices; or
   - native wallet sheet: add the provider/Pay Flutter SDK and pass its token to
     the backend for confirmation.
4. For native Apple Pay, create the Apple Merchant ID and payment-processing
   certificate, add the Apple Pay capability and
   `com.apple.developer.in-app-payments` entitlement, and configure supported
   networks/country/currency.
5. For native Google Pay, configure the gateway and merchant IDs, request
   production access, add the Android integration, and switch from TEST to
   PRODUCTION only after approval.
6. Test both success and cancellation plus failed, pending, duplicate-tap,
   webhook-delay, and refund scenarios on physical iPhone and supported Android
   devices. Only then set `kWalletPayEnabled` to `true` (or replace it with a
   backend-controlled capability flag).

## Release gate

Do not enable `kWalletPayEnabled` yet. A passing Flutter build proves only that
the disabled UI and hosted checkout compile; it does not prove merchant
activation, device eligibility, provider configuration, or a real wallet
charge. Production readiness must include successful sandbox/test wallet
charges and backend webhook confirmation for both platforms.

## Repository validation result

- `flutter analyze --no-pub` completed with 146 pre-existing issues; none is in
  this report or a wallet integration (the wallet integration is absent).
- A clean `flutter pub get` is currently blocked by stale dependency pins:
  `collection 1.19.0` conflicts with `flutter_test` (`1.19.1`), `intl 0.19.0`
  conflicts with `flutter_localizations` (`0.20.2`), and the pinned
  `retrofit_generator 9.1.5` depends on the removed Dart `_macros` package.
- Consequently, `flutter test --no-pub` crashes in Flutter's
  `computeTransitiveDependencies` while reading the stale package graph, before
  any application test runs. Dependencies must be migrated as a separate task
  before CI can provide a clean test signal on this Flutter SDK.
- `flutter build apk --debug --no-pub` reaches Gradle but fails in Flutter's
  plugin loader because the stale plugin metadata represents
  `androidPlugin.dev_dependency` as a map instead of the Boolean expected by
  Flutter 3.35.6. No APK was produced.
