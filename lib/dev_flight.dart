import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/cache/cache_manager.dart';
import 'data/cache/data_cache_manager.dart';
import 'data/network/api/auth_api.dart';
import 'data/repositories/data_auth_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'main.dart' show sl;
import 'presentation/resourses/wawat_dark.dart';
import 'screens/flight/flight_routes.dart';
import 'screens/flight/screens/aircraft/aircraft_passport_screen.dart';
import 'screens/flight/screens/airport/airport_card_screen.dart';
import 'screens/flight/screens/flight/flight_card_screen.dart';
import 'screens/flight/screens/map/global_delay_screen.dart';
import 'screens/flight/data/models/flight.dart';

/// Раздел «Uçuş radarı» на выдуманных ответах — без сервера.
///
/// Зачем: эндпоинты раздела на бэкенде ещё не выкачены (`/flight-data/health`
/// отвечает 404), поэтому на живом приложении видно только пустые состояния и
/// ошибки. А проверить нужно именно экраны с данными: карточку рейса, табло,
/// задержки, паспорт борта — там, где разметка сложная.
///
/// Как устроено: настоящий `Dio` из DI подменяется адаптером, который отдаёт
/// заготовленные ответы по §7 гайда. Приложение об этом ничего не знает —
/// работают настоящие экраны, настоящий репозиторий и настоящий кэш.
///
///     fvm flutter run -t lib/dev_flight.dart -d <симулятор>
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final dio = Dio(BaseOptions(baseUrl: 'https://api.wawatair.com/api/v1'))
    ..httpClientAdapter = _FakeFlightServer();

  sl.registerLazySingleton<Dio>(() => dio);
  sl.registerLazySingleton<CacheManager>(() => DataCacheManager());
  sl.registerLazySingleton<AuthApi>(() => AuthApi(dio));
  sl.registerLazySingleton<AuthRepository>(() => DataAuthRepository());

  // Слежение живёт под входом: без токена видно только приглашение войти.
  await sl.get<CacheManager>().saveAccessToken('dev-token');

  runApp(const _DevFlightApp());
}

class _DevFlightApp extends StatefulWidget {
  const _DevFlightApp();

  @override
  State<_DevFlightApp> createState() => _DevFlightAppState();
}

class _DevFlightAppState extends State<_DevFlightApp> {
  bool _dark = true;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Wawat flight dev',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          fontFamily: 'Instrument Sans',
          fontFamilyFallback: const ['Noto Sans'],
          scaffoldBackgroundColor: Colors.white,
          colorScheme: const ColorScheme.light(primary: Color(0xFF017BFE)),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Instrument Sans',
          fontFamilyFallback: const ['Noto Sans'],
          scaffoldBackgroundColor: WawatDark.bg,
          canvasColor: WawatDark.bg,
          colorScheme: const ColorScheme.dark(primary: Color(0xFF017BFE)),
          useMaterial3: true,
        ),
        themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
        home: _DevHome(
          dark: _dark,
          onTheme: (v) => setState(() => _dark = v),
        ),
      );
}

class _DevHome extends StatelessWidget {
  const _DevHome({required this.dark, required this.onTheme});

  final bool dark;
  final ValueChanged<bool> onTheme;

  @override
  Widget build(BuildContext context) {
    final key = FlightKey(
      number: 'J278',
      flightDate: _day(0),
      departureCode: 'GYD',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uçuş radarı — заглушки'),
        actions: [
          Switch(value: dark, onChanged: onTheme),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Сервера нет: ответы выдуманы по §7 гайда. Экраны, репозиторий и '
            'кэш — настоящие.',
          ),
          const SizedBox(height: 16),
          _Go('Раздел целиком', () => FlightNav.open(context)),
          _Go(
            'Карточка рейса J2 78',
            () => FlightNav.push(context, FlightCardScreen(flightKey: key)),
          ),
          _Go(
            'Аэропорт GYD',
            () => FlightNav.push(context, const AirportCardScreen(code: 'GYD')),
          ),
          _Go(
            'Борт 4K-AZ81',
            () => FlightNav.push(
              context,
              const AircraftPassportScreen(
                registration: '4K-AZ81',
                airlineCode: 'J2',
                airlineName: 'Azerbaijan Airlines',
              ),
            ),
          ),
          _Go(
            'Задержки по миру',
            () => FlightNav.push(context, const GlobalDelayScreen()),
          ),
        ],
      ),
    );
  }
}

class _Go extends StatelessWidget {
  const _Go(this.label, this.onTap);

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FilledButton(onPressed: onTap, child: Text(label)),
      );
}

// ─────────────────────────── выдуманный сервер ───────────────────────────

String _two(int v) => v.toString().padLeft(2, '0');

