import 'dart:async';

import 'package:buking/data/network/response/chat_response.dart';
import 'package:buking/screens/home/tabs/profile_tab/deals/deal_action_runner.dart';
import 'package:buking/screens/home/tabs/profile_tab/deals/deal_action_sheets.dart';
import 'package:buking/screens/home/tabs/profile_tab/deals/widgets/deal_action_buttons.dart';
import 'package:buking/screens/home/tabs/profile_tab/deals/widgets/deal_status.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _complete = DealAction(
  key: 'complete',
  label: 'Təsdiqlə',
  style: 'primary',
  endpoint: 'complete',
);
const _completeWithConfirm = DealAction(
  key: 'complete',
  label: 'Təsdiqlə',
  style: 'primary',
  endpoint: 'complete',
  confirm: true,
);
const _dispute = DealAction(
  key: 'dispute',
  label: 'Problem var',
  style: 'danger',
  endpoint: 'dispute',
  needsInput: true,
  confirm: true,
);
const _withdraw = DealAction(
  key: 'withdraw',
  label: 'Təklifi geri çək',
  style: 'danger',
  endpoint: 'cancel',
  needsInput: true,
);
const _counter = DealAction(
  key: 'counter',
  label: 'Şərtləri dəyiş',
  style: 'secondary',
  endpoint: 'counter',
  needsInput: true,
);

Map<String, dynamic> _cardJson(dynamic actions, {bool withKey = true}) => {
      'type': 'delivered',
      'label': 'Çatdırıldı',
      'shipment_id': '01JSHIPMENT',
      'shipment_status': 'delivered',
      'is_interactive': true,
      if (withKey) 'actions': actions,
      'payload': {'weight_kg': 2, 'price_total': 16},
    };

Map<String, dynamic> _shipmentJson({
  dynamic actions,
  bool withActions = true,
  String status = 'delivered',
  bool awaitingMe = true,
  List<String> available = const [],
}) =>
    {
      'id': '01JSHIPMENT',
      'status': status,
      'status_label': status,
      'is_awaiting_me': awaitingMe,
      'available_actions': available,
      if (withActions) 'actions': actions,
    };

Finder _elevated(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate((widget) => widget is ElevatedButton),
    );

bool _isEnabled(WidgetTester tester, String label) =>
    tester.widget<ElevatedButton>(_elevated(label)).onPressed != null;

Widget _host(Widget child, {double width = 320, ThemeData? theme}) =>
    MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Center(child: SizedBox(width: width, child: child)),
      ),
    );

class _Harness {
  final controller = DealActionController();
  final bodies = <Map<String, dynamic>?>[];
  final messages = <(String, bool)>[];
  Completer<String?>? pending;
  late BuildContext context;

  Future<void> pump(WidgetTester tester, {TargetPlatform? platform}) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: platform),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              this.context = context;
              return const SizedBox.expand();
            },
          ),
        ),
      ),
    );
  }

  Future<void> run(
    DealAction action, {
    String scope = 'message-1',
    DealCounterPrefill prefill = const DealCounterPrefill(),
    Map<String, String> content = const {},
  }) {
    return controller.run(
      context,
      scope: scope,
      action: action,
      content: content,
      prefill: prefill,
      execute: (body) {
        bodies.add(body);
        return (pending = Completer<String?>()).future;
      },
      onMessage: (message, {required isError}) =>
          messages.add((message, isError)),
    );
  }
}

