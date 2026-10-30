import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/models/aircraft.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';

/// `aircraft/gallery` — один снимок борта с автором и лицензией.
///
/// Запроса нет: `image{}` приходит внутри паспорта (§9.5). Отдельный
/// `/aircraft/{reg}/image` отдаёт провайдерский формат (`htmlAttributions`
/// вместо `attributions`) — здесь он не нужен.
///
/// Снимок один: ни галереи, ни карусели в ответе нет. Размеров картинки тоже
/// нет, поэтому рамка держит постоянное отношение сторон.
///
/// Фото без подписи об авторстве не показывается нигде (§4.5) — это условие
/// лицензии. Нет `image` — весь блок, строки, карточка прав и кнопка уходят,
/// остаётся спокойное «шəkil yoxdur».
class AircraftGalleryScreen extends StatelessWidget {
  const AircraftGalleryScreen({super.key, required this.aircraft});

  final Aircraft aircraft;

  @override
  Widget build(BuildContext context) {
    final image = aircraft.image;
    final hasImage = image?.url != null;
    return FlightScaffold(
      title: '${aircraft.registration} · ${ft('gallery_short', 'Şəkil')}',
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: FHeroIntro(
          title: ft('gallery_title', 'Şəkil'),
          message: hasImage
              ? ft('gallery_hero', 'Müəllif və lisenziya ilə')
              : ft('gallery_hero_empty', 'Bu təyyarə üçün şəkil yoxdur'),
        ),
      ),
      slivers: [
        FlightBody(
          children: hasImage
              ? _withImage(context, image!)
              : [
                  FCalmEmpty(
                    icon: PhosphorIconsFill.image,
                    title: ft(
                      'gallery_empty',
                      'Bu təyyarə üçün şəkil yoxdur',
                    ),
                    message: ft(
                      'gallery_empty_message',
                      'Kataloqda bu bortun şəkli saxlanılmır — filonun böyük '
                          'hissəsi belədir.',
                    ),
                  ),
                ],
        ),
      ],
    );
  }

  List<Widget> _withImage(BuildContext context, AircraftImage image) {
    final d = fDark(context);
    final rows = <FRow>[
      if (image.author != null)
        FRow(ft('gallery_author', 'Müəllif'), value: image.author),
      if (image.title != null)
        FRow(ft('gallery_caption', 'Başlıq'), value: image.title),
      if (AircraftLicense.shortName(image.license) != null)
        FRow(
          ft('gallery_license', 'Lisenziya'),
          value: AircraftLicense.shortName(image.license),
        ),
      if (image.sourceDomain != null)
        FRow(ft('gallery_source', 'Mənbə'), value: image.sourceDomain),
    ];

    return [
      ClipRRect(
        borderRadius: FT.rTile,
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: Image.network(
            image.url!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : _frame(d, loading: true),
            errorBuilder: (_, __, ___) => _frame(d),
          ),
        ),
      ),
      if (rows.isNotEmpty)
        FCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < rows.length; i++)
                FRow(
                  rows[i].label,
                  value: rows[i].value,
                  last: i == rows.length - 1,
                ),
            ],
          ),
        ),
      _copyright(context, image),
      if (image.webUrl != null)
        FSecondaryButton(
          label: ft('gallery_open', 'Şəklin səhifəsinə bax'),
          icon: PhosphorIconsBold.arrowSquareOut,
          onTap: () => _open(context, image.webUrl!),
        ),
    ];
  }

  Widget _frame(bool d, {bool loading = false}) => Container(
        color: FT.chip(d),
        alignment: Alignment.center,
        child: loading
            ? SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(cMuted(d)),
                ),
              )
            : Icon(
                PhosphorIconsFill.airplaneTilt,
                size: 30,
                color: cMuted(d),
              ),
      );

  /// Карточка прав. Строки `attributions[]` приходят готовым HTML — теги
  /// снимаются, текст показывается как есть. Ниже — условие лицензии своими
  /// словами: сырой enum провайдера на экран не выводится.
  Widget _copyright(BuildContext context, AircraftImage image) {
    final d = fDark(context);
    final lines = image.attributions
        .map(fStripHtml)
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty && image.author != null) {
      lines.add('Photo © ${image.author}');
    }
    final license = AircraftLicense.shortName(image.license);
    final note = fLicenseNote(image.license);
    if (license != null) {
      lines.add(
        note == null
            ? '${ft('gallery_license', 'Lisenziya')}: $license'
            : '${ft('gallery_license', 'Lisenziya')}: $license — $note',
      );
    }
    if (lines.isEmpty) {
      lines.add(ft('gallery_rights_unknown', 'Müəllif göstərilməyib'));
    }

    return FCard(
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FIconChip(
            icon: PhosphorIconsFill.copyright,
            size: 30,
            iconSize: 14,
            color: cText2(d),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ft('gallery_rights', 'Müəllif hüququ qeydi'),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    color: cText(d),
                  ),
                ),
                const SizedBox(height: 3),
                for (final line in lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      line,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        color: cText3(d),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      fToast(context, ft('gallery_open_failed', 'Keçid açılmadı'));
    }
  }
}

/// Условие лицензии одной строкой. Сырой enum на экран не идёт (§9.5), а
/// условия у семейств лицензий разные — человеку важно именно это.
String? fLicenseNote(String? license) {
  switch (license) {
    case AircraftLicense.allRightsReserved:
      return ft(
        'license_arr',
        'icazəsiz istifadə olunmur',
      );
    case AircraftLicense.bySa:
      return ft(
        'license_sa',
        'dəyişiklik edilərsə eyni lisenziya ilə paylaşılmalıdır',
      );
    case AircraftLicense.byNcSa:
      return ft(
        'license_nc_sa',
        'kommersiya məqsədi yoxdur, dəyişiklik eyni lisenziya ilə paylaşılır',
      );
    case AircraftLicense.byNc:
      return ft('license_nc', 'kommersiya məqsədi ilə istifadə olunmur');
    case AircraftLicense.byNcNd:
      return ft(
        'license_nc_nd',
        'kommersiya məqsədi yoxdur, dəyişiklik edilmir',
      );
    case AircraftLicense.by:
      return ft('license_by', 'müəllif göstərilməklə istifadə oluna bilər');
    case AircraftLicense.byNd:
      return ft('license_nd', 'dəyişiklik edilmədən paylaşılır');
    case AircraftLicense.noKnownRestrictions:
    case AircraftLicense.usGovernmentWork:
    case AircraftLicense.cc0:
    case AircraftLicense.publicDomainMark:
      return ft('license_free', 'sərbəst istifadə oluna bilər');
    default:
      return null;
  }
}

/// Подпись под фото. `attributions[]` приходит строками HTML — теги
/// убираются, текст показывается как есть. Показывать её обязательно там, где
/// показано фото (§4.5).
String? fAttributionText(AircraftImage image) {
  final lines = image.attributions
      .map(fStripHtml)
      .where((line) => line.isNotEmpty)
      .toList();
  if (lines.isNotEmpty) return lines.join(' · ');
  final author = image.author;
  if (author == null || author.isEmpty) return null;
  return 'Photo © $author';
}

/// Убирает теги и разворачивает частые сущности: строки авторства приходят
/// готовым HTML, а показывать их нужно обычным текстом.
String fStripHtml(String raw) => raw
    .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ')
    .replaceAll(RegExp(r'<[^>]*>'), '')
    .replaceAll('&amp;', '&')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&middot;', '·')
    .replaceAll('&copy;', '©')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();
