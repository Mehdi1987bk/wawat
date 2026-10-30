import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../data/cache/cache_manager.dart';
import '../../../../data/network/request/create_listing_request.dart';
import '../../../../data/network/response/city.dart';
import '../../../../data/network/response/listing_response.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../main.dart';
import '../../../../presentation/resourses/theme_colors.dart';
import '../../../home/tabs/create_post/create_post_screen.dart';
import '../../../home/tabs/home_tab/widget/auth_modal_utils.dart';
import '../../../home/tabs/profile_tab/new_profile/profile_api.dart';
import '../../data/flight_error.dart';
import '../../data/flight_link_store.dart';
import '../../data/flight_repository.dart';
import '../../data/models/airport.dart';
import '../../data/models/flight.dart';
import '../../data/models/flight_enums.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_status_visual.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import 'link_listing_screen.dart';

/// `link/attach` — рейс привязывается к объявлению.
///
/// Два пути, как в прототипе:
///
/// * **Новое объявление.** Подписка оформляется здесь (ошибку видно сразу,
///   пока человек на этом экране), затем открывается обычный экран создания
///   объявления с уже заполненными маршрутом, датой, временем и номером.
///   Дальше идёт родной путь приложения — шаг веса и цены, затем предложение
///   продвижения. Связка запоминается в момент создания.
/// * **Существующее объявление.** Поля рейса дописываются в объявление
///   (`PATCH /listings/{id}`), оформляется подписка, и экран переходит к
///   карточке объявления — ровно как в прототипе.
///
/// Чего сервер пока не умеет (§15): кода аэропорта вылета объявление не
/// принимает, а `listing_id` подписки — внутреннее число, которого у
/// приложения нет. Поэтому код вылета и ULID объявления ложатся в
/// [FlightLinkStore] на телефоне, и подписка уходит без `listing_id`.
class LinkAttachScreen extends StatefulWidget {
  const LinkAttachScreen({
    super.key,
    required this.flight,
    required this.from,
    required this.to,
  });

  final FlightSummary flight;
  final AirportSummary from;
  final AirportSummary to;

  @override
  State<LinkAttachScreen> createState() => _LinkAttachScreenState();
}

class _LinkAttachScreenState extends State<LinkAttachScreen> {
  final _repo = FlightRepository.instance;
  final _store = FlightLinkStore.instance;
  final _profile = WawatProfileApi();

  bool _newListing = true;
  bool _signedIn = false;
  bool _loadingListings = false;
  bool _busy = false;

  List<Listing> _active = const [];
  int? _activeCount;
  Listing? _picked;
  FlightError? _error;

  @override
  void initState() {
    super.initState();
    _store.load();
    _init();
  }

  Future<void> _init() async {
    final token = await sl.get<CacheManager>().getToken();
    if (!mounted) return;
    final signedIn = token != null && token.isNotEmpty;
    setState(() => _signedIn = signedIn);
    if (signedIn) _loadActive();
  }