/// `YYYY-MM-DD` со сдвигом в днях от сегодняшнего.
String _day(int offset) {
  final d = DateTime.now().add(Duration(days: offset));
  return '${d.year}-${_two(d.month)}-${_two(d.day)}';
}

/// `2026-11-01T09:30:00+00:00` — UTC-метка сегодняшнего дня.
String _utc(int hour, int minute, {int dayOffset = 0}) {
  final d = DateTime.now().toUtc().add(Duration(days: dayOffset));
  return DateTime.utc(d.year, d.month, d.day, hour, minute)
      .toIso8601String()
      .replaceFirst('Z', '+00:00');
}

/// `2026-11-01 13:30+04:00` — местная метка аэропорта как её шлёт сервер.
String _local(int hour, int minute, String offset, {int dayOffset = 0}) {
  final d = DateTime.now().add(Duration(days: dayOffset));
  return '${d.year}-${_two(d.month)}-${_two(d.day)} '
      '${_two(hour)}:${_two(minute)}$offset';
}

Map<String, dynamic> _summary({
  required String number,
  required String display,
  required String from,
  required String to,
  required String status,
  required String label,
  required int depH,
  required int depM,
  required int arrH,
  required int arrM,
  String? model,
  String airline = 'Azerbaijan Airlines',
  String iata = 'J2',
  int? depDelay,
  int? arrDelay,
  bool cargo = false,
  bool live = false,
  int dayOffset = 0,
}) =>
    {
      'number': number,
      'display_number': display,
      'flight_date': _day(dayOffset),
      'departure_code': from,
      'arrival_code': to,
      'status': status,
      'status_label': label,
      'is_cargo': cargo,
      'airline': {'name': airline, 'iata': iata, 'icao': 'AHY'},
      'aircraft_model': model,
      'departure_at': _utc(depH - 4, depM, dayOffset: dayOffset),
      'arrival_at': _utc(arrH - 3, arrM, dayOffset: dayOffset),
      'departure_local': _local(depH, depM, '+04:00', dayOffset: dayOffset),
      'arrival_local': _local(arrH, arrM, '+03:00', dayOffset: dayOffset),
      'departure_delay_minutes': depDelay,
      'arrival_delay_minutes': arrDelay,
      'is_live': live,
      'departure_confirmed': status != 'expected',
      'arrival_confirmed': status == 'arrived',
    };

final _board = <Map<String, dynamic>>[
  _summary(
    number: 'J278',
    display: 'J2 78',
    from: 'GYD',
    to: 'IST',
    status: 'expected',
    label: 'Gözlənilir',
    depH: 13,
    depM: 30,
    arrH: 15,
    arrM: 50,
    model: 'Airbus A320neo',
  ),
  _summary(
    number: 'TK333',
    display: 'TK 333',
    from: 'GYD',
    to: 'IST',
    status: 'boarding',
    label: 'Minik gedir',
    depH: 14,
    depM: 5,
    arrH: 16,
    arrM: 25,
    model: 'Airbus A321',
    airline: 'Turkish Airlines',
    iata: 'TK',
  ),
  _summary(
    number: 'PC742',
    display: 'PC 742',
    from: 'GYD',
    to: 'SAW',
    status: 'delayed',
    label: 'Gecikir',
    depH: 15,
    depM: 20,
    arrH: 17,
    arrM: 40,
    model: 'Airbus A320',
    airline: 'Pegasus',
    iata: 'PC',
    depDelay: 45,
    arrDelay: 38,
  ),
  _summary(
    number: 'SU1861',
    display: 'SU 1861',
    from: 'GYD',
    to: 'SVO',
    status: 'departed',
    label: 'Havada',
    depH: 11,
    depM: 10,
    arrH: 13,
    arrM: 55,
    model: 'Airbus A320',
    airline: 'Aeroflot',
    iata: 'SU',
    live: true,
  ),
  _summary(
    number: 'W64398',
    display: 'W6 4398',
    from: 'GYD',
    to: 'BUD',
    status: 'canceled',
    label: 'Ləğv edilib',
    depH: 16,
    depM: 45,
    arrH: 18,
    arrM: 30,
    airline: 'Wizz Air',
    iata: 'W6',
  ),
  _summary(
    number: 'QR374',
    display: 'QR 374',
    from: 'GYD',
    to: 'DOH',
    status: 'arrived',
    label: 'Enib',
    depH: 7,
    depM: 15,
    arrH: 9,
    arrM: 40,
    model: 'Boeing 787-8',
    airline: 'Qatar Airways',
    iata: 'QR',
    arrDelay: -6,
  ),
  _summary(
    number: 'TK9821',
    display: 'TK 9821',
    from: 'GYD',
    to: 'IST',
    status: 'expected',
    label: 'Gözlənilir',
    depH: 20,
    depM: 10,
    arrH: 22,
    arrM: 30,
    model: 'Airbus A330-200F',
    airline: 'Turkish Cargo',
    iata: 'TK',
    cargo: true,
  ),
  _summary(
    number: 'FZ1718',
    display: 'FZ 1718',
    from: 'GYD',
    to: 'DXB',
    status: 'diverted',
    label: 'Başqa limana yönəldilib',
    depH: 5,
    depM: 55,
    arrH: 9,
    arrM: 5,
    model: 'Boeing 737 MAX 8',
    airline: 'flydubai',
    iata: 'FZ',
  ),
];

