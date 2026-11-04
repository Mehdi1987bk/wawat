import 'package:buking/services/api_error.dart';

class ErrorParser {
  static String parseDioError(dynamic e) {
    if (e is! Object) return '';
    return errorMessage(e);
  }
}
