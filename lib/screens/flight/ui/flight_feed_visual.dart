import '../data/models/flight_enums.dart';
import '../flight_text.dart';
import 'flight_tokens.dart';

/// Как показывать состояние потока данных.
///
/// Слова провайдера на экран не выводятся: `OK` и `OKPartial` — «İşləyir»,
/// `Down` и `Degraded` — «Dayanıb», `Unavailable` — «Əlçatmaz», всё
/// остальное — «Bilinmir». Тон у `OKPartial` мягче: поток жив, но не весь.
({String label, FTone tone}) fFeedVisual(String? status) => switch (status) {
      FeedStatus.ok => (
          label: ft('feed_working', 'İşləyir'),
          tone: FTone.ok,
        ),
      FeedStatus.okPartial => (
          label: ft('feed_working', 'İşləyir'),
          tone: FTone.warn,
        ),
      FeedStatus.down || FeedStatus.degraded => (
          label: ft('feed_stopped', 'Dayanıb'),
          tone: FTone.bad,
        ),
      FeedStatus.unavailable => (
          label: ft('feed_unavailable', 'Əlçatmaz'),
          tone: FTone.mute,
        ),
      _ => (
          label: ft('feed_unknown', 'Bilinmir'),
          tone: FTone.mute,
        ),
    };

/// Покрытие полосы приходит английским словом провайдера.
String fRunwaySurface(String? surface) => switch (surface) {
      'Asphalt' => ft('surface_asphalt', 'Asfalt'),
      'Concrete' => ft('surface_concrete', 'Beton'),
      'Grass' => ft('surface_grass', 'Çəmən'),
      'Dirt' => ft('surface_dirt', 'Torpaq'),
      'Gravel' => ft('surface_gravel', 'Çınqıl'),
      'DryLakebed' => ft('surface_lakebed', 'Quru göl yatağı'),
      'Water' => ft('surface_water', 'Su'),
      'Snow' => ft('surface_snow', 'Qar'),
      'Unknown' => ft('surface_unknown', 'Bilinmir'),
      // Непереведённое значение показываем как есть: выдумывать нельзя.
      _ => surface ?? ft('surface_unknown', 'Bilinmir'),
    };