Map<String, dynamic> _endpoint({
  required String iata,
  required String icao,
  required String name,
  required String city,
  required String country,
  required String zone,
  required double lat,
  required double lon,
  required String offset,
  required int schedH,
  required int schedM,
  int? revisedH,
  int? revisedM,
  int? runwayH,
  int? runwayM,
  String? terminal,
  String? gate,
  String? belt,
  String? desk,
  String? runway,
  int? delay,
  List<String> quality = const ['basic'],
}) =>
    {
      'airport': {
        'iata': iata,
        'icao': icao,
        'name': name,
        'municipality': city,
        'country_code': country,
        'time_zone': zone,
        'lat': lat,
        'lon': lon,
      },
      'scheduled': {
        'utc': _utc(schedH - int.parse(offset.substring(1, 3)), schedM),
        'local': _local(schedH, schedM, offset),
      },
      'revised': revisedH == null
          ? null
          : {
              'utc': _utc(revisedH - int.parse(offset.substring(1, 3)),
                  revisedM ?? 0),
              'local': _local(revisedH, revisedM ?? 0, offset),
            },
      'predicted': null,
      'runway_time': runwayH == null
          ? null
          : {
              'utc':
                  _utc(runwayH - int.parse(offset.substring(1, 3)), runwayM ?? 0),
              'local': _local(runwayH, runwayM ?? 0, offset),
            },
      'terminal': terminal,
      'check_in_desk': desk,
      'gate': gate,
      'baggage_belt': belt,
      'runway': runway,
      'quality': quality,
      'delay_minutes': delay,
    };

Map<String, dynamic> _detail() => {
      ..._summary(
        number: 'J278',
        display: 'J2 78',
        from: 'GYD',
        to: 'IST',
        status: 'en_route',
        label: 'Havada',
        depH: 13,
        depM: 30,
        arrH: 15,
        arrM: 50,
        model: 'Airbus A320neo',
        depDelay: 12,
        arrDelay: 8,
        live: true,
      ),
      'call_sign': 'AHY078',
      'codeshare_status': 'operator',
      'great_circle_km': 1792.86,
      'aircraft': {
        'reg': '4K-AZ81',
        'mode_s': '60043F',
        'model': 'Airbus A320-251N',
        'image': {
          'url': 'https://picsum.photos/seed/a320neo/1200/675',
          'web_url': 'https://commons.wikimedia.org/',
          'author': 'Anna Zvereva',
          'title': 'Azerbaijan Airlines 4K-AZ81',
          'license': 'AttributionShareAlikeCC',
          'attributions': ['Anna Zvereva / Wikimedia Commons / CC BY-SA 2.0'],
        },
      },
      'departure': _endpoint(
        iata: 'GYD',
        icao: 'UBBB',
        name: 'Heydar Aliyev',
        city: 'Baku',
        country: 'AZ',
        zone: 'Asia/Baku',
        lat: 40.4675,
        lon: 50.0467,
        offset: '+04:00',
        schedH: 13,
        schedM: 30,
        revisedH: 13,
        revisedM: 42,
        runwayH: 13,
        runwayM: 47,
        terminal: '1',
        gate: 'A3',
        desk: '12–18',
        runway: '16',
        delay: 12,
        quality: ['basic', 'live'],
      ),
      'arrival': _endpoint(
        iata: 'IST',
        icao: 'LTFM',
        name: 'Istanbul',
        city: 'Istanbul',
        country: 'TR',
        zone: 'Europe/Istanbul',
        lat: 41.2753,
        lon: 28.7519,
        offset: '+03:00',
        schedH: 15,
        schedM: 50,
        revisedH: 15,
        revisedM: 58,
        terminal: 'I',
        gate: 'F7',
        belt: '14',
        delay: 8,
        quality: ['basic'],
      ),
      'location': {
        'lat': 41.0214,
        'lon': 32.8870,
        'altitude_m': 11277,
        'altitude_ft': 37000,
        'pressure_altitude_ft': 37000,
        'pressure_hpa': 1013.2,
        'ground_speed_kmh': 842,
        'ground_speed_kt': 455,
        'true_track': 287.5,
        'vsi_fpm': 0,
        'reported_at': _utc(DateTime.now().toUtc().hour,
            DateTime.now().toUtc().minute - 1),
      },
      'flight_plan': {
        'route': 'BAKU UB1 ERZ UA4 ANKRA DCT IST',
        'rules': 'Ifr',
        'type': 'Scheduled',
        'status': 'Filed',
        'revision': 1,
        'altitude_ft': 37000,
        'airspeed_kt': 470,
        'updated_at': _utc(10, 15),
      },
      'progress_percent': 42,
      'track': [
        for (var i = 0; i < 12; i++)
          {
            'lat': 40.4675 + (41.2753 - 40.4675) * i / 11,
            'lon': 50.0467 + (28.7519 - 50.0467) * i / 11,
            'altitude_m': i < 2 ? 1500 * (i + 1) : 11277,
            'ground_speed_kmh': i < 2 ? 420 : 842,
            'true_track': 287.5,
            'reported_at': _utc(9, 30 + i * 5),
          },
      ],
      'source_updated_at': _utc(DateTime.now().toUtc().hour, 0),
      'refreshed_at': _utc(DateTime.now().toUtc().hour,
          DateTime.now().toUtc().minute),
    };

