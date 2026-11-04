import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/network/api/chat_api.dart';
import 'data/network/response/chat_response.dart';
import 'data/network/response/content_response.dart';
import 'domain/repositories/auth_repository.dart';
import 'main.dart' show sl;
import 'presentation/resourses/wawat_dark.dart';
import 'screens/chat/widgets/message_bubble.dart';
import 'screens/home/tabs/profile_tab/deals/deal_action_runner.dart';
import 'screens/home/tabs/profile_tab/deals/deal_action_sheets.dart';
import 'screens/home/tabs/profile_tab/deals/deal_detail_screen.dart';
import 'services/localization_service.dart';
import 'services/theme_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  sl
    ..registerSingleton<ChatApi>(_FakeChatApi(_backend))
    ..registerSingleton<AuthRepository>(_FakeContentRepository());
  runApp(const _DevDealActionsApp());
}

final _backend = _FakeBackend();

const _fontFamily = 'Instrument Sans';
const _fontFallback = <String>['Noto Sans'];

class _DevDealActionsApp extends StatefulWidget {
  const _DevDealActionsApp();

  @override
  State<_DevDealActionsApp> createState() => _DevDealActionsAppState();
}

class _DevDealActionsAppState extends State<_DevDealActionsApp> {
  final _theme = _DevThemeManager();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeManager>.value(value: _theme),
        ChangeNotifierProvider.value(value: LocalizationService.instance),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, theme, _) => _app(theme.isDarkMode),
      ),
    );
  }

  Widget _app(bool dark) {
    return MaterialApp(
      title: 'Wawat deal actions dev',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFallback,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF5B4FFF),
          secondary: Color(0xFF5B4FFF),
          surface: Colors.white,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFallback,
        scaffoldBackgroundColor: WawatDark.bg,
        canvasColor: WawatDark.bg,
        colorScheme: const ColorScheme.dark(
          primary: WawatDark.brand,
          onPrimary: Colors.white,
          secondary: WawatDark.brand,
          surface: WawatDark.surface,
          onSurface: WawatDark.textPrimary,
          error: WawatDark.danger,
        ),
        useMaterial3: true,
      ),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: _DevDealActionsScreen(
        isDark: dark,
        onToggleTheme: _theme.toggle,
      ),
    );
  }
}

class _DevThemeManager extends ThemeManager {
  bool _dark = false;

  @override
  bool get isDarkMode => _dark;

  void toggle() {
    _dark = !_dark;
    notifyListeners();
  }
}

class _DevDealActionsScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const _DevDealActionsScreen({
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<_DevDealActionsScreen> createState() => _DevDealActionsScreenState();
}

class _DevDealActionsScreenState extends State<_DevDealActionsScreen> {
  final _dealActions = DealActionController();
  late List<ChatMessage> _messages = _backend.messages();

  bool _narrow = false;

  @override
  void dispose() {
    _dealActions.dispose();
    super.dispose();
  }

  void _onDealAction(ChatMessage message, DealAction action) {
    final card = message.card;
    final shipmentId = card?.shipmentId;
    if (card == null || shipmentId == null) return;
    _dealActions.run(
      context,
      scope: message.id,
      action: action,
      content: const {},
      prefill: DealCounterPrefill.fromPayload(card.payload),
      execute: (body) async {
        final answer = await _backend.post(shipmentId, action.endpoint, body);
        if (mounted) setState(() => _messages = _backend.messages());
        return answer;
      },
      onMessage: _showMessage,
    );
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              isError ? const Color(0xFFEF4444) : const Color(0xFF0271EB),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          duration: Duration(seconds: isError ? 4 : 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final messages = _messages.reversed.toList();
    final screen = MediaQuery.of(context);
    final Widget feed = ListView.builder(
      reverse: true,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageBubble(
          key: ValueKey(message.id),
          message: message,
          isMyMessage: message.isMine,
          isCurrentOffer: _backend.isCurrentOffer(message),
          onDealAction: _onDealAction,
          dealActions: _dealActions,
        );
      },
    );
    return Scaffold(
      backgroundColor: isDark ? WawatDark.bg : const Color(0xFFEAEEF4),
      appBar: AppBar(
        title: const Text('Düymələr'),
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: isDark ? WawatDark.textPrimary : const Color(0xFF0F172A),
        ),
        backgroundColor: isDark ? WawatDark.bar : Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Sövdələşmə ekranı',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DealDetailScreen(shipmentId: 's3'),
                ),
              );
              if (mounted) setState(() => _messages = _backend.messages());
            },
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          IconButton(
            tooltip: 'Dar ekran (360)',
            onPressed: () => setState(() => _narrow = !_narrow),
            icon: Icon(
              Icons.smartphone,
              color: _narrow ? const Color(0xFF0271EB) : null,
            ),
          ),
          IconButton(
            tooltip: 'Növbəti sorğu xəta ilə bitsin',
            onPressed: () =>
                setState(() => _backend.failNext = !_backend.failNext),
            icon: Icon(
              Icons.bug_report_outlined,
              color: _backend.failNext ? const Color(0xFFEF4444) : null,
            ),
          ),
          IconButton(
            tooltip: 'Yenidən başla',
            onPressed: () => setState(() {
              _backend.reset();
              _messages = _backend.messages();
            }),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Mövzu',
            onPressed: widget.onToggleTheme,
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode_outlined),
          ),
        ],
      ),
      body: !_narrow
          ? feed
          : Center(
              child: SizedBox(
                width: 360,
                child: MediaQuery(
                  data: screen.copyWith(size: Size(360, screen.size.height)),
                  child: feed,
                ),
              ),
            ),
    );
  }
}

