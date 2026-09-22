# Backend task: IAP package catalog

The mobile app now treats `GET /api/v1/purchases/catalog` as the source of
truth for VIP and boost package metadata. Google Play and App Store remain the
source of truth for product availability, localized currency, charged price,
and the purchase itself.

## Request

```http
GET /api/v1/purchases/catalog
Authorization: Bearer <token>
Accept: application/json
Accept-Language: az
```

Supported languages: `az`, `en`, `ru`, `tr`, `ua`. The backend must return
`name` and `description` in the requested language. The mobile locale `ua`
maps to the store locale `uk-UA` only when products are configured in Google
Play or App Store.

## Required response

```json
{
  "data": {
    "products": [
      {
        "package_id": "vip-3-days",
        "product_id": "wawat.app.vip.3d",
        "kind": "vip",
        "name": "VİP · 3 gün",
        "description": "Elanı 3 gün VİP et",
        "duration_days": 3,
        "price": 3,
        "currency": "AZN",
        "recommended": false,
        "sort_order": 10
      },
      {
        "package_id": "boost-medium",
        "product_id": "wawat.app.boost.medium",
        "kind": "featured",
        "package": "medium",
        "name": "Önə çıxarılan · Orta",
        "description": "Zəmanətli göstəriş paketi",
        "guaranteed_min": 352,
        "guaranteed_max": 588,
        "price": 7.99,
        "currency": "USD",
        "recommended": true,
        "sort_order": 20
      },
      {
        "package_id": "boost-small",
        "product_id": "wawat.app.boost.small",
        "kind": "featured",
        "package": "small",
        "name": "Önə çıxarılan · Kiçik",
        "description": "Zəmanətli göstəriş paketi",
        "guaranteed_min": 117,
        "guaranteed_max": 235,
        "price": 3.99,
        "currency": "USD",
        "recommended": false,
        "sort_order": 30
      }
    ]
  }
}
```

Return every active package in `data.products`, including all VIP durations
and all boost packages. The examples above do not limit the list.

## Field rules

| Field | Rule |
| --- | --- |
| `package_id` | Stable backend identifier. Never reuse it for another package. |
| `product_id` | Exact immutable ID configured in both stores. |
| `kind` | `vip` or `featured`. |
| `name` | Localized package name from `Accept-Language`. |
| `description` | Localized package description from `Accept-Language`. |
| `duration_days` | Required only for `vip`. |
| `package` | Stable code required only for `featured`. |
| `guaranteed_min/max` | Required for `featured`; calculated by the backend and never hardcoded by mobile. |
| `recommended` | Controls the recommended badge. At most one package per kind should be `true`. |
| `sort_order` | Ascending display order. |
| `price/currency` | Fallback display only. The final price shown and charged comes from the store. |

## Validation requirements

- Return only products that are configured and active in the current store.
- Keep `product_id` identical across the backend, Google Play, App Store, and
  receipt-validation allowlist.
- Reject purchase validation when the purchased product ID does not match the
  pending promotion order.
- Snapshot package name, duration or range, amount and currency into the order
  so later catalog changes cannot alter an existing purchase.
- `guaranteed_min` must be positive and `guaranteed_max >= guaranteed_min`.
- Cache by language; do not serve an Azerbaijani cached response to Russian or
  other locales.

## Migration

The app still accepts the old catalog response. Until this endpoint is
deployed, it falls back to `/promotions/pricing` and store product text. After
deployment, the new catalog fields take priority automatically.

## Production VIP catalogue

As of 2026-09-13, the approved production catalogue is `1/3/5` days. Keep
these values identical in pricing, order creation, receipt validation, Google
Play and App Store:

| Duration | Product ID | Fallback price |
| --- | --- | --- |
| 1 day | `wawat.app.vip.1d` | `$0.99` |
| 3 days | `wawat.app.vip.3d` | `$1.99` |
| 5 days | `wawat.app.vip.5d` | `$2.99` |

Return all three rows from `GET /api/v1/purchases/catalog`. Do not map one
product ID to another duration. Migrate or cancel unpaid orders that reference
the retired `7d` and `30d` products, while keeping verification idempotent.
