# Backend checklist: Google Play IAP verification

## Problem confirmed

Google Play completes the test purchase, but the Wawatair API rejects the
real `purchase_token`. Publishing the Android application to production will
not fix this. Internal testing uses the same Google Play Developer API receipt
verification as production.

The backend currently selects the verifier with `IapSettings::google_live`:

- `google_live = false`: `SandboxVerifier` accepts only artificial tokens in
  the form `sandbox|<product_id>|<transaction_id>` and rejects every real Play
  token with HTTP 422.
- `google_live = true`: `GoogleReceiptVerifier` verifies the token using the
  Google Play Android Developer API.

The mobile app deliberately leaves a purchase unconsumed when server
verification fails. After the backend is fixed, tapping **Retry** sends the
same already-paid token to the server again. It must not open a second Google
Play payment dialog or charge the customer twice.

## 1. Google Play Console

Use this service account:

```text
firebase-adminsdk-fbsvc@wawatair-b212f.iam.gserviceaccount.com
```

Google Cloud project:

```text
wawatair-b212f
```

In Google Play Console, grant this service account access to Wawat Air and at
least these permissions:

- View app information
- View financial data, orders, and cancellation survey responses

Confirm that **Google Play Android Developer API** is enabled in the linked
Google Cloud project. Permission changes can take several minutes to become
effective.

## 2. Secret file on production

The JSON file already generated for this account is named:

```text
wawatair-b212f-firebase-adminsdk-fbsvc-571aa6d1f1.json
```

Upload it outside the repository, for example:

```text
/var/www/api.wawatair.com/storage/app/google-play/service-account.json
```

Recommended permissions:

```bash
sudo chown wawatair:wawatair /var/www/api.wawatair.com/storage/app/google-play/service-account.json
sudo chmod 600 /var/www/api.wawatair.com/storage/app/google-play/service-account.json
```

Never commit this JSON file and never paste its `private_key` into logs or
ordinary chat messages.

## 3. Production `.env`

Set the exact Android application id and absolute credentials path:

```dotenv
GOOGLE_PLAY_PACKAGE_NAME=az.buking.buking
GOOGLE_PLAY_SERVICE_ACCOUNT=/var/www/api.wawatair.com/storage/app/google-play/service-account.json
```

Then rebuild Laravel configuration cache:

```bash
cd /var/www/api.wawatair.com
/usr/bin/php8.4 artisan optimize:clear
/usr/bin/php8.4 artisan optimize
```

## 4. Enable the real Google verifier

In `/adminv2/settings`, open the **Iap** group and save:

```text
enabled: true
google_live: true
android_package_id: az.buking.buking
```

Alternatively, run on the server:

```bash
cd /var/www/api.wawatair.com
/usr/bin/php8.4 artisan tinker --execute='$s = app(\App\Settings\IapSettings::class); $s->enabled = true; $s->google_live = true; $s->android_package_id = "az.buking.buking"; $s->save();'
```

Verify without printing secrets:

```bash
/usr/bin/php8.4 artisan tinker --execute='$s = app(\App\Settings\IapSettings::class); dump(["enabled" => $s->enabled, "google_live" => $s->google_live, "android_package_id" => $s->android_package_id, "package_env" => config("services.google_play.package_name"), "credentials_exist" => is_file(config("services.google_play.service_account"))]);'
```

Expected result:

```text
enabled = true
google_live = true
android_package_id = az.buking.buking
package_env = az.buking.buking
credentials_exist = true
```

## 5. Synchronize product ids

As confirmed by the backend on 2026-09-13, the production VIP catalogue is
`1/3/5` days at `$0.99/$1.99/$2.99`. Google Play, App Store, mobile and backend
must use these exact products:

| Duration | Product ID |
| --- | --- |
| 1 day | `wawat.app.vip.1d` |
| 3 days | `wawat.app.vip.3d` |
| 5 days | `wawat.app.vip.5d` |

Boost products:

| Package | Product ID |
| --- | --- |
| Small | `wawat.app.boost.small` |
| Medium | `wawat.app.boost.medium` |
| Large | `wawat.app.boost.large` |

Update the production promotion settings so `/promotions/pricing`,
`/purchases/catalog`, order creation, `ProductCatalog::productIdFor()` and the
Google Play product ids all agree. Do not map a paid store product to another
duration or package on the server.

## 6. Retry and verify the existing purchase

Do not ask the tester to buy the item again. Keep the existing Google Play
purchase unconsumed and tap **Retry** in mobile version `1.0.53 (54)` after the
server changes above.

Monitor the backend while retrying:

```bash
cd /var/www/api.wawatair.com
tail -f storage/logs/laravel.log | grep --line-buffered 'Google IAP'
```

The mobile request is:

```http
POST /api/v1/promotions/{promotion_id}/pay
Authorization: Bearer <user-token>
Content-Type: application/json

{
  "method": "google",
  "purchase_token": "<token returned by Google Play>"
}
```

Success must be idempotent and return HTTP 200:

```json
{
  "data": {
    "activated": true,
    "promotion": {
      "status": "active"
    }
  }
}
```

For an announcement still in moderation, `activated` may be `false` only when
the returned promotion status is `pending_activation`; the verified purchase
must still be persisted exactly once.

## Error diagnosis

| Result | Meaning | Fix |
| --- | --- | --- |
| HTTP 422, purchase not verified | Usually `google_live=false`, wrong token, or product mismatch | Enable the live verifier and compare the pending order product id with Play |
| HTTP 503 | Missing credentials, OAuth failure, Play API disabled, missing Play Console permission, or temporary Google outage | Check the JSON path, API enablement, permissions and server log |
| HTTP 409, purchase already used | The same Google transaction is attached to another order | Do not grant twice; inspect the stored purchase/order mapping |
| HTTP 200, `activated=true` | Verification and activation succeeded | Mobile consumes the Play purchase and opens the success screen |

## Release decision

Do not promote the Android build to production merely to test this fix. First
make the existing internal-test purchase return HTTP 200 after tapping Retry.
No new AAB is required for the backend configuration change.