class _FakeBackend {
  _FakeBackend() {
    reset();
  }

  bool failNext = false;
  final List<Map<String, dynamic>> _feed = [];
  final Map<String, String> _roles = {};
  int _nextId = 0;

  static const _terms = {
    'weight_kg': 2.5,
    'price_total': 16,
    'package_type_code': 'documents',
    'city_from_name': 'Bakı',
    'city_to_name': 'İstanbul',
  };

  List<ChatMessage> messages() => _feed.map(ChatMessage.fromJson).toList();

  Map<String, dynamic> shipment(String shipmentId) {
    final card = _feed.lastWhere(
      (item) => item['card']['shipment_id'] == shipmentId,
    )['card'] as Map<String, dynamic>;
    final status = card['shipment_status'] as String;
    return {
      'id': shipmentId,
      'status': status,
      'status_label': card['label'],
      'is_awaiting_me': (card['actions'] as List).isNotEmpty,
      'available_actions': const <String>[],
      'actions': card['actions'],
      'my_role': _roles[shipmentId],
      'weight_kg': _terms['weight_kg'],
      'price_total': _terms['price_total'],
      'package_type_code': _terms['package_type_code'],
      'city_from': 'Bakı',
      'city_to': 'İstanbul',
      'travel_date': '2026-10-14',
      'sender': {'id': '1', 'fullname': 'Mən'},
      'carrier': {'id': '2', 'fullname': 'Aysel Məmmədova'},
      'created_at': '2026-10-12T12:00:00',
    };
  }

  bool isCurrentOffer(ChatMessage message) {
    final shipmentId = message.card?.shipmentId;
    final newest = _feed.lastWhere(
      (item) =>
          item['card']['type'] == 'proposal' &&
          item['card']['shipment_id'] == shipmentId,
      orElse: () => const {},
    );
    return newest['id'] == message.id;
  }

  void reset() {
    _feed.clear();
    _nextId = 0;
    failNext = false;
    _roles
      ..clear()
      ..addAll({'s1': 'carrier', 's2': 'sender', 's3': 'sender'});

    _add('s1', 'proposal', 'Təklif', 'proposal_pending', payload: {
      ..._terms,
      'price_total': 12,
    });
    _add('s1', 'proposal', 'Qarşı təklif', 'proposal_pending',
        isMine: true, actions: _actionsFor('s1', 'proposal_pending', true));
    _add('s2', 'proposal', 'Təklif', 'proposal_pending',
        payload: {..._terms, 'weight_kg': 4, 'price_total': 28},
        actions: _actionsFor('s2', 'proposal_pending', false));
    _add('s3', 'picked_up', 'Bağlama götürüldü', 'picked_up');
    _add('s3', 'delivered', 'Çatdırıldı', 'delivered',
        actions: _actionsFor('s3', 'delivered', false));
  }

