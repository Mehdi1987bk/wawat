import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:buking/data/network/response/receipt.dart';
import 'package:buking/data/network/response/verification_state.dart';
import 'package:buking/screens/payments/receipt_pdf.dart';
import 'package:buking/screens/payments/receipt_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _pdfUrl = 'https://api.wawatair.com/api/v1/receipts/promotion/01M3/pdf';
final _pdfBytes = Uint8List.fromList(utf8.encode('%PDF-1.7\n…receipt…'));

/// Answers every request from [handler] and counts the calls.
class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

Dio _dio(_Adapter adapter) => Dio()..httpClientAdapter = adapter;

ResponseBody _pdfResponse() => ResponseBody.fromBytes(
  _pdfBytes,
  200,
  headers: {
    'content-type': ['application/pdf'],
    'content-disposition': [
      'attachment; filename="wawatair-receipt-WA-12345678.pdf"',
    ],
  },
);

ResponseBody _json(int status, Map<String, dynamic> body) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        'content-type': ['application/json'],
      },
    );

Receipt _receipt({String? pdfUrl = _pdfUrl}) => Receipt(
  kind: 'promotion',
  number: 'WA-12345678',
  title: 'VİP · 3 gün',
  amount: 5,
  currency: 'AZN',
  status: 'paid',
  isPaid: true,
  supportEmail: 'support@wawatair.com',
  pdfUrl: pdfUrl,
);

class _FakeStore extends ReceiptPdfStore {
  _FakeStore({this.location = ReceiptPdfLocation.downloads, this.opens = true});

  final ReceiptPdfLocation location;
  final bool opens;
  final saved = <ReceiptPdfFile>[];
  int openCalls = 0;
  int shareCalls = 0;

  @override
  Future<SavedReceiptPdf> save(ReceiptPdfFile file) async {
    saved.add(file);
    return SavedReceiptPdf(location, 'content://downloads/1', file);
  }

  @override
  Future<bool> open(SavedReceiptPdf saved, {String? subject}) async {
    openCalls++;
    return opens;
  }

  @override
  Future<void> share(ReceiptPdfFile file, {String? subject}) async {
    shareCalls++;
  }
}

Future<void> _pumpReceipt(
  WidgetTester tester, {
  required Receipt receipt,
  Dio? dio,
  ReceiptPdfStore store = const ReceiptPdfStore(),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ReceiptScreen(receipt: receipt, dio: dio, store: store),
    ),
  );
  await tester.pumpAndSettle();
}

/// Taps [label] and lets the (real-async) Dio request finish.
Future<void> _tapAndSettle(WidgetTester tester, Finder target) async {
  await tester.runAsync(() async {
    await tester.tap(target);
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });
  await tester.pumpAndSettle();
}

