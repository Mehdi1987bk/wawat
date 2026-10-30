import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../data/network/response/listing_response.dart';
import '../../../../data/network/response/notification_response.dart';
import '../../../../presentation/resourses/theme_colors.dart';
import '../../../home/tabs/listings/details/listing_details_screen.dart';
import '../../data/flight_error.dart';
import '../../data/flight_link_store.dart';
import '../../data/flight_notifications.dart';
import '../../data/flight_repository.dart';
import '../../data/models/flight.dart';
import '../../data/models/flight_enums.dart';
import '../../data/models/flight_watch.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_status_visual.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import '../flight/flight_card_screen.dart';

/// `link/listing` — объявление, к которому привязан рейс.
///
/// Экран показывает то, что про рейс и объявление известно на самом деле:
/// живую карточку рейса, поля объявления и историю уведомлений по этому
/// рейсу (§11 — цель у всех девяти типов одинаковая, поэтому лента
/// фильтруется по `target`).
///
/// Строки «Alıcı» в прототипе здесь нет: у объявления покупателя не бывает —
/// он появляется в сделке. Вместо выдуманного имени стоит кнопка, которая
/// открывает объявление целиком, где сделки и переписка уже есть.
class LinkListingScreen extends StatefulWidget {
  const LinkListingScreen({super.key, required this.listing});

  final Listing listing;

  @override
  State<LinkListingScreen> createState() => _LinkListingScreenState();
}

class _LinkListingScreenState extends State<LinkListingScreen> {
  final _repo = FlightRepository.instance;
  final _store = FlightLinkStore.instance;

  FlightDetail? _detail;
  FlightWatch? _watch;
  List<NotificationItem> _events = const [];
  FlightError? _error;
  bool _loading = true;

  FlightKey? _key;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Тройка рейса собирается из объявления и локальной связки: кода аэропорта
  /// вылета объявление не отдаёт (§15, пробел 1), он лежит рядом.
  Future<FlightKey?> _resolveKey() async {
    await _store.load();
    final link = _store.forListing(widget.listing.id);
    if (link != null) return link.key;
    final number = widget.listing.flightNumber?.trim();
    final date = widget.listing.flightDate?.trim();
    if (number == null || number.isEmpty) return null;
    if (date == null || date.isEmpty) return null;
    return FlightKey(number: number, flightDate: date);
  }

  Future<void> _load({bool force = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final key = await _resolveKey();
    if (!mounted) return;
    _key = key;
    if (key == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final detail = await _repo.flightDetail(key, force: force);
      if (!mounted) return;
      final watches = await _repo
          .watches()
          .then<List<FlightWatch>>((v) => v.data ?? const [])
          .catchError((_) => const <FlightWatch>[]);
      final events = await FlightNotifications.forFlight(key, force: force)
          .catchError((_) => const <NotificationItem>[]);
      if (!mounted) return;
      setState(() {
        _detail = detail.data;
        _watch = watches.where((w) => w.key == key).isEmpty
            ? null
            : watches.firstWhere((w) => w.key == key);
        _events = events;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = FlightError.from(e);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final detail = _detail;
    final live = detail?.summary.statusGroup == FlightStatusGroup.inAir;
    return FlightScaffold(
      title: ft('link_listing_title', 'Elan'),
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (detail != null)
                  FBadge(
                    live
                        ? ft('link_listing_live', 'UÇUŞ HAVADADIR')
                        : (detail.statusLabel ??
                                fStatusVisual(detail.status).label)
                            .toUpperCase(),
                    ping: live,
                    background: live
                        ? const Color(0x3D10B981)
                        : Colors.white.withValues(alpha: .16),
                    foreground: live ? const Color(0xFFA7F3D0) : Colors.white,
                  ),
                if (detail != null && listing.statusLabel != null)
                  const SizedBox(width: 7),
                if (listing.statusLabel != null)
                  FBadge(
                    listing.statusLabel!,
                    background: Colors.white.withValues(alpha: .16),
                    foreground: Colors.white,
                  ),
              ],
            ),
            const SizedBox(height: 11),
            Text(
              _title(),
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                height: 1.25,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              _subtitle(),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: FT.onHero(.6),
              ),
            ),
          ],
        ),
      ),
      slivers: [
        FlightBody(gap: 12, children: _content()),
      ],
      bottom: FSecondaryButton(
        label: ft('link_listing_open', 'Elanı tam aç'),
        icon: PhosphorIconsBold.arrowSquareOut,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ListingDetailsScreen(listingId: widget.listing.id),
          ),
        ),
      ),
    );
  }

  String _title() {
    final description = widget.listing.description?.trim();
    if (description != null && description.isNotEmpty) {
      return description.length > 90
          ? '${description.substring(0, 90)}…'
          : description;
    }
    final from = widget.listing.cityFrom;
    final to = widget.listing.cityTo;
    if (from != null && to != null) {
      return ft('link_listing_route', '{from} → {to}', {
        'from': from,
        'to': to,
      });
    }
    return widget.listing.typeLabel ?? ft('link_listing_title', 'Elan');
  }

  String _subtitle() {
    final parts = <String>[];
    final weight = widget.listing.maxWeightKg;
    if (weight != null) {
      parts.add(ft('link_listing_upto', '{n} kq-a qədər', {
        'n': fNum(weight),
      }));
    }
    final date = fDateStringShort(widget.listing.flightDate);
    if (date != '—') parts.add(date);
    return parts.join(' · ');
  }

  List<Widget> _content() {
    if (_loading) return const [FCardSkeleton(rows: 3)];
    if (_error != null) {
      return [FErrorView(error: _error!, onRetry: () => _load(force: true))];
    }
    return [
      if (_key == null)
        FCalmEmpty(
          icon: PhosphorIconsFill.linkBreak,
          title: ft('link_listing_none', 'Uçuş bağlanmayıb'),
          message: ft(
            'link_listing_none_message',
            'Bu elanda uçuş məlumatı yoxdur. Radardan uçuş seçib bağlaya '
                'bilərsən.',
          ),
        )
      else if (_detail != null)
        _FlightCard(
          detail: _detail!,
          watched: _watch != null,
          onTap: () => FlightNav.push(
            context,
            FlightCardScreen(flightKey: _key!),
          ),
        ),
      _facts(),
      if (_events.isNotEmpty) _history(),
    ];
  }

  Widget _facts() {
    final listing = widget.listing;
    final owner = listing.owner;
    final name = owner?.fullName?.trim().isNotEmpty == true
        ? owner!.fullName!.trim()
        : owner?.username;
    final weight = listing.maxWeightKg;
    final reserved = listing.reservedKg ?? 0;
    return FCard(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          if (name != null)
            FRow(ft('link_listing_owner', 'Elan sahibi'), value: name),
          if (weight != null)
            FRow(
              ft('link_listing_weight', 'Çəki'),
              value: '${fNum(reserved)} / ${fNum(weight)} '
                  '${ft('unit_kg', 'kq')}',
            ),
          if (listing.pricePerKg != null)
            FRow(
              ft('link_listing_price', 'Qiymət'),
              value: '${fNum(listing.pricePerKg!)} ₼ / '
                  '${ft('unit_kg', 'kq')}',
            ),
          FRow(
            ft('link_listing_status', 'Status'),
            valueWidget: _statusBadge(),
            last: true,
          ),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    final detail = _detail;
    if (detail == null) {
      return FBadge(
        widget.listing.statusLabel ?? ft('unknown', 'Bilinmir'),
        fontSize: 10,
      );
    }
    final visual = fStatusVisual(detail.status);
    return FBadge(
      detail.statusLabel ?? visual.label,
      tone: visual.tone,
      fontSize: 10,
    );
  }

  Widget _history() {
    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FCardTitle(ft('link_listing_history', 'Bildiriş tarixçəsi')),
          const SizedBox(height: 5),
          for (var i = 0; i < _events.length; i++)
            _eventRow(_events[i], last: i == _events.length - 1),
        ],
      ),
    );
  }

  Widget _eventRow(NotificationItem item, {required bool last}) {
    final visual = fFlightNotifVisual(item.type);
    return FEventRow(
      icon: visual.icon,
      tone: visual.tone,
      title: item.title,
      subtitle: item.body,
      time: fAgo(DateTime.tryParse(item.createdAt)),
      last: last,
    );
  }
}

