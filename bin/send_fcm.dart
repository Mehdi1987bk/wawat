// Отправка тестового FCM (HTTP v1). Без gcloud — только JSON сервисного аккаунта.
//
// Использование:
//   dart run bin/send_fcm.dart <FCM_TOKEN>
//   dart run bin/send_fcm.dart <путь_к_service_account.json> <FCM_TOKEN>
//
// Если путь не указан — ищется любой *service_account*.json или *firebase*adminsdk*.json в scripts/

import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

const projectId = 'wawatair-b212f';
const fcmScope = 'https://www.googleapis.com/auth/firebase.messaging';

String _scriptsPath() {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  final projectRoot = scriptDir.path.endsWith('bin') ? scriptDir.parent : scriptDir;
  return '${projectRoot.path}${Platform.pathSeparator}scripts';
}

Future<String?> _findServiceAccountJson(String requestedPath, String scriptsPath) async {
  final requested = File(requestedPath);
  if (await requested.exists()) return requestedPath;

  final scriptsDir = Directory(scriptsPath);
  if (!await scriptsDir.exists()) return null;

  await for (final entity in scriptsDir.list()) {
    if (entity is! File) continue;
    if (!entity.path.endsWith('.json')) continue;
    final content = await entity.readAsString();
    try {
      final map = jsonDecode(content) as Map<String, dynamic>;
      if (map.containsKey('private_key') && map.containsKey('client_email')) {
        return entity.path;
      }
    } catch (_) {}
  }
  return null;
}

Future<void> main(List<String> args) async {
  String? jsonPath;
  final fcmToken = args.length >= 2 ? args[1] : (args.isNotEmpty ? args[0] : null);

  if (fcmToken == null || fcmToken.isEmpty) {
    print('Usage: dart run bin/send_fcm.dart <FCM_TOKEN>');
    print('   or: dart run bin/send_fcm.dart <service_account.json> <FCM_TOKEN>');
    print('');
    print('Download service account JSON: Firebase Console → Project settings → Service accounts');
    print('  → "Generate new private key" → save file into project scripts/ folder');
    print('  https://console.firebase.google.com/project/wawatair-b212f/settings/serviceaccounts/adminsdk');
    exit(1);
  }

  final scriptsPath = _scriptsPath();
  if (args.length >= 2) {
    jsonPath = await _findServiceAccountJson(args[0], scriptsPath);
  } else {
    jsonPath = await _findServiceAccountJson('$scriptsPath${Platform.pathSeparator}service_account.json', scriptsPath);
  }

  if (jsonPath == null) {
    print('No service account JSON found.');
    print('');
    print('Looked in: $scriptsPath');
    print('');
    print('1. Open: https://console.firebase.google.com/project/wawatair-b212f/settings/serviceaccounts/adminsdk');
    print('2. Click "Generate new private key"');
    print('3. Save the downloaded .json file into the folder above (e.g. drag it into wawat/scripts/ in Finder)');
    print('4. Run this command again.');
    exit(1);
  }

  final file = File(jsonPath);
  print('Using: $jsonPath');

  final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  final credentials = ServiceAccountCredentials.fromJson(json);

  final client = http.Client();
  try {
    final accessCredentials = await obtainAccessCredentialsViaServiceAccount(
      credentials,
      [fcmScope],
      client,
    );

    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
    );
    final body = jsonEncode({
      'message': {
        'token': fcmToken,
        'notification': {
          'title': 'Test',
          'body': 'Тестовое уведомление',
        },
      },
    });

    final response = await client.post(
      url,
      headers: {
        'Authorization': 'Bearer ${accessCredentials.accessToken.data}',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print(response.body);
    if (response.statusCode >= 400) exit(1);
  } finally {
    client.close();
  }
}