/// Небольшая таблица портов. Без неё `/airports/{code}` отвечал бы на любой
/// код бакинской записью, и экран глобальных задержек подписывал бы EGLL
/// словом «Baku».
const _airportTable = <String, List<Object>>{
  // iata: [icao, name, city, country, cc, tz, lat, lon, site]
  'GYD': ['UBBB', 'Heydar Aliyev', 'Baku', 'Azerbaijan', 'AZ', 'Asia/Baku',
      40.4675, 50.0467, 'https://www.airport.az'],
  'NAJ': ['UBBN', 'Nakhchivan', 'Nakhchivan', 'Azerbaijan', 'AZ', 'Asia/Baku',
      39.1888, 45.4584, 'https://www.airport.az'],
  'IST': ['LTFM', 'Istanbul', 'Istanbul', 'Türkiye', 'TR', 'Europe/Istanbul',
      41.2753, 28.7519, 'https://www.istairport.com'],
  'SAW': ['LTFJ', 'Sabiha Gökçen', 'Istanbul', 'Türkiye', 'TR',
      'Europe/Istanbul', 40.8986, 29.3092, 'https://www.sabihagokcen.aero'],
  'DXB': ['OMDB', 'Dubai', 'Dubai', 'United Arab Emirates', 'AE', 'Asia/Dubai',
      25.2528, 55.3644, 'https://www.dubaiairports.ae'],
  'SVO': ['UUEE', 'Sheremetyevo', 'Moscow', 'Russia', 'RU', 'Europe/Moscow',
      55.9726, 37.4146, 'https://www.svo.aero'],
  'LHR': ['EGLL', 'Heathrow', 'London', 'United Kingdom', 'GB',
      'Europe/London', 51.4706, -0.4619, 'https://www.heathrow.com'],
};

/// ICAO → IATA, чтобы запрос по любому коду нашёл запись.
final _airportByIcao = {
  for (final e in _airportTable.entries) e.value[0] as String: e.key,
};

/// Порт по любому коду; незнакомый код отдаётся заглушкой с этим же кодом,
/// а не бакинской записью.
Map<String, dynamic> _airportOf(String code) {
  final c = code.toUpperCase();
  final iata = _airportTable.containsKey(c) ? c : _airportByIcao[c];
  final r = iata == null ? null : _airportTable[iata]!;
  if (iata == null || r == null) {
    return _airport(c, icao: c, name: c, city: c, country: '—',
        countryCode: '—', tz: 'UTC', lat: 0, lon: 0);
  }
  return _airport(iata,
      icao: r[0] as String,
      name: r[1] as String,
      city: r[2] as String,
      country: r[3] as String,
      countryCode: r[4] as String,
      tz: r[5] as String,
      lat: r[6] as double,
      lon: r[7] as double);
}

Map<String, dynamic> _airport(
  String code, {
  String icao = 'UBBB',
  String name = 'Heydar Aliyev',
  String city = 'Baku',
  String country = 'Azerbaijan',
  String countryCode = 'AZ',
  String tz = 'Asia/Baku',
  double lat = 40.4675,
  double lon = 50.0467,
}) =>
    {
      'code': code,
      'iata': code,
      'icao': icao,
      'name': name,
      'full_name': '$city $name',
      'city': city,
      'country_code': countryCode,
      'country': country,
      'time_zone': tz,
      'lat': lat,
      'lon': lon,
      'is_featured': true,
    };