/// Карточка рейса на фирменном синем — та же геометрия, что в прототипе.
class _FlightCard extends StatelessWidget {
  const _FlightCard({
    required this.detail,
    required this.watched,
    required this.onTap,
  });

  final FlightDetail detail;
  final bool watched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final summary = detail.summary;
    final airline = summary.airline?.name;
    final from = detail.departure.best?.local?.clock ??
        summary.departureLocal?.clock;
    final to = detail.arrival.best?.local?.clock ?? summary.arrivalLocal?.clock;
    return Material(
      color: cCard(d),
      borderRadius: FT.rCard,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: FT.hero(d),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          airline == null
                              ? summary.displayNumber
                              : '${summary.displayNumber} · $airline',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (watched)
                        FBadge(
                          ft('link_listing_watched', 'İzlənir'),
                          fontSize: 10,
                          background: Colors.white.withValues(alpha: .22),
                          foreground: Colors.white,
                        ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      _End(
                        code: summary.departureCode ?? '—',
                        time: from,
                        align: CrossAxisAlignment.start,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FProgressBar(
                          percent: (detail.progressPercent ?? 0) / 100,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _End(
                        code: summary.arrivalCode ?? '—',
                        time: to,
                        align: CrossAxisAlignment.end,
                      ),
                    ],
                  ),
                  if (_tail() != null) ...[
                    const SizedBox(height: 9),
                    Text(
                      _tail()!,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: FT.onHero(.75),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsFill.checkCircle,
                    size: 15,
                    color: FT.ok(d),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      ft(
                        'link_listing_auto',
                        'Uçuş məlumatı avtomatik yenilənir',
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cText2(d),
                      ),
                    ),
                  ),
                  Icon(
                    PhosphorIconsBold.caretRight,
                    size: 15,
                    color: cText3(d),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// «51 dəqiqə sonra enir · yeni saat 11:05» — считается из того времени,
  /// которое сервер назвал самым достоверным, и подписывается, если оно
  /// отличается от расписания.
  String? _tail() {
    final arrival = detail.arrival;
    final best = arrival.best?.utc;
    final parts = <String>[];
    if (best != null && detail.summary.statusGroup == FlightStatusGroup.inAir) {
      final left = best.difference(DateTime.now().toUtc()).inMinutes;
      if (left > 0) {
        parts.add(ft('link_listing_lands_in', '{time} sonra enir', {
          'time': fMinutesShort(left),
        }));
      }
    }
    final revised = arrival.revised?.local?.clock;
    if (revised != null && revised != arrival.scheduled?.local?.clock) {
      parts.add(ft('link_listing_new_time', 'yeni saat {time}', {
        'time': revised,
      }));
    }
    return parts.isEmpty ? null : parts.join(' · ');
  }
}

class _End extends StatelessWidget {
  const _End({required this.code, required this.time, required this.align});

  final String code;
  final String? time;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          code,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            height: 1,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time ?? '—',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: FT.onHero(.65),
          ),
        ),
      ],
    );
  }
}