void main() {
  group('Deal action model', () {
    test('reads card actions in the order the server sent them', () {
      final card = ChatCard.fromJson(_cardJson([
        {
          'key': 'complete',
          'label': 'Təsdiqlə',
          'style': 'primary',
          'endpoint': 'complete',
          'needs_input': false,
          'confirm': false,
        },
        {
          'key': 'dispute',
          'label': 'Problem var',
          'style': 'danger',
          'endpoint': 'dispute',
          'needs_input': true,
          'confirm': true,
        },
      ]));

      expect(card.shipmentStatus, 'delivered');
      expect(card.actions.map((a) => a.key), ['complete', 'dispute']);
      expect(card.actions.first.label, 'Təsdiqlə');
      expect(card.actions.first.isPrimary, isTrue);
      expect(card.actions.first.needsInput, isFalse);
      expect(card.actions.first.confirm, isFalse);
      expect(card.actions.last.isDanger, isTrue);
      expect(card.actions.last.needsInput, isTrue);
      expect(card.actions.last.confirm, isTrue);
    });

    test('keeps the endpoint apart from the key', () {
      final card = ChatCard.fromJson(_cardJson([
        {'key': 'withdraw', 'label': 'Təklifi geri çək', 'endpoint': 'cancel'},
        {'key': 'picked_up', 'label': 'Götürdüm', 'endpoint': 'picked-up'},
      ]));

      expect(card.actions.map((a) => a.endpoint), ['cancel', 'picked-up']);
      expect(card.actions.first.style, 'secondary');
    });

    test('a card without usable actions has no buttons', () {
      expect(ChatCard.fromJson(_cardJson(null, withKey: false)).actions,
          isEmpty);
      expect(ChatCard.fromJson(_cardJson(null)).actions, isEmpty);
      expect(ChatCard.fromJson(_cardJson(const [])).actions, isEmpty);
      expect(ChatCard.fromJson(_cardJson('complete')).actions, isEmpty);
      expect(ChatCard.fromJson(_cardJson({'key': 'complete'})).actions,
          isEmpty);
    });

    test('skips entries that cannot be drawn or posted', () {
      final card = ChatCard.fromJson(_cardJson([
        'complete',
        {'key': 'no_label', 'endpoint': 'accept'},
        {'key': 'no_endpoint', 'label': 'Qəbul et'},
        {'key': 'blank', 'label': '  ', 'endpoint': 'accept'},
        {'key': 'accept', 'label': 'Qəbul et', 'endpoint': 'accept'},
      ]));

      expect(card.actions.map((a) => a.key), ['accept']);
    });

    test('is_interactive alone never produces buttons', () {
      final card = ChatCard.fromJson(_cardJson(null, withKey: false));
      expect(card.isInteractive, isTrue);
      expect(card.actions, isEmpty);
    });

    test('withoutActions drops only the buttons', () {
      final card = ChatCard.fromJson(_cardJson([
        {'key': 'complete', 'label': 'Təsdiqlə', 'endpoint': 'complete'},
      ]));
      final stripped = card.withoutActions();

      expect(stripped.actions, isEmpty);
      expect(stripped.type, card.type);
      expect(stripped.label, card.label);
      expect(stripped.shipmentId, card.shipmentId);
      expect(stripped.shipmentStatus, card.shipmentStatus);
      expect(stripped.payload, card.payload);
    });

    test('a shipment tells "no buttons" apart from "no actions field"', () {
      final none = ShipmentData.fromJson(_shipmentJson(actions: const []));
      final absent = ShipmentData.fromJson(_shipmentJson(withActions: false));

      expect(none.actions, isEmpty);
      expect(absent.actions, isNull);
    });
  });

  group('Deal screen actions', () {
    test('uses the server list as is — even when it is empty', () {
      final shipment = ShipmentData.fromJson(_shipmentJson(
        actions: const [],
        available: const ['complete', 'dispute'],
      ));

      expect(dealActionsOf(shipment, const {}), isEmpty);
    });

    test('rebuilds buttons from legacy ids only without an actions field', () {
      final shipment = ShipmentData.fromJson(_shipmentJson(
        withActions: false,
        status: 'accepted',
        available: const ['picked_up', 'cancel', 'something_new'],
      ));
      final actions = dealActionsOf(shipment, const {});

      expect(actions.map((a) => a.key), ['picked_up', 'cancel']);
      expect(actions.first.endpoint, 'picked-up');
      expect(actions.first.confirm, isTrue);
      expect(actions.last.needsInput, isTrue);
      expect(actions.every((a) => a.label.isNotEmpty), isTrue);
    });

    test('legacy: the author of a pending proposal can take it back', () {
      final shipment = ShipmentData.fromJson(_shipmentJson(
        withActions: false,
        status: 'proposal_pending',
        awaitingMe: false,
      ));
      final actions = dealActionsOf(shipment, const {});

      expect(actions.single.key, 'withdraw');
      expect(actions.single.endpoint, 'cancel');
      expect(actions.single.needsInput, isTrue);
    });
  });

  group('Button line layout', () {
    test('three short buttons share one line equally', () {
      final lines = layoutDealActionWidths([60, 70, 80], 316);

      expect(lines, hasLength(1));
      expect(lines.single, everyElement(closeTo(100, 0.001)));
    });

    test('a button whose label does not fit its share takes more', () {
      final lines = layoutDealActionWidths([60, 60, 150], 300);

      expect(lines, hasLength(1));
      expect(lines.single[2], 150);
      expect(lines.single[0], closeTo(67, 0.001));
      expect(lines.single[1], closeTo(67, 0.001));
    });

    test('more than three buttons wrap to a second line', () {
      final lines = layoutDealActionWidths([50, 50, 50, 50], 300);

      expect(lines.map((line) => line.length), [3, 1]);
      expect(lines.last.single, 300);
    });

    test('buttons that do not fit side by side wrap instead of scrolling', () {
      final lines = layoutDealActionWidths([150, 150, 150], 300);

      expect(lines.map((line) => line.length), [1, 1, 1]);
    });

    test('never lays a line out wider than the card', () {
      for (final natural in [
        [40.0],
        [500.0],
        [120.0, 130.0],
        [90.0, 200.0, 40.0],
        [140.0, 60.0, 60.0, 220.0, 30.0],
      ]) {
        for (final line in layoutDealActionWidths(natural, 280)) {
          final total = line.fold<double>(0, (sum, width) => sum + width) +
              8 * (line.length - 1);
          expect(total, lessThanOrEqualTo(280 + 0.001), reason: '$natural');
        }
      }
    });

    test('keeps every button, in order', () {
      expect(layoutDealActionWidths([140, 60, 60, 220, 30], 280), [
        [140.0, 62.0, 62.0],
        [220.0, 52.0],
      ]);
    });

    test('three buttons a little too wide give up padding, not the row', () {
      const natural = [86.0, 81.0, 120.0];
      const available = 283.6;

      expect(layoutDealActionWidths(natural, available),
          hasLength(greaterThan(1)));

      final lines = layoutDealActionWidths(natural, available, squeeze: 12);
      expect(lines, hasLength(1));
      final line = lines.single;
      expect(line[0] + line[1] + line[2] + 16, closeTo(available, 0.001));
      for (var i = 0; i < natural.length; i++) {
        expect(line[i], greaterThanOrEqualTo(natural[i] - 12));
        expect(line[i], lessThan(natural[i]));
      }
    });

    test('squeezing has a limit: labels are never cut to keep a row', () {
      final lines = layoutDealActionWidths([150, 150, 150], 300, squeeze: 12);

      expect(lines.map((line) => line.length), [2, 1]);
      expect(lines.first, everyElement(closeTo(146, 0.001)));
      expect(lines.last.single, 300);
    });

    test('room to spare is not squeezed', () {
      expect(
        layoutDealActionWidths([60, 70, 80], 316, squeeze: 12).single,
        everyElement(closeTo(100, 0.001)),
      );
    });
  });

  group('DealActionButtons', () {
    testWidgets('draws the server labels in the server order', (tester) async {
      const labels = ['Problem var', 'Şərtləri dəyiş', 'Təsdiqlə'];
      final tapped = <String>[];
      await tester.pumpWidget(_host(
        DealActionButtons(
          actions: const [_dispute, _counter, _complete],
          onAction: (action) => tapped.add(action.key),
        ),
        width: 640,
      ));

      final centers = [
        for (final label in labels) tester.getCenter(find.text(label)),
      ];
      expect(centers[0].dx, lessThan(centers[1].dx));
      expect(centers[1].dx, lessThan(centers[2].dx));
      expect(centers.map((center) => center.dy).toSet(), hasLength(1));
      expect(tester.getSize(find.byType(DealActionButtons)).height, 40);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Təsdiqlə'));
      await tester.tap(find.text('Problem var'));
      expect(tapped, ['complete', 'dispute']);
    });

    testWidgets('stacked on a narrow card, the order runs top to bottom',
        (tester) async {
      await tester.pumpWidget(_host(DealActionButtons(
        actions: const [_dispute, _counter, _complete],
        onAction: (_) {},
      )));

      final ys = [
        for (final label in ['Problem var', 'Şərtləri dəyiş', 'Təsdiqlə'])
          tester.getCenter(find.text(label)).dy,
      ];
      expect(ys[0], lessThan(ys[1]));
      expect(ys[1], lessThan(ys[2]));
      expect(tester.takeException(), isNull);
    });

    testWidgets('three buttons that almost fit stay in one row, labels whole',
        (tester) async {
      DealAction action(String label) =>
          DealAction(key: label, label: label, endpoint: label);
      const labels = ['Qebul1', 'Redd22', 'Deyis3'];
      Future<void> pumpAt(double width) => tester.pumpWidget(_host(
            DealActionButtons(
              actions: [for (final label in labels) action(label)],
              onAction: (_) {},
            ),
            width: width,
          ));

      await pumpAt(640);
      final whole = [
        for (final label in labels) tester.getSize(find.text(label)),
      ];
      final natural =
          whole.fold<double>(0, (sum, size) => sum + size.width) + 3 * 24 + 16;

      await pumpAt(natural - 20);
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(DealActionButtons)).height, 40);
      for (var i = 0; i < labels.length; i++) {
        expect(tester.getSize(find.text(labels[i])), whole[i]);
      }
    });

    testWidgets('is 40px tall and fills the card width', (tester) async {
      await tester.pumpWidget(_host(
        DealActionButtons(
          actions: const [_complete, _dispute],
          onAction: (_) {},
        ),
        width: 420,
      ));

      final size = tester.getSize(find.byType(DealActionButtons));
      expect(size.height, 40);
      expect(size.width, 420);
    });

    testWidgets('draws nothing for a card without actions', (tester) async {
      await tester.pumpWidget(_host(Column(
        children: [
          DealActionButtons(actions: const [], onAction: (_) {}),
          DealCardActions(actions: const [], onAction: (_) {}),
        ],
      )));

      expect(find.byType(InkWell), findsNothing);
      expect(tester.getSize(find.byType(DealCardActions)).height, 0);
    });

    testWidgets('while sending: spinner on the tapped button, all inert',
        (tester) async {
      final tapped = <String>[];
      await tester.pumpWidget(_host(DealActionButtons(
        actions: const [_complete, _dispute],
        locked: true,
        busyKey: 'complete',
        onAction: (action) => tapped.add(action.key),
      )));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Təsdiqlə'), findsNothing);
      expect(find.text('Problem var'), findsOneWidget);
      expect(
        tester.getSize(find.byType(CircularProgressIndicator)),
        const Size(16, 16),
      );

      await tester.tap(find.text('Problem var'));
      await tester.tap(find.byType(CircularProgressIndicator));
      expect(tapped, isEmpty);
    });

    testWidgets('long labels wrap to more lines without overflowing',
        (tester) async {
      await tester.pumpWidget(_host(
        DealActionButtons(
          actions: const [
            DealAction(
                key: 'a', label: 'Çatdırılmanı təsdiqlə', endpoint: 'a'),
            DealAction(
                key: 'b', label: 'Şərtləri yenidən dəyiş', endpoint: 'b'),
            DealAction(key: 'c', label: 'Problem barədə yaz', endpoint: 'c'),
            DealAction(key: 'd', label: 'Ləğv et', endpoint: 'd'),
          ],
          onAction: (_) {},
        ),
        width: 240,
      ));

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(DealActionButtons)).height,
        greaterThan(40),
      );
      for (final label in ['Çatdırılmanı təsdiqlə', 'Ləğv et']) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('renders in the dark theme', (tester) async {
      await tester.pumpWidget(_host(
        DealCardActions(
          actions: const [_complete, _counter, _dispute],
          onAction: (_) {},
        ),
        theme: ThemeData.dark(),
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('Təsdiqlə'), findsOneWidget);
    });
  });

  group('DealActionController', () {
    testWidgets('a double tap sends one request', (tester) async {
      final harness = _Harness();
      await harness.pump(tester);

      final first = harness.run(_complete);
      final second = harness.run(_complete);
      final other = harness.run(_dispute, scope: 'message-2');
      await tester.pump();

      expect(harness.bodies, [null]);
      expect(harness.controller.isLocked('message-1'), isTrue);
      expect(harness.controller.busyKey('message-1'), 'complete');
      expect(harness.controller.isLocked('message-2'), isFalse);

      harness.pending!.complete('Sövdələşmə tamamlandı');
      await Future.wait([first, second, other]);

      expect(harness.bodies, hasLength(1));
      expect(harness.messages, [('Sövdələşmə tamamlandı', false)]);
      expect(harness.controller.isBusy, isFalse);
      expect(harness.controller.isLocked('message-1'), isFalse);
    });

    testWidgets('an error shows the server message and unlocks the buttons',
        (tester) async {
      final harness = _Harness();
      await harness.pump(tester);

      final running = harness.run(_complete);
      await tester.pump();
      final request = RequestOptions(path: '/shipments/1/complete');
      harness.pending!.completeError(DioException(
        requestOptions: request,
        response: Response(
          requestOptions: request,
          statusCode: 422,
          data: {'message': 'Bu əməliyyat artıq mümkün deyil.'},
        ),
      ));
      await running;

      expect(harness.messages, [('Bu əməliyyat artıq mümkün deyil.', true)]);
      expect(harness.controller.isBusy, isFalse);

      final retry = harness.run(_complete);
      await tester.pump();
      expect(harness.bodies, hasLength(2));
      harness.pending!.complete(null);
      await retry;
      expect(harness.messages.last.$2, isFalse);
      expect(harness.messages.last.$1, isNotEmpty);
    });

    testWidgets('notifies listeners when the lock changes', (tester) async {
      final harness = _Harness();
      await harness.pump(tester);
      var notifications = 0;
      harness.controller.addListener(() => notifications++);

      final running = harness.run(_complete);
      await tester.pump();
      expect(notifications, 1);
      harness.pending!.complete('ok');
      await running;
      expect(notifications, 2);
    });

    testWidgets('confirm: asks first, sends only on a yes', (tester) async {
      final harness = _Harness();
      await harness.pump(tester);

      final declined = harness.run(_completeWithConfirm);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Əminsiniz?'), findsOneWidget);
      expect(find.text('Təsdiqlə'), findsNWidgets(2));
      await tester.tap(find.widgetWithText(TextButton, 'Ləğv et'));
      await tester.pumpAndSettle();
      await declined;
      expect(harness.bodies, isEmpty);
      expect(harness.controller.isBusy, isFalse);

      final accepted = harness.run(_completeWithConfirm);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Təsdiqlə'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(harness.bodies, [null]);
      harness.pending!.complete('ok');
      await accepted;
    });

    testWidgets('confirm is a native alert on iOS', (tester) async {
      final harness = _Harness();
      await harness.pump(tester, platform: TargetPlatform.iOS);

      final running = harness.run(_completeWithConfirm);
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text('Əminsiniz?'), findsOneWidget);
      await tester.tap(find.widgetWithText(CupertinoDialogAction, 'Ləğv et'));
      await tester.pumpAndSettle();
      await running;
      expect(harness.bodies, isEmpty);
    });

    testWidgets('dispute is not sent with fewer than 5 characters',
        (tester) async {
      final harness = _Harness();
      await harness.pump(tester);

      final running = harness.run(_dispute);
      await tester.pumpAndSettle();
      expect(find.text('Nə baş verdi?'), findsOneWidget);
      expect(find.text('Problem var'), findsOneWidget);
      expect(_isEnabled(tester, 'Problemi göndər'), isFalse);

      await tester.enterText(find.byType(TextField), '  abcd  ');
      await tester.pump();
      expect(find.text('4/1000'), findsOneWidget);
      expect(find.text('Ən azı 5 simvol yazın'), findsOneWidget);
      expect(_isEnabled(tester, 'Problemi göndər'), isFalse);
      await tester.tap(find.text('Problemi göndər'));
      await tester.pumpAndSettle();
      expect(harness.bodies, isEmpty);

      await tester.enterText(find.byType(TextField), ' Mal zədələnib ');
      await tester.pump();
      expect(find.text('Ən azı 5 simvol yazın'), findsNothing);
      expect(_isEnabled(tester, 'Problemi göndər'), isTrue);

      await tester.tap(find.text('Problemi göndər'));
      await tester.pumpAndSettle();
      expect(find.text('Əminsiniz?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Ləğv et'));
      await tester.pumpAndSettle();
      expect(harness.bodies, isEmpty);
      expect(find.text(' Mal zədələnib '), findsOneWidget);

      await tester.tap(find.text('Problemi göndər'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Problem var'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(harness.bodies, [
        {'reason': 'Mal zədələnib'},
      ]);
      harness.pending!.complete('ok');
      await running;
    });

    testWidgets('dismissing the input sheet sends nothing', (tester) async {
      final harness = _Harness();
      await harness.pump(tester);

      final running = harness.run(_dispute);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Geri'));
      await tester.pumpAndSettle();
      await running;

      expect(harness.bodies, isEmpty);
      expect(harness.messages, isEmpty);
      expect(harness.controller.isBusy, isFalse);
    });

    testWidgets('cancelling requires a reason and posts its code',
        (tester) async {
      final harness = _Harness();
      await harness.pump(tester);

      final running = harness.run(_withdraw);
      await tester.pumpAndSettle();
      expect(find.text('Təklifi geri çək'), findsNWidgets(2));
      expect(_isEnabled(tester, 'Təklifi geri çək'), isFalse);
      await tester.tap(_elevated('Təklifi geri çək'));
      await tester.pumpAndSettle();
      expect(harness.bodies, isEmpty);

      await tester.tap(find.text('Şərtlərlə razılaşmadıq'));
      await tester.pump();
      expect(_isEnabled(tester, 'Təklifi geri çək'), isTrue);
      await tester.enterText(find.byType(TextField), ' Qiymət uyğun deyil ');
      await tester.tap(_elevated('Təklifi geri çək'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(harness.bodies, [
        {
          'reason_code': 'terms_disagreement',
          'reason_note': 'Qiymət uyğun deyil',
        },
      ]);
      harness.pending!.complete('ok');
      await running;
    });

    testWidgets('a failed request keeps what was typed for the next try',
        (tester) async {
      final harness = _Harness();
      await harness.pump(tester);
      Future<void> close() async {
        await tester.ensureVisible(find.text('Geri'));
        await tester.tap(find.text('Geri'));
      }

      Future<void> fillAndSend() async {
        await tester.tap(_elevated('Təklifi geri çək'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
      }

      var running = harness.run(_withdraw);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Şərtlərlə razılaşmadıq'));
      await tester.enterText(find.byType(TextField), 'Qiymət uyğun deyil');
      await tester.pump();
      await fillAndSend();
      final request = RequestOptions(path: '/shipments/1/cancel');
      harness.pending!.completeError(DioException(
        requestOptions: request,
        response: Response(requestOptions: request, statusCode: 429),
      ));
      await running;
      await tester.pumpAndSettle();
      expect(harness.messages.single.$2, isTrue);

      running = harness.run(_withdraw, scope: 'message-2');
      await tester.pumpAndSettle();
      expect(find.text('Qiymət uyğun deyil'), findsNothing);
      expect(_isEnabled(tester, 'Təklifi geri çək'), isFalse);
      await close();
      await tester.pumpAndSettle();
      await running;

      running = harness.run(_withdraw);
      await tester.pumpAndSettle();
      expect(find.text('Qiymət uyğun deyil'), findsOneWidget);
      expect(_isEnabled(tester, 'Təklifi geri çək'), isTrue);
      await fillAndSend();
      expect(harness.bodies.last, {
        'reason_code': 'terms_disagreement',
        'reason_note': 'Qiymət uyğun deyil',
      });
      harness.pending!.complete('ok');
      await running;
      await tester.pumpAndSettle();

      running = harness.run(_withdraw);
      await tester.pumpAndSettle();
      expect(find.text('Qiymət uyğun deyil'), findsNothing);
      expect(_isEnabled(tester, 'Təklifi geri çək'), isFalse);
      await close();
      await tester.pumpAndSettle();
      await running;
    });

    testWidgets('a failed counter offer reopens with the terms that were sent',
        (tester) async {
      final harness = _Harness();
      await harness.pump(tester);
      final prefill = DealCounterPrefill.fromPayload(const {
        'weight_kg': 2,
        'price_total': 16,
        'package_type_code': 'documents',
      });

      var running = harness.run(_counter, prefill: prefill);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(1), '21');
      await tester.enterText(find.byType(TextField).at(2), 'Yük ağırdır');
      await tester.pump();
      await tester.ensureVisible(find.text('Qarşı təklifi göndər'));
      await tester.tap(find.text('Qarşı təklifi göndər'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      final request = RequestOptions(path: '/shipments/1/counter');
      harness.pending!.completeError(DioException(
        requestOptions: request,
        response: Response(requestOptions: request, statusCode: 422),
      ));
      await running;
      await tester.pumpAndSettle();

      running = harness.run(_counter, prefill: prefill);
      await tester.pumpAndSettle();
      expect(find.text('21'), findsOneWidget);
      expect(find.text('16'), findsNothing);
      expect(find.text('Yük ağırdır'), findsOneWidget);
      await tester.ensureVisible(find.text('İmtina et'));
      await tester.tap(find.text('İmtina et'));
      await tester.pumpAndSettle();
      await running;
    });

    testWidgets('counter form starts from the card terms', (tester) async {
      final harness = _Harness();
      await harness.pump(tester);

      final running = harness.run(
        _counter,
        prefill: DealCounterPrefill.fromPayload(const {
          'weight_kg': '2.50',
          'price_total': 16,
          'package_type_code': 'documents',
        }),
      );
      await tester.pumpAndSettle();
      expect(find.text('Şərtləri dəyiş'), findsOneWidget);
      expect(find.text('2.5'), findsOneWidget);
      expect(find.text('16'), findsOneWidget);
      expect(_isEnabled(tester, 'Qarşı təklifi göndər'), isTrue);

      await tester.enterText(find.byType(TextField).at(1), '0');
      await tester.pump();
      expect(_isEnabled(tester, 'Qarşı təklifi göndər'), isFalse);

      await tester.enterText(find.byType(TextField).at(1), '20,5');
      await tester.enterText(find.byType(TextField).at(2), 'Daha çox yük var');
      await tester.pump();
      await tester.ensureVisible(find.text('Qarşı təklifi göndər'));
      await tester.tap(find.text('Qarşı təklifi göndər'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(harness.bodies, [
        {
          'weight_kg': 2.5,
          'price_total': 20.5,
          'package_type_code': 'documents',
          'note': 'Daha çox yük var',
        },
      ]);
      harness.pending!.complete('ok');
      await running;
    });

    testWidgets('an input action this build cannot collect is not sent',
        (tester) async {
      final harness = _Harness();
      await harness.pump(tester);

      await harness.run(const DealAction(
        key: 'reschedule',
        label: 'Vaxtı dəyiş',
        endpoint: 'reschedule',
        needsInput: true,
      ));

      expect(harness.bodies, isEmpty);
      expect(harness.messages.single.$2, isTrue);
      expect(harness.controller.isBusy, isFalse);
    });
  });

  group('dealActionErrorMessage', () {
    final request = RequestOptions(path: '/shipments/1/accept');
    DioException failure(Object? data, [int status = 422]) => DioException(
          requestOptions: request,
          response: Response(
              requestOptions: request, statusCode: status, data: data),
        );

    test('prefers the server message', () {
      expect(
        dealActionErrorMessage(failure({
          'message': 'Bu təklif artıq cavablandırılıb.',
          'errors': {
            'reason': ['Səbəb çox qısadır.'],
          },
        }, 403)),
        'Bu təklif artıq cavablandırılıb.',
      );
    });

    test('falls back to the first validation error, then a generic line', () {
      expect(
        dealActionErrorMessage(failure({
          'errors': {
            'reason': ['Səbəb çox qısadır.'],
          },
        })),
        'Səbəb çox qısadır.',
      );
      expect(dealActionErrorMessage(failure('<html>')), isNotEmpty);
      expect(dealActionErrorMessage(StateError('boom')), isNotEmpty);
      expect(
        dealActionErrorMessage(
            DioException(requestOptions: request, type: DioExceptionType.cancel)),
        isNotEmpty,
      );
    });
  });
}