void main() {
  group('Receipt.pdf_url', () {
    test('parsed from the receipt block', () {
      final r = Receipt.fromJson(const {
        'kind': 'verification',
        'number': 'WA-1',
        'is_paid': true,
        'pdf_url': _pdfUrl,
      })!;
      expect(r.pdfUrl, _pdfUrl);
    });

    test('null / empty while unpaid', () {
      expect(Receipt.fromJson(const {'kind': 'promotion'})!.pdfUrl, isNull);
      expect(
        Receipt.fromJson(const {'kind': 'promotion', 'pdf_url': ''})!.pdfUrl,
        isNull,
      );
    });

    test('verification carries the receipt (nested or at the root)', () {
      final nested = VerificationState.fromJson(const {
        'id': 'v1',
        'status': 'approved',
        'receipt': {'kind': 'verification', 'is_paid': true, 'pdf_url': 'x'},
      });
      expect(nested.receipt?.kind, 'verification');
      expect(nested.receipt?.pdfUrl, 'x');

      final root = VerificationState.fromJson(const {
        'id': 'v1',
        'status': 'approved',
      }, fallbackReceipt: _receipt());
      expect(root.receipt?.number, 'WA-12345678');
    });
  });

  group('file name', () {
    test('from Content-Disposition', () {
      expect(
        receiptPdfFileName(
          'attachment; filename="wawatair-receipt-WA-XXXX.pdf"',
          'WA-1',
        ),
        'wawatair-receipt-WA-XXXX.pdf',
      );
    });

    test('RFC 5987 filename* wins', () {
      expect(
        receiptPdfFileName(
          "attachment; filename=\"a.pdf\"; filename*=UTF-8''wawatair-receipt-WA-9.pdf",
          'WA-1',
        ),
        'wawatair-receipt-WA-9.pdf',
      );
    });

    test('falls back to the receipt number; never a path', () {
      expect(receiptPdfFileName(null, 'WA-7'), 'wawatair-receipt-WA-7.pdf');
      expect(
        receiptPdfFileName('attachment; filename="../../etc/x y"', 'WA-7'),
        'x_y.pdf',
      );
    });
  });

  group('downloadReceiptPdf', () {
    test(
      '200 PDF → bytes + server file name, Bearer via the app Dio',
      () async {
        final adapter = _Adapter((_) async => _pdfResponse());
        final file = await downloadReceiptPdf(_dio(adapter), _receipt());

        expect(file.bytes, _pdfBytes);
        expect(file.fileName, 'wawatair-receipt-WA-12345678.pdf');
        expect(adapter.requests.single.uri.toString(), _pdfUrl);
        expect(adapter.requests.single.responseType, ResponseType.bytes);
      },
    );

    test('no connection → network', () async {
      final adapter = _Adapter(
        (_) async => throw const SocketException('offline'),
      );
      await expectLater(
        downloadReceiptPdf(_dio(adapter), _receipt()),
        throwsA(
          isA<ReceiptPdfException>().having(
            (e) => e.failure,
            'failure',
            ReceiptPdfFailure.network,
          ),
        ),
      );
    });

    test('404 → server, with the backend message', () async {
      final adapter = _Adapter(
        (_) async => _json(404, {'message': 'Qəbz tapılmadı.'}),
      );
      await expectLater(
        downloadReceiptPdf(_dio(adapter), _receipt()),
        throwsA(
          isA<ReceiptPdfException>()
              .having((e) => e.failure, 'failure', ReceiptPdfFailure.server)
              .having((e) => e.statusCode, 'status', 404)
              .having((e) => e.serverMessage, 'message', 'Qəbz tapılmadı.'),
        ),
      );
    });

    test('200 but not a PDF → notPdf', () async {
      final adapter = _Adapter(
        (_) async => ResponseBody.fromString('<html>login</html>', 200),
      );
      await expectLater(
        downloadReceiptPdf(_dio(adapter), _receipt()),
        throwsA(
          isA<ReceiptPdfException>().having(
            (e) => e.failure,
            'failure',
            ReceiptPdfFailure.notPdf,
          ),
        ),
      );
    });
  });

  group('receipt screen', () {
    testWidgets('no pdf_url → no PDF button', (tester) async {
      await _pumpReceipt(tester, receipt: _receipt(pdfUrl: null));
      expect(find.text('PDF yüklə'), findsNothing);
    });

    testWidgets('«PDF yüklə» downloads, saves to Downloads and opens it', (
      tester,
    ) async {
      final adapter = _Adapter((_) async => _pdfResponse());
      final store = _FakeStore();
      await _pumpReceipt(
        tester,
        receipt: _receipt(),
        dio: _dio(adapter),
        store: store,
      );

      await _tapAndSettle(tester, find.text('PDF yüklə'));

      expect(store.saved.single.bytes, _pdfBytes);
      expect(store.saved.single.fileName, 'wawatair-receipt-WA-12345678.pdf');
      expect(store.openCalls, 1);
      // The viewer is another app: the "saved" note waits for the return.
      expect(
        find.text('Qəbz «Yükləmələr» qovluğunda saxlanıldı.'),
        findsNothing,
      );
      for (final state in const [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pumpAndSettle();
      expect(
        find.text('Qəbz «Yükləmələr» qovluğunda saxlanıldı.'),
        findsOneWidget,
      );
      expect(find.text('PDF yaradıla bilmədi.'), findsNothing);

      // Second tap reuses the downloaded bytes — no second request.
      ScaffoldMessenger.of(
        tester.element(find.byType(ReceiptScreen)),
      ).removeCurrentSnackBar();
      await tester.pumpAndSettle();
      await _tapAndSettle(tester, find.text('PDF yüklə'));
      expect(adapter.requests, hasLength(1));
      expect(store.openCalls, 2);
    });

    testWidgets('no connection → the network text', (tester) async {
      final adapter = _Adapter(
        (_) async => throw const SocketException('offline'),
      );
      final store = _FakeStore();
      await _pumpReceipt(
        tester,
        receipt: _receipt(),
        dio: _dio(adapter),
        store: store,
      );

      await _tapAndSettle(tester, find.text('PDF yüklə'));

      expect(
        find.text(
          'İnternet bağlantısı yoxdur. Bağlantını yoxlayıb yenidən cəhd edin.',
        ),
        findsOneWidget,
      );
      expect(store.saved, isEmpty);
    });

    testWidgets('server error without a message → the server text', (
      tester,
    ) async {
      final adapter = _Adapter((_) async => _json(500, const {}));
      await _pumpReceipt(
        tester,
        receipt: _receipt(),
        dio: _dio(adapter),
        store: _FakeStore(),
      );

      await _tapAndSettle(tester, find.text('PDF yüklə'));

      expect(
        find.text(
          'Server qəbzi göndərə bilmədi. Bir az sonra yenidən cəhd edin.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('server error with a message → the backend message', (
      tester,
    ) async {
      final adapter = _Adapter(
        (_) async => _json(429, {'message': 'Çox sorğu. Bir dəqiqə gözləyin.'}),
      );
      await _pumpReceipt(
        tester,
        receipt: _receipt(),
        dio: _dio(adapter),
        store: _FakeStore(),
      );

      await _tapAndSettle(tester, find.text('PDF yüklə'));

      expect(find.text('Çox sorğu. Bir dəqiqə gözləyin.'), findsOneWidget);
    });

    testWidgets('share button stays available separately', (tester) async {
      final adapter = _Adapter((_) async => _pdfResponse());
      final store = _FakeStore();
      await _pumpReceipt(
        tester,
        receipt: _receipt(),
        dio: _dio(adapter),
        store: store,
      );

      await _tapAndSettle(tester, find.byTooltip('Paylaş'));

      expect(store.shareCalls, 1);
      expect(store.saved, isEmpty);
    });
  });
}