  Future<void> _loadActive() async {
    setState(() => _loadingListings = true);
    try {
      final result = await _profile.myListingsFiltered(filter: 'active');
      if (!mounted) return;
      final matched = result.filters.where((f) => f.key == 'active');
      setState(() {
        _active = result.page.data;
        // Счётчик из `meta.filters`, а не из длины страницы: страница первая.
        _activeCount =
            matched.isEmpty ? result.page.data.length : matched.first.count;
        _loadingListings = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingListings = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flight = widget.flight;
    final visual = fStatusVisual(flight.status);
    final live = flight.statusGroup == FlightStatusGroup.inAir;
    return FlightScaffold(
      title: ft('link_attach_title', 'Elana bağla'),
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FBadge(
              (flight.statusLabel ?? visual.label).toUpperCase(),
              ping: live,
              background: live
                  ? const Color(0x3D10B981)
                  : Colors.white.withValues(alpha: .16),
              foreground: live ? const Color(0xFFA7F3D0) : Colors.white,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.from.code,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Icon(
                    PhosphorIconsFill.arrowRight,
                    size: 16,
                    color: FT.onHero(.55),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.to.code,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    flight.displayNumber,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: FT.onHero(.75),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              _heroLine(),
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
        FlightBody(gap: 11, children: _content()),
      ],
      bottom: _signedIn
          ? FPrimaryButton(
              label: ft('link_attach_action', 'Bağla və davam et'),
              icon: PhosphorIconsBold.link,
              loading: _busy,
              onTap: _canSubmit ? _submit : null,
            )
          : null,
    );
  }

  String _heroLine() {
    final flight = widget.flight;
    final date = fDateStringShort(flight.flightDate);
    final from = flight.departureLocal?.clock;
    final to = flight.arrivalLocal?.clock;
    if (from == null || to == null) return date;
    return '$date · $from → $to';
  }

  bool get _canSubmit =>
      !_busy && (_newListing || (!_newListing && _picked != null));

  List<Widget> _content() {
    final d = fDark(context);
    if (!_signedIn) {
      return [
        FSignInRequired(
          onSignIn: _signIn,
          title: ft('link_attach_signin', 'Elan üçün giriş lazımdır'),
          message: ft(
            'link_attach_signin_message',
            'Uçuşu elana bağlamaq və bildiriş almaq üçün hesaba gir.',
          ),
        ),
      ];
    }
    return [
      if (_error != null)
        FErrorView(error: _error!, onRetry: _submit, onSignIn: _signIn),
      FPickRow(
        selected: _newListing,
        onTap: () => setState(() {
          _newListing = true;
          _picked = null;
        }),
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        leading: _modeIcon(PhosphorIconsFill.plusCircle, _newListing),
        child: _modeText(
          title: ft('link_attach_new', 'Yeni elan yarat'),
          subtitle: ft('link_attach_new_hint', 'Səfər məlumatı özü dolacaq'),
        ),
      ),
      FPickRow(
        selected: !_newListing,
        onTap: () => setState(() => _newListing = false),
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        leading: _modeIcon(PhosphorIconsFill.package, !_newListing),
        child: _modeText(
          title: ft('link_attach_existing', 'Mövcud elana bağla'),
          subtitle: _activeCount == null
              ? ft('link_attach_existing_loading', 'Elanlar yüklənir…')
              : ft('link_attach_existing_hint', '{n} aktiv elanın var', {
                  'n': '${_activeCount!}',
                }),
        ),
      ),
      if (!_newListing) ..._listingPicker(),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: FCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FCardTitle(ft('link_attach_copy', 'Elana nə köçürüləcək')),
              const SizedBox(height: 3),
              for (final line in _copyLines()) ...[
                const SizedBox(height: 8),
                FCheckLine(line),
              ],
              Container(
                margin: const EdgeInsets.only(top: 11),
                padding: const EdgeInsets.only(top: 11),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: cLine(d))),
                ),
                child: Text(
                  ft(
                    'link_attach_rest',
                    'Çəki, qiymət və qeydləri özün yazacaqsan.',
                  ),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: cText3(d),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      FBrandNoteCard(
        icon: PhosphorIconsFill.bellRinging,
        title: ft('link_attach_watch', 'İzləmə sənin üçün qoşulur'),
        message: ft(
          'link_attach_watch_message',
          'Uçuş gecikəndə, qapı dəyişəndə və ya təyyarə enəndə sənə bildiriş '
              'gedir. Qarşı tərəf uçuşu özü izləməlidir.',
        ),
      ),
    ];
  }

  Widget _modeIcon(IconData icon, bool selected) {
    final d = fDark(context);
    return Container(
      height: 38,
      width: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? cCard(d) : FT.chip(d),
        borderRadius: FT.rIcon,
      ),
      child: Icon(
        icon,
        size: 17,
        color: selected ? FT.brand600(d) : cText2(d),
      ),
    );
  }

  Widget _modeText({required String title, required String subtitle}) {
    final d = fDark(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: cText(d),
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: cText3(d),
          ),
        ),
      ],
    );
  }

  /// Выбор объявления — этого экрана в прототипе нет: там кнопка «Mövcud
  /// elana bağla» ведёт дальше сразу. Но привязать рейс можно только к
  /// конкретному объявлению, поэтому список открывается здесь же.
  List<Widget> _listingPicker() {
    final d = fDark(context);
    if (_loadingListings) return const [FListSkeleton(rows: 2)];
    if (_active.isEmpty) {
      return [
        FCalmEmpty(
          icon: PhosphorIconsFill.package,
          title: ft('link_attach_no_active', 'Aktiv elanın yoxdur'),
          message: ft(
            'link_attach_no_active_message',
            'Yeni elan yarat — səfər məlumatı özü dolacaq.',
          ),
        ),
      ];
    }
    return [
      Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 2),
        child: Text(
          ft('link_attach_choose', 'Hansı elana bağlanacaq'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: cText3(d),
          ),
        ),
      ),
      for (final listing in _active)
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: FPickRow(
            selected: _picked?.id == listing.id,
            onTap: () => setState(() => _picked = listing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _listingTitle(listing),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: cText(d),
                  ),
                ),
                Text(
                  _listingHint(listing),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: cText3(d),
                  ),
                ),
              ],
            ),
          ),
        ),
    ];
  }

  String _listingTitle(Listing listing) {
    final from = listing.cityFrom;
    final to = listing.cityTo;
    if (from != null && to != null) return '$from → $to';
    final description = listing.description?.trim();
    if (description != null && description.isNotEmpty) return description;
    return '#${listing.id}';
  }

  String _listingHint(Listing listing) {
    final parts = <String>[];
    final date = fDateStringShort(listing.flightDate);
    if (date != '—') parts.add(date);
    if (listing.flightNumber != null && listing.flightNumber!.isNotEmpty) {
      parts.add(listing.flightNumber!);
    }
    if (listing.maxWeightKg != null) {
      parts.add('${fNum(listing.maxWeightKg!)} ${ft('unit_kg', 'kq')}');
    }
    return parts.isEmpty
        ? ft('link_attach_no_flight', 'Uçuş göstərilməyib')
        : parts.join(' · ');
  }

  List<String> _copyLines() {
    final flight = widget.flight;
    final from = widget.from;
    final to = widget.to;
    final departure = flight.departureLocal?.clock;
    final arrival = flight.arrivalLocal?.clock;
    return [
      ft('link_copy_route', 'Marşrut: {from} → {to}', {
        'from': from.city ?? from.code,
        'to': to.city ?? to.code,
      }),
      if (from.name != null)
        ft('link_copy_airport', 'Gediş limanı: {code} · {name}', {
          'code': from.code,
          'name': from.name!,
        })
      else
        ft('link_copy_airport_code', 'Gediş limanı: {code}', {
          'code': from.code,
        }),
      ft('link_copy_date', 'Tarix: {date}', {
        'date': fDateStringLong(flight.flightDate),
      }),
      if (departure != null)
        ft('link_copy_departure', 'Gediş saatı: {time}', {'time': departure}),
      if (arrival != null)
        ft('link_copy_arrival', 'Çatma saatı: {time}', {'time': arrival}),
      ft('link_copy_number', 'Uçuş nömrəsi: {number}', {
        'number': flight.displayNumber,
      }),
    ];
  }

  void _signIn() => AuthModalUtils.showAuthRequiredModal(
        context,
        onLoginSuccess: _init,
        onRegisterSuccess: _init,
      );

  Future<void> _submit() async {
    final key = widget.flight.key;
    if (key == null || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // Подписка оформляется первой: её отказ видно здесь, а не после того,
      // как объявление уже создано. `listing_id` не передаётся — он ждёт
      // внутреннее число, которого у приложения нет (§15).
      await _repo.watch(key, events: WatchEvent.defaults);
      if (!mounted) return;
      if (_newListing) {
        await _createListing(key);
      } else {
        await _attachExisting(key);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = FlightError.from(e);
        _busy = false;
      });
      return;
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _createListing(FlightKey key) async {
    final flight = widget.flight;
    final cities = await _resolveCities();
    if (!mounted) return;
    final prefill = TripFlightPrefill(
      fromCity: cities.$1,
      toCity: cities.$2,
      flightDate: DateTime.tryParse(key.flightDate),
      flightTime: _timeOf(flight.departureLocal?.clock),
      flightNumber: _compactNumber(flight.number),
      onCreated: (listing) {
        _store.save(
          FlightLink(
            listingId: listing.id,
            number: key.number,
            flightDate: key.flightDate,
            departureCode: key.departureCode ?? widget.from.code,
            title: _listingTitle(listing),
            linkedAt: DateTime.now(),
          ),
        );
      },
    );
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(
          initialType: 'trip',
          flightPrefill: prefill,
        ),
      ),
    );
  }

  Future<void> _attachExisting(FlightKey key) async {
    final listing = _picked;
    if (listing == null) return;
    final flight = widget.flight;
    final request = CreateListingRequest(
      type: listing.type,
      cityFromId: listing.cityFromId ?? 0,
      cityToId: listing.cityToId ?? 0,
      packageTypeCodes: listing.packageTypeCodes,
      description: listing.description,
      allowPriceNegotiation: listing.allowPriceNegotiation,
      flightDate: key.flightDate,
      flightTime: flight.departureLocal?.clock,
      flightNumber: _compactNumber(flight.number),
      maxWeightKg: listing.maxWeightKg,
      pricePerKg: listing.pricePerKg,
    );
    final response = await sl.get<AuthRepository>().updateListing(
          listing.id,
          request,
          '${DateTime.now().microsecondsSinceEpoch}',
        );
    await _store.save(
      FlightLink(
        listingId: listing.id,
        number: key.number,
        flightDate: key.flightDate,
        departureCode: key.departureCode ?? widget.from.code,
        title: _listingTitle(response.data),
        linkedAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    await FlightNav.replace(
      context,
      LinkListingScreen(listing: response.data),
    );
  }

  /// Город объявления и город аэропорта — разные справочники. Совпадение
  /// ищется по названию; не нашлось — поле останется пустым, человек выберет
  /// город сам.
  Future<(City?, City?)> _resolveCities() async {
    final repository = sl.get<AuthRepository>();
    Future<City?> find(String? name) async {
      if (name == null || name.trim().isEmpty) return null;
      try {
        final response = await repository.getListingCities(name, limit: 20);
        final needle = name.trim().toLowerCase();
        for (final city in response.data) {
          if (city.name.trim().toLowerCase() == needle) return city;
        }
        return response.data.isEmpty ? null : response.data.first;
      } catch (_) {
        return null;
      }
    }

    final from = await find(widget.from.city ?? widget.from.name);
    final to = await find(widget.to.city ?? widget.to.name);
    return (from, to);
  }

  /// `TK 333` → `TK333`: у объявления поле не длиннее 8 символов.
  String _compactNumber(String number) {
    final compact = number.replaceAll(' ', '').toUpperCase();
    return compact.length > 8 ? compact.substring(0, 8) : compact;
  }

  TimeOfDay? _timeOf(String? clock) {
    if (clock == null) return null;
    final parts = clock.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }
}
