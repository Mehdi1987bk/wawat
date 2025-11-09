import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../generated/l10n.dart';
import '../../main.dart';

String parseError(dynamic error, BuildContext context) {
  logger.e(error);
  String? message;
  switch (error.runtimeType) {
    case DioError:
      message = _parseDioError(error as DioError, context);
      break;
    default:
      message = error.toString();
  }
  return message ?? "";
}

String? _parseDioError(
    DioError error,
    BuildContext context,
    ) {
  String? message;
  switch (error.type) {
    case DioErrorType.unknown: // Updated from "other" to "unknown"
      if (error.error is SocketException) {
        message = S.of(context).noInternetConnection;
      } else {
        if (error.error is Response) {
          final dioError = (error.error as Response).data.toString();
          message = dioError;
        } else {
          message = S.of(context).somethingWentWrong;
        }
      }
      break;
    case DioErrorType.badResponse: // Updated from "response" to "badResponse"
      try {
        message = error.message;
      } catch (e) {
        logger.e(e);
        message = error.message;
      }
      break;
    default:
      message = S.of(context).somethingWentWrong;
  }
  return message;
}
