class NoSuchEmailException implements Exception {
  String email;

  NoSuchEmailException({required this.email});
}
