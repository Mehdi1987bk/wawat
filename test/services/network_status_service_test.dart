import 'package:buking/services/network_failure.dart';
import 'package:buking/services/network_status_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

const _fiveSeconds = Duration(seconds: 5);

RequestOptions _request({bool optional = false}) => RequestOptions(
      path: 'https://api.wawatair.com/api/v1/app/config',
      extra: {if (optional) NetworkFailure.attemptKey: 1},
    );

void main() {
  final status = NetworkStatusService.instance;

  setUp(status.markOnline);

  test('обычный запрос не дождался соединения — экран «нет сети»', () {
    status.handleDioError(DioException.connectionTimeout(
      timeout: _fiveSeconds,
      requestOptions: _request(),
    ));

    expect(status.isOffline, isTrue);
  });

  test('необязательный запрос с коротким таймаутом приложение не закрывает',
      () {
    for (final error in [
      DioException.connectionTimeout(
        timeout: _fiveSeconds,
        requestOptions: _request(optional: true),
      ),
      DioException.receiveTimeout(
        timeout: _fiveSeconds,
        requestOptions: _request(optional: true),
      ),
    ]) {
      status.handleDioError(error);

      expect(status.isOffline, isFalse, reason: error.type.name);
    }
  });

  test('соединения нет физически — «нет сети», какой бы ни был запрос', () {
    status.handleDioError(DioException.connectionError(
      requestOptions: _request(optional: true),
      reason: 'Failed host lookup',
    ));

    expect(status.isOffline, isTrue);
  });

  test('ответил наш сервер — сеть есть', () {
    status.markOffline();

    status.handleDioError(DioException.badResponse(
      statusCode: 422,
      requestOptions: _request(),
      response: Response<dynamic>(
        requestOptions: _request(),
        statusCode: 422,
      ),
    ));

    expect(status.isOffline, isFalse);
  });
}
