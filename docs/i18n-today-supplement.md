# i18n handoff — keys added today (supplement to `i18n-new-keys.json`)

**19 new CMS keys** introduced by today's feature work **after** the 598-key sweep (`i18n-new-keys.json`). These are the ONLY strings from today not yet in a handoff. Translations are already filled (az/ru/en/tr/ua/es).

## How to ship (no app change needed)

- Add each key below to CMS `/content` for every language.
- The app fetches `GET /content?lang=<locale>` (whole map, no group filter) and resolves keys globally, so **once you add them, the app picks them up on next content sync — automatically, no client release.**
- Until then the app shows the AZ master as a built-in fallback.
- `group` is informational (mirrors the existing deliverable); it does not affect resolution.
- **Placeholders `{amount}` `{code}` `{days}` and the symbols `$ · −` must stay verbatim** in every language.

| key | group | az | ru | en | tr | ua | es |
|---|---|---|---|---|---|---|---|
| `auth.terms_connector` | auth |  və  |  и  |  and  |  ve  |  та  |  y  |
| `auth.terms_link` | auth | İstifadə qaydaları | Условия использования | Terms of Use | Kullanım Koşulları | Умови використання | Términos de uso |
| `legal.privacy.title` | legal | Məxfilik siyasəti | Политика конфиденциальности | Privacy Policy | Gizlilik Politikası | Політика конфіденційності | Política de privacidad |
| `legal.terms.title` | legal | İstifadə şərtləri | Условия использования | Terms of Use | Kullanım Koşulları | Умови використання | Términos de uso |
| `promo.reason.invalid` | promo | Promokod yanlışdır, artıq istifadə olunub və ya vaxtı keçib. | Промокод недействителен, уже использован или истёк. | Promo code is invalid, already used, or expired. | Promosyon kodu geçersiz, daha önce kullanılmış ya da süresi dolmuş. | Промокод недійсний, уже використаний або прострочений. | El código promocional no es válido, ya se usó o venció. |
| `promo.reason.below_min_order` | promo | Sifariş məbləği bu promokod üçün minimuma çatmır. | Сумма заказа меньше минимальной для этого промокода. | Order amount is below the minimum for this promo code. | Sipariş tutarı bu promosyon kodu için gereken minimumun altında. | Сума замовлення менша за мінімум для цього промокоду. | El monto del pedido no alcanza el mínimo para este código promocional. |
| `promo.reason.currency_mismatch` | promo | Promokod başqa valyutadadır. | Промокод в другой валюте. | This promo code is in a different currency. | Promosyon kodu farklı bir para biriminde. | Промокод у іншій валюті. | El código promocional es de otra moneda. |
| `promo.reason.feature_disabled` | promo | Promokodlar müvəqqəti olaraq deaktivdir. | Промокоды временно отключены. | Promo codes are temporarily disabled. | Promosyon kodları geçici olarak devre dışı. | Промокоди тимчасово вимкнені. | Los códigos promocionales están desactivados temporalmente. |
| `promo.reason.listing_not_active` | promo | Elan aktiv olmadığı üçün promokod tətbiq olunmur. | Объявление неактивно, поэтому промокод нельзя применить. | The listing isn't active, so the promo code can't be applied. | İlan aktif olmadığı için promosyon kodu uygulanamıyor. | Оголошення неактивне, тому промокод не застосовується. | El anuncio no está activo, por eso no se puede aplicar el código promocional. |
| `promo.reason.no_promo_code` | promo | Promokod daxil edin. | Введите промокод. | Enter a promo code. | Promosyon kodu girin. | Введіть промокод. | Ingresa un código promocional. |
| `promo.reason.generic` | promo | Promokod tətbiq olunmadı. | Промокод не применён. | Promo code wasn't applied. | Promosyon kodu uygulanmadı. | Промокод не застосовано. | No se pudo aplicar el código promocional. |
| `promotion.promo_applied` | promotion | Promokod tətbiq olundu · −{amount} $ | Промокод применён · −{amount} $ | Promo code applied · −{amount} $ | Promosyon kodu uygulandı · −{amount} $ | Промокод застосовано · −{amount} $ | Código promocional aplicado · −{amount} $ |
| `promotion.promo_line` | promotion | Promokod · {code} | Промокод · {code} | Promo code · {code} | Promosyon kodu · {code} | Промокод · {code} | Código promocional · {code} |
| `promotion.total_before` | promotion | İlkin məbləğ | Исходная сумма | Original amount | İlk tutar | Початкова сума | Monto original |
| `promotion.payment.wallet_pay_subtitle` | promotion | Sürətli və təhlükəsiz ödəniş | Быстрая и безопасная оплата | Fast, secure checkout | Hızlı ve güvenli ödeme | Швидка й безпечна оплата | Pago rápido y seguro |
| `promotion.choose_from_wallet` | promotion | Promokodlarımdan seç | Выбрать из моих промокодов | Choose from my promo codes | Promosyon kodlarımdan seç | Обрати з моїх промокодів | Elegir de mis códigos promocionales |
| `promotion.wallet_title` | promotion | Promokodlarım | Мои промокоды | My promo codes | Promosyon kodlarım | Мої промокоди | Mis códigos promocionales |
| `promotion.wallet_empty` | promotion | Aktiv promokodun yoxdur. | У вас нет активных промокодов. | You have no active promo codes. | Aktif promosyon kodun yok. | У вас немає активних промокодів. | No tienes códigos promocionales activos. |
| `promotion.wallet_days_left` | promotion | {days} gün qalıb | Осталось {days} дн. | {days} days left | {days} gün kaldı | Залишилось {days} дн. | Quedan {days} días |

## By feature

- **auth** (2): Registration — tappable “Privacy Policy · Terms of Use” links
- **legal** (2): Legal Markdown screens (privacy / terms titles)
- **promo** (7): Promo-code apply — validation reasons (quote `applicable:false`)
- **promotion** (8): Promo-code apply — checkout/payment discount UI + wallet picker; Apple/Google Pay tile subtitle
