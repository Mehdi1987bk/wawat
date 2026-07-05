class AuthActionResult {
  final bool isSuccess;
  final String? message;
  final Map<String, String> fieldErrors;

  const AuthActionResult._({
    required this.isSuccess,
    this.message,
    this.fieldErrors = const {},
  });

  const AuthActionResult.success({String? message})
      : this._(isSuccess: true, message: message);

  const AuthActionResult.failure({
    String? message,
    Map<String, String> fieldErrors = const {},
  }) : this._(
          isSuccess: false,
          message: message,
          fieldErrors: fieldErrors,
        );
}