Map<String, dynamic> _airportFull(String code) {
  final a = _airportOf(code);
  final iata = a['iata'] as String;
  final site = _airportTable[iata]?[8] as String?;
  return {
      ...a,
      'continent': 'Asia',
      'local_code': null,
      'elevation_m': 3,
      'local_time': DateTime.now().toIso8601String(),
      'urls': {
        'website': site,
        'wikipedia': 'https://en.wikipedia.org/wiki/${a['name']}_Airport',
        'google_maps': 'https://maps.google.com/?q=${a['lat']},${a['lon']}',
      },
      'runway_count': 2,
      'runways': [
        {
          'name': '16',
          'true_heading': 167,
          'length_m': 4007,
          'width_m': 60,
          'surface': 'Asphalt',
          'is_closed': false,
          'has_lighting': true,
          'displaced_threshold_m': null,
          'lat': 40.49,
          'lon': 50.03,
        },
        {
          'name': '34',
          'true_heading': 347,
          'length_m': 3200,
          'width_m': 45,
          'surface': 'Concrete',
          'is_closed': true,
          'has_lighting': false,
          'displaced_threshold_m': 300,
          'lat': 40.44,
          'lon': 50.06,
        },
      ],
      'listings_count': 12,
  };
}

Map<String, dynamic> _delaySide({
  required int total,
  required int qualified,
  required int cancelled,
  String? median,
  double? index,
}) =>
    {
      'numTotal': total,
      'numQualifiedTotal': qualified,
      'numCancelled': cancelled,
      if (median != null) 'medianDelay': median,
      if (index != null) 'delayIndex': index,
    };

final _aircraft = <String, dynamic>{
  'registration': '4K-AZ81',
  'mode_s': '60043F',
  'serial': '10421',
  'model': 'Airbus A320-251N',
  'model_code': 'A20N',
  'type_name': 'Airbus A320neo',
  'iata_type': '32N',
  'icao_code': 'A20N',
  'airline_name': 'Azerbaijan Airlines',
  'production_line': 'Airbus A320',
  'seats': 174,
  'engines': 2,
  'engine_type': 'Jet',
  'is_freighter': false,
  'active': true,
  'verified': true,
  'age_years': 6.4,
  'rollout_date': '2020-02-11',
  'first_flight_date': '2020-03-02',
  'delivery_date': '2020-04-18',
  'registration_date': '2020-04-18',
  'image': {
    'url': 'https://picsum.photos/seed/a320neo/1200/675',
    'web_url': 'https://commons.wikimedia.org/',
    'author': 'Anna Zvereva',
    'title': 'Azerbaijan Airlines 4K-AZ81',
    'license': 'AttributionShareAlikeCC',
    'attributions': ['Anna Zvereva / Wikimedia Commons / CC BY-SA 2.0'],
  },
  'registrations': [
    {
      'reg': '4K-AZ81',
      'mode_s': '60043F',
      'airline_name': 'Azerbaijan Airlines',
      'registered_on': '2020-04-18',
      'active': true,
    },
    {
      'reg': 'F-WWDR',
      'airline_name': 'Airbus',
      'registered_on': '2020-03-02',
      'active': false,
    },
  ],
};

