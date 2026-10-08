class AuthActionResult {
  final bool isSuccess;
  final String? message;
  final Map<String, String> fieldErrors;

  /// Машинный код ошибки из конверта ответа ({message, code, errors?}).
  /// По нему, а не по локализованному тексту, определяется состояние аккаунта.
  final String? code;

  /// HTTP-статус ответа (403 → аккаунт ограничен, 401/422 → неверный вход).
  final int? statusCode;

  const AuthActionResult._({
    required this.isSuccess,
    this.message,
    this.fieldErrors = const {},
    this.code,
    this.statusCode,
  });

  const AuthActionResult.success({String? message})
      : this._(isSuccess: true, message: message);

  const AuthActionResult.failure({
    String? message,
    Map<String, String> fieldErrors = const {},
    String? code,
    int? statusCode,
  }) : this._(
          isSuccess: false,
          message: message,
          fieldErrors: fieldErrors,
          code: code,
          statusCode: statusCode,
        );
}
