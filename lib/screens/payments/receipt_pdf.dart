import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/network/response/receipt.dart';

/// The receipt PDF is rendered by the BACKEND (`receipt.pdf_url`) — the app only
/// downloads it and puts it where the user can find it again:
///  • Android 10+ → the public «Downloads» folder (MediaStore, no permission);
///  • iOS → the app's Documents, opened in the system preview (QuickLook), from
///    which the user saves it to «Files» or sends it on.
/// Android 8–9 has no permission-free Downloads API → falls back to the share
/// sheet.

/// Why a download failed — each maps to its own user-facing text.
enum ReceiptPdfFailure {
  /// No connection / timeout: the request never got an answer.
  network,

  /// The server answered with an error status (404 foreign/unpaid, 429, 5xx).
  server,

  /// 200, but the body is not a PDF (HTML/JSON error page, empty body).
  notPdf,

  /// Downloaded fine, but writing it to the device failed.
  save,
}

class ReceiptPdfException implements Exception {
  final ReceiptPdfFailure failure;
  final int? statusCode;

  /// The backend's own localized `message`, when an error body carried one.
  final String? serverMessage;
  final Object? cause;

  const ReceiptPdfException(
    this.failure, {
    this.statusCode,
    this.serverMessage,
    this.cause,
  });

  @override
  String toString() =>
      'ReceiptPdfException(${failure.name}'
      '${statusCode == null ? '' : ', status $statusCode'}'
      '${cause == null ? '' : ', cause: $cause'})';
}

/// A downloaded receipt PDF, still in memory.
class ReceiptPdfFile {
  final String fileName;
  final Uint8List bytes;

  const ReceiptPdfFile(this.fileName, this.bytes);
}

enum ReceiptPdfLocation { downloads, documents, temporary }

/// Where [ReceiptPdfStore.save] put the file.
class SavedReceiptPdf {
  final ReceiptPdfLocation location;

  /// Android `content://` uri (downloads) or an absolute file path.
  final String target;
  final ReceiptPdfFile file;

  const SavedReceiptPdf(this.location, this.target, this.file);
}

/// Downloads `receipt.pdfUrl` with the app's authenticated [dio].
Future<ReceiptPdfFile> downloadReceiptPdf(Dio dio, Receipt receipt) async {
  final url = receipt.pdfUrl;
  if (url == null || url.isEmpty) {
    throw const ReceiptPdfException(ReceiptPdfFailure.server);
  }
  final Response<List<int>> response;
  try {
    response = await dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
  } on DioException catch (e) {
    if (_isNetwork(e)) {
      throw ReceiptPdfException(ReceiptPdfFailure.network, cause: e);
    }
    throw ReceiptPdfException(
      ReceiptPdfFailure.server,
      statusCode: e.response?.statusCode,
      serverMessage: _serverMessage(e.response?.data),
      cause: e,
    );
  }
  final bytes = Uint8List.fromList(response.data ?? const []);
  if (!_looksLikePdf(bytes)) {
    throw ReceiptPdfException(
      ReceiptPdfFailure.notPdf,
      statusCode: response.statusCode,
      cause:
          'content-type: ${response.headers.value('content-type')}, '
          '${bytes.length} bytes',
    );
  }
  return ReceiptPdfFile(
    receiptPdfFileName(
      response.headers.value('content-disposition'),
      receipt.number,
    ),
    bytes,
  );
}

/// File name from `Content-Disposition` (`attachment; filename="…"`), else
/// `wawatair-receipt-<number>.pdf`. Always a bare, safe `*.pdf` name.
@visibleForTesting
String receiptPdfFileName(String? contentDisposition, String number) {
  String? name;
  if (contentDisposition != null) {
    final star = RegExp(
      r"filename\*\s*=\s*(?:UTF-8'')?([^;]+)",
      caseSensitive: false,
    ).firstMatch(contentDisposition);
    final plain = RegExp(
      r'filename\s*=\s*"?([^";]+)"?',
      caseSensitive: false,
    ).firstMatch(contentDisposition);
    name = star != null
        ? Uri.decodeComponent(star.group(1)!.trim())
        : plain?.group(1)?.trim();
  }
  if (name == null || name.isEmpty) {
    name = number.isEmpty ? 'wawatair-receipt' : 'wawatair-receipt-$number';
  }
  name = name.split(RegExp(r'[/\\]')).last;
  name = name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  if (!name.toLowerCase().endsWith('.pdf')) name = '$name.pdf';
  return name;
}