/// Подменный транспорт: вместо сети — заготовки по §7 гайда.
class _FakeFlightServer implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    // Задержка нужна: без неё не видно ни скелетонов, ни блокировки кнопок.
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final path = options.uri.path.replaceFirst('/api/v1', '');
    final s = path.split('/').where((e) => e.isNotEmpty).toList();
    final q = options.uri.queryParameters;
    final body = _route(options.method.toUpperCase(), s, q);
    if (body == null) {
      debugPrint('[dev_flight] нет заготовки: ${options.method} $path');
      return _json({'data': <dynamic>[]});
    }
    return _json(body);
  }

  Map<String, dynamic>? _route(
    String method,
    List<String> s,
    Map<String, String> q,
  ) {
    if (s.isEmpty) return null;

    if (method == 'POST' || method == 'DELETE') {
      if (s.first == 'me' || s.first == 'flights') {
        return {
          'data': _watch(1,
                  events: const ['status_changed', 'schedule_changed',
                    'gate_changed', 'departed', 'arrived']),
        };
      }
      return {'data': null};
    }

    switch (s.first) {
      case 'flight-data':
        return {
          'data': {
            'feeds': {
              'schedules': {'service': 'FlightSchedules', 'status': 'OK'},
              'live': {'service': 'LiveFlights', 'status': 'OKPartial'},
              'adsb': {'service': 'AdsbUpdates', 'status': 'Degraded'},
            },
            'degraded': true,
          },
          'meta': {'cached': true, 'fetched_at': _utc(DateTime.now().toUtc().hour, 0)},
        };

      case 'flights':
        if (s.length == 2 && s[1] == 'search') {
          return {
            'data': ['J278', 'J279', 'TK333', 'TK9821', 'PC742'],
          };
        }
        if (s.length >= 3 && s[1] == 'by-registration') {
          return {'data': _board.take(3).toList()};
        }
        if (s.length == 3 && s[2] == 'dates') {
          return {
            'data': [for (var i = -3; i <= 7; i++) _day(i)],
          };
        }
        if (s.length == 3 && s[2] == 'history') {
          return {
            'data': [
              for (var i = 1; i <= 7; i++)
                _summary(
                  number: 'J278',
                  display: 'J2 78',
                  from: 'GYD',
                  to: 'IST',
                  status: i.isEven ? 'arrived' : 'delayed',
                  label: i.isEven ? 'Enib' : 'Gecikib',
                  depH: 13,
                  depM: 30,
                  arrH: 15,
                  arrM: 50,
                  model: 'Airbus A320neo',
                  depDelay: i.isEven ? 0 : 20 + i * 4,
                  arrDelay: i.isEven ? -3 : 15 + i * 3,
                  dayOffset: -i,
                ),
            ],
          };
        }
        if (s.length == 3 && s[2] == 'delays') {
          return {
            'data': {
              'medianDelay': '0:14',
              'delayPercentiles': [
                {'percentile': 50, 'delay': '0:14'},
                {'percentile': 80, 'delay': '0:41'},
                {'percentile': 90, 'delay': '1:05'},
              ],
              'numFlightsDelayedBrackets': [
                {'from': '0:00', 'to': '0:15', 'numFlights': 48},
                {'from': '0:15', 'to': '0:30', 'numFlights': 21},
                {'from': '0:30', 'to': '1:00', 'numFlights': 12},
                {'from': '1:00', 'numFlights': 6},
              ],
              'numConsideredFlights': 87,
              'class': 'Good',
            },
          };
        }
        if (s.length == 4 && s[3] == 'detail') {
          return {
            'data': _detail(),
            'meta': {'cached': false},
          };
        }
        if (s.length == 3) {
          // Под TK333 в этот день летят два плеча — проверка выбора плеча.
          if (s[1].toUpperCase().startsWith('TK333')) {
            return {
              'data': [
                _board[1],
                _summary(
                  number: 'TK333',
                  display: 'TK 333',
                  from: 'IST',
                  to: 'GYD',
                  status: 'expected',
                  label: 'Gözlənilir',
                  depH: 17,
                  depM: 35,
                  arrH: 21,
                  arrM: 5,
                  model: 'Airbus A321',
                  airline: 'Turkish Airlines',
                  iata: 'TK',
                ),
              ],
            };
          }
          return {
            'data': [_board.first],
          };
        }
        return null;

      case 'routes':
        return {'data': _board.take(4).toList()};

      case 'airports':
        if (s.length == 1) {
          return {
            'data': [
              _airport('GYD'),
              _airport('IST',
                  icao: 'LTFM',
                  name: 'Istanbul',
                  city: 'Istanbul',
                  country: 'Turkey',
                  countryCode: 'TR',
                  lat: 41.2753,
                  lon: 28.7519),
              _airport('DXB',
                  icao: 'OMDB',
                  name: 'Dubai',
                  city: 'Dubai',
                  country: 'United Arab Emirates',
                  countryCode: 'AE',
                  lat: 25.2528,
                  lon: 55.3644),
              _airport('SVO',
                  icao: 'UUEE',
                  name: 'Sheremetyevo',
                  city: 'Moscow',
                  country: 'Russia',
                  countryCode: 'RU',
                  lat: 55.9726,
                  lon: 37.4146),
              _airport('NAJ',
                  icao: 'UBBN',
                  name: 'Nakhchivan',
                  city: 'Nakhchivan',
                  country: 'Azerbaijan',
                  countryCode: 'AZ',
                  lat: 39.1888,
                  lon: 45.4584),
            ],
          };
        }
        if (s.length == 2 && s[1] == 'search') {
          final near = q.containsKey('lat');
          return {
            'data': [
              {..._airport('GYD'), if (near) 'distance_km': 16.5},
              {
                ..._airport('NAJ',
                    icao: 'UBBN',
                    name: 'Nakhchivan',
                    city: 'Nakhchivan',
                    country: 'Azerbaijan',
                    countryCode: 'AZ',
                    lat: 39.1888,
                    lon: 45.4584),
                if (near) 'distance_km': 438.2,
              },
            ],
          };
        }
        if (s.length == 2 && s[1] == 'delays') {
          return {
            'data': [
              {
                'airportIcao': 'EGLL',
                'departuresDelayInformation': _delaySide(
                    total: 612,
                    qualified: 540,
                    cancelled: 7,
                    median: '0:22',
                    index: 2.4),
                'arrivalsDelayInformation': _delaySide(
                    total: 598,
                    qualified: 512,
                    cancelled: 4,
                    median: '0:18',
                    index: 2.1),
              },
              {
                'airportIcao': 'OMDB',
                'departuresDelayInformation': _delaySide(
                    total: 744,
                    qualified: 690,
                    cancelled: 2,
                    median: '0:09',
                    index: 1.2),
                'arrivalsDelayInformation': _delaySide(
                    total: 731,
                    qualified: 664,
                    cancelled: 1,
                    median: '0:11',
                    index: 1.4),
              },
              {
                // Измерений нет — экран обязан сказать «ölçülməyib».
                'airportIcao': 'UBBB',
                'departuresDelayInformation':
                    _delaySide(total: 38, qualified: 0, cancelled: 0),
                'arrivalsDelayInformation':
                    _delaySide(total: 41, qualified: 0, cancelled: 0),
              },
            ],
            'meta': {'stale': true, 'fetched_at': _utc(DateTime.now().toUtc().hour - 1, 40)},
          };
        }
        if (s.length == 2) return {'data': _airportFull(s[1].toUpperCase())};
        if (s.length == 3) {
          switch (s[2]) {
            case 'runways':
              return {'data': _airportFull(s[1])['runways']};
            case 'board':
              final arrivals = q['direction'] == 'arrival';
              return {
                'data': [
                  for (final f in _board)
                    arrivals
                        ? {
                            ...f,
                            'departure_code': f['arrival_code'],
                            'arrival_code': f['departure_code'],
                          }
                        : f,
                ],
                'meta': {
                  'direction': q['direction'] ?? 'departure',
                  'from': q['from'],
                  'to': q['to'],
                  'cached': true,
                },
              };
            case 'delays':
              return {
                'data': {
                  'airportIcao': 'UBBB',
                  'departuresDelayInformation': _delaySide(
                      total: 38,
                      qualified: 0,
                      cancelled: 0), // Баку: измерений нет
                  'arrivalsDelayInformation':
                      _delaySide(total: 41, qualified: 0, cancelled: 0),
                },
              };
            case 'routes':
              return {
                'data': [
                  {
                    'destination': {
                      'icao': 'LTFM',
                      'iata': 'IST',
                      'name': 'Istanbul',
                      'municipalityName': 'Istanbul',
                      'countryCode': 'TR',
                      'location': {'lat': 41.2753, 'lon': 28.7519},
                    },
                    'averageDailyFlights': 6.4,
                    'operators': [
                      {'name': 'Turkish Airlines', 'iata': 'TK', 'icao': 'THY'},
                      {'name': 'AZAL', 'iata': 'J2', 'icao': 'AHY'},
                    ],
                  },
                  {
                    'destination': {
                      'icao': 'OMDB',
                      'iata': 'DXB',
                      'name': 'Dubai',
                      'municipalityName': 'Dubai',
                      'countryCode': 'AE',
                      'location': {'lat': 25.2528, 'lon': 55.3644},
                    },
                    'averageDailyFlights': 2.0,
                    'operators': [
                      {'name': 'flydubai', 'iata': 'FZ', 'icao': 'FDB'},
                    ],
                  },
                  {
                    'destination': {
                      'icao': 'UUEE',
                      'iata': 'SVO',
                      'name': 'Sheremetyevo',
                      'municipalityName': 'Moscow',
                      'countryCode': 'RU',
                      'location': {'lat': 55.9726, 'lon': 37.4146},
                    },
                    'averageDailyFlights': 1.3,
                    'operators': [
                      {'name': 'Aeroflot', 'iata': 'SU', 'icao': 'AFL'},
                    ],
                  },
                ],
              };
            case 'solar':
              return {
                'data': {
                  'sunElevation': 34.2,
                  'sunAzimuth': 198.7,
                  'dayTime': [
                    {'from': '07:12', 'to': '18:04'},
                  ],
                  'dawnAstronomical': '05:34',
                  'dawnNautical': '06:08',
                  'dawnCivil': '06:44',
                  'sunrise': '07:12',
                  'noonTrue': '12:38',
                  'sunset': '18:04',
                  'duskCivil': '18:32',
                  'duskNautical': '19:08',
                  'duskAstronomical': '19:42',
                },
              };
            case 'feeds':
              return {
                'data': {
                  'flightSchedulesFeed': {
                    'service': 'FlightSchedules',
                    'status': 'OK',
                    'minAvailableLocalDate': _day(-30),
                    'maxAvailableLocalDate': _day(30),
                  },
                  'liveFlightUpdatesFeed': {
                    'service': 'LiveFlightUpdates',
                    'status': 'OKPartial',
                  },
                  'adsbUpdatesFeed': {
                    'service': 'AdsbUpdates',
                    'status': 'Unavailable',
                  },
                },
              };
          }
        }
        if (s.length == 4 && s[2] == 'distance') {
          return {
            'data': {
              'from': {
                'iata': 'GYD',
                'icao': 'UBBB',
                'name': 'Heydar Aliyev',
                'municipalityName': 'Baku',
                'countryCode': 'AZ',
                'location': {'lat': 40.4675, 'lon': 50.0467},
              },
              'to': {
                'iata': 'IST',
                'icao': 'LTFM',
                'name': 'Istanbul',
                'municipalityName': 'Istanbul',
                'countryCode': 'TR',
                'location': {'lat': 41.2753, 'lon': 28.7519},
              },
              'greatCircleDistance': {
                'meter': 1792860.0,
                'km': 1792.86,
                'mile': 1113.9,
                'nm': 967.9,
              },
              'approxFlightTime': '02:51',
            },
          };
        }
        return null;

      case 'aircraft':
        if (s.length == 2 && s[1] == 'search') {
          return {
            'data': [
              {
                'reg': '4K-AZ81',
                'model': 'Airbus A320-251N',
                'modelCode': 'A20N',
                'typeName': 'Airbus A320neo',
                'numSeats': 174,
                'numEngines': 2,
                'engineType': 'Jet',
                'isFreighter': false,
                'active': true,
                'ageYears': 6.4,
                'airlineName': 'Azerbaijan Airlines',
              },
            ],
          };
        }
        if (s.length == 2) return {'data': _aircraft};
        if (s.length == 3 && s[2] == 'registrations') {
          return {'data': _aircraft['registrations']};
        }
        if (s.length == 3 && s[2] == 'image') {
          return {
            'data': {
              'url': 'https://picsum.photos/seed/a320neo/1200/675',
              'webUrl': 'https://commons.wikimedia.org/',
              'author': 'Anna Zvereva',
              'title': 'Azerbaijan Airlines 4K-AZ81',
              'description': 'Airbus A320-251N at Baku',
              'license': 'AttributionShareAlikeCC',
              'htmlAttributions': [
                'Anna Zvereva / Wikimedia Commons / CC BY-SA 2.0',
              ],
            },
          };
        }
        return null;

      case 'airlines':
        // Парк отдаётся по-настоящему постранично: иначе «ещё» подгружало бы
        // те же четыре борта и счётчик врал бы.
        const total = 24;
        final size = int.tryParse('${q['per_page'] ?? 10}') ?? 10;
        final offset = int.tryParse('${q['offset'] ?? 0}') ?? 0;
        final items = [
          for (var i = offset; i < offset + size && i < total; i++)
            _fleetItem(i),
        ];
        return {
          'data': {
            'totalCount': total,
            'pageOffset': offset,
            'pageSize': size,
            'hasNextPage': offset + items.length < total,
            'count': items.length,
            'items': items,
          },
        };

      case 'me':
        if (s.length == 2 && s[1] == 'flight-watches') {
          return {
            'data': [
              _watch(1,
                  events: const ['status_changed', 'schedule_changed',
                    'gate_changed', 'departed', 'arrived']),
              _watch(2,
                  events: const ['departed', 'arrived'],
                  muted: true,
                  flight: _board[2]),
            ],
          };
        }
        return null;

      case 'notifications':
        return {
          'data': <dynamic>[],
          'meta': {'current_page': 1, 'last_page': 1},
        };
    }
    return null;
  }

  /// Борт №[i] парка: три модели вперемешку, одна грузовая — чтобы группировка
