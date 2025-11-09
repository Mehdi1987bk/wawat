import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secure_storage.dart';

const pascodeKey = 'pascodeKey';

class DataSecureStorage extends SecureStorage {
  final storage = const FlutterSecureStorage();

  @override
  Future<void> delete() {
    return storage.deleteAll();
  }

  @override
  Future<String?> read() {
    return storage.read(key: pascodeKey);
  }

  @override
  Future<void> write(String value) {
    return storage.write(key: pascodeKey, value: value);
  }

  @override
  Future<bool> isSaved() async {
    try {
      final pascode = await read();
      return pascode != null;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
