import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../home/tabs/listings/details/listing_details_screen.dart';
import '../../data/flight_error.dart';
import '../../data/flight_link_store.dart';
import '../../data/flight_local_store.dart';
import '../../data/flight_repository.dart';
import '../../data/models/airport.dart';
import '../../data/models/flight.dart';
import '../../data/models/flight_enums.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_map.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_status_visual.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import '../aircraft/aircraft_passport_screen.dart';
import '../airport/airport_card_screen.dart';
import '../airport/airport_feeds_screen.dart';
import '../link/link_attach_screen.dart';
import '../map/map_radar_screen.dart';
import '../watch/watch_new_screen.dart';
import 'flight_calendar_screen.dart';
import 'flight_delays_screen.dart';
import 'flight_details_screen.dart';
import 'flight_history_screen.dart';
import 'flight_instances_screen.dart';
import 'flight_passport_screen.dart';
import 'flight_plan_screen.dart';
import 'flight_statuses_screen.dart';

/// Карточка рейса — один экран на все состояния.
///
/// В прототипе это шесть отдельных экранов (`flight/live`, `no-position`,
/// `boarding`, `delayed`, `canceled`, `diverted`), но данные у них одни и те
/// же: `GET /flights/{number}/{date}/detail?departure_code=…`. Поэтому здесь
/// один экран, который ветвится по `status` — иначе шесть копий расходились
/// бы при первой же правке.
///
/// Что показывается, решают поля ответа, а не статус:
/// * телеметрия — только когда `location != null` (§9); на бакинских
///   маршрутах координат нет, и тогда вместо живой карточки идёт «Mövqe
///   yoxdur»: метка на карте ставится по `progress_percent`;
/// * «Uçuş planı» — только когда пришёл `flight_plan.route`;
/// * у `/detail` нет `meta`, поэтому полоска «данные на …» берёт время из
///   `refreshed_at` (иначе `source_updated_at`).
///
/// Рейс не опрашивается по таймеру: сервер сам обновляет подписанные рейсы и
/// присылает push (§4.4).
class FlightCardScreen extends StatefulWidget {
  const FlightCardScreen({super.key, required this.flightKey});

  final FlightKey flightKey;

  @override
  State<FlightCardScreen> createState() => _FlightCardScreenState();
}

class _FlightCardScreenState extends State<FlightCardScreen> {
  final _repo = FlightRepository.instance;
  final _local = FlightLocalStore.instance;
  final _links = FlightLinkStore.instance;

  FlightDetail? _detail;
  FlightError? _error;
  bool _loading = true;
  bool _saved = false;
  List<FlightLink> _linked = const [];