/// по типу на экране парка была видна.
Map<String, dynamic> _fleetItem(int i) {
  const models = [
    ['Airbus A320-251N', 'A20N', 'Airbus A320neo', 174, 6.4, false],
    ['Boeing 787-8', 'B788', 'Boeing 787 Dreamliner', 211, 9.1, false],
    ['Boeing 767-300F', 'B763', 'Boeing 767 Freighter', 0, 24.3, true],
  ];
  final m = models[i % models.length];
  return {
    'reg': '4K-AZ${81 + i}',
    'model': m[0],
    'modelCode': m[1],
    'typeName': m[2],
    'numSeats': m[3] == 0 ? null : m[3],
    'numEngines': 2,
    'engineType': 'Jet',
    'isFreighter': m[5],
    'active': i % 7 != 6,
    'ageYears': m[4],
    'airlineName': 'Azerbaijan Airlines',
  };
}

Map<String, dynamic> _watch(
    int id, {
    required List<String> events,
    bool muted = false,
    Map<String, dynamic>? flight,
  }) =>
      {
        'id': id,
        'events': events,
        'listing_id': null,
        'muted_until': muted
            ? DateTime.now().toUtc().add(const Duration(hours: 3)).toIso8601String()
            : null,
        'created_at': DateTime.now()
            .toUtc()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
        'flight': flight ?? _board.first,
      };

  ResponseBody _json(Map<String, dynamic> body, [int code = 200]) =>
      ResponseBody.fromString(jsonEncode(body), code, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      });

  @override
  void close({bool force = false}) {}
}
