import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../../data/network/response/chat_response.dart';
import '../../../../../services/localization_service.dart';
import 'deal_action_sheets.dart';

typedef DealActionExecutor = Future<String?> Function(
    Map<String, dynamic>? body);

typedef DealActionMessenger = void Function(String message,
    {required bool isError});

String dealActionErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) return message;
      final errors = data['errors'];
      if (errors is Map) {
        for (final value in errors.values) {
          final first = value is List && value.isNotEmpty ? value.first : value;
          final text = first?.toString().trim() ?? '';
          if (text.isNotEmpty) return text;
        }
      }
    }
  }
  return tr('deals.error.action_failed',
      'Əməliyyat alınmadı. Yenidən cəhd edin.');
}

class DealActionController extends ChangeNotifier {
  String? _scope;
  String? _busyKey;
  bool _collecting = false;
  bool _disposed = false;

  final Map<String, Map<String, dynamic>> _drafts = {};

  bool get isBusy => _collecting || _scope != null;

  bool isLocked(String scope) => _scope == scope;

  String? busyKey(String scope) => _scope == scope ? _busyKey : null;

  Future<void> run(
    BuildContext context, {
    required String scope,
    required DealAction action,
    required Map<String, String> content,
    required DealActionExecutor execute,
    required DealActionMessenger onMessage,
    DealCounterPrefill prefill = const DealCounterPrefill(),
  }) async {
    if (isBusy) return;

    Future<bool> confirm(BuildContext dialogContext) =>
        showDealActionConfirmDialog(
          dialogContext,
          title: action.label,
          confirmLabel: action.label,
          danger: action.isDanger,
        );

    final draftKey = '$scope|${action.key}';
    Map<String, dynamic>? body;
    _collecting = true;
    try {
      if (action.needsInput) {
        final collect = _inputFor(action);
        if (collect == null) {
          onMessage(
            tr('deals.action.unsupported',
                'Bu əməliyyat üçün tətbiqi yeniləyin.'),
            isError: true,
          );
          return;
        }
        body = await collect(
          context,
          action: action,
          content: content,
          prefill: prefill,
          draft: _drafts[draftKey],
          confirmSubmit: action.confirm ? confirm : null,
        );
        if (body == null) return;
      } else if (action.confirm) {
        if (!await confirm(context)) return;
      }
    } finally {
      _collecting = false;
    }

    _scope = scope;
    _busyKey = action.key;
    _notify();
    try {
      final message = await execute(body);
      _drafts.remove(draftKey);
      onMessage(
        message != null && message.trim().isNotEmpty
            ? message
            : tr('common.operation_completed', 'Əməliyyat tamamlandı'),
        isError: false,
      );
    } catch (error) {
      if (body != null) _drafts[draftKey] = body;
      onMessage(dealActionErrorMessage(error), isError: true);
    } finally {
      _scope = null;
      _busyKey = null;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

typedef _InputCollector = Future<Map<String, dynamic>?> Function(
  BuildContext context, {
  required DealAction action,
  required Map<String, String> content,
  required DealCounterPrefill prefill,
  required Map<String, dynamic>? draft,
  required DealConfirmSubmit? confirmSubmit,
});

_InputCollector? _inputFor(DealAction action) {
  for (final id in [action.endpoint, action.key]) {
    switch (id) {
      case 'counter':
        return _collectCounter;
      case 'dispute':
        return _collectDispute;
      case 'cancel':
      case 'withdraw':
        return _collectCancel;
    }
  }
  return null;
}

Future<Map<String, dynamic>?> _collectCounter(
  BuildContext context, {
  required DealAction action,
  required Map<String, String> content,
  required DealCounterPrefill prefill,
  required Map<String, dynamic>? draft,
  required DealConfirmSubmit? confirmSubmit,
}) {
  return showDealCounterOfferSheet(
    context,
    content: content,
    prefill: draft == null ? prefill : DealCounterPrefill.fromPayload(draft),
    note: draft?['note']?.toString(),
    title: action.label,
    confirmSubmit: confirmSubmit,
  );
}

Future<Map<String, dynamic>?> _collectDispute(
  BuildContext context, {
  required DealAction action,
  required Map<String, String> content,
  required DealCounterPrefill prefill,
  required Map<String, dynamic>? draft,
  required DealConfirmSubmit? confirmSubmit,
}) {
  return showDealDisputeSheet(
    context,
    content: content,
    initialReason: draft?['reason']?.toString(),
    title: action.label,
    confirmSubmit: confirmSubmit,
  );
}

Future<Map<String, dynamic>?> _collectCancel(
  BuildContext context, {
  required DealAction action,
  required Map<String, String> content,
  required DealCounterPrefill prefill,
  required Map<String, dynamic>? draft,
  required DealConfirmSubmit? confirmSubmit,
}) {
  return showDealCancelSheet(
    context,
    content: content,
    initialReasonCode: draft?['reason_code']?.toString(),
    initialNote: draft?['reason_note']?.toString(),
    title: action.label,
    submitLabel: action.label,
    confirmSubmit: confirmSubmit,
  );
}
