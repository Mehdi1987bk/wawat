abstract class SecureStorage {
  Future<String?> read();

  Future<void> delete();

  Future<void> write(String value);

  Future<bool> isSaved();
}