  Future<String> post(
    String shipmentId,
    String endpoint,
    Map<String, dynamic>? body,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    if (failNext) {
      failNext = false;
      final request = RequestOptions(path: '/shipments/$shipmentId/$endpoint');
      throw DioException(
        requestOptions: request,
        response: Response(
          requestOptions: request,
          statusCode: 422,
          data: {'message': 'Bu əməliyyat artıq mümkün deyil.'},
        ),
      );
    }

    for (final item in _feed) {
      if (item['card']['shipment_id'] == shipmentId) {
        item['card']['actions'] = const <Map<String, dynamic>>[];
      }
    }

    final current = _feed.lastWhere(
      (item) => item['card']['shipment_id'] == shipmentId,
    )['card']['shipment_status'] as String;
    switch (endpoint) {
      case 'accept':
        _add(shipmentId, 'accepted', 'Təklif qəbul edildi', 'accepted',
            actions: _actionsFor(shipmentId, 'accepted', false));
        return 'Təklif qəbul edildi';
      case 'decline':
        _add(shipmentId, 'declined', 'Təklif rədd edildi', 'declined');
        return 'Təklif rədd edildi';
      case 'counter':
        _add(shipmentId, 'proposal', 'Qarşı təklif', 'proposal_pending',
            isMine: true,
            payload: {..._terms, ...?body},
            actions: _actionsFor(shipmentId, 'proposal_pending', true));
        return 'Qarşı təklif göndərildi';
      case 'cancel':
        final withdrawn = current == 'proposal_pending';
        _add(shipmentId, 'cancelled', 'Sövdələşmə ləğv edildi', 'cancelled',
            payload: {..._terms, ...?body});
        return withdrawn ? 'Təklif geri çəkildi' : 'Sövdələşmə ləğv edildi';
      case 'picked-up':
        _add(shipmentId, 'picked_up', 'Bağlama götürüldü', 'picked_up',
            actions: _actionsFor(shipmentId, 'picked_up', false));
        return 'Bağlama götürüldü';
      case 'delivered':
        _add(shipmentId, 'delivered', 'Çatdırıldı', 'delivered',
            actions: _actionsFor(shipmentId, 'delivered', false));
        return 'Çatdırılma qeyd edildi';
      case 'complete':
        _add(shipmentId, 'completed', 'Tamamlandı', 'completed');
        return 'Sövdələşmə tamamlandı';
      case 'dispute':
        _add(shipmentId, 'disputed', 'Problem bildirildi', 'disputed',
            payload: {..._terms, ...?body});
        return 'Müraciətiniz qeydə alındı';
    }
    throw StateError('Unknown endpoint: $endpoint');
  }

  List<Map<String, dynamic>> _actionsFor(
    String shipmentId,
    String status,
    bool mineProposal,
  ) {
    final isCarrier = _roles[shipmentId] == 'carrier';
    Map<String, dynamic> action(
      String key,
      String label,
      String style, {
      String? endpoint,
      bool needsInput = false,
      bool confirm = false,
    }) =>
        {
          'key': key,
          'label': label,
          'style': style,
          'endpoint': endpoint ?? key,
          'needs_input': needsInput,
          'confirm': confirm,
        };
    final dispute = action('dispute', 'Problem var', 'danger',
        needsInput: true, confirm: true);
    final cancel =
        action('cancel', 'Ləğv et', 'danger', needsInput: true, confirm: true);
    return switch (status) {
      'proposal_pending' when mineProposal => [
          action('withdraw', 'Təklifi geri çək', 'danger',
              endpoint: 'cancel', needsInput: true),
        ],
      'proposal_pending' => [
          action('accept', 'Qəbul et', 'primary'),
          action('decline', 'Rədd et', 'danger', confirm: true),
          action('counter', 'Şərtləri dəyiş', 'secondary', needsInput: true),
        ],
      'accepted' when isCarrier => [
          action('picked_up', 'Götürdüm', 'primary',
              endpoint: 'picked-up', confirm: true),
          cancel,
        ],
      'accepted' => [cancel],
      'picked_up' when isCarrier => [
          action('delivered', 'Çatdırdım', 'primary', confirm: true),
          dispute,
        ],
      'picked_up' => [dispute],
      'delivered' when isCarrier => [dispute],
      'delivered' => [action('complete', 'Təsdiqlə', 'primary'), dispute],
      _ => const [],
    };
  }

  void _add(
    String shipmentId,
    String type,
    String label,
    String status, {
    bool isMine = false,
    Map<String, dynamic> payload = _terms,
    List<Map<String, dynamic>> actions = const [],
  }) {
    final id = ++_nextId;
    _feed.add({
      'id': 'm$id',
      'type': 'system_card',
      'is_mine': isMine,
      'created_at': DateTime(2026, 10, 12, 12, id).toIso8601String(),
      'sender': {'id': isMine ? 1 : 2, 'fullname': isMine ? 'Mən' : 'Aysel'},
      'card': {
        'type': type,
        'label': label,
        'shipment_id': shipmentId,
        'shipment_status': status,
        'is_interactive': false,
        'actions': actions,
        'payload': payload,
      },
    });
  }
}

class _FakeChatApi extends ChatApi {
  _FakeChatApi(this._backend) : super(Dio());

  final _FakeBackend _backend;

  @override
  Future<ShipmentResponse> getShipment(String shipmentId) async {
    return ShipmentResponse.fromJson({'data': _backend.shipment(shipmentId)});
  }

  @override
  Future<String?> shipmentAction(
    String shipmentId,
    String action, {
    Map<String, dynamic>? body,
  }) {
    return _backend.post(shipmentId, action, body);
  }
}

class _FakeContentRepository implements AuthRepository {
  @override
  Future<ContentResponse> getContent({String? group, String? lang}) async {
    return ContentResponse();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
