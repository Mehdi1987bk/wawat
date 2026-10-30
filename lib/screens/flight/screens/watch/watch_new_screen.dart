import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../presentation/resourses/theme_colors.dart';
import '../../data/flight_auth.dart';
import '../../data/flight_error.dart';
import '../../data/flight_repository.dart';
import '../../data/models/flight.dart';
import '../../data/models/flight_enums.dart';
import '../../flight_routes.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_event_visual.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_status_visual.dart';
import '../../ui/flight_tokens.dart';
import '../../ui/flight_widgets.dart';
import 'watch_center_screen.dart';
import 'watch_route_new_screen.dart';
import 'watch_signin_screen.dart';

/// `watch/new` — взять рейс под слежение по номеру.
///
/// Порядок жёсткий (§9): номер и дата → `GET /flights/{number}/{date}`
/// (всегда массив) → выбор плеча → `POST /flights/{number}/{date}/watch`.
/// Без `departure_code` сервер возьмёт первое плечо дня, а это может быть не
/// тот рейс, который человек ждёт.
///
/// В адресе номер пишется слитно (`J278`), на экране — как у перевозчика
/// («J2 78»): это два разных вида одной строки.
///
/// `events` заменяет набор целиком; пустой массив сервер не принимает
/// (`min:1`) — чтобы не приходило ничего, подписку удаляют.
class WatchNewScreen extends StatefulWidget {
  const WatchNewScreen({super.key, this.flightKey, this.displayNumber});

  /// Рейс, с карточки которого пришли: номер, дата и плечо уже известны.
  final FlightKey? flightKey;
  final String? displayNumber;

  @override
  State<WatchNewScreen> createState() => _WatchNewScreenState();
}

class _WatchNewScreenState extends State<WatchNewScreen> {
  final _repo = FlightRepository.instance;
  final _number = TextEditingController();

  late DateTime _date;
  final Set<String> _events = {...WatchEvent.defaults};

  List<FlightSummary> _legs = const [];
  FlightSummary? _leg;
  String? _departureCode;

  FlightError? _error;
  bool _looking = false;
  bool _saving = false;
  bool _asked = false;
  bool _signedIn = true;