bool _isNetwork(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return true;
    case DioExceptionType.unknown:
      final cause = e.error;
      return cause is SocketException ||
          cause is HttpException ||
          cause is HandshakeException;
    default:
      return false;
  }
}

bool _looksLikePdf(Uint8List bytes) =>
    bytes.length > 4 &&
    bytes[0] == 0x25 && // %
    bytes[1] == 0x50 && // P
    bytes[2] == 0x44 && // D
    bytes[3] == 0x46; // F

/// The error body arrives as raw bytes (responseType.bytes) — decode Laravel's
/// `{"message": "…"}` so the user sees the server's own localized reason.
String? _serverMessage(Object? data) {
  try {
    Object? json = data;
    if (data is List<int>) json = jsonDecode(utf8.decode(data));
    if (data is String) json = jsonDecode(data);
    if (json is Map) {
      final message = json['message']?.toString().trim();
      if (message != null && message.isNotEmpty) return message;
    }
  } catch (_) {
    /* not JSON — no server message */
  }
  return null;
}

/// Saves / opens / shares a downloaded receipt. Native side: `MainActivity.kt`
/// (MediaStore Downloads + ACTION_VIEW) and `AppDelegate.swift` (QuickLook).
class ReceiptPdfStore {
  const ReceiptPdfStore();

  static const _channel = MethodChannel('az.buking.buking/receipt_files');

  Future<SavedReceiptPdf> save(ReceiptPdfFile file) async {
    try {
      if (Platform.isAndroid) {
        final uri = await _channel.invokeMethod<String>('saveToDownloads', {
          'name': file.fileName,
          'bytes': file.bytes,
        });
        if (uri != null && uri.isNotEmpty) {
          return SavedReceiptPdf(ReceiptPdfLocation.downloads, uri, file);
        }
        // Android 8–9: no MediaStore Downloads → temp copy + share sheet.
        final dir = await getTemporaryDirectory();
        return SavedReceiptPdf(
          ReceiptPdfLocation.temporary,
          await _write(dir, file),
          file,
        );
      }
      final dir = await getApplicationDocumentsDirectory();
      return SavedReceiptPdf(
        ReceiptPdfLocation.documents,
        await _write(dir, file),
        file,
      );
    } on ReceiptPdfException {
      rethrow;
    } catch (e) {
      throw ReceiptPdfException(ReceiptPdfFailure.save, cause: e);
    }
  }

  /// Shows the saved PDF. False when nothing on the device can display it
  /// (Android without a PDF viewer) — the file is still saved.
  Future<bool> open(SavedReceiptPdf saved, {String? subject}) async {
    switch (saved.location) {
      case ReceiptPdfLocation.downloads:
        return await _channel.invokeMethod<bool>('openUri', {
              'uri': saved.target,
            }) ??
            false;
      case ReceiptPdfLocation.documents:
        return await _channel.invokeMethod<bool>('preview', {
              'path': saved.target,
            }) ??
            false;
      case ReceiptPdfLocation.temporary:
        await share(saved.file, subject: subject);
        return true;
    }
  }

  /// The system share sheet (mail, messengers, «Save to Files», …).
  Future<void> share(ReceiptPdfFile file, {String? subject}) async {
    final dir = await getTemporaryDirectory();
    final path = await _write(dir, file);
    await Share.shareXFiles([
      XFile(path, mimeType: 'application/pdf'),
    ], subject: subject);
  }

  static Future<String> _write(Directory dir, ReceiptPdfFile file) async {
    final out = File('${dir.path}/${file.fileName}');
    await out.writeAsBytes(file.bytes, flush: true);
    return out.path;
  }
}
