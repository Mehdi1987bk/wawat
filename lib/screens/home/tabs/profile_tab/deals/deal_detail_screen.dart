import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../data/network/response/chat_response.dart';
import '../../../../../presentation/bloc/base_screen.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/localization_service.dart';
import '../../../../../services/wawat_content.dart';
import '../../../../chat/chat/chat_conversation_screen.dart';
import '../new_profile/new_profile_screen.dart';
import 'deal_action_sheets.dart';
import 'deal_detail_bloc.dart';
import 'widgets/deal_flightpath.dart';
import 'widgets/deal_status.dart';
import 'widgets/deal_stepper.dart';

const _stepperStatuses = [
  'proposal_pending',
  'accepted',
  'picked_up',
  'delivered',
  'completed',
];

// Тема-зависимые цвета. Светлая ветка = точь-в-точь как было (белый режим не
// меняется), тёмная ветка = единый графит из [WawatDark].
Color _cCard(bool d) => d ? WawatDark.surface : Colors.white;
Color _cScreen(bool d) => d ? WawatDark.bg : dealScreenBg;
Color _cTitle(bool d) => d ? WawatDark.textPrimary : dealInk900;
Color _cInk700(bool d) => d ? WawatDark.textSecondary : dealInk700;
Color _cInk500(bool d) => d ? WawatDark.textSecondary : dealInk500;
Color _cMuted(bool d) => d ? WawatDark.textMuted : dealInk400;
Color _cLine(bool d) => d ? WawatDark.border : dealInk200;
Color _cHairline(bool d) => d ? WawatDark.divider : dealInk100;
Color _cFill(bool d) => d ? WawatDark.surfaceAlt : dealInk100;
Color _cBrandSoft(bool d) => d ? WawatDark.brandSoft : dealBrand50;
BoxShadow? _cCardShadow(bool d) => d
    ? null
    : BoxShadow(color: dealInk900.withValues(alpha: 0.04), blurRadius: 12);
BoxBorder? _cCardBorder(bool d) =>
    d ? Border.all(color: WawatDark.border) : null;

class DealDetailScreen extends BaseScreen<DealDetailBloc> {
  final String shipmentId;

  DealDetailScreen({super.key, required this.shipmentId});

  @override
  State<DealDetailScreen> createState() => _DealDetailScreenState();
}