  /// Ближайшая дата этого номера после отменённой. В ответе её нет —
  /// отдельный запрос `/dates` (§9, `flight/canceled`).
  String? _nextDate;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool force = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await _local.load();
    await _links.load();
    try {
      final response = await _repo.flightDetail(widget.flightKey, force: force);
      if (!mounted) return;
      setState(() {
        _detail = response.data;
        _saved = _local.isSavedFlight(widget.flightKey);
        _linked = _links.forFlight(widget.flightKey);
        _loading = false;
      });
      final detail = response.data;
      if (detail != null && detail.summary.isCanceled) _loadNextDate(detail);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = FlightError.from(e);
        _loading = false;
      });
    }
  }

  Future<void> _loadNextDate(FlightDetail detail) async {
    final today = DateTime.now();
    try {
      final response = await _repo.flightDates(
        detail.number,
        from: fApiDate(today),
        to: fApiDate(today.add(const Duration(days: 30))),
      );
      final dates = (response.data ?? const <String>[])
          .where((date) => date.compareTo(widget.flightKey.flightDate) > 0)
          .toList()
        ..sort();
      if (!mounted || dates.isEmpty) return;
      setState(() => _nextDate = dates.first);
    } catch (_) {
      // Дата следующего рейса — приятное дополнение, а не содержание экрана.
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    final title = detail?.displayNumber ?? widget.flightKey.number;

    if (_loading) {
      return FlightScaffold(
        title: title,
        slivers: const [
          FlightBody(children: [FCardSkeleton(rows: 5)]),
        ],
      );
    }

    if (_error != null) {
      return FlightScaffold(
        title: title,
        slivers: [
          FlightBody(
            children: [
              FErrorView(
                error: _error!,
                onRetry: () => _load(force: true),
                onBack: () => Navigator.of(context).maybePop(),
                notFoundTitle: ft('card_not_found', 'Bu uçuş tapılmadı'),
                notFoundMessage: ft(
                  'card_not_found_message',
                  'Nömrə və ya tarix dəyişmiş ola bilər. Başqa tarixə bax.',
                ),
                notFoundActions: [
                  FSecondaryButton(
                    label: ft('card_other_date', 'Başqa tarix'),
                    icon: PhosphorIconsBold.calendarDots,
                    onTap: _openCalendar,
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    }

    if (detail == null) {
      // §4.3: `data: null` — такого рейса у провайдера нет. Это не сбой.
      return FlightScaffold(
        title: title,
        slivers: [
          FlightBody(
            children: [
              FCalmEmpty(
                icon: PhosphorIconsFill.airplaneTilt,
                title: ft('card_empty', 'Bu uçuş üçün məlumat yoxdur'),
                message: ft(
                  'card_empty_message',
                  'Mənbədə bu nömrə və tarix üçün yazı yoxdur. Təqvimdən '
                      'başqa günə baxa bilərsən.',
                ),
              ),
              FSecondaryButton(
                label: ft('card_calendar', 'Təqvim'),
                icon: PhosphorIconsBold.calendarDots,
                onTap: _openCalendar,
              ),
            ],
          ),
        ],
      );
    }

    return FlightScaffold(
      title: detail.displayNumber,
      actions: [
        FSkyAction(
          icon: _saved ? PhosphorIconsFill.star : PhosphorIconsBold.star,
          onTap: () => _toggleSaved(detail),
        ),
        FSkyAction(
          icon: PhosphorIconsBold.shareNetwork,
          onTap: () => _share(detail),
        ),
      ],
      hero: _hero(detail),
      stale: _staleLine(detail),
      slivers: [
        FlightBody(gap: 12, children: _body(detail)),
        SliverToBoxAdapter(child: _about(detail)),
      ],
    );
  }

  // ─────────────────────────────── Небо ───────────────────────────────

  Widget _hero(FlightDetail detail) {
    final summary = detail.summary;
    final visual = fStatusVisual(detail.status);
    final live = summary.statusGroup == FlightStatusGroup.inAir;
    final diverted = detail.status == FlightStatus.diverted;
    final canceled = summary.isCanceled;
    final progress = detail.progressPercent;
    final showProgress = !canceled && !diverted && progress != null;
    final location = detail.location;
    final aircraft = _aircraftBadgeText(detail);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              FBadge(
                (summary.statusLabel ?? visual.label).toUpperCase(),
                icon: live && summary.isLive ? null : visual.icon,
                ping: live && summary.isLive,
                background: FT.heroBadgeBg(visual.tone),
                foreground: FT.heroBadgeFg(visual.tone),
                onTap: _openStatuses,
              ),
              if (!live && aircraft != null)
                FBadge(
                  aircraft,
                  background: Colors.white.withValues(alpha: .16),
                  foreground: Colors.white,
                ),
            ],
          ),
          const SizedBox(height: 14),
          FRouteBlock(
            fromCode: _code(detail.departure, summary.departureCode),
            toCode: _code(detail.arrival, summary.arrivalCode),
            fromCity: _city(detail.departure),
            toCity: _city(detail.arrival),
            fromTime: _best(detail.departure),
            toTime: _best(detail.arrival),
            fromWas: _was(detail.departure),
            toWas: _was(detail.arrival),
            fromMeta: canceled
                ? ft('card_canceled_short', 'Ləğv edildi')
                : _endpointMeta(detail.departure),
            toMeta: canceled
                ? ft('card_canceled_short', 'Ləğv edildi')
                : _endpointMeta(detail.arrival),
            duration: canceled
                ? '—'
                : (diverted
                    ? ft('card_diverted_short', 'yönləndirildi')
                    : fMinutesShort(summary.duration?.inMinutes)),
            distance: detail.greatCircleKm == null
                ? null
                : fKm(detail.greatCircleKm),
          ),
          if (showProgress) ...[
            const SizedBox(height: 26),
            FProgressBar(percent: progress.toDouble()),
            const SizedBox(height: 10),
            _progressLine(detail, progress),
          ],
          if (location != null) ...[
            const SizedBox(height: 20),
            FLiveGrid(
              cells: [
                FLiveCell(
                  value: fMeters(location.altitudeM),
                  label: ft('card_altitude', 'Hündürlük'),
                ),
                FLiveCell(
                  value: fSpeed(location.groundSpeedKmh),
                  label: ft('card_speed', 'Sürət'),
                ),
                FLiveCell(
                  value: fKm(detail.remainingKm),
                  label: ft('card_left', 'Qalıb'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Под полосой: слева доля пути, справа остаток. Когда координат нет,
  /// честно сказано, что доля посчитана по расписанию (§9).
  Widget _progressLine(FlightDetail detail, int progress) {
    final live = detail.hasPosition;
    final left = _minutesLeft(detail);
    final arrived = detail.status == FlightStatus.arrived;
    final passed = live
        ? ft('card_passed', '{n}% keçib', {'n': '$progress'})
        : ft('card_passed_estimated', '{n}% keçib (təxmini)', {'n': '$progress'});
    final String tail;
    if (arrived) {
      final at = _best(detail.arrival);
      tail = at == null
          ? ft('card_landed', 'endi')
          : ft('card_landed_at', '{time}-da endi', {'time': at});
    } else if (live && left != null) {
      tail = ft('card_left_minutes', '{time} qalıb', {
        'time': fMinutesLong(left),
      });
    } else {
      tail = ft('card_by_schedule', 'cədvəl vaxtına görə');
    }
    return Row(
      children: [
        Expanded(
          child: Text(
            passed,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: FT.onHero(.55),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          tail,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────── Тело ───────────────────────────────

  List<Widget> _body(FlightDetail detail) {
    final status = detail.status;
    if (detail.summary.isCanceled) return _canceledBody(detail);
    if (status == FlightStatus.diverted) return _divertedBody(detail);
    if (status == FlightStatus.delayed) return _delayedBody(detail);
    if (detail.summary.statusGroup == FlightStatusGroup.beforeDeparture) {
      return _beforeDepartureBody(detail);
    }
    return _airborneBody(detail);
  }

  /// Живой рейс и «позиции нет» — одно тело: карта, факты, телеметрия.
  List<Widget> _airborneBody(FlightDetail detail) {
    final location = detail.location;
    final now = DateTime.now().toUtc();
    return [
      if (_canAttachListing(detail))
        FBrandActionCard(
          icon: PhosphorIconsFill.package,
          title: ft('card_attach', 'Bu uçuşla elan yarat'),
          subtitle: ft('card_attach_sub', 'Marşrut və saat özü dolacaq'),
          onTap: () => _openAttach(detail),
        ),
      if (_linked.isNotEmpty) _linkedCard(detail),
      ...?_map(detail),
      _factsCard(detail),
      if (location != null) _telemetryCard(detail, location),
      if (location == null) ..._estimatedCards(detail),
      if (detail.arrivalOverdue(now))
        FInfoNote(
          ft(
            'card_overdue',
            'Gəliş vaxtı keçib, enmə təsdiqi hələ gəlməyib. Təsdiq limanın '
                'canlı yayımından gəlir.',
          ),
          icon: PhosphorIconsFill.clockCountdown,
        ),
      _linksCard(detail),
      FSecondaryButton(
        label: ft('card_watch', 'Bu uçuş üçün xəbərdarlıq qur'),
        icon: PhosphorIconsBold.bellRinging,
        onTap: _openWatch,
      ),
    ];
  }

  /// До вылета: миник, регистрация, закрытый выход. Обратного отсчёта в
  /// ответе нет — он считается от `revised` (иначе `scheduled`).
  List<Widget> _beforeDepartureBody(FlightDetail detail) {
    final departure = detail.departure;
    final visual = fStatusVisual(detail.status);
    final minutes = _minutesToDeparture(detail);
    final notice = _departureNotice(detail);
    return [
      if (notice != null)
        FNoticeCard(
          icon: visual.icon,
          title: detail.statusLabel ?? visual.label,
          message: notice,
          tone: visual.tone == FTone.mute ? FTone.info : visual.tone,
        ),
      if (_canAttachListing(detail))
        FBrandActionCard(
          icon: PhosphorIconsFill.package,
          title: ft('card_attach', 'Bu uçuşla elan yarat'),
          subtitle: ft('card_attach_sub', 'Marşrut və saat özü dolacaq'),
          onTap: () => _openAttach(detail),
        ),
      if (_linked.isNotEmpty) _linkedCard(detail),
      FCard(
        child: Column(
          children: [
            FRow(
              ft('card_departure_scheduled', 'Gediş (cədvəl)'),
              value: departure.scheduled?.local?.clock,
            ),
            FRow(
              ft('card_terminal', 'Terminal'),
              value: departure.terminal,
            ),
            FRow(ft('card_gate', 'Qapı'), value: departure.gate),
            FRow(
              ft('card_check_in', 'Check-in masası'),
              value: departure.checkInDesk,
              last: true,
            ),
          ],
        ),
      ),
      ...?_map(detail),
      _factsCard(detail),
      _linksCard(detail),
      if (minutes != null && minutes > 0)
        FPrimaryButton(
          label: ft('card_to_departure', 'Gedişə {time}', {
            'time': fMinutesLong(minutes),
          }),
          icon: PhosphorIconsBold.timer,
          onTap: () => _openAirport(detail.departure),
        )
      else
        FSecondaryButton(
          label: ft('card_watch', 'Bu uçuş üçün xəbərdarlıq qur'),
          icon: PhosphorIconsBold.bellRinging,
          onTap: _openWatch,
        ),
    ];
  }

  List<Widget> _delayedBody(FlightDetail detail) {
    final departure = detail.departure;
    final arrival = detail.arrival;
    final d = fDark(context);
    final delay = departure.delayMinutes ?? detail.summary.departureDelayMinutes;
    final revised = departure.revised?.local?.clock;
    final arrivalRevised = arrival.revised?.local?.clock ??
        arrival.predicted?.local?.clock;
    final parts = <String>[
      if (revised != null)
        ft('card_delayed_new', 'Yeni gediş saatı {time}.', {'time': revised}),
      if (arrivalRevised != null)
        ft('card_delayed_arrival', 'Enmə təxminən {time}-də gözlənilir.', {
          'time': arrivalRevised,
        }),
    ];
    return [
      FNoticeCard(
        icon: PhosphorIconsFill.clockCountdown,
        title: delay == null
            ? (detail.statusLabel ?? ft('status_delayed', 'Gecikir'))
            : ft('card_delayed_title', 'Uçuş {n} dəqiqə gecikir', {
                'n': '${delay.abs()}',
              }),
        // Причина задержки в ответе не приходит — выдуманного текста здесь нет.
        message: parts.isEmpty ? null : parts.join(' '),
      ),
      FCard(
        child: Column(
          children: [
            FRow(
              ft('card_by_schedule_row', 'Cədvəl üzrə'),
              value: departure.scheduled?.local?.clock,
            ),
            FRow(
              ft('card_revised', 'Dəqiqləşdirilmiş'),
              value: revised,
              valueColor: FT.warn(d),
            ),
            FRow(
              ft('card_delay', 'Gecikmə'),
              value: delay == null ? null : fMinutesLong(delay),
              valueColor: FT.warn(d),
            ),
            FRow(
              ft('card_arrival_revised', 'Gəliş (dəqiqləşdirilmiş)'),
              value: arrivalRevised,
              valueColor: FT.warn(d),
              last: true,
            ),
          ],
        ),
      ),
      if (_linked.isNotEmpty) _linkedCard(detail),
      if (_canAttachListing(detail))
        FBrandActionCard(
          icon: PhosphorIconsFill.package,
          title: ft('card_attach', 'Bu uçuşla elan yarat'),
          subtitle: ft('card_attach_sub', 'Marşrut və saat özü dolacaq'),
          onTap: () => _openAttach(detail),
        ),
      _factsCard(detail),
      _linksCard(detail),
      FSecondaryButton(
        label: ft('card_watch', 'Bu uçuş üçün xəbərdarlıq qur'),
        icon: PhosphorIconsBold.bellRinging,
        onTap: _openWatch,
      ),
    ];
  }

  List<Widget> _canceledBody(FlightDetail detail) {
    final d = fDark(context);
    final visual = fStatusVisual(detail.status);
    final from = _code(detail.departure, detail.summary.departureCode);
    final to = _code(detail.arrival, detail.summary.arrivalCode);
    final departure = detail.departure.scheduled?.local?.clock;
    final arrival = detail.arrival.scheduled?.local?.clock;
    return [
      FNoticeCard(
        icon: visual.icon,
        tone: FTone.bad,
        title: detail.statusLabel ?? visual.label,
        // Время отмены в ответе не приходит, причина тоже.
        message: ft(
          'card_canceled_message',
          'Bu uçuş icra olunmayacaq.',
        ),
      ),
      FCard(
        child: Column(
          children: [
            FRow(ft('card_route', 'Marşrut'), value: '$from → $to'),
            FRow(
              ft('card_by_schedule_row', 'Cədvəl üzrə'),
              value: departure == null || arrival == null
                  ? null
                  : '$departure → $arrival',
              last: _linked.isEmpty && _nextDate == null,
            ),
            if (_linked.isNotEmpty)
              FRow(
                ft('card_linked', 'Bağlı elan'),
                value: ft('card_linked_count', '{n} elan təsirlənir', {
                  'n': '${_linked.length}',
                }),
                valueColor: FT.bad(d),
                last: _nextDate == null,
              ),
            if (_nextDate != null)
              FRow(
                ft('card_next_flight', 'Növbəti uçuş'),
                value: fDateStringShort(_nextDate),
                onTap: () => _openDate(detail, _nextDate!),
                last: true,
              ),
          ],
        ),
      ),
      Row(
        children: [
          Expanded(
            child: FPrimaryButton(
              label: ft('card_another_flight', 'Başqa uçuş'),
              icon: PhosphorIconsBold.magnifyingGlass,
              onTap: () => FlightNav.toSection(context, FlightSection.search),
            ),
          ),
          if (_linked.isNotEmpty) ...[
            const SizedBox(width: 8),
            Expanded(
              child: FGhostButton(
                label: ft('card_open_listing', 'Elanı aç'),
                onTap: () => _openListing(_linked.first),
              ),
            ),
          ],
        ],
      ),
      _factsCard(detail),
      _linksCard(detail),
    ];
  }

  List<Widget> _divertedBody(FlightDetail detail) {
    final d = fDark(context);
    final visual = fStatusVisual(detail.status);
    final arrival = detail.arrival;
    final code = _code(arrival, detail.summary.arrivalCode);
    final city = arrival.airport?.municipality ?? arrival.airport?.name;
    final landed = arrival.runwayTime?.local?.clock ??
        arrival.revised?.local?.clock ??
        arrival.predicted?.local?.clock;
    return [
      FNoticeCard(
        icon: visual.icon,
        tone: FTone.bad,
        title: detail.statusLabel ?? visual.label,
        // Причину смены курса источник не даёт (§9) — пишем только факт.
        message: city == null
            ? ft('card_diverted_message_code', 'Təyyarə {code} limanına endi.', {
                'code': code,
              })
            : ft(
                'card_diverted_message',
                'Təyyarə {city} ({code}) limanına endi.',
                {'city': city, 'code': code},
              ),
      ),
      FCard(
        child: Column(
          children: [
            // «Запланированный аэропорт» в ответе не остаётся: после смены
            // курса `arrival` — это уже фактический аэропорт (§9). Поэтому
            // строки «Planlanan təyinat» здесь нет.
            FRow(
              ft('card_landed_airport', 'Faktiki enmə'),
              value: city == null ? code : '$code — $city',
              valueColor: FT.bad(d),
            ),
            FRow(ft('card_landing_time', 'Enmə saatı'), value: landed),
            FRow(
              ft('card_landing_confirmed', 'Enmə təsdiqi'),
              valueWidget: FBadge(
                detail.summary.arrivalConfirmed
                    ? ft('card_confirmed', 'TƏSDİQLƏNDİ')
                    : ft('card_awaiting', 'GÖZLƏNİLİR'),
                tone: detail.summary.arrivalConfirmed ? FTone.ok : FTone.mute,
                fontSize: 9,
              ),
              last: true,
            ),
          ],
        ),
      ),
      if (_linked.isNotEmpty) _linkedCard(detail),
      _factsCard(detail),
      _linksCard(detail),
      FSecondaryButton(
        label: city == null
            ? ft('card_open_airport_code', '{code} limanına bax', {'code': code})
            : ft('card_open_airport', '{city} ({code}) limanına bax', {
                'city': city,
                'code': code,
              }),
        icon: PhosphorIconsBold.mapPin,
        onTap: () => _openAirport(arrival),
      ),
    ];
  }

  // ───────────────────────────── Карточки ─────────────────────────────

  Widget _factsCard(FlightDetail detail) {
    final summary = detail.summary;
    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FCardTitle(ft('card_about', 'Uçuş haqqında')),
          FRow(
            ft('card_date', 'Tarix'),
            value: fDateStringLong(summary.flightDate),
          ),
          FRow(ft('card_airline', 'Aviaşirkət'), value: summary.airline?.name),
          FRow(
            ft('card_aircraft', 'Təyyarə'),
            value: detail.aircraft?.model ?? summary.aircraftModel,
          ),
          FRow(
            ft('card_registration', 'Qeydiyyat nişanı'),
            value: detail.aircraft?.reg,
          ),
          FRow(
            ft('card_duration', 'Uçuş müddəti'),
            value: summary.duration == null
                ? null
                : fMinutesLong(summary.duration!.inMinutes),
          ),
          FRow(
            ft('card_distance', 'Məsafə'),
            value: detail.greatCircleKm == null
                ? null
                : fKm(detail.greatCircleKm),
            last: true,
          ),
        ],
      ),
    );
  }

  Widget _telemetryCard(FlightDetail detail, FlightLocation location) {
    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FCardTitle(
            ft('card_telemetry', 'Canlı telemetriya'),
            trailing: FBadge(
              ft('card_live', 'CANLI'),
              tone: FTone.ok,
              fontSize: 9,
            ),
          ),
          FRow(
            ft('card_track', 'Kurs'),
            value: location.trueTrack == null
                ? null
                : '${location.trueTrack!.round()}°',
          ),
          FRow(
            ft('card_vsi', 'Şaquli sürət'),
            value: _vsi(location.vsiFpm),
          ),
          // Эшелон — из давления, а высота в метрах — из `altitude_m`: одно
          // и то же число двумя способами на одном экране не показывается.
          FRow(
            ft('card_level', 'Eşelon'),
            value: location.pressureAltitudeFt == null
                ? null
                : fFlightLevel(location.pressureAltitudeFt),
          ),
          FRow(
            ft('card_pressure', 'Təzyiq'),
            value: location.pressureHpa == null
                ? null
                : '${location.pressureHpa!.round()} ${ft('unit_hpa', 'hPa')}',
          ),
          FRow(
            ft('card_coordinates', 'Koordinat'),
            value: fCoordinates(location.lat, location.lon),
            mono: true,
          ),
          FRow(
            ft('card_last_signal', 'Son siqnal'),
            value: fAgo(location.reportedAt),
            last: true,
          ),
        ],
      ),
    );
  }

  /// Когда координат нет: доля пути, два времени и подтверждение посадки, а
  /// рядом — откуда взялись данные по каждой стороне (`quality[]`).
  List<Widget> _estimatedCards(FlightDetail detail) {
    final progress = detail.progressPercent;
    final departure = detail.departure;
    final arrival = detail.arrival;
    return [
      FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FCardTitle(
              ft('card_estimated', 'Təxmini gediş'),
              trailing: FBadge(
                _qualityLabel(departure.quality).toUpperCase(),
                fontSize: 9,
                tone: _qualityTone(departure.quality),
              ),
            ),
            FRow(
              ft('card_progress', 'Yol keçilib'),
              value: progress == null ? null : '$progress%',
            ),
            FRow(
              ft('card_departure_pair', 'Gediş (cədvəl → dəqiq)'),
              value: _timePair(departure),
            ),
            FRow(
              ft('card_arrival_pair', 'Gəliş (cədvəl → dəqiq)'),
              value: _timePair(arrival),
            ),
            FRow(
              ft('card_landing_confirmed', 'Enmə təsdiqi'),
              valueWidget: FBadge(
                detail.summary.arrivalConfirmed
                    ? ft('card_confirmed', 'TƏSDİQLƏNDİ')
                    : ft('card_awaiting', 'GÖZLƏNİLİR'),
                tone: detail.summary.arrivalConfirmed ? FTone.ok : FTone.mute,
                fontSize: 9,
              ),
              last: true,
            ),
          ],
        ),
      ),
      FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FCardTitle(ft('card_source', 'Məlumatın mənbəyi')),
            FRow(
              ft('card_departure_side', 'Gediş tərəfi ({code})', {
                'code': _code(departure, detail.summary.departureCode),
              }),
              valueWidget: FBadge(
                _qualityLabel(departure.quality).toUpperCase(),
                fontSize: 9,
                tone: _qualityTone(departure.quality),
              ),
            ),
            FRow(
              ft('card_arrival_side', 'Gəliş tərəfi ({code})', {
                'code': _code(arrival, detail.summary.arrivalCode),
              }),
              valueWidget: FBadge(
                _qualityLabel(arrival.quality).toUpperCase(),
                fontSize: 9,
                tone: _qualityTone(arrival.quality),
              ),
              last: true,
            ),
            const SizedBox(height: 11),
            FSecondaryButton(
              label: ft('card_feeds', 'Data mənbələrinə bax'),
              icon: PhosphorIconsBold.pulse,
              onTap: () => _openFeeds(detail),
            ),
          ],
        ),
      ),
      FInfoNote(
        ft(
          'card_no_position',
          'Bu uçuş üçün təyyarə mövqeyi gəlmir. Xəritədəki nişan cədvəl '
              'vaxtına görə hesablanıb.',
        ),
      ),
    ];
  }

  /// Привязанное объявление. Текст говорит только то, что известно: сколько
  /// объявлений привязано на этом телефоне. Про то, что покупателю ушло
  /// уведомление, здесь не написано — это знает сервер, не приложение.
  Widget _linkedCard(FlightDetail detail) {
    final link = _linked.first;
    return FBrandNoteCard(
      icon: PhosphorIconsFill.package,
      title: _linked.length == 1
          ? ft('card_linked_one', 'Bu uçuşa bağlı elanın var')
          : ft('card_linked_many', 'Bu uçuşa bağlı {n} elanın var', {
              'n': '${_linked.length}',
            }),
      message: ft(
        'card_linked_message',
        'Uçuş vaxtı dəyişəndə elanın səfər məlumatını yenilə.',
      ),
      onTap: () => _openListing(link),
    );
  }

  /// Самолёт и полётный план. План приходит редко: нет `route` — нет строки.
  Widget _linksCard(FlightDetail detail) {
    final reg = detail.aircraft?.reg;
    final plan = detail.flightPlan;
    final rows = <Widget>[
      if (reg != null)
        FListRow(
          flat: true,
          icon: PhosphorIconsRegular.airplane,
          title: reg,
          subtitle: ft('card_aircraft_card', 'Təyyarə kartına keç'),
          // Код авиакомпании есть только здесь: в ответе по борту приходит
          // имя компании, но не код, а парк просят именно по коду.
          onTap: () => FlightNav.push(
            context,
            AircraftPassportScreen(
              registration: reg,
              airlineCode: detail.summary.airline?.iata ??
                  detail.summary.airline?.icao,
              airlineName: detail.summary.airline?.name,
            ),
          ),
        ),
      if (plan != null && plan.hasRoute)
        FListRow(
          flat: true,
          icon: PhosphorIconsRegular.listBullets,
          title: ft('card_plan', 'Uçuş planı'),
          subtitle: [
            plan.rules,
            ft('card_plan_route', 'marşrut'),
            ft('card_plan_level', 'eşelon'),
          ].whereType<String>().join(' · '),
          onTap: () => FlightNav.push(
            context,
            FlightPlanScreen(detail: detail),
          ),
        ),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return FGroupCard(children: rows);
  }

  /// «Bu uçuş haqqında» — пять строк в самом низу, как в прототипе.
  Widget _about(FlightDetail detail) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FSectionTitle(ft('card_section_about', 'Bu uçuş haqqında')),
          FListRow(
            icon: PhosphorIconsRegular.clock,
            title: ft('card_details', 'Gediş və gəliş detalları'),
            subtitle: ft('card_details_sub', '4 vaxt · terminal · qapı · lent'),
            onTap: () => FlightNav.push(
              context,
              FlightDetailsScreen(detail: detail),
            ),
          ),
          const SizedBox(height: 8),
          FListRow(
            icon: PhosphorIconsRegular.identificationBadge,
            title: ft('card_passport', 'Uçuş pasportu'),
            subtitle: ft(
              'card_passport_sub',
              'çağırış kodu · kodşerinq · yük',
            ),
            onTap: () => FlightNav.push(
              context,
              FlightPassportScreen(detail: detail),
            ),
          ),
          const SizedBox(height: 8),
          FListRow(
            icon: PhosphorIconsRegular.calendarDots,
            title: ft('card_calendar_row', 'Təqvim'),
            subtitle: ft(
              'card_calendar_sub',
              'bu nömrə hansı tarixlərdə uçur',
            ),
            onTap: _openCalendar,
          ),
          const SizedBox(height: 8),
          FListRow(
            icon: PhosphorIconsRegular.chartLine,
            title: ft('card_history', 'Son uçuşlar'),
            subtitle: ft('card_history_sub', '14 günlük tarixçə'),
            onTap: () => FlightNav.push(
              context,
              FlightHistoryScreen(
                number: detail.number,
                displayNumber: detail.displayNumber,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FListRow(
            icon: PhosphorIconsRegular.timer,
            title: ft('card_delays', 'Gecikmə statistikası'),
            subtitle: ft('card_delays_sub', 'median · persentil · qruplar'),
            onTap: () => FlightNav.push(
              context,
              FlightDelaysScreen(
                number: detail.number,
                displayNumber: detail.displayNumber,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Карта рисуется только когда известны координаты обоих концов: иначе
  /// дугу строить не из чего.
  List<Widget>? _map(FlightDetail detail) {
    final from = detail.departure.airport;
    final to = detail.arrival.airport;
    if (from == null || to == null) return null;
    if (!from.hasPosition || !to.hasPosition) return null;

    final arc = fGreatCircle(
      LatLng(from.lat!, from.lon!),
      LatLng(to.lat!, to.lon!),
    );
    final done = fRouteDone(arc, detail.progressPercent?.toDouble());
    final location = detail.location;
    final live = location != null && location.hasPosition;
    final plane = live
        ? LatLng(location.lat!, location.lon!)
        : (done.isEmpty ? null : done.last);

    return [
      FMapFrame(
        map: FFlightMap(
          routes: [FMapRoute(all: arc, done: done)],
          airports: [
            FMapAirport(
              point: LatLng(from.lat!, from.lon!),
              code: from.code,
              onTap: () => _openAirport(detail.departure),
            ),
            FMapAirport(
              point: LatLng(to.lat!, to.lon!),
              code: to.code,
              onTap: () => _openAirport(detail.arrival),
            ),
          ],
          planes: [
            if (plane != null && !detail.summary.isCanceled)
              FMapPlane(
                point: plane,
                track: location?.trueTrack,
                label: detail.displayNumber,
                live: live,
              ),
          ],
        ),
        corners: [
          Positioned(
            left: 10,
            bottom: 9,
            child: live
                ? FBadge(
                    ft('card_map_live', 'Canlı'),
                    tone: FTone.ok,
                    ping: true,
                  )
                : FBadge(
                    ft('card_map_estimated', 'Təxmini yerləşmə'),
                    icon: PhosphorIconsFill.path,
                  ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: FMapChip(
              label: ft('card_map_full', 'Tam ekran'),
              icon: PhosphorIconsBold.arrowsOut,
              // На радаре этот рейс сразу в центре — иначе человек ищет
              // свою метку среди остальных подписок.
              onTap: () => FlightNav.push(
                context,
                MapRadarScreen(focus: detail.summary.key),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  // ───────────────────────────── Значения ─────────────────────────────

  String _code(FlightEndpoint endpoint, String? fallback) =>
      endpoint.airport?.code ?? fallback ?? '—';

  String? _city(FlightEndpoint endpoint) {
    final airport = endpoint.airport;
    if (airport == null) return null;
    final parts = [airport.municipality, airport.name]
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// Самое достоверное время конца рейса: полоса → уточнение → прогноз →
  /// расписание (§7.2). Строка местного времени показывается как есть.
  String? _best(FlightEndpoint endpoint) => endpoint.best?.local?.clock;

  /// Прежнее время — только когда показано не расписание и время другое.
  String? _was(FlightEndpoint endpoint) {
    final kind = endpoint.bestKind;
    if (kind == null || kind == FlightTimeKind.scheduled) return null;
    final scheduled = endpoint.scheduled?.local?.clock;
    if (scheduled == null) return null;
    return scheduled == endpoint.best?.local?.clock ? null : scheduled;
  }

  String? _endpointMeta(FlightEndpoint endpoint) {
    final parts = <String>[
      if (endpoint.terminal != null)
        ft('card_terminal_short', 'Terminal {t}', {'t': endpoint.terminal!}),
      if (endpoint.gate != null)
        ft('card_gate_short', 'Qapı {g}', {'g': endpoint.gate!}),
      if (endpoint.baggageBelt != null)
        ft('card_belt_short', 'Lent {b}', {'b': endpoint.baggageBelt!}),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  String? _aircraftBadgeText(FlightDetail detail) {
    final airline = detail.summary.airline;
    final model = detail.aircraft?.model ?? detail.summary.aircraftModel;
    final parts = [airline?.iata ?? airline?.name, model]
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// `09:15 → 09:52` или `09:15 → dəqiqləşmə yoxdur`.
  String _timePair(FlightEndpoint endpoint) {
    final scheduled = endpoint.scheduled?.local?.clock ?? '—';
    final exact = endpoint.runwayTime?.local?.clock ??
        endpoint.revised?.local?.clock ??
        endpoint.predicted?.local?.clock;
    return '$scheduled → ${exact ?? ft('card_no_revision', 'dəqiqləşmə yoxdur')}';
  }

  String? _vsi(int? fpm) {
    if (fpm == null) return null;
    final sign = fpm > 0 ? '+' : (fpm < 0 ? '−' : '');
    return '$sign${fpm.abs()} ${ft('unit_fpm', 'ft/dəq')}';
  }

  /// `quality[]` своя у каждой стороны — общей плашки на рейс не бывает (§9).
  String _qualityLabel(List<String> quality) {
    if (quality.contains(FlightQuality.live)) {
      return ft('quality_live', 'Canlı');
    }
    if (quality.contains(FlightQuality.approximate)) {
      return ft('quality_approximate', 'Təxmini');
    }
    if (quality.contains(FlightQuality.basic)) {
      return ft('quality_basic', 'Cədvəl üzrə');
    }
    return ft('quality_unknown', 'Bilinmir');
  }

  FTone _qualityTone(List<String> quality) {
    if (quality.contains(FlightQuality.live)) return FTone.ok;
    if (quality.contains(FlightQuality.approximate)) return FTone.info;
    return FTone.mute;
  }

  /// У `/detail` нет `meta`, поэтому время данных — `refreshed_at`.
  String? _staleLine(FlightDetail detail) {
    final at = detail.dataTimestamp;
    if (at == null) return null;
    return ft('stale_line', 'Məlumat {time} vəziyyətinə görədir', {
      'time': fClock(at),
    });
  }

  int? _minutesLeft(FlightDetail detail) {
    final expected = detail.arrival.best?.utc ?? detail.summary.arrivalAt;
    if (expected == null) return null;
    final left = expected.difference(DateTime.now().toUtc()).inMinutes;
    return left <= 0 ? null : left;
  }

  int? _minutesToDeparture(FlightDetail detail) {
    final expected = detail.departure.revised?.utc ??
        detail.departure.scheduled?.utc ??
        detail.summary.departureAt;
    if (expected == null) return null;
    return expected.difference(DateTime.now().toUtc()).inMinutes;
  }

  /// Объявление можно создать только на будущий вылет: сервер проверяет
  /// `flight_date` как `after_or_equal:today`, а время — правилом
  /// `DepartureNotPassed`. Поэтому у улетевшего рейса этой кнопки нет, хотя
  /// в прототипе она нарисована и на живом рейсе.
  bool _canAttachListing(FlightDetail detail) {
    if (detail.summary.isCanceled) return false;
    final minutes = _minutesToDeparture(detail);
    return minutes != null && minutes > 0;
  }

  String? _departureNotice(FlightDetail detail) {
    final time = detail.departure.revised?.local?.clock ??
        detail.departure.scheduled?.local?.clock;
    final gate = detail.departure.gate;
    if (detail.status == FlightStatus.boarding ||
        detail.status == FlightStatus.checkIn) {
      if (gate != null && time != null) {
        return ft(
          'card_boarding_note_gate',
          'Qapı {gate}-yə get. Gediş {time}-da planlaşdırılıb.',
          {'gate': gate, 'time': time},
        );
      }
      if (time != null) {
        return ft('card_boarding_note', 'Gediş {time}-da planlaşdırılıb.', {
          'time': time,
        });
      }
      return null;
    }
    if (detail.status == FlightStatus.gateClosed) {
      return ft(
        'card_gate_closed_note',
        'Minik bitdi. Qapı bağlandı.',
      );
    }
    return null;
  }

  // ─────────────────────────────── Действия ───────────────────────────

  Future<void> _toggleSaved(FlightDetail detail) async {
    final from = _code(detail.departure, detail.summary.departureCode);
    final to = _code(detail.arrival, detail.summary.arrivalCode);
    final saved = await _local.toggleFlight(
      FlightSaved(
        number: detail.number,
        displayNumber: detail.displayNumber,
        flightDate: widget.flightKey.flightDate,
        departureCode: widget.flightKey.departureCode ??
            detail.summary.departureCode,
        route: '$from → $to',
      ),
    );
    if (!mounted) return;
    setState(() => _saved = saved);
    fToast(
      context,
      saved
          ? ft('card_saved', 'Seçilmişlərə əlavə olundu')
          : ft('card_unsaved', 'Seçilmişlərdən çıxarıldı'),
    );
  }

  Future<void> _share(FlightDetail detail) async {
    final from = _code(detail.departure, detail.summary.departureCode);
    final to = _code(detail.arrival, detail.summary.arrivalCode);
    final time = _best(detail.departure);
    final parts = <String>[
      detail.displayNumber,
      '$from → $to',
      fDateStringLong(detail.summary.flightDate),
      if (time != null) time,
    ];
    await Share.share(parts.join(' · '));
  }

  void _openStatuses() =>
      FlightNav.push(context, const FlightStatusesScreen());

  void _openWatch() => FlightNav.push(
        context,
        WatchNewScreen(flightKey: widget.flightKey),
      );

  void _openCalendar() {
    final detail = _detail;
    FlightNav.push(
      context,
      FlightCalendarScreen(
        number: detail?.number ?? widget.flightKey.number,
        displayNumber: detail?.displayNumber ?? widget.flightKey.number,
        selected: widget.flightKey.flightDate,
      ),
    );
  }

  void _openDate(FlightDetail detail, String date) => FlightNav.push(
        context,
        FlightInstancesScreen(
          number: detail.number,
          displayNumber: detail.displayNumber,
          date: date,
        ),
      );

  void _openAirport(FlightEndpoint endpoint) {
    final code = endpoint.airport?.code;
    if (code == null) return;
    FlightNav.push(context, AirportCardScreen(code: code));
  }

  void _openFeeds(FlightDetail detail) {
    final code = detail.departure.airport?.code ??
        detail.summary.departureCode;
    if (code == null) return;
    FlightNav.push(context, AirportFeedsScreen(code: code));
  }

  void _openListing(FlightLink link) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ListingDetailsScreen(listingId: link.listingId),
        ),
      );

  Future<void> _openAttach(FlightDetail detail) async {
    final from = detail.departure.airport;
    final to = detail.arrival.airport;
    if (from == null || to == null) return;
    await FlightNav.push(
      context,
      LinkAttachScreen(
        flight: detail.summary,
        from: AirportSummary.fromRef(from),
        to: AirportSummary.fromRef(to),
      ),
    );
    if (!mounted) return;
    await _links.load();
    setState(() => _linked = _links.forFlight(widget.flightKey));
  }
}