  @override
  void initState() {
    super.initState();
    final key = widget.flightKey;
    _number.text = widget.displayNumber ?? key?.number ?? '';
    _departureCode = key?.departureCode;
    final date = key == null ? null : DateTime.tryParse(key.flightDate);
    _date = date ?? DateTime.now();
    _checkAuth();
    if (_compactNumber.length >= 3) _lookup();
  }

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    final signedIn = await FlightAuth.signedIn();
    if (!mounted) return;
    setState(() => _signedIn = signedIn);
  }

  /// Номер для адреса: без пробелов и в верхнем регистре.
  String get _compactNumber =>
      _number.text.replaceAll(' ', '').trim().toUpperCase();

  FlightKey? get _key {
    final number = _compactNumber;
    if (number.length < 3) return null;
    return FlightKey(
      number: number,
      flightDate: fApiDate(_date),
      departureCode: _departureCode,
    );
  }

  /// Плечи этого номера на выбранную дату. Запрос делается по явному
  /// действию — ввод номера по буквам сюда не ходит (§4.4).
  Future<void> _lookup() async {
    final number = _compactNumber;
    if (number.length < 3) return;
    setState(() {
      _looking = true;
      _asked = true;
      _error = null;
    });
    try {
      final result = await _repo.flights(number, fApiDate(_date));
      if (!mounted) return;
      final legs = result.data ?? const <FlightSummary>[];
      setState(() {
        _legs = legs;
        _leg = _pickDefault(legs);
        _departureCode = _leg?.departureCode ?? _departureCode;
        _looking = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = FlightError.from(e);
        _legs = const [];
        _leg = null;
        _looking = false;
      });
    }
  }

  /// Пришло одно плечо — выбирать нечего. Пришло несколько: оставляем то, чьё
  /// плечо уже было известно, иначе ждём выбора человека.
  FlightSummary? _pickDefault(List<FlightSummary> legs) {
    if (legs.isEmpty) return null;
    if (legs.length == 1) return legs.first;
    final code = _departureCode?.toUpperCase();
    if (code == null) return null;
    for (final leg in legs) {
      if (leg.departureCode?.toUpperCase() == code) return leg;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FlightScaffold(
      title: ft('watch_new_title', 'Uçuş izləməyə al'),
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FSegment(
              onHero: true,
              index: 0,
              items: [
                ft('watch_by_number', 'Uçuş nömrəsi'),
                ft('watch_by_route', 'Marşrut'),
              ],
              onChanged: (value) {
                if (value == 0) return;
                FlightNav.replace(context, const WatchRouteNewScreen());
              },
            ),
            const SizedBox(height: 14),
            FHeroSearchField(
              controller: _number,
              icon: PhosphorIconsBold.airplaneTilt,
              hint: ft('watch_number_hint', 'J2 78'),
              uppercase: true,
              onSubmitted: (_) => _lookup(),
              onChanged: (_) => setState(() {
                _legs = const [];
                _leg = null;
              }),
            ),
            const SizedBox(height: 10),
            FEqualRow(
              children: [
                Expanded(
                  flex: 27,
                  child: FHeroPickField(
                    label: ft('watch_date', 'Tarix'),
                    value: fDateShort(_date),
                    hint: fWeekday(_date),
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 20,
                  child: FHeroPickField(
                    label: ft('watch_leg', 'Gediş'),
                    value: _leg?.departureCode ?? _departureCode ?? '—',
                    hint: _legHint,
                    onTap: _legs.length > 1 ? _pickLeg : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ft(
                'watch_leg_note',
                'Eyni nömrə bir gündə bir neçə dəfə uça bilər — hansı ayağı '
                    'izlədiyini gediş limanı təyin edir.',
              ),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.45,
                color: FT.onHero(.55),
              ),
            ),
          ],
        ),
      ),
      slivers: [
        FlightBody(children: _body()),
      ],
    );
  }

  String? get _legHint {
    if (_looking) return ft('watch_leg_looking', 'yoxlanılır…');
    final leg = _leg;
    if (leg != null) return leg.departureLocal?.clock;
    if (_legs.length > 1) {
      return ft('watch_leg_pick', '{n} ayaq — seç', {'n': '${_legs.length}'});
    }
    return null;
  }

  List<Widget> _body() {
    return [
      if (_error != null)
        FErrorView(
          error: _error!,
          onRetry: _lookup,
          onSignIn: () => FlightAuth.present(context, onDone: _checkAuth),
          notFoundTitle: ft('watch_not_found', 'Bu uçuş tapılmadı'),
          notFoundMessage: ft(
            'watch_not_found_message',
            'Nömrəni və tarixi yoxla. Hansı günlər uçduğunu təqvimdən görə '
                'bilərsən.',
          ),
        ),
      if (_error == null && _legs.isEmpty && !_looking && _asked)
        FCalmEmpty(
          icon: PhosphorIconsFill.calendarX,
          title: ft('watch_no_flight', 'Bu tarixdə uçuş yoxdur'),
          message: ft(
            'watch_no_flight_message',
            'Bu nömrə seçilmiş gündə uçmur. Başqa tarix seç.',
          ),
        ),
      FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FCardTitle(ft('watch_events_title', 'Nə baş verəndə xəbər gəlsin?')),
            for (var i = 0; i < WatchEvent.all.length; i++)
              _eventRow(WatchEvent.all[i], last: i == WatchEvent.all.length - 1),
          ],
        ),
      ),
      FPrimaryButton(
        label: ft('watch_save', 'İzləməyə al'),
        icon: PhosphorIconsBold.check,
        loading: _saving,
        onTap: _key == null ? null : _save,
      ),
      if (!_signedIn)
        FGhostButton(
          label: ft('watch_signin_hint', 'Hesaba daxil olmamısan? Daxil ol'),
          onTap: () => FlightNav.push(
            context,
            WatchSignInScreen(onSignedIn: _checkAuth),
          ),
        ),
    ];
  }

  Widget _eventRow(String event, {required bool last}) {
    final visual = fWatchEventVisual(event);
    return FToggleRow(
      icon: visual.icon,
      title: visual.title,
      subtitle: visual.hint,
      value: _events.contains(event),
      last: last,
      onChanged: (value) => setState(() {
        if (value) {
          _events.add(event);
        } else {
          _events.remove(event);
        }
      }),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: now.subtract(const Duration(days: 2)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _date = picked;
      _legs = const [];
      _leg = null;
    });
    _lookup();
  }

  Future<void> _pickLeg() async {
    final picked = await showModalBottomSheet<FlightSummary>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final d = fDark(sheetContext);
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          decoration: BoxDecoration(
            color: cScreen(d),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ft('watch_leg_sheet', 'Hansı ayağı izləyirsən?'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cText(d),
                  ),
                ),
                const SizedBox(height: 12),
                for (final leg in _legs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FFlightRow(
                      number: leg.displayNumber,
                      statusLabel:
                          leg.statusLabel ?? fStatusVisual(leg.status).label,
                      statusTone: fStatusVisual(leg.status).tone,
                      route:
                          '${leg.departureCode ?? '—'} → ${leg.arrivalCode ?? '—'}',
                      times: leg.departureLocal?.clock == null
                          ? null
                          : '${leg.departureLocal!.clock} → '
                              '${leg.arrivalLocal?.clock ?? '—'}',
                      meta: leg.airline?.name,
                      onTap: () => Navigator.of(sheetContext).pop(leg),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || picked == null) return;
    setState(() {
      _leg = picked;
      _departureCode = picked.departureCode;
    });
  }

  Future<void> _save() async {
    final key = _key;
    if (key == null) return;
    if (_events.isEmpty) {
      // Пустой массив сервер отклоняет (`min:1`) — объясняем это заранее.
      fToast(context, ft('watch_need_event', 'Ən azı bir hadisə seç'));
      return;
    }
    if (_legs.length > 1 && _leg == null) {
      fToast(context, ft('watch_need_leg', 'Hansı ayağı izlədiyini seç'));
      return;
    }
    if (!await FlightAuth.signedIn()) {
      if (!mounted) return;
      FlightAuth.present(context, onDone: () {
        _checkAuth();
        _save();
      });
      return;
    }
    setState(() => _saving = true);
    try {
      await _repo.watch(key, events: _events.toList());
      if (!mounted) return;
      setState(() => _saving = false);
      fToast(context, ft('watch_saved', 'İzləməyə alındı'));
      FlightNav.replace(context, const WatchCenterScreen());
    } catch (e) {
      if (!mounted) return;
      final error = FlightError.from(e);
      setState(() => _saving = false);
      if (error.isUnauthenticated) {
        FlightAuth.present(context, onDone: _checkAuth);
        return;
      }
      fToast(
        context,
        error.display(ft('watch_save_failed', 'İzləmə qurulmadı')),
      );
    }
  }
}