class _DealDetailScreenState
    extends BaseState<DealDetailScreen, DealDetailBloc> {
  /// UI id of the deal action currently being sent to the backend (null = idle).
  /// Drives the in-button loader and blocks repeat taps on the action bar.
  String? _busyAction;

  @override
  DealDetailBloc provideBloc() => DealDetailBloc(widget.shipmentId);

  @override
  Color? backgroundColor() =>
      _cScreen(Theme.of(context).brightness == Brightness.dark);

  @override
  bool get showProgressIndicator => false;

  @override
  PreferredSizeWidget appBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: _cCard(isDark),
      surfaceTintColor: _cCard(isDark),
      elevation: 0,
      centerTitle: false,
      toolbarHeight: 56,
      automaticallyImplyLeading: false,
      titleSpacing: 10,
      title: StreamBuilder<DealDetailState>(
        stream: bloc.state,
        initialData: bloc.value,
        builder: (context, snapshot) {
          final content = snapshot.data?.content ?? const {};
          return Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).maybePop(),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(PhosphorIconsBold.caretLeft,
                      color: _cInk700(isDark), size: 23),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  WawatContent.text(content, 'deals.title_short', 'Sövdələşmə'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _cTitle(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget body() {
    return StreamBuilder<DealDetailState>(
      stream: bloc.state,
      initialData: bloc.value,
      builder: (context, snapshot) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final state = snapshot.data ?? const DealDetailState.initial();
        if (state.loading && state.shipment == null) {
          return const Center(
              child: CircularProgressIndicator(color: dealBrand));
        }
        if (state.error != null && state.shipment == null) {
          return _ErrorView(content: state.content, onRetry: bloc.load);
        }
        final shipment = state.shipment;
        if (shipment == null) return const SizedBox.shrink();
        return RefreshIndicator(
          color: dealBrand,
          onRefresh: bloc.load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(shipment: shipment, content: state.content),
                if (_stepperStatuses.contains(shipment.status)) ...[
                  const SizedBox(height: 8),
                  DealStepper(status: shipment.status, content: state.content),
                ],
                const SizedBox(height: 12),
                ..._statusNotices(shipment, state.content),
                _RouteCard(shipment: shipment, content: state.content),
                const SizedBox(height: 12),
                _TermsCard(shipment: shipment, content: state.content),
                if (shipment.status == 'cancelled') ...[
                  const SizedBox(height: 12),
                  _CancelReasonCard(shipment: shipment, content: state.content),
                ],
                if (_showTimeline(shipment)) ...[
                  const SizedBox(height: 12),
                  _TimelineCard(shipment: shipment, content: state.content),
                ],
                if (_showCounterpart(shipment)) ...[
                  const SizedBox(height: 12),
                  _CounterpartCard(
                    shipment: shipment,
                    content: state.content,
                    onChat: () => _openChat(shipment),
                    onOpenProfile: () => _openProfile(shipment),
                  ),
                ],
                if (shipment.status == 'disputed') ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _openChat(shipment),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _cInk700(isDark),
                          side: BorderSide(color: _cLine(isDark)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(PhosphorIconsFill.chatCircleDots,
                            size: 17),
                        label: Text(
                          WawatContent.text(state.content, 'deals.action.chat',
                              'Söhbətə keç'),
                          style: const TextStyle(
                              fontSize: 13.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _showTimeline(ShipmentData shipment) {
    return shipment.pickedUpAt != null ||
        shipment.deliveredAt != null ||
        shipment.completedAt != null;
  }

  bool _showCounterpart(ShipmentData shipment) {
    return !dealIsTerminal(shipment.status) ||
        shipment.status == 'auto_completed';
  }

  List<Widget> _statusNotices(
      ShipmentData shipment, Map<String, String> content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget? notice;
    if (shipment.status == 'proposal_pending' && !shipment.isAwaitingMe) {
      notice = _NoticeBox(
        icon: PhosphorIconsFill.clock,
        color: isDark ? WawatDark.warning : dealAmber700,
        background: isDark ? WawatDark.surfaceAlt : dealAmber100,
        text: WawatContent.text(
          content,
          'deals.pending_expires_template',
          'Təklifin vaxtı: {date}-a qədər',
        ).replaceAll('{date}', dealShortDate(shipment.expiresAt)),
      );
    } else if (shipment.status == 'delivered') {
      notice = _NoticeBox(
        icon: PhosphorIconsFill.info,
        color: isDark ? WawatDark.brand : dealBrand700,
        background: isDark ? WawatDark.brandSoft : dealBrand50,
        text: WawatContent.text(
          content,
          'deals.auto_complete_hint',
          '3 gün ərzində təsdiq etməsəniz, sövdələşmə avtomatik tamamlanacaq.',
        ),
      );
    } else if (shipment.status == 'auto_completed') {
      notice = _NoticeBox(
        icon: PhosphorIconsFill.clockCountdown,
        color: _cInk500(isDark),
        background: _cCard(isDark),
        bordered: true,
        text: WawatContent.text(
          content,
          'deals.auto_completed_note',
          'Mal çatdırıldıqdan 3 gün sonra göndərən təsdiq etmədiyi üçün sövdələşmə avtomatik tamamlandı. Rəy yaza bilərsiniz.',
        ),
      );
    } else if (shipment.status == 'disputed') {
      notice = _NoticeBox(
        icon: PhosphorIconsFill.headset,
        color: _cInk500(isDark),
        background: _cCard(isDark),
        bordered: true,
        text: WawatContent.text(
          content,
          'deals.dispute.admin_note',
          'Komandamız hər iki tərəflə əlaqə saxlayacaq. Söhbətdə əlavə məlumat verə bilərsiniz.',
        ),
      );
    } else if (shipment.status == 'expired') {
      notice = _NoticeBox(
        icon: PhosphorIconsFill.info,
        color: _cInk500(isDark),
        background: _cCard(isDark),
        bordered: true,
        text: WawatContent.text(
          content,
          'deals.expired_note',
          'Təklifin cavab müddəti bitdi. Yenidən təklif göndərə bilərsiniz.',
        ),
      );
    }
    if (notice == null) return const [];
    return [notice, const SizedBox(height: 12)];
  }

  Future<void> _openChat(ShipmentData shipment) async {
    final conversationId = shipment.conversationId;
    if (conversationId == null || conversationId.isEmpty) return;
    final counterpart = shipment.isCarrier ? shipment.sender : shipment.carrier;
    final conversation = Conversation(
      id: conversationId,
      user: ChatUser(
        id: 0,
        fullname: counterpart?.fullname ?? '',
        username: counterpart?.username,
        avatarFull: counterpart?.avatarFull,
        avatarThumb: counterpart?.avatarThumb,
        isVerified: counterpart?.isVerified ?? false,
      ),
      unreadCount: 0,
      isPinned: false,
      isArchived: false,
    );
    await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => ChatConversationScreen(conversation: conversation)),
    );
  }

  void _openProfile(ShipmentData shipment) {
    final counterpart = shipment.isCarrier ? shipment.sender : shipment.carrier;
    final userId = counterpart?.profileId;
    if (userId == null) {
      _toast(tr('deals.profile_not_found', 'Profil məlumatı tapılmadı.'),
          isError: true);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PublicProfileScreen(userId: userId)),
    );
  }

  Future<void> _openReview(
    ShipmentData shipment,
    Map<String, String> content,
    int initialRating,
  ) async {
    final counterpart = shipment.isCarrier ? shipment.sender : shipment.carrier;
    final result = await showDealReviewSheet(
      context,
      content: content,
      counterpartName: counterpart?.fullname ?? '',
      counterpartAvatar: (counterpart?.avatarThumbUrl.isNotEmpty ?? false)
          ? counterpart!.avatarThumbUrl
          : null,
      initialRating: initialRating,
    );
    if (result == null || !mounted) return;
    try {
      final review = await bloc.submitReview(
        rating: result['rating'] as int,
        comment: result['comment'] as String?,
      );
      if (!mounted) return;
      // approved → published now (green); pending → sent to moderation.
      final fallback = review.isApproved
          ? tr('deals.review.published', 'Rəyiniz yayımlandı')
          : tr('deals.review.pending_moderation',
              'Rəyiniz moderasiyaya göndərildi');
      _toast(
        review.message.isNotEmpty ? review.message : fallback,
        isSuccess: review.isApproved,
      );
    } catch (error) {
      if (mounted) _toast(_extractError(error), isError: true);
    }
  }

  void _toast(String message, {bool isError = false, bool isSuccess = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isError
        ? dealRed600
        : isSuccess
            ? const Color(0xFF16A34A)
            : (isDark ? WawatDark.elevated : dealInk900);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: bg,
          content: Text(message,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      );
  }

  @override
  Widget? bottomNavigationBar() {
    return StreamBuilder<DealDetailState>(
      stream: bloc.state,
      initialData: bloc.value,
      builder: (context, snapshot) {
        final shipment = snapshot.data?.shipment;
        final content = snapshot.data?.content ?? const {};
        if (shipment == null) return const SizedBox.shrink();
        // Completed deals: pin the star-rating prompt at the bottom. Tapping a
        // star opens the review sheet directly (no separate submit button).
        if (shipment.status == 'completed' ||
            shipment.status == 'auto_completed') {
          return _ReviewBar(
            shipment: shipment,
            content: content,
            onReview: (rating) => _openReview(shipment, content, rating),
          );
        }
        if (dealIsTerminal(shipment.status)) return const SizedBox.shrink();
        return _ActionBar(
          shipment: shipment,
          content: content,
          busyAction: _busyAction,
          onAction: (action) {
            if (_busyAction != null) return;
            _handleAction(action, shipment, content);
          },
        );
      },
    );
  }

  Future<void> _handleAction(
    String action,
    ShipmentData shipment,
    Map<String, String> content,
  ) async {
    switch (action) {
      case 'accept':
        await _runAction('accept');
        break;
      case 'decline':
        await _runAction('decline');
        break;
      case 'counter':
        final body = await showDealCounterOfferSheet(context,
            content: content, shipment: shipment);
        if (body != null) await _runAction('counter', body: body);
        break;
      case 'withdraw':
      case 'cancel':
        final body = await showDealCancelSheet(context, content: content);
        if (body != null) {
          await _runAction('cancel', body: body, uiAction: action);
        }
        break;
      case 'picked-up':
        final confirmed = await showDealConfirmDialog(
          context,
          icon: PhosphorIconsFill.package,
          iconColor: dealBrand,
          title: WawatContent.text(
            content,
            'deals.confirm.picked_up.title',
            'Malı götürdüyünüzü təsdiqləyirsiniz?',
          ),
          body: WawatContent.text(
            content,
            'deals.confirm.irreversible_body',
            'Bu əməldən sonra sövdələşmə tamamlanmış sayılacaq və geri qaytarıla bilməz.',
          ),
          content: content,
        );
        if (confirmed) await _runAction('picked-up');
        break;
      case 'delivered':
        final confirmed = await showDealConfirmDialog(
          context,
          icon: PhosphorIconsFill.mapPinLine,
          iconColor: dealBrand,
          title: WawatContent.text(
            content,
            'deals.confirm.delivered.title',
            'Çatdırdığınızı təsdiqləyirsiniz?',
          ),
          body: WawatContent.text(
            content,
            'deals.confirm.irreversible_body',
            'Bu əməldən sonra sövdələşmə tamamlanmış sayılacaq və geri qaytarıla bilməz.',
          ),
          content: content,
        );
        if (confirmed) await _runAction('delivered');
        break;
      case 'complete':
        final confirmed = await showDealConfirmDialog(
          context,
          icon: PhosphorIconsFill.sealCheck,
          iconColor: dealBrand,
          title: WawatContent.text(
            content,
            'deals.confirm.complete.title',
            'Malı aldığınızı təsdiqləyirsiniz?',
          ),
          body: WawatContent.text(
            content,
            'deals.confirm.irreversible_body',
            'Bu əməldən sonra sövdələşmə tamamlanmış sayılacaq və geri qaytarıla bilməz.',
          ),
          content: content,
        );
        if (confirmed) await _runAction('complete');
        break;
      case 'dispute':
        final body = await showDealDisputeSheet(context, content: content);
        if (body != null) await _runAction('dispute', body: body);
        break;
    }
  }

  Future<void> _runAction(
    String action, {
    Map<String, dynamic>? body,
    String? uiAction,
  }) async {
    if (_busyAction != null) return;
    setState(() => _busyAction = uiAction ?? action);
    try {
      final message = await bloc.runAction(action, body: body);
      if (mounted && message != null) _toast(message);
    } catch (error) {
      if (mounted) _toast(_extractError(error), isError: true);
    } finally {
      if (mounted) setState(() => _busyAction = null);
    }
  }

  String _extractError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) return message;
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
      }
    }
    return tr(
        'deals.error.action_failed', 'Əməliyyat alınmadı. Yenidən cəhd edin.');
  }
}

class _Header extends StatelessWidget {
  final ShipmentData shipment;
  final Map<String, String> content;

  const _Header({required this.shipment, required this.content});

  String _title() {
    if (shipment.status == 'proposal_pending' && !shipment.isAwaitingMe) {
      return WawatContent.text(
          content, 'deals.awaiting_reply', 'Cavab gözlənilir');
    }
    if (shipment.status == 'picked_up') {
      return WawatContent.text(
          content, 'deals.detail_title.picked_up', 'Mal yoldadır');
    }
    return dealStatusLabel(content, shipment.status, shipment.statusLabel);
  }

  String _subtitle() {
    final role = shipment.myRole;
    switch (shipment.status) {
      case 'proposal_pending':
        return WawatContent.text(
          content,
          shipment.isAwaitingMe
              ? 'deals.sub.pending_me'
              : 'deals.sub.pending_them',
          shipment.isAwaitingMe
              ? 'Sizə yeni təklif gəlib — cavab verin'
              : 'Təklifiniz göndərildi · qarşı tərəf cavab verməlidir',
        );
      case 'accepted':
        return WawatContent.text(
          content,
          role == 'carrier'
              ? 'deals.sub.accepted_carrier'
              : 'deals.sub.accepted_sender',
          role == 'carrier'
              ? 'Razılaşma bağlandı · malı göndərəndən götürün'
              : 'Razılaşma bağlandı · daşıyıcı malı götürəcək',
        );
      case 'picked_up':
        return WawatContent.text(
          content,
          role == 'carrier'
              ? 'deals.sub.picked_up_carrier'
              : 'deals.sub.picked_up_sender',
          role == 'carrier'
              ? 'Təyinat şəhərinə çatanda «Çatdırdım» seçin'
              : 'Mal yoldadır · daşıyıcı çatdırana qədər gözləyin',
        );
      case 'delivered':
        return WawatContent.text(
          content,
          role == 'sender'
              ? 'deals.sub.delivered_sender'
              : 'deals.sub.delivered_carrier',
          role == 'sender'
              ? 'Malı aldınızsa təsdiqləyin — sövdələşmə tamamlanacaq'
              : 'Çatdırıldı · göndərənin təsdiqini gözləyin',
        );
      default:
        return WawatContent.text(content, 'deals.sub.${shipment.status}', '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visual = dealStatusVisual(shipment.status, isDark);
    final subtitle = _subtitle();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [visual.background, _cScreen(isDark).withValues(alpha: 0)],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
                color: visual.background,
                borderRadius: BorderRadius.circular(18)),
            child: Icon(visual.icon, color: visual.color, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            _title(),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _cTitle(isDark),
                fontSize: 17,
                fontWeight: FontWeight.w600),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: visual.color,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

class _NoticeBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final bool bordered;
  final String text;

  const _NoticeBox({
    required this.icon,
    required this.color,
    required this.background,
    required this.text,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: bordered
              ? Border.all(
                  color: isDark
                      ? WawatDark.border
                      : dealInk900.withValues(alpha: 0.06))
              : null,
          boxShadow: bordered && !isDark
              ? [
                  BoxShadow(
                      color: dealInk900.withValues(alpha: 0.04), blurRadius: 10)
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                    color: color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final ShipmentData shipment;
  final Map<String, String> content;

  const _RouteCard({required this.shipment, required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cCard(isDark),
          borderRadius: BorderRadius.circular(20),
          border: _cCardBorder(isDark),
          boxShadow:
              _cCardShadow(isDark) == null ? null : [_cCardShadow(isDark)!],
        ),
        child: Column(
          children: [
            DealFlightPath(
              cityFrom: shipment.cityFrom ?? '',
              cityTo: shipment.cityTo ?? '',
              muted: dealIsTerminal(shipment.status),
            ),
            if (shipment.travelDate != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: _cLine(isDark))),
                ),
                child: Row(
                  children: [
                    Icon(PhosphorIconsRegular.calendarBlank,
                        size: 14, color: _cInk500(isDark)),
                    const SizedBox(width: 6),
                    Text(
                      '${WawatContent.text(content, 'deals.terms.trip_date', 'Səfər')}: '
                      '${dealShortDate(shipment.travelDate)}',
                      style: TextStyle(
                          color: _cInk500(isDark),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TermsCard extends StatelessWidget {
  final ShipmentData shipment;
  final Map<String, String> content;

  const _TermsCard({required this.shipment, required this.content});

  @override
  Widget build(BuildContext context) {
    final rows = <List<String>>[
      if (shipment.weightKg != null)
        [
          WawatContent.text(content, 'deals.terms.weight', 'Çəki'),
          '${shipment.weightKg} kq'
        ],
      if (shipment.packageTypeCode != null)
        [
          WawatContent.text(content, 'deals.terms.package', 'Bağlama'),
          dealPackageLabel(shipment.packageTypeCode)
        ],
      if (shipment.priceTotal != null)
        [
          WawatContent.text(content, 'deals.terms.price', 'Qiymət'),
          '${shipment.priceTotal!.toStringAsFixed(0)} \$',
        ],
      if (shipment.note != null && shipment.note!.isNotEmpty)
        [
          WawatContent.text(content, 'deals.terms.note', 'Qeyd'),
          shipment.note!
        ],
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: _cCard(isDark),
          borderRadius: BorderRadius.circular(20),
          border: _cCardBorder(isDark),
          boxShadow:
              _cCardShadow(isDark) == null ? null : [_cCardShadow(isDark)!],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  WawatContent.text(content, 'deals.section.terms', 'Şərtlər'),
                  style: TextStyle(
                    color: _cMuted(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
            for (var i = 0; i < rows.length; i++)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  border: i == 0
                      ? null
                      : Border(top: BorderSide(color: _cHairline(isDark))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(rows[i][0],
                        style:
                            TextStyle(color: _cInk500(isDark), fontSize: 13)),
                    Flexible(
                      child: Text(
                        rows[i][1],
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: _cTitle(isDark),
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CancelReasonCard extends StatelessWidget {
  final ShipmentData shipment;
  final Map<String, String> content;

  const _CancelReasonCard({required this.shipment, required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Soft red treatment so the cancellation reads clearly as "cancelled".
    final redFg = isDark ? WawatDark.danger : dealRed600;
    final redBg = isDark ? WawatDark.surfaceAlt : dealRed50;
    final redBorder = isDark
        ? WawatDark.danger.withValues(alpha: 0.35)
        : dealRed600.withValues(alpha: 0.16);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: redBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: redBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIconsFill.prohibit, color: redFg, size: 15),
                const SizedBox(width: 6),
                Text(
                  WawatContent.text(
                      content, 'deals.cancel.reason_label', 'Ləğv səbəbi'),
                  style: TextStyle(
                    color: redFg,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              shipment.cancelReasonLabel ?? '',
              style: TextStyle(
                  color: _cTitle(isDark),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600),
            ),
            if (shipment.cancelReasonNote != null &&
                shipment.cancelReasonNote!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                '«${shipment.cancelReasonNote}»',
                style: TextStyle(
                    color: _cInk500(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final ShipmentData shipment;
  final Map<String, String> content;

  const _TimelineCard({required this.shipment, required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandBadgeBg = isDark ? WawatDark.brandSoft : dealBrand50;
    final brandBadgeFg = isDark ? WawatDark.brand : dealBrand;
    final emeraldBadgeBg = isDark ? WawatDark.surfaceAlt : dealEmerald50;
    final emeraldBadgeFg = isDark ? WawatDark.success : dealEmerald600;
    final entries = <List<dynamic>>[
      if (shipment.pickedUpAt != null)
        [
          PhosphorIconsFill.package,
          brandBadgeBg,
          brandBadgeFg,
          tr('deals.timeline.picked_up', 'Mal götürüldü'),
          shipment.pickedUpAt
        ],
      if (shipment.deliveredAt != null)
        [
          PhosphorIconsFill.mapPinLine,
          brandBadgeBg,
          brandBadgeFg,
          tr('deals.timeline.delivered', 'Çatdırıldı'),
          shipment.deliveredAt
        ],
      if (shipment.completedAt != null)
        [
          PhosphorIconsFill.checkCircle,
          emeraldBadgeBg,
          emeraldBadgeFg,
          tr('deals.timeline.completed', 'Tamamlandı'),
          shipment.completedAt
        ],
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cCard(isDark),
          borderRadius: BorderRadius.circular(20),
          border: _cCardBorder(isDark),
          boxShadow:
              _cCardShadow(isDark) == null ? null : [_cCardShadow(isDark)!],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              WawatContent.text(content, 'deals.section.history', 'Tarixçə'),
              style: TextStyle(
                color: _cMuted(isDark),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 8),
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          color: entry[1] as Color, shape: BoxShape.circle),
                      child: Icon(entry[0] as IconData,
                          size: 12, color: entry[2] as Color),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry[3] as String,
                          style: TextStyle(
                              color: _cInk700(isDark),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          dealShortDate(entry[4] as String?),
                          style: TextStyle(
                              color: _cMuted(isDark),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CounterpartCard extends StatelessWidget {
  final ShipmentData shipment;
  final Map<String, String> content;
  final VoidCallback onChat;
  final VoidCallback onOpenProfile;

  const _CounterpartCard(
      {required this.shipment,
      required this.content,
      required this.onChat,
      required this.onOpenProfile});

  @override
  Widget build(BuildContext context) {
    final counterpart = shipment.isCarrier ? shipment.sender : shipment.carrier;
    if (counterpart == null) return const SizedBox.shrink();
    final roleLabel = WawatContent.text(
      content,
      shipment.isCarrier ? 'deals.role.sender' : 'deals.role.carrier',
      shipment.isCarrier ? 'Göndərən' : 'Daşıyıcı',
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cCard(isDark),
          borderRadius: BorderRadius.circular(20),
          border: _cCardBorder(isDark),
          boxShadow:
              _cCardShadow(isDark) == null ? null : [_cCardShadow(isDark)!],
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onOpenProfile,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: _cFill(isDark),
                      backgroundImage: counterpart.avatarThumbUrl.isEmpty
                          ? null
                          : CachedNetworkImageProvider(
                              counterpart.avatarThumbUrl),
                      child: counterpart.avatarThumbUrl.isEmpty
                          ? Icon(PhosphorIconsFill.user,
                              color: _cMuted(isDark), size: 20)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            roleLabel,
                            style: TextStyle(
                                color: _cMuted(isDark),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  counterpart.fullname,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: _cTitle(isDark),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (counterpart.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(PhosphorIconsFill.sealCheck,
                                    size: 14, color: dealBrand),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: onChat,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: _cBrandSoft(isDark),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(PhosphorIconsFill.chatCircleDots,
                    color: dealBrand, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pinned bottom bar for completed deals: a star row that submits directly —
/// tapping a star opens the review sheet with that rating pre-selected (no
/// separate submit button).
class _ReviewBar extends StatefulWidget {
  final ShipmentData shipment;
  final Map<String, String> content;
  final ValueChanged<int> onReview;

  const _ReviewBar({
    required this.shipment,
    required this.content,
    required this.onReview,
  });

  @override
  State<_ReviewBar> createState() => _ReviewBarState();
}

class _ReviewBarState extends State<_ReviewBar> {
  // Reflects the last tapped rating (kept if the user backs out of the sheet).
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    final shipment = widget.shipment;
    final content = widget.content;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final counterpart = shipment.isCarrier ? shipment.sender : shipment.carrier;
    final question = WawatContent.text(
      content,
      'deals.review.question_template',
      '{name} ilə təcrübən necə idi?',
    ).replaceAll('{name}', counterpart?.fullname ?? '');
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: isDark
            ? WawatDark.surface.withValues(alpha: 0.96)
            : Colors.white.withValues(alpha: 0.96),
        border: Border(top: BorderSide(color: _cLine(isDark))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              question,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _cTitle(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final value = i + 1;
                final active = value <= _rating;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() => _rating = value);
                    widget.onReview(value);
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Icon(
                      active
                          ? PhosphorIconsFill.star
                          : PhosphorIconsRegular.star,
                      color: const Color(0xFFF5B301),
                      size: 36,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final ShipmentData shipment;
  final Map<String, String> content;
  final ValueChanged<String> onAction;
  final String? busyAction;

  const _ActionBar({
    required this.shipment,
    required this.content,
    required this.onAction,
    this.busyAction,
  });

  bool get _anyBusy => busyAction != null;

  /// While any action is in flight, only the tapped button reacts (as a
  /// spinner) and the rest go inert — one tap, one request.
  VoidCallback? _tap(String action) => _anyBusy ? null : () => onAction(action);

  static Widget _spinner(Color color) => SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actions = dealSupportedActions(shipment.availableActions);

    if (shipment.status == 'proposal_pending' && !shipment.isAwaitingMe) {
      return _bar(isDark, [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _tap('withdraw'),
            style: OutlinedButton.styleFrom(
              backgroundColor: isDark ? WawatDark.surfaceAlt : dealRed50,
              foregroundColor: isDark ? WawatDark.danger : dealRed600,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: busyAction == 'withdraw'
                ? _spinner(isDark ? WawatDark.danger : dealRed600)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(PhosphorIconsBold.arrowUUpLeft, size: 17),
                      const SizedBox(width: 8),
                      Text(
                        WawatContent.text(content, 'deals.action.withdraw',
                            'Təklifi geri götür'),
                        style: const TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
          ),
        ),
      ]);
    }

    if (shipment.status == 'proposal_pending' && shipment.isAwaitingMe) {
      return _bar(isDark, [
        Row(
          children: [
            if (actions.contains('counter'))
              Expanded(
                child: OutlinedButton(
                  onPressed: _tap('counter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _cInk700(isDark),
                    side: BorderSide(color: _cLine(isDark)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: busyAction == 'counter'
                      ? _spinner(_cInk700(isDark))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(PhosphorIconsBold.arrowUUpLeft,
                                size: 16),
                            const SizedBox(width: 8),
                            Text(
                              dealActionLabel(content, 'counter'),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                ),
              ),
            if (actions.contains('counter') && actions.contains('accept'))
              const SizedBox(width: 8),
            if (actions.contains('accept'))
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _tap('accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dealBrand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: busyAction == 'accept'
                      ? _spinner(Colors.white)
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(PhosphorIconsBold.check, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              dealActionLabel(content, 'accept'),
                              style: const TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                ),
              ),
          ],
        ),
        if (actions.contains('decline'))
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: TextButton(
              onPressed: _tap('decline'),
              child: busyAction == 'decline'
                  ? _spinner(isDark ? WawatDark.danger : dealRed600)
                  : Text(
                      dealActionLabel(content, 'decline'),
                      style: TextStyle(
                          color: isDark ? WawatDark.danger : dealRed600,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600),
                    ),
            ),
          ),
      ]);
    }

    Widget? primary;
    if (shipment.status == 'accepted' && actions.contains('picked-up')) {
      primary = _primaryButton(PhosphorIconsFill.package,
          dealActionLabel(content, 'picked_up'), 'picked-up');
    } else if (shipment.status == 'picked_up' &&
        actions.contains('delivered')) {
      primary = _primaryButton(PhosphorIconsFill.mapPinLine,
          dealActionLabel(content, 'delivered'), 'delivered');
    } else if (shipment.status == 'delivered' && actions.contains('complete')) {
      primary = _primaryButton(PhosphorIconsFill.sealCheck,
          dealActionLabel(content, 'complete'), 'complete');
    }

    final textLinks = <Widget>[];
    if (actions.contains('dispute')) {
      textLinks.add(_textLink(content, 'dispute', _cInk500(isDark)));
    }
    if (actions.contains('cancel')) {
      textLinks.add(
          _textLink(content, 'cancel', isDark ? WawatDark.danger : dealRed600));
    }

    if (primary == null && textLinks.isEmpty) return const SizedBox.shrink();

    return _bar(isDark, [
      if (primary != null) SizedBox(width: double.infinity, child: primary),
      if (textLinks.isNotEmpty)
        Padding(
          padding: EdgeInsets.only(top: primary != null ? 8 : 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < textLinks.length; i++) ...[
                if (i > 0) const SizedBox(width: 20),
                textLinks[i],
              ],
            ],
          ),
        ),
    ]);
  }

  Widget _primaryButton(IconData icon, String label, String action) {
    return ElevatedButton(
      onPressed: _tap(action),
      style: ElevatedButton.styleFrom(
        backgroundColor: dealBrand,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: busyAction == action
          ? _spinner(Colors.white)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 17),
                const SizedBox(width: 8),
                Text(label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
    );
  }

  Widget _textLink(Map<String, String> content, String action, Color color) {
    if (busyAction == action) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: _spinner(color),
      );
    }
    return TextButton.icon(
      onPressed: _tap(action),
      icon: Icon(
          action == 'dispute'
              ? PhosphorIconsRegular.warningOctagon
              : PhosphorIconsRegular.prohibit,
          size: 15,
          color: color),
      label: Text(
        dealActionLabel(content, action),
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _bar(bool isDark, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: isDark
            ? WawatDark.surface.withValues(alpha: 0.96)
            : Colors.white.withValues(alpha: 0.96),
        border: Border(top: BorderSide(color: _cLine(isDark))),
      ),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Map<String, String> content;
  final VoidCallback onRetry;

  const _ErrorView({required this.content, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIconsFill.wifiSlash,
                color: isDark ? WawatDark.dangerText : dealRed600, size: 28),
            const SizedBox(height: 10),
            Text(
              WawatContent.text(content, 'deals.error.load',
                  'Yüklənmədi. İnternet bağlantısını yoxlayın.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _cInk500(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                  backgroundColor: dealBrand, foregroundColor: Colors.white),
              child: Text(WawatContent.text(content, 'deals.retry', 'Yenidən')),
            ),
          ],
        ),
      ),
    );
  }
}
