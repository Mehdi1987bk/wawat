# Backend üçün task — Wawatair məcburi yenilənmə

Namazov layihəsindəki məcburi yenilənmə məntiqinin eynisini Wawatair üçün hazırlayın. Mobil tərəf artıq startup zamanı, login-dən əvvəl aşağıdakı public endpoint-i çağırır.

## 1. Public API

`GET /api/v1/app/version-check`

Endpoint autentifikasiya tələb etməməlidir.

Mobil tətbiqin göndərdiyi query parametrlər:

- `platform`: `ios` və ya `android`
- `version`: tətbiqin version name-i, məsələn `1.0.48`
- `version_name`: `version` ilə eyni dəyər
- `build_number`: iOS build number / Android versionCode, məsələn `47`
- `package_name`: iOS üçün `wawat.app`, Android üçün real applicationId
- `lang`: `az`, `ru`, `en`, `tr`, `ua` və ya `es`

Uğurlu cavab nümunəsi:

```json
{
  "data": {
    "platform": "ios",
    "latest_version": "1.0.49",
    "latest_build": 48,
    "minimum_supported_version": "1.0.48",
    "minimum_supported_build": 47,
    "update_available": true,
    "force_update": false,
    "title": "Yeniləmə tələb olunur",
    "message": "Davam etmək üçün Wawatair-in yeni versiyasını quraşdırın.",
    "store_url": "https://apps.apple.com/app/id6755226789"
  }
}
```

`force_update=true` olduqda tətbiq bağlanmayan yenilənmə ekranı göstərir və istifadəçini mağazaya göndərir. `title` və `message` seçilmiş `lang` dilində qaytarılmalıdır.

## 2. Müqayisə qaydası

Əsas müqayisə rəqəm olan build üzrə aparılsın:

`force_update = rule.enabled && request.build_number < rule.minimum_supported_build`

`update_available = request.build_number < rule.latest_build`

iOS və Android üçün qaydalar ayrıdır. Semver yalnız istifadəçiyə göstərmək üçündür; `1.0.10` və `1.0.9` string kimi müqayisə edilməsin. Parametr yoxdursa və ya düzgün formatda deyilsə, təhlükəsiz cavab olaraq `force_update=false` qaytarın və xətanı loglayın.

## 3. Admin panel

Admin paneldə “Mobil tətbiq versiyaları” bölməsi yaradın. iOS və Android üçün ayrıca aşağıdakı sahələr olsun:

- Aktivdir (`enabled`)
- Son versiya (`latest_version`)
- Son build (`latest_build`, integer)
- Minimum dəstəklənən versiya (`minimum_supported_version`)
- Minimum dəstəklənən build (`minimum_supported_build`, integer)
- Store URL (`store_url`)
- `title` və `message` — bütün tətbiq dilləri üçün lokalizasiya
- Dəyişdirən admin, dəyişmə tarixi və audit history

Validasiya:

- `minimum_supported_build <= latest_build`
- iOS Store URL `apps.apple.com`, Android Store URL `play.google.com` domeninə aid olsun
- Qaydanı aktiv etməzdən əvvəl hər iki URL və build sahələri məcburidir
- Dəyişiklik yadda saxlanarkən təsdiq pəncərəsində neçə build-in bloklanacağı göstərilsin

## 4. İlkin konfiqurasiya

- iOS package/bundle: `wawat.app`
- iOS Store URL: `https://apps.apple.com/app/id6755226789`
- Android package/applicationId: `az.buking.buking`
- İlk deploy zamanı `enabled=false` və ya `minimum_supported_build=0` saxlayın ki, təsadüfən bütün istifadəçilər bloklanmasın

## 5. Testlər

- Cari build minimumdan aşağıdır → `force_update=true`
- Cari build minimuma bərabərdir → `force_update=false`
- Platformalar bir-birinə təsir etmir
- `lang` üzrə düzgün mətn gəlir
- Auth-suz sorğu `200` qaytarır
- Yanlış/missing build bütün istifadəçiləri bloklamır
- Admin validation və audit history işləyir

Hazır olduqda mobil komandaya staging və production endpoint cavablarını, həmçinin admin bölməsinin URL-ni göndərin.
