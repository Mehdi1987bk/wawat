# Задача бэкенду: эндпоинт `GET /api/v1/purchases/catalog`

Мобильное приложение (Flutter) уже переведено на покупки через App Store / Google
Play (IAP). Клиент готов полностью. Осталась **одна серверная задача**: отдать
каталог товаров, чтобы приложение знало, какой store-товар показывать на каждом
экране, как его назвать и что написать в описании. **Цена берётся из стора, не с
бэкенда** — сервер отдаёт названия/метаданные, стор отдаёт цену и проводит оплату.

## Эндпоинт

`GET /api/v1/purchases/catalog`

- Авторизация: как у остальных `/api/v1/*` (Bearer-токен пользователя).
- Локализация: по заголовку `Accept-Language` (az / ru / en) — поле `name` и
  `description` возвращать на языке запроса.

## Формат ответа

```json
{
  "data": {
    "products": [
      {
        "product_id": "wawat.app.vip.1d",
        "kind": "vip",
        "name": "VİP · 1 gün",
        "description": "Elanı 1 gün VİP et",
        "duration_days": 1,
        "sort_order": 1
      },
      {
        "product_id": "wawat.app.vip.3d",
        "kind": "vip",
        "name": "VİP · 3 gün",
        "description": "Elanı 3 gün VİP et",
        "duration_days": 3,
        "sort_order": 2
      },
      {
        "product_id": "wawat.app.vip.5d",
        "kind": "vip",
        "name": "VİP · 5 gün",
        "description": "Elanı 5 gün VİP et",
        "duration_days": 5,
        "sort_order": 3
      },

      {
        "product_id": "wawat.app.boost.small",
        "kind": "featured",
        "package": "small",
        "name": "Önə çıxarılan · Kiçik",
        "description": "Zəmanətli göstəriş paketi",
        "guaranteed_min": 117,
        "guaranteed_max": 235,
        "sort_order": 1
      },
      {
        "product_id": "wawat.app.boost.medium",
        "kind": "featured",
        "package": "medium",
        "name": "Önə çıxarılan · Orta",
        "description": "Zəmanətli göstəriş paketi",
        "guaranteed_min": 352,
        "guaranteed_max": 588,
        "recommended": true,
        "sort_order": 2
      },
      {
        "product_id": "wawat.app.boost.large",
        "kind": "featured",
        "package": "large",
        "name": "Önə çıxarılan · Böyük",
        "description": "Zəmanətli göstəriş paketi",
        "guaranteed_min": 588,
        "guaranteed_max": 1000,
        "sort_order": 3
      },

      {
        "product_id": "wawat.app.quota.small",
        "kind": "quota",
        "name": "Listing limit +1",
        "description": "1 əlavə elan",
        "extra_listings": 1,
        "sort_order": 1
      },
      {
        "product_id": "wawat.app.quota.medium",
        "kind": "quota",
        "name": "Listing limit +3",
        "description": "3 əlavə elan",
        "extra_listings": 3,
        "sort_order": 2
      },
      {
        "product_id": "wawat.app.quota.large",
        "kind": "quota",
        "name": "Listing limit +5",
        "description": "5 əlavə elan",
        "extra_listings": 5,
        "sort_order": 3
      }
    ]
  }
}
```

## Правила по полям

| Поле | Обяз. | Смысл |
| --- | --- | --- |
| `product_id` | да | Идентификатор товара в App Store / Google Play. **Должен совпадать точно** с тем, что заведено в сторах (см. список ниже). По нему клиент запрашивает у стора цену и проводит оплату. |
| `kind` | да | `vip` \| `featured` \| `quota` \| `verification`. Определяет, на каком экране показывается товар. |
| `name` | да | Локализованное название (по `Accept-Language`). Показывается пользователю. |
| `description` | нет | Локализованное описание/подзаголовок. |
| `duration_days` | для vip | Срок VIP в днях (1 / 3 / 5). Клиент группирует VIP по этому полю. |
| `package` | для featured | Код пакета boost: `small` \| `medium` \| `large`. |
| `guaranteed_min` / `guaranteed_max` | для featured | Диапазон гарантированных показов (для строки «Показов: 117–235»). |
| `extra_listings` | для quota | Сколько доп. объявлений даёт пакет. |
| `recommended` | нет | `true` — карточка помечается как рекомендованная. |
| `sort_order` | нет | Порядок в списке (по возрастанию). |
| `price` / `currency` | **НЕ нужно** | Цену клиент берёт из стора. Можно не присылать вовсе. |

## Точные product_id (уже заведены в сторах)

```
wawat.app.vip.1d        vip       1 день
wawat.app.vip.3d        vip       3 дня
wawat.app.vip.5d        vip       5 дней
wawat.app.boost.small   featured  small
wawat.app.boost.medium  featured  medium
wawat.app.boost.large   featured  large
wawat.app.quota.small   quota     +1 объявление
wawat.app.quota.medium  quota     +3 объявления
wawat.app.quota.large   quota     +5 объявлений
```

## Важно

- Для каждого типа (`vip`, `featured`, `quota`) вернуть **все 3 пакета** — иначе на
  экране будет меньше вариантов, чем нужно.
- `product_id` должен **буква-в-букву** совпадать со сторами, иначе стор не найдёт
  товар и оплата будет недоступна.
- Оплата (валидация чека App Store / Google Play, начисление VIP/boost/лимита
  пользователю) — отдельный существующий флоу; здесь только каталог для показа и
  выбора товара.

## Как проверить

`GET /api/v1/purchases/catalog` с `Accept-Language: az` должен вернуть 9 товаров
(3 vip + 3 featured + 3 quota) с указанными `product_id` и локализованными `name`.
После этого экраны VIP, «Продвинуть» и «Лимит объявлений» в приложении покажут по
3 варианта с ценами из стора.
