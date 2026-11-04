import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:buking/services/guarded_request.dart';
import 'package:buking/services/network_failure.dart';
import 'package:dio/dio.dart';

typedef NetworkStep = FutureOr<ResponseBody> Function(RequestOptions options);

class ScriptedNetwork implements HttpClientAdapter {
  ScriptedNetwork(this.steps, {DateTime? start})
      : now = start ?? DateTime(2026, 10, 13, 12);

  final List<NetworkStep> steps;

  DateTime now;
  final DateTime _origin = DateTime(2026, 10, 13, 12);

  Duration answerTook = Duration.zero;

  final List<RequestOptions> requests = [];
  final List<Duration> sentAt = [];
  final List<Duration> pauses = [];

  DateTime clock() => now;

  Future<void> sleep(Duration pause) async {
    pauses.add(pause);
    now = now.add(pause);
  }

  void advance(Duration by) => now = now.add(by);

  Dio dio() {
    final dio = Dio()..httpClientAdapter = this;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.extra[NetworkFailure.startedAtKey] =
            DateTime.now().subtract(answerTook);
        handler.next(options);
      },
    ));
    return dio;
  }

  GuardedRequest request({double jitter = 0}) => GuardedRequest(
        dio: dio,
        clock: clock,
        sleep: sleep,
        jitter: jitter,
      );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    sentAt.add(now.difference(_origin));
    final step = steps[requests.length <= steps.length
        ? requests.length - 1
        : steps.length - 1];
    return step(options);
  }

  @override
  void close({bool force = false}) {}
}

const _json = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

NetworkStep ok(Map<String, dynamic> body) =>
    (_) => ResponseBody.fromString(jsonEncode(body), 200, headers: _json);

NetworkStep status(
  int code, {
  Object body = '<html>error</html>',
  Map<String, List<String>> headers = const {},
}) =>
    (_) => body is Map
        ? ResponseBody.fromString(jsonEncode(body), code,
            headers: {..._json, ...headers})
        : ResponseBody.fromString(body.toString(), code, headers: {
            Headers.contentTypeHeader: ['text/html'],
            ...headers,
          });

NetworkStep captivePortal() => (_) => ResponseBody.fromString(
      '<html>Sign in to Wi-Fi</html>',
      200,
      headers: {
        Headers.contentTypeHeader: ['text/html'],
      },
    );

NetworkStep offline() => (options) => throw DioException.connectionError(
      requestOptions: options,
      reason: 'Failed host lookup',
    );
