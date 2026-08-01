import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:buking/presentation/common/app_bottom_sheet.dart';
import 'package:buking/presentation/common/listing_share.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../data/network/api/chat_api.dart';
import '../../../../../data/network/request/listing_proposal_request.dart';
import '../../../../../data/network/response/listing_response.dart';
import '../../../../../data/network/response/user.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/base_screen.dart';
import '../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/theme_aware_screen.dart';
import '../../../../../services/theme_manager.dart';
import '../../../../../services/wawat_content.dart';
import '../../../../chat/chat/chat_conversation_screen.dart';
import '../../create_post/create_post_screen.dart';
import '../../home_tab/widget/auth_modal_utils.dart';
import '../../profile_tab/new_profile/new_profile_screen.dart';
import '../../profile_tab/tier/tier_badge.dart';
import 'listing_details_bloc.dart';

const _brand = Color(0xFF0271EB);
const _brand50 = Color(0xFFEAF3FE);
const _amber = Color(0xFFE8A400);
const _amber50 = Color(0xFFFEF6E7);
const _ink900 = Color(0xFF0F172A);
const _ink800 = Color(0xFF1E293B);
const _ink700 = Color(0xFF334155);
const _ink600 = Color(0xFF475569);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);
const _screenBg = Colors.white;

String _t(Map<String, String> content, String key, String fallback) {
  return WawatContent.text(content, key, fallback);
}

enum ListingDetailsInitialAction {
  proposal,
  message,
}

final Set<String> _openingProposalListingIds = <String>{};
final Set<String> _openingChatUserIds = <String>{};

Future<void> showListingProposalFlow(
  BuildContext context, {
  required Listing listing,
  Map<String, String> packageNamesByCode = const {},
  Map<String, String> content = const {},
}) async {
  if (_openingProposalListingIds.contains(listing.id)) return;
  final repository = sl.get<AuthRepository>();
  if (!await repository.isLogged()) {
    if (context.mounted) AuthModalUtils.showAuthRequiredModal(context);
    return;
  }
  if (!context.mounted) return;

  _openingProposalListingIds.add(listing.id);
  try {
    var packageNames = packageNamesByCode;
    if (packageNames.isEmpty) {
      try {
        final response = await repository.getListingPackageTypes();
        packageNames = {
          for (final item in response.data) item.code: item.name,
        };
      } catch (_) {}
    }
    if (!context.mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sent = await showAppBottomSheet<_ProposalSuccessData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: isDark ? WawatDark.scrim : null,
      builder: (_) => _ProposalSheet(
        listing: listing,
        packageNamesByCode: packageNames,
        onChatTap: () => openListingChat(
          context,
          listing: listing,
          content: content,
        ),
        onSubmit: ({
          required packageTypeCode,
          weightKg,
          priceTotal,
          note,
        }) {
          return repository.createListingProposal(
            listing.id,
            ListingProposalRequest(
              packageTypeCode: packageTypeCode,
              weightKg: weightKg,
              priceTotal: priceTotal,
              note: note,
            ),
            'listing-proposal-${DateTime.now().microsecondsSinceEpoch}',
          );
        },
      ),
    );
    if (!context.mounted || sent == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ProposalSuccessScreen(
          listing: listing,
          data: sent,
          onChatTap: () => openListingChat(
            context,
            listing: listing,
            content: content,
          ),
        ),
      ),
    );
  } finally {
    _openingProposalListingIds.remove(listing.id);
  }
}

Future<void> openListingChat(
  BuildContext context, {
  required Listing listing,
  Map<String, String> content = const {},
}) async {
  final repository = sl.get<AuthRepository>();
  if (!await repository.isLogged()) {
    if (context.mounted) AuthModalUtils.showAuthRequiredModal(context);
    return;
  }
  if (!context.mounted) return;

  var ownerId = listing.owner?.id?.trim() ?? listing.ownerId?.trim() ?? '';
  if (ownerId.isEmpty) {
    try {
      final details = await repository.getListingDetails(listing.id);
      ownerId =
          details.data.owner?.id?.trim() ?? details.data.ownerId?.trim() ?? '';
    } catch (_) {}
  }
  if (ownerId.isEmpty) {
    ownerId = listing.owner?.username?.trim() ?? '';
  }
  if (ownerId.isEmpty) {
    _showListingActionError(
      context,
      _t(content, 'chat.user_not_found', 'İstifadəçi məlumatı tapılmadı.'),
    );
    return;
  }
  if (_openingChatUserIds.contains(ownerId)) return;

  _openingChatUserIds.add(ownerId);
  try {
    final response = await sl.get<ChatApi>().startChat({'user_id': ownerId});
    if (!context.mounted) return;
    final conversation = response.data;
    if (conversation == null) {
      _showListingActionError(
        context,
        _t(content, 'chat.open_error', 'Söhbəti açmaq alınmadı.'),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatConversationScreen(conversation: conversation),
      ),
    );
  } catch (_) {
    if (!context.mounted) return;
    _showListingActionError(
      context,
      _t(content, 'chat.open_error', 'Söhbəti açmaq alınmadı.'),
    );
  } finally {
    _openingChatUserIds.remove(ownerId);
  }
}

void _showListingActionError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(PhosphorIconsFill.warning, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

class ListingDetailsScreen extends BaseScreen<ListingDetailsBloc> {
  final String listingId;
  final ListingDetailsInitialAction? initialAction;
  final bool returnToHomeOnBack;

  ListingDetailsScreen({
    super.key,
    required this.listingId,
    this.initialAction,
    this.returnToHomeOnBack = false,
  });

  @override
  State<ListingDetailsScreen> createState() => _ListingDetailsScreenState();
}

class _ListingDetailsScreenState
    extends BaseState<ListingDetailsScreen, ListingDetailsBloc> {
  late Future<_DetailsBundle> _detailsFuture;
  Map<String, String> _content = const {};
  bool _initialActionHandled = false;
  bool _allowRoutePop = false;
  // Optimistic favorite state, so tapping the heart re-renders only the icon
  // instead of re-running _detailsFuture (which would reload the whole page).
  // Null = follow the loaded listing; cleared on every real _reload().
  bool? _favoritedOverride;

  @override
  bool get showProgressIndicator => false;

  void _handleBack() {
    if (widget.returnToHomeOnBack) {
      _returnToHome();
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _returnToHome() {
    if (!mounted) return;
    if (!_allowRoutePop) {
      setState(() => _allowRoutePop = true);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  @override
  void initState() {
    super.initState();
    _detailsFuture = _load();
  }

  Future<_DetailsBundle> _load() async {
    final results = await Future.wait([
      bloc.loadPackageTypes(),
      bloc.loadContent().catchError((_) => <String, String>{}),
      bloc.currentUser().catchError((_) => null),
      bloc.getDetails(widget.listingId),
    ]);
    final packageNames = bloc.packageNamesByCode;
    final content = results[1] as Map<String, String>;
    final user = results[2] as User?;
    final response = results[3] as ListingResponse;
    _content = content;
    return _DetailsBundle(
      response: response,
      packageNames: packageNames,
      content: content,
      currentUser: user,
    );
  }

  @override
  Widget body() {
    final content = Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        final isDark = themeManager.isDarkMode;
        return ThemeAwareScreen(
          isDark: isDark,
          lightBackgroundColor: _screenBg,
          darkBackgroundColor: WawatDark.bg,
          child: FutureBuilder<_DetailsBundle>(
            future: _detailsFuture,
            builder: (context, snapshot) {
              final bundle = snapshot.data;
              final listing = bundle?.response.data;
              final isOwner = listing == null
                  ? false
                  : _isOwner(listing, bundle?.currentUser);
              if (listing != null &&
                  !isOwner &&
                  !_initialActionHandled &&
                  widget.initialAction != null) {
                _initialActionHandled = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  switch (widget.initialAction!) {
                    case ListingDetailsInitialAction.proposal:
                      _showProposalSheet(listing);
                      break;
                    case ListingDetailsInitialAction.message:
                      _openMessage(listing);
                      break;
                  }
                });
              }
              final bottomHeight = listing == null
                  ? 0.0
                  : 112.0 + MediaQuery.of(context).padding.bottom;
              return Stack(
                children: [
                  SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        _TopBar(
                          listing: listing,
                          isDark: isDark,
                          isOwner: isOwner,
                          isFavorited:
                              _favoritedOverride ?? (listing?.isFavorited ?? false),
                          content: bundle?.content ?? const {},
                          onBack: _handleBack,
                          onShare: listing == null
                              ? null
                              : () => _shareListing(listing),
                          onFavorite: listing == null || isOwner
                              ? null
                              : () => _toggleFavorite(listing),
                          onReport: listing == null || isOwner
                              ? null
                              : () => _showReportSheet(listing),
                        ),
                        Expanded(
                          child: CustomScrollView(
                            slivers: [
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting)
                                const SliverToBoxAdapter(
                                    child: _DetailsSkeleton())
                              else if (snapshot.hasError)
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: _ErrorState(
                                    content: _content,
                                    onRetry: _reload,
                                  ),
                                )
                              else if (bundle != null)
                                ..._contentSlivers(bundle, isOwner)
                              else
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: _ErrorState(
                                    content: _content,
                                    onRetry: _reload,
                                  ),
                                ),
                              SliverToBoxAdapter(
                                  child: SizedBox(height: bottomHeight)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (listing != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _ActionBar(
                        listing: listing,
                        isOwner: isOwner,
                        content: bundle?.content ?? const {},
                        onMessage: () => _openMessage(listing),
                        onOffer: () => _showProposalSheet(listing),
                        onEdit: () => _openEdit(listing),
                        onPause: () => _pause(listing),
                        onResume: () => _resume(listing),
                        onRepost: () => _repost(listing),
                        onDelete: () => _showDeleteSheet(listing),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
    if (!widget.returnToHomeOnBack) return content;
    return PopScope(
      canPop: _allowRoutePop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _returnToHome();
      },
      child: content,
    );
  }

  List<Widget> _contentSlivers(_DetailsBundle bundle, bool isOwner) {
    final listing = bundle.response.data;
    final similar = bundle.response.meta?.similar ?? const <Listing>[];
    final ownerTopBanner =
        isOwner ? _ownerTopBanner(listing.status ?? 'active') : null;
    return [
      if (ownerTopBanner != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ownerTopBanner,
          ),
        ),
      SliverToBoxAdapter(
        child: _RouteHero(
          listing: listing,
          packageNamesByCode: bundle.packageNames,
          content: bundle.content,
          isOwner: isOwner,
        ),
      ),
      if (isOwner)
        SliverToBoxAdapter(
          child: _OwnerManagementBlock(
            listing: listing,
            content: bundle.content,
            packageNamesByCode: bundle.packageNames,
          ),
        )
      else if (listing.owner != null)
        SliverToBoxAdapter(
          child: _TrustBlock(
            owner: listing.owner!,
            content: bundle.content,
            onTap: () => _openOwnerProfile(listing.owner!),
          ),
        ),
      if (!isOwner) ...[
        SliverToBoxAdapter(
          child: _FactsGrid(
            listing: listing,
            isOwner: isOwner,
            content: bundle.content,
          ),
        ),
        SliverToBoxAdapter(
          child: _PackageTypesBlock(
            listing: listing,
            packageNamesByCode: bundle.packageNames,
            content: bundle.content,
          ),
        ),
        SliverToBoxAdapter(
          child: _DescriptionBlock(
            listing: listing,
            content: bundle.content,
          ),
        ),
        if (similar.isNotEmpty)
          SliverToBoxAdapter(
            child: _SimilarBlock(
              listings: similar,
              packageNamesByCode: bundle.packageNames,
              content: bundle.content,
              onOpen: (item) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ListingDetailsScreen(listingId: item.id),
                  ),
                );
              },
              onShowAll: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _SimilarListingsScreen(
                      listings: similar,
                      content: bundle.content,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    ];
  }

  bool _isOwner(Listing listing, User? user) {
    final ownerUsername = listing.owner?.username;
    final currentUsername = user?.username;
    return ownerUsername != null &&
        ownerUsername.isNotEmpty &&
        currentUsername != null &&
        currentUsername.isNotEmpty &&
        ownerUsername == currentUsername;
  }

  Future<void> _toggleFavorite(Listing listing) async {
    final isLogged = await bloc.isLogged();
    if (!mounted) return;
    if (!isLogged) {
      AuthModalUtils.showAuthRequiredModal(context);
      return;
    }
    final current = _favoritedOverride ?? listing.isFavorited;
    final nextValue = !current;
    // Flip the heart instantly and keep the loaded page as-is — no _reload(),
    // which would re-run _detailsFuture and rebuild the whole screen.
    setState(() => _favoritedOverride = nextValue);
    try {
      await bloc.setFavorite(listing, nextValue);
    } catch (_) {
      if (!mounted) return;
      setState(() => _favoritedOverride = current); // revert on failure
      _showError('Əməliyyat alınmadı.');
      return;
    }
    if (!mounted) return;
    _snack(
      nextValue
          ? _t(_content, 'listing.favorited', 'Elan seçilmişlərə əlavə edildi.')
          : _t(_content, 'listing.unfavorited',
              'Elan seçilmişlərdən çıxarıldı.'),
    );
  }

  Future<void> _pause(Listing listing) async {
    final confirmed = await _confirmAction(
      title: 'Elanı dayandır?',
      message:
          'Bu elan lentdən çıxacaq və istifadəçilər onu görməyəcək. Davam edək?',
      confirmLabel: 'Dayandır',
    );
    if (!confirmed) return;
    try {
      final response = await bloc.pauseListing(listing.id);
      if (!mounted) return;
      // Show the backend's (localized) message; reload picks up the new status.
      _showSuccess(response.message ??
          _t(_content, 'listing.paused', 'Elan dayandırıldı.'));
      _reload();
    } catch (_) {
      if (!mounted) return;
      _showError('Əməliyyat alınmadı.');
    }
  }

  Future<void> _resume(Listing listing) async {
    final confirmed = await _confirmAction(
      title: 'Elanı aktivləşdir?',
      message: 'Elan yenidən lentdə görünəcək. Davam edək?',
      confirmLabel: 'Aktiv et',
    );
    if (!confirmed) return;
    try {
      // Resume does NOT always go back to `active`: a listing paused while on
      // moderation returns to `moderation`. Trust the response — show its
      // message and let _reload() refresh the UI by the real returned status.
      final response = await bloc.resumeListing(listing.id);
      if (!mounted) return;
      _showSuccess(
        response.message ??
            _t(_content, 'listing.resumed', 'Elan yenidən aktivləşdirildi.'),
      );
      _reload();
    } catch (_) {
      if (!mounted) return;
      _showError('Əməliyyat alınmadı.');
    }
  }

  Future<void> _repost(Listing listing) async {
    // Repost needs a NEW future date, so we don't fire /repost with the old
    // (expired) date — that 422s. Instead open the publish form pre-filled from
    // this listing (everything but the date); it submits POST /listings/{id}/
    // repost and shows its own success (new listing → moderation). The form also
    // surfaces the localized 4xx `message` (past date, quota limit, …).
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => CreatePostScreen(repostListing: listing),
      ),
    );
  }

  Future<void> _openEdit(Listing listing) async {
    final result = await Navigator.of(context).push<ListingResponse>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => CreatePostScreen(editListing: listing),
      ),
    );
    if (!mounted || result == null) return;
    // Any edit re-runs moderation — surface that and reload the fresh state.
    _showSuccess(
      result.message ??
          _t(_content, 'listing.updated_moderation',
              'Elan yeniləndi və yenidən moderasiyaya göndərildi.'),
    );
    _reload();
  }

  Future<void> _openMessage(Listing listing) async {
    await openListingChat(context, listing: listing, content: _content);
  }

  void _shareListing(Listing listing) {
    // Open the OS share sheet (WhatsApp, Telegram, …) instead of a bare copy.
    shareListing(listing);
  }

  void _openOwnerProfile(ListingOwner owner) {
    final userId = (owner.id ?? owner.username ?? '').trim();
    if (userId.isEmpty) {
      _showError('Profil məlumatı tapılmadı.');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PublicProfileScreen(
          userId: userId,
          initialOwner: owner,
        ),
      ),
    );
  }

  Future<void> _showProposalSheet(Listing listing) async {
    // Full listing has no space left — block the flow even if it was reached via
    // a deep-link initial action, not just the (already disabled) CTA.
    if (listing.isFull) {
      _snack(listing.statusLabel ??
          _t(_content, 'listing.fully_booked', 'Yer yoxdur.'));
      return;
    }
    await showListingProposalFlow(
      context,
      listing: listing,
      packageNamesByCode: bloc.packageNamesByCode,
      content: _content,
    );
  }

  Future<void> _showDeleteSheet(Listing listing) async {
    final confirmed = await _confirmAction(
      title: 'Elanı sil?',
      message: 'Bu əməliyyat geri qaytarılmır. Davam etmək istəyirsən?',
      confirmLabel: 'Sil',
      isDanger: true,
    );
    if (!confirmed) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deleted = await showAppBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: isDark ? WawatDark.scrim : null,
      builder: (_) => _ReasonSheet(
        title: 'Elanı sil',
        subtitle: 'Silmə səbəbini seç.',
        actionLabel: 'Sil',
        isDanger: true,
        reasons: _deleteReasons(_content),
        onSubmit: (reason, note) {
          return bloc.deleteListing(
            id: listing.id,
            reasonCode: reason,
            reasonNote: note,
          );
        },
      ),
    );
    if (!mounted || deleted != true) return;
    _showSuccess(_t(_content, 'listing.deleted', 'Elan silindi.'));
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _showReportSheet(Listing listing) async {
    final isLogged = await bloc.isLogged();
    if (!mounted) return;
    if (!isLogged) {
      AuthModalUtils.showAuthRequiredModal(context);
      return;
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sent = await showAppBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: isDark ? WawatDark.scrim : null,
      builder: (_) => _ReasonSheet(
        title: 'Şikayət et',
        subtitle: 'Səbəbi seç və ya qısa qeyd yaz.',
        actionLabel: 'Göndər',
        reasons: _reportReasons(_content),
        onSubmit: (reason, note) {
          return bloc.reportListing(
            listingId: listing.id,
            reasonCode: reason,
            note: note,
          );
        },
      ),
    );
    if (!mounted || sent != true) return;
    _snack('Şikayət göndərildi.');
  }

  void _reload() {
    setState(() {
      _favoritedOverride = null;
      _detailsFuture = _load();
    });
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccess(String message) {
    _showToast(message, const Color(0xFF10B981), PhosphorIconsFill.checkCircle);
  }

  void _showError(String message) {
    _showToast(message, const Color(0xFFEF4444), PhosphorIconsFill.warning);
  }

  void _showToast(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 22),
      ),
    );
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
    required String confirmLabel,
    bool isDanger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _ConfirmActionDialog(
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          isDanger: isDanger,
        );
      },
    );
    return result == true;
  }

  @override
  ListingDetailsBloc provideBloc() {
    return ListingDetailsBloc();
  }
}

class _DetailsBundle {
  final ListingResponse response;
  final Map<String, String> packageNames;
  final Map<String, String> content;
  final User? currentUser;

  _DetailsBundle({
    required this.response,
    required this.packageNames,
    required this.content,
    required this.currentUser,
  });
}

class _ConfirmActionDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final bool isDanger;

  const _ConfirmActionDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.isDanger,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = cText(isDark);
    final primary = isDanger ? const Color(0xFFEF4444) : _brand;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cCard(isDark),
          borderRadius: BorderRadius.circular(26),
          border: cCardBorder(isDark),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.10),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: isDark ? WawatDark.textSecondary : _ink500,
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark
                            ? WawatDark.surfaceAlt
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Ləğv et',
                        style: TextStyle(
                          color: isDark ? WawatDark.textPrimary : _ink500,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        confirmLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final Listing? listing;
  final bool isDark;
  final bool isOwner;
  final bool isFavorited;
  final Map<String, String> content;
  final VoidCallback onBack;
  final VoidCallback? onShare;
  final VoidCallback? onFavorite;
  final VoidCallback? onReport;

  const _TopBar({
    required this.listing,
    required this.isDark,
    required this.isOwner,
    required this.isFavorited,
    required this.content,
    required this.onBack,
    this.onShare,
    this.onFavorite,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = cText(isDark);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 12),
      decoration: BoxDecoration(
        color: cBar(isDark),
        border: Border(
          bottom: BorderSide(
            color: isDark ? WawatDark.divider : _ink900.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onBack,
            child: Icon(
              PhosphorIconsBold.arrowLeft,
              color: titleColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isOwner ? 'Elanım' : _t(content, 'listing.detail_title', 'Elan'),
              style: TextStyle(
                color: titleColor,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isOwner)
            _TopIcon(
              icon: PhosphorIconsBold.dotsThreeVertical,
              color: titleColor,
              onTap: onReport,
            )
          else ...[
            _TopIcon(
              icon: PhosphorIconsRegular.shareNetwork,
              color: isDark ? WawatDark.icon : _ink500,
              onTap: onShare,
              onLongPress: onReport,
            ),
            _TopIcon(
              icon: isFavorited
                  ? PhosphorIconsFill.heart
                  : PhosphorIconsRegular.heart,
              color: isFavorited
                  ? Colors.red
                  : (isDark ? WawatDark.icon : _ink500),
              onTap: onFavorite,
            ),
          ],
        ],
      ),
    );
  }
}

class _TopIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _TopIcon({
    required this.icon,
    this.color = _ink500,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class _RouteHero extends StatelessWidget {
  final Listing listing;
  final Map<String, String> packageNamesByCode;
  final Map<String, String> content;
  final bool isOwner;

  const _RouteHero({
    required this.listing,
    required this.packageNamesByCode,
    required this.content,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isOwner && _isMutedOwnerStatus(listing.status);
    final accent = muted
        ? (isDark ? WawatDark.textMuted : _ink400)
        : (listing.isTrip
            ? (isDark ? WawatDark.brandText : _brand)
            : (isDark ? WawatDark.warning : _amber));
    final accent50 = muted
        ? (isDark ? WawatDark.surfaceAlt : const Color(0xFFF1F5F9))
        : (listing.isTrip
            ? (isDark ? WawatDark.brandChip : _brand50)
            : (isDark ? WawatDark.warningBg : _amber50));
    return Container(
      color: isDark ? WawatDark.bg : Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TypeBadge(
                listing: listing,
                content: content,
                muted: muted,
              ),
              const Spacer(),
              if (isOwner)
                _StatusBadge(listing: listing, content: content)
              else if (listing.promotionType != null)
                _PromotionBadge(
                  promotionType: listing.promotionType!,
                  content: content,
                ),
            ],
          ),
          const SizedBox(height: 18),
          Opacity(
            opacity: muted ? 0.7 : 1,
            child: _RouteLine(
                listing: listing, accent: accent, accent50: accent50),
          ),
          const SizedBox(height: 16),
          _DateRibbon(listing: listing, accent: accent, accent50: accent50),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final Listing listing;
  final Map<String, String> content;
  final bool muted;

  const _TypeBadge({
    required this.listing,
    required this.content,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTrip = listing.isTrip;
    final accent = muted
        ? (isDark ? WawatDark.textMuted : _ink500)
        : (isTrip
            ? (isDark ? WawatDark.brandText : _brand)
            : (isDark ? WawatDark.warning : _amber));
    final accent50 = muted
        ? (isDark ? WawatDark.surfaceAlt : const Color(0xFFF1F5F9))
        : (isTrip
            ? (isDark ? WawatDark.brandChip : _brand50)
            : (isDark ? WawatDark.warningBg : _amber50));
    final label = listing.typeLabel ??
        _t(
          content,
          isTrip ? 'enum.listing_type.trip' : 'enum.listing_type.shipment_post',
          isTrip ? 'SƏFƏR' : 'GÖNDƏRİŞ',
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent50,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isTrip ? PhosphorIconsFill.airplaneTilt : PhosphorIconsFill.package,
            color: accent,
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: accent,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Listing listing;
  final Map<String, String> content;

  const _StatusBadge({
    required this.listing,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = listing.status ?? 'active';
    final color = _statusColor(status, isDark);
    final label = listing.statusLabel ??
        _t(content, 'enum.listing_status.$status', status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromotionBadge extends StatelessWidget {
  final String promotionType;
  final Map<String, String> content;

  const _PromotionBadge({
    required this.promotionType,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = _t(
      content,
      'enum.promotion_type.$promotionType',
      promotionType == 'vip' ? 'VİP' : 'Önə çıxarılan',
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? WawatDark.goldSoftBg : const Color(0x3DF2FC2A),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            promotionType == 'vip'
                ? PhosphorIconsFill.crownSimple
                : PhosphorIconsFill.rocketLaunch,
            color: isDark ? WawatDark.goldSoftText : _amber,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: isDark ? WawatDark.goldSoftText : _ink800,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteLine extends StatelessWidget {
  final Listing listing;
  final Color accent;
  final Color accent50;

  const _RouteLine({
    required this.listing,
    required this.accent,
    required this.accent50,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RouteSide(
            city: listing.cityFrom ?? '-',
            country: _countryFallback(listing.cityFrom),
          ),
        ),
        const SizedBox(width: 8),
        _RouteTrack(
          isTrip: listing.isTrip,
          accent: accent,
          accent50: accent50,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _RouteSide(
            city: listing.cityTo ?? '-',
            country: _countryFallback(listing.cityTo),
            alignRight: true,
          ),
        ),
      ],
    );
  }
}

class _RouteSide extends StatelessWidget {
  final String city;
  final String? country;
  final bool alignRight;

  const _RouteSide({
    required this.city,
    this.country,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          country ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: cMuted(isDark),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          city,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: cText(isDark),
            fontSize: 25,
            height: 1.05,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _RouteTrack extends StatelessWidget {
  final bool isTrip;
  final Color accent;
  final Color accent50;

  const _RouteTrack({
    required this.isTrip,
    required this.accent,
    required this.accent50,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dot(color: accent, filled: true),
        _Dash(color: accent.withValues(alpha: 0.22)),
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: accent50, shape: BoxShape.circle),
          child: Icon(
            isTrip ? PhosphorIconsFill.airplaneTilt : PhosphorIconsFill.package,
            color: accent,
            size: 17,
          ),
        ),
        _Dash(color: accent.withValues(alpha: 0.22)),
        _Dot(color: accent, filled: false),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final bool filled;

  const _Dot({required this.color, required this.filled});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: filled ? color : (isDark ? WawatDark.bg : Colors.white),
        shape: BoxShape.circle,
        border: filled ? null : Border.all(color: color, width: 2),
      ),
    );
  }
}

class _Dash extends StatelessWidget {
  final Color color;

  const _Dash({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: color, width: 2)),
      ),
    );
  }
}

class _DateRibbon extends StatelessWidget {
  final Listing listing;
  final Color accent;
  final Color accent50;

  const _DateRibbon({
    required this.listing,
    required this.accent,
    required this.accent50,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = listing.isTrip
        ? [
            _formatDate(listing.flightDate),
            if ((listing.flightTime ?? '').isNotEmpty)
              _formatTime(listing.flightTime),
          ].whereType<String>().join(' · ')
        : _formatDateRange(listing.deliveryDateFrom, listing.deliveryDateTo);
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(PhosphorIconsFill.calendarDots, color: accent, size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: cText(isDark),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustBlock extends StatelessWidget {
  final ListingOwner owner;
  final Map<String, String> content;
  final VoidCallback? onTap;

  const _TrustBlock({
    required this.owner,
    required this.content,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = _initials(owner.displayName);
    final tier = owner.tier;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(context),
        child: Column(
          children: [
            Row(
              children: [
                _Avatar(initials: initials, color: cBrandText(isDark)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              owner.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: cText(isDark),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (owner.isVerified) ...[
                            const SizedBox(width: 5),
                            Icon(PhosphorIconsFill.sealCheck,
                                color: cBrandText(isDark), size: 18),
                          ],
                          if (tier != null && tier.isNotEmpty) ...[
                            const SizedBox(width: 5),
                            TierBadge(tier: tier, content: content),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 5,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(PhosphorIconsFill.star,
                              color: isDark
                                  ? WawatDark.star
                                  : const Color(0xFFF59E0B),
                              size: 15),
                          Text(
                            owner.ratingAvg?.toStringAsFixed(1) ?? '0',
                            style: TextStyle(
                              color: isDark ? WawatDark.textPrimary : _ink800,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '(${owner.ratingCount ?? 0})',
                            style: TextStyle(
                              color: cText2(isDark),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text('·', style: TextStyle(color: cFaint(isDark))),
                          Text(
                            '${owner.completedShipmentsCount ?? 0} çatdırılma',
                            style: TextStyle(
                              color: cText2(isDark),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(PhosphorIconsRegular.caretRight, color: cFaint(isDark)),
              ],
            ),
            if (owner.avgResponseMinutes != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? WawatDark.successBg : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(PhosphorIconsFill.lightning,
                        color: isDark
                            ? WawatDark.success
                            : const Color(0xFF059669),
                        size: 16),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Adətən ~${owner.avgResponseMinutes} dəqiqəyə cavab verir',
                        style: TextStyle(
                          color: isDark
                              ? WawatDark.success
                              : const Color(0xFF047857),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OwnerManagementBlock extends StatelessWidget {
  final Listing listing;
  final Map<String, String> content;
  final Map<String, String> packageNamesByCode;

  const _OwnerManagementBlock({
    required this.listing,
    required this.content,
    required this.packageNamesByCode,
  });

  @override
  Widget build(BuildContext context) {
    final status = listing.status ?? 'active';
    if (status == 'partially_booked' || status == 'fully_booked') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: [
            _ReservationProgressCard(listing: listing),
            const SizedBox(height: 12),
            const _OwnerInfoBanner(
              icon: PhosphorIconsFill.info,
              color: _brand,
              background: _brand50,
              darkColor: WawatDark.brandText,
              darkBackground: WawatDark.brandChip,
              title: null,
              message:
                  'Aktiv sövdələşmə olduğu üçün redaktə məhduddur. Silmək istəsəniz, əvvəl açıq sövdələşmələri həll edin.',
            ),
            const SizedBox(height: 14),
            _OwnerDetailsCard(
              listing: listing,
              packageNamesByCode: packageNamesByCode,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          if (status == 'active') ...[
            _OwnerStatsGrid(listing: listing),
            const SizedBox(height: 14),
          ],
          _OwnerDetailsCard(
            listing: listing,
            packageNamesByCode: packageNamesByCode,
          ),
        ],
      ),
    );
  }
}

class _OwnerStatsGrid extends StatelessWidget {
  final Listing listing;

  const _OwnerStatsGrid({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _OwnerStatCard(
            value: '${listing.viewCount ?? 0}',
            label: 'Baxış',
            icon: PhosphorIconsRegular.eye,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _OwnerStatCard(
            value: '${listing.favoritesCount ?? 0}',
            label: 'Seçilmiş',
            icon: PhosphorIconsRegular.heart,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _OwnerStatCard(
            value: listing.isTrip
                ? '${_num(listing.freeWeightKg)}kq'
                : '${_num(listing.weightKg)}kq',
            label: listing.isTrip ? 'Boş' : 'Çəki',
            icon: PhosphorIconsRegular.scales,
          ),
        ),
      ],
    );
  }
}

class _OwnerStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _OwnerStatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: _cardDecoration(context, radius: 18),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: cText(isDark),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: cMuted(isDark), size: 13),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cMuted(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReservationProgressCard extends StatelessWidget {
  final Listing listing;

  const _ReservationProgressCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reserved = listing.reservedKg ?? 0;
    final max = listing.maxWeightKg ?? 0;
    final free = listing.freeWeightKg ?? 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(context, radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Rezerv olunub',
                style: TextStyle(
                  color: cText(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${_num(reserved)} / ${_num(max)} kq',
                style: TextStyle(
                  color: cBrandText(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: _progress(reserved, max),
              color: _brand,
              backgroundColor: isDark
                  ? WawatDark.surfaceAlt
                  : _ink900.withValues(alpha: 0.07),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            '${_num(free)} kq boş yer qalıb',
            style: TextStyle(
              color: cText2(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerDetailsCard extends StatelessWidget {
  final Listing listing;
  final Map<String, String> packageNamesByCode;

  const _OwnerDetailsCard({
    required this.listing,
    required this.packageNamesByCode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final packages = listing.packageTypeCodes
        .map((code) => packageNamesByCode[code] ?? code)
        .join(', ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detallar',
          style: TextStyle(
            color: cText(isDark),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cCard(isDark),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  isDark ? WawatDark.border : _ink900.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            children: [
              if (listing.isTrip)
                _OwnerDetailRow(
                  label: 'Qiymət',
                  value: listing.allowPriceNegotiation == true
                      ? 'Razılaşma'
                      : '${_num(listing.pricePerKg)} \$/kq',
                ),
              if (listing.isTrip)
                _OwnerDetailRow(
                  label: 'Reys',
                  value: (listing.flightNumber ?? '').isEmpty
                      ? '-'
                      : listing.flightNumber!,
                ),
              _OwnerDetailRow(
                label: 'Bağlamalar',
                value: packages.isEmpty ? '-' : packages,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OwnerDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _OwnerDetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: cText2(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cText(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerInfoBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final Color? darkColor;
  final Color? darkBackground;
  final String? title;
  final String message;

  const _OwnerInfoBanner({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.message,
    this.darkColor,
    this.darkBackground,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? (darkColor ?? color) : color;
    final bg = isDark ? (darkBackground ?? background) : background;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      color: fg,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: TextStyle(
                    color: fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FactsGrid extends StatelessWidget {
  final Listing listing;
  final bool isOwner;
  final Map<String, String> content;

  const _FactsGrid({
    required this.listing,
    required this.isOwner,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final facts = listing.isTrip
        ? [
            _FactData(
              PhosphorIconsRegular.scales,
              'Boş yer',
              '${_num(listing.freeWeightKg)} kq',
              suffix: '/ ${_num(listing.maxWeightKg)} kq',
            ),
            _FactData(
              PhosphorIconsRegular.tag,
              'Qiymət',
              listing.allowPriceNegotiation == true
                  ? 'Razılaşma'
                  : '${_num(listing.pricePerKg)} \$',
              suffix: listing.allowPriceNegotiation == true ? null : '/kq',
            ),
            _FactData(
              PhosphorIconsRegular.airplaneInFlight,
              'Reys',
              (listing.flightNumber ?? '').isEmpty
                  ? '-'
                  : listing.flightNumber!,
            ),
            _FactData(
              PhosphorIconsRegular.clock,
              'Dərc olunub',
              _relativeDate(listing.createdAt),
            ),
          ]
        : [
            _FactData(
              PhosphorIconsRegular.scales,
              'Çəki',
              '${_num(listing.weightKg)} kq',
            ),
            _FactData(
              PhosphorIconsRegular.calendarBlank,
              'Təhvil',
              _formatDateRange(
                  listing.deliveryDateFrom, listing.deliveryDateTo),
            ),
            _FactData(
              PhosphorIconsRegular.clock,
              'Dərc olunub',
              _relativeDate(listing.createdAt),
            ),
          ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: GridView.builder(
        itemCount: facts.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.86,
        ),
        itemBuilder: (context, index) => _FactCard(data: facts[index]),
      ),
    );
  }
}

class _FactData {
  final IconData icon;
  final String label;
  final String value;
  final String? suffix;

  _FactData(this.icon, this.label, this.value, {this.suffix});
}

class _FactCard extends StatelessWidget {
  final _FactData data;

  const _FactCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: _cardDecoration(context, radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(data.icon, color: cMuted(isDark), size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data.label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cMuted(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: data.value,
              children: [
                if (data.suffix != null)
                  TextSpan(
                    text: ' ${data.suffix}',
                    style: TextStyle(
                      color: cMuted(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: cText(isDark),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageTypesBlock extends StatelessWidget {
  final Listing listing;
  final Map<String, String> packageNamesByCode;
  final Map<String, String> content;

  const _PackageTypesBlock({
    required this.listing,
    required this.packageNamesByCode,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    if (listing.packageTypeCodes.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            listing.isTrip ? 'Qəbul olunan bağlamalar' : 'Bağlama növü',
            style: TextStyle(
              color: cText(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final code in listing.packageTypeCodes)
                _Chip(
                  icon: _packageIcon(code),
                  label: packageNamesByCode[code] ?? code,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DescriptionBlock extends StatelessWidget {
  final Listing listing;
  final Map<String, String> content;

  const _DescriptionBlock({
    required this.listing,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final text = listing.description?.trim();
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Təsvir',
            style: TextStyle(
              color: cText(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            text,
            style: TextStyle(
              color: cText3(isDark),
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimilarBlock extends StatelessWidget {
  final List<Listing> listings;
  final Map<String, String> packageNamesByCode;
  final Map<String, String> content;
  final ValueChanged<Listing> onOpen;
  final VoidCallback onShowAll;

  const _SimilarBlock({
    required this.listings,
    required this.packageNamesByCode,
    required this.content,
    required this.onOpen,
    required this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Oxşar elanlar',
                    style: TextStyle(
                      color: cText(isDark),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onShowAll,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Text(
                      'Hamısı',
                      style: TextStyle(
                        color: cBrandText(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          SizedBox(
            height: 132,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: listings.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) => _SimilarCard(
                listing: listings[index],
                onTap: () => onOpen(listings[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimilarListingsScreen extends StatelessWidget {
  final List<Listing> listings;
  final Map<String, String> content;

  const _SimilarListingsScreen({
    required this.listings,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: cScreen(isDark),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                decoration: BoxDecoration(
                  color: cBar(isDark),
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? WawatDark.divider
                          : _ink900.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Icon(
                        PhosphorIconsBold.arrowLeft,
                        color: isDark ? WawatDark.textPrimary : _ink700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Oxşar elanlar',
                        style: TextStyle(
                          color: cText(isDark),
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              sliver: SliverList.separated(
                itemCount: listings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final listing = listings[index];
                  return _SimilarListCard(
                    listing: listing,
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) =>
                              ListingDetailsScreen(listingId: listing.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimilarListCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;

  const _SimilarListCard({
    required this.listing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = listing.isTrip
        ? (isDark ? WawatDark.brandText : _brand)
        : (isDark ? WawatDark.warning : _amber);
    final accent50 = listing.isTrip
        ? (isDark ? WawatDark.brandChip : _brand50)
        : (isDark ? WawatDark.warningBg : _amber50);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(context, radius: 22),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                listing.isTrip
                    ? PhosphorIconsFill.airplaneTilt
                    : PhosphorIconsFill.package,
                color: accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${listing.cityFrom ?? '-'} → ${listing.cityTo ?? '-'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cText(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    listing.isTrip
                        ? '${_formatDate(listing.flightDate)} · ${_num(listing.freeWeightKg)} kq boş'
                        : _formatDateRange(
                            listing.deliveryDateFrom,
                            listing.deliveryDateTo,
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cText2(isDark),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (listing.isTrip)
              Text(
                listing.allowPriceNegotiation == true
                    ? 'Razılaşma ilə'
                    : '${_num(listing.pricePerKg)} \$/kq',
                style: TextStyle(
                  color: cText(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(width: 8),
            Icon(PhosphorIconsRegular.caretRight, color: cFaint(isDark)),
          ],
        ),
      ),
    );
  }
}

class _SimilarCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;

  const _SimilarCard({
    required this.listing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = listing.isTrip
        ? (isDark ? WawatDark.brandText : _brand)
        : (isDark ? WawatDark.warning : _amber);
    final accent50 = listing.isTrip
        ? (isDark ? WawatDark.brandChip : _brand50)
        : (isDark ? WawatDark.warningBg : _amber50);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 168,
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(context, radius: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: accent50,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    listing.isTrip
                        ? PhosphorIconsFill.airplaneTilt
                        : PhosphorIconsFill.package,
                    color: accent,
                    size: 14,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    listing.isTrip ? 'Səfər' : 'Göndəriş',
                    style: TextStyle(
                      color: accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${listing.cityFrom ?? '-'} → ${listing.cityTo ?? '-'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cText(isDark),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              listing.isTrip
                  ? '${_formatDate(listing.flightDate)} · ${_num(listing.freeWeightKg)} kq boş'
                  : _formatDateRange(
                      listing.deliveryDateFrom, listing.deliveryDateTo),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cText2(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (listing.isTrip)
              Text(
                listing.allowPriceNegotiation == true
                    ? 'Razılaşma ilə'
                    : '${_num(listing.pricePerKg)} \$/kq',
                style: TextStyle(
                  color: cText(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final Listing listing;
  final bool isOwner;
  final Map<String, String> content;
  final VoidCallback onMessage;
  final VoidCallback onOffer;
  final VoidCallback onEdit;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onRepost;
  final VoidCallback onDelete;

  const _ActionBar({
    required this.listing,
    required this.isOwner,
    required this.content,
    required this.onMessage,
    required this.onOffer,
    required this.onEdit,
    required this.onPause,
    required this.onResume,
    required this.onRepost,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.of(context).padding.bottom;
    final status = listing.status ?? 'active';
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottom),
      decoration: BoxDecoration(
        color: cBar(isDark),
        border: Border(
          top: BorderSide(
            color: isDark ? WawatDark.border : _ink900.withValues(alpha: 0.06),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : _ink900.withValues(alpha: 0.14),
            blurRadius: 30,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: isOwner
          ? _ownerActions(status)
          : Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Mesaj',
                    icon: PhosphorIconsFill.chatCircle,
                    variant: _ActionVariant.ghost,
                    onTap: onMessage,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  // No space left on a full listing → the offer CTA is disabled.
                  child: listing.isFull
                      ? _ActionButton(
                          label: listing.statusLabel ?? 'Yer yoxdur',
                          icon: PhosphorIconsFill.prohibit,
                          variant: _ActionVariant.disabled,
                          onTap: () {},
                        )
                      : _ActionButton(
                          label: 'Təklif göndər',
                          icon: PhosphorIconsFill.paperPlaneTilt,
                          variant: _ActionVariant.primary,
                          onTap: onOffer,
                        ),
                ),
              ],
            ),
    );
  }

  Widget _ownerActions(String status) {
    if (status == 'paused') {
      return Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: 'Redaktə',
              icon: PhosphorIconsBold.pencilSimple,
              variant: _ActionVariant.ghost,
              onTap: onEdit,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _ActionButton(
              label: 'Yenidən aktivləşdir',
              icon: PhosphorIconsFill.play,
              variant: _ActionVariant.primary,
              onTap: onResume,
            ),
          ),
        ],
      );
    }
    if (status == 'expired') {
      return Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: 'Sil',
              icon: PhosphorIconsRegular.trash,
              variant: _ActionVariant.ghost,
              onTap: onDelete,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _ActionButton(
              label: 'Yenidən paylaş',
              icon: PhosphorIconsBold.arrowClockwise,
              variant: _ActionVariant.primary,
              onTap: onRepost,
            ),
          ),
        ],
      );
    }
    if (status == 'rejected') {
      return Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: 'Sil',
              icon: PhosphorIconsRegular.trash,
              variant: _ActionVariant.ghost,
              onTap: onDelete,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _ActionButton(
              label: 'Düzəlt',
              icon: PhosphorIconsBold.pencilSimple,
              variant: _ActionVariant.primary,
              onTap: onEdit,
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Redaktə',
            icon: PhosphorIconsBold.pencilSimple,
            variant: _ActionVariant.ghost,
            onTap: onEdit,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            label: 'Dayandır',
            icon: PhosphorIconsBold.pause,
            variant: _ActionVariant.secondary,
            onTap: onPause,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            label: 'Sil',
            icon: PhosphorIconsRegular.trash,
            variant: _ActionVariant.danger,
            onTap: onDelete,
          ),
        ),
      ],
    );
  }
}

enum _ActionVariant { primary, secondary, ghost, danger, disabled }

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final _ActionVariant variant;
  final VoidCallback onTap;
  final bool loading;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.variant,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = switch (variant) {
      _ActionVariant.primary => _brand,
      _ActionVariant.secondary => isDark ? WawatDark.brandBadge : _brand50,
      _ActionVariant.ghost =>
        isDark ? WawatDark.surfaceAlt : const Color(0xFFF3F4F6),
      _ActionVariant.danger =>
        isDark ? WawatDark.danger : const Color(0xFFEF4444),
      _ActionVariant.disabled =>
        isDark ? WawatDark.surfaceAlt : const Color(0xFFEDF1F5),
    };
    final fg = switch (variant) {
      _ActionVariant.primary => Colors.white,
      _ActionVariant.secondary => isDark ? WawatDark.brandText : _brand,
      _ActionVariant.ghost => isDark ? WawatDark.textSecondary : _ink600,
      _ActionVariant.danger => Colors.white,
      _ActionVariant.disabled =>
        isDark ? WawatDark.textMuted : const Color(0xFF94A3B8),
    };
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (loading || variant == _ActionVariant.disabled) ? null : onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: variant == _ActionVariant.primary
              ? [
                  BoxShadow(
                    color: _brand.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  )
                ]
              : null,
        ),
        child: loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: fg, size: 20),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fg,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ProposalSheet extends StatefulWidget {
  final Listing listing;
  final Map<String, String> packageNamesByCode;
  final VoidCallback? onChatTap;
  final Future<void> Function({
    required String packageTypeCode,
    double? weightKg,
    double? priceTotal,
    String? note,
  }) onSubmit;

  const _ProposalSheet({
    required this.listing,
    required this.packageNamesByCode,
    this.onChatTap,
    required this.onSubmit,
  });

  @override
  State<_ProposalSheet> createState() => _ProposalSheetState();
}

class _ProposalSheetState extends State<_ProposalSheet> {
  late String _packageCode;
  final _weightController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();
  bool _loading = false;
  String? _errorText;
  bool _conversationError = false;

  @override
  void initState() {
    super.initState();
    _packageCode = widget.listing.packageTypeCodes.isNotEmpty
        ? widget.listing.packageTypeCodes.first
        : '';
  }

  @override
  void dispose() {
    _weightController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const inset = 0.0; // keyboard inset handled by showAppBottomSheet
    final free = widget.listing.freeWeightKg;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: _SheetShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Grabber(),
            Row(
              children: [
                Text(
                  'Təklif göndər',
                  style: TextStyle(
                    color: cText(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(PhosphorIconsBold.x,
                        color: isDark ? WawatDark.icon : _ink700, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Bağlama növü',
              style: TextStyle(
                color: cText(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final code in widget.listing.packageTypeCodes)
                  _SelectableChip(
                    selected: _packageCode == code,
                    label: widget.packageNamesByCode[code] ?? code,
                    icon: _packageIcon(code),
                    onTap: () => setState(() => _packageCode = code),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SheetInput(
                    controller: _weightController,
                    label: 'Çəki',
                    hint: free == null ? 'kq' : 'Boş: ${_num(free)} kq',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SheetInput(
                    controller: _priceController,
                    label: 'Ümumi qiymət',
                    hint: '\$',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SheetInput(
              controller: _noteController,
              label: 'Qeyd',
              hint: 'Qısa mesaj yaz...',
              maxLines: 3,
            ),
            if (widget.listing.isTrip &&
                widget.listing.pricePerKg != null &&
                widget.listing.allowPriceNegotiation != true) ...[
              const SizedBox(height: 9),
              Text(
                'Təxmini qiyməti çəkiyə görə hesablaya bilərsən: ${_num(widget.listing.pricePerKg)} \$/kq',
                style: TextStyle(
                  color: cText2(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              _ProposalErrorBox(
                message: _errorText!,
                showChatButton: _conversationError,
                onChatTap: () {
                  Navigator.pop(context);
                  widget.onChatTap?.call();
                },
              ),
            ],
            const SizedBox(height: 16),
            _ActionButton(
              label: 'Təklif göndər',
              icon: PhosphorIconsFill.paperPlaneTilt,
              variant: _ActionVariant.primary,
              onTap: _submit,
              loading: _loading,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_packageCode.isEmpty) return;
    setState(() {
      _loading = true;
      _errorText = null;
      _conversationError = false;
    });
    try {
      await widget.onSubmit(
        packageTypeCode: _packageCode,
        weightKg: double.tryParse(_weightController.text.replaceAll(',', '.')),
        priceTotal: double.tryParse(_priceController.text.replaceAll(',', '.')),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(
        context,
        _ProposalSuccessData(
          packageName: widget.packageNamesByCode[_packageCode] ?? _packageCode,
          weightKg:
              double.tryParse(_weightController.text.replaceAll(',', '.')),
          priceTotal:
              double.tryParse(_priceController.text.replaceAll(',', '.')),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final parsed = _proposalErrorMessage(error);
      setState(() {
        _loading = false;
        _errorText = parsed.message;
        _conversationError = parsed.isConversation;
      });
    }
  }
}

class _ProposalError {
  final String message;
  final bool isConversation;

  _ProposalError({
    required this.message,
    required this.isConversation,
  });
}

_ProposalError _proposalErrorMessage(Object error) {
  const fallback = 'Təklif göndərilmədi. Məlumatları yoxla və yenidən cəhd et.';
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      final errors = data['errors'];
      final conversation = errors is Map ? errors['conversation'] : null;
      final conversationText = _firstErrorText(conversation);
      if (conversationText != null) {
        return _ProposalError(
          message: _friendlyProposalError(conversationText),
          isConversation: true,
        );
      }
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return _ProposalError(
          message: _friendlyProposalError(message),
          isConversation: false,
        );
      }
      if (errors is Map) {
        for (final value in errors.values) {
          final text = _firstErrorText(value);
          if (text != null) {
            return _ProposalError(
              message: _friendlyProposalError(text),
              isConversation: false,
            );
          }
        }
      }
    }
  }
  return _ProposalError(message: fallback, isConversation: false);
}

String _friendlyProposalError(String message) {
  if (message == 'There is still an active order in this chat.') {
    return 'Bu söhbətdə artıq aktiv sifariş var. Davam etmək üçün mövcud söhbətə keç.';
  }
  return message;
}

String? _firstErrorText(Object? value) {
  if (value is String && value.trim().isNotEmpty) return value;
  if (value is List && value.isNotEmpty) {
    final first = value.first;
    if (first is String && first.trim().isNotEmpty) return first;
  }
  return null;
}

class _ProposalErrorBox extends StatelessWidget {
  final String message;
  final bool showChatButton;
  final VoidCallback onChatTap;

  const _ProposalErrorBox({
    required this.message,
    required this.showChatButton,
    required this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? WawatDark.dangerSoftBg : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? WawatDark.dangerSoftBorder : const Color(0xFFFECACA),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                PhosphorIconsFill.warningCircle,
                color: isDark ? WawatDark.dangerText : const Color(0xFFDC2626),
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color:
                        isDark ? WawatDark.dangerText : const Color(0xFF991B1B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          if (showChatButton) ...[
            const SizedBox(height: 12),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onChatTap,
              child: Container(
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? WawatDark.surface : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIconsFill.chatCircle,
                        color: cBrandText(isDark), size: 18),
                    const SizedBox(width: 7),
                    Text(
                      'Söhbətə keç',
                      style: TextStyle(
                        color: cBrandText(isDark),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProposalSuccessData {
  final String packageName;
  final double? weightKg;
  final double? priceTotal;

  _ProposalSuccessData({
    required this.packageName,
    this.weightKg,
    this.priceTotal,
  });
}

class _ProposalSuccessScreen extends StatelessWidget {
  final Listing listing;
  final _ProposalSuccessData data;
  final VoidCallback onChatTap;

  const _ProposalSuccessScreen({
    required this.listing,
    required this.data,
    required this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ownerName = listing.owner?.firstName ??
        listing.owner?.displayName.split(' ').first ??
        'İstifadəçi';
    return Scaffold(
      backgroundColor: isDark ? WawatDark.bg : _brand,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 104,
                height: 104,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark
                      ? WawatDark.brandChip
                      : Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: const _BrandMark(size: 60),
              ),
              const SizedBox(height: 46),
              Text(
                'Təklif göndərildi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? WawatDark.textPrimary : Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                '$ownerName təklifinizə baxıb cavab verəcək.\nSöhbətdən danışıqları davam etdirə bilərsiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? WawatDark.textSecondary
                      : Colors.white.withValues(alpha: 0.88),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                decoration: BoxDecoration(
                  color: isDark
                      ? WawatDark.surface
                      : Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(24),
                  border: isDark ? Border.all(color: WawatDark.border) : null,
                ),
                child: Column(
                  children: [
                    _SuccessSummaryRow(
                      label: 'Bağlama',
                      value: [
                        data.packageName,
                        if (data.weightKg != null) '${_num(data.weightKg)} kq',
                      ].join(' · '),
                    ),
                    if (data.priceTotal != null) ...[
                      const SizedBox(height: 18),
                      _SuccessSummaryRow(
                        label: 'Ümumi qiymət',
                        value: '${_num(data.priceTotal)} \$',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 42),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onChatTap,
                child: Container(
                  height: 58,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? _brand : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIconsFill.chatCircle,
                          color: isDark ? Colors.white : _brand, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Söhbətə keç',
                        style: TextStyle(
                          color: isDark ? Colors.white : _brand,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => Navigator.of(context).maybePop(),
                child: Text(
                  'Elana qayıt',
                  style: TextStyle(
                    color: isDark
                        ? WawatDark.textSecondary
                        : Colors.white.withValues(alpha: 0.78),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

/// The Wawat launcher mark (two-tone "W") on a white chip so the black+blue
/// logo stays legible on ANY background — brand blue, dark or light. The soft
/// shadow + hairline keep the chip delineated even on a white surface.
class _BrandMark extends StatelessWidget {
  final double size;

  const _BrandMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x11000000)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.16),
        child: Image.asset(
          'assets/icon.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}

class _SuccessSummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SuccessSummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? WawatDark.textSecondary : Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? WawatDark.textPrimary : Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReasonSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final bool isDanger;
  final List<_Reason> reasons;
  final Future<void> Function(String reasonCode, String? note) onSubmit;

  const _ReasonSheet({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.reasons,
    required this.onSubmit,
    this.isDanger = false,
  });

  @override
  State<_ReasonSheet> createState() => _ReasonSheetState();
}

class _ReasonSheetState extends State<_ReasonSheet> {
  late String _reason;
  final _noteController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _reason = widget.reasons.first.code;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const inset = 0.0; // keyboard inset handled by showAppBottomSheet
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: _SheetShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Grabber(),
            Text(
              widget.title,
              style: TextStyle(
                color: cText(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.subtitle,
              style: TextStyle(
                color: cText2(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            for (final reason in widget.reasons)
              _RadioRow(
                label: reason.label,
                selected: _reason == reason.code,
                onTap: () => setState(() => _reason = reason.code),
              ),
            const SizedBox(height: 10),
            _SheetInput(
              controller: _noteController,
              label: 'Qeyd',
              hint: 'İstəyə bağlı',
              maxLines: 3,
            ),
            const SizedBox(height: 14),
            _ActionButton(
              label: widget.actionLabel,
              icon: widget.isDanger
                  ? PhosphorIconsRegular.trash
                  : PhosphorIconsFill.flag,
              variant: widget.isDanger
                  ? _ActionVariant.danger
                  : _ActionVariant.primary,
              onTap: _submit,
              loading: _loading,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await widget.onSubmit(
        _reason,
        _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Əməliyyat alınmadı.')),
      );
    }
  }
}

class _SheetShell extends StatelessWidget {
  final Widget child;

  const _SheetShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        18 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: cCard(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: child,
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        width: 40,
        height: 5,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? WawatDark.grab : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}

class _SheetInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;

  const _SheetInput({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: cText(isDark),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(color: cText(isDark)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? WawatDark.placeholder : _ink400,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: isDark ? WawatDark.surfaceAlt : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color:
                    isDark ? WawatDark.border : _ink900.withValues(alpha: 0.07),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color:
                    isDark ? WawatDark.border : _ink900.withValues(alpha: 0.07),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: isDark ? WawatDark.focusRing : _brand,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectableChip extends StatelessWidget {
  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SelectableChip({
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandText = cBrandText(isDark);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? WawatDark.brandBadge : _brand50)
              : (isDark ? WawatDark.surfaceAlt : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? (isDark ? WawatDark.brand : _brand)
                : (isDark ? WawatDark.border : _ink900.withValues(alpha: 0.08)),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color:
                    selected ? brandText : (isDark ? WawatDark.icon : _ink500),
                size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? brandText
                    : (isDark ? WawatDark.textPrimary : _ink800),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 10),
              Icon(PhosphorIconsFill.checkCircle, color: brandText, size: 17),
            ],
          ],
        ),
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandText = cBrandText(isDark);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? WawatDark.brandBadge : _brand50)
              : (isDark ? WawatDark.surfaceAlt : Colors.white),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected
                ? (isDark ? WawatDark.brand : _brand)
                : (isDark ? WawatDark.border : _ink900.withValues(alpha: 0.08)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? brandText
                      : (isDark ? WawatDark.textPrimary : _ink800),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              selected
                  ? PhosphorIconsFill.checkCircle
                  : PhosphorIconsRegular.circle,
              color: selected ? brandText : cFaint(isDark),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? WawatDark.surfaceAlt : Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isDark ? WawatDark.border : _ink900.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: cMuted(isDark), size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: cText3(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final Color color;

  const _Avatar({
    required this.initials,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailsSkeleton extends StatelessWidget {
  const _DetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          _SkeletonBox(height: 190, radius: 26),
          const SizedBox(height: 14),
          _SkeletonBox(height: 86, radius: 22),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(child: _SkeletonBox(height: 86, radius: 18)),
              SizedBox(width: 10),
              Expanded(child: _SkeletonBox(height: 86, radius: 18)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double radius;

  const _SkeletonBox({
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? WawatDark.skeletonBase : const Color(0xFFE7EBF1),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Map<String, String> content;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.content,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIconsRegular.eyeSlash,
                color: cBrandText(isDark), size: 58),
            const SizedBox(height: 14),
            Text(
              'Elan tapılmadı',
              style: TextStyle(
                color: cText(isDark),
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Elan silinmiş, moderasiyada ola bilər və ya sənə açıq deyil.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cText2(isDark),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            _ActionButton(
              label: 'Yenidən yoxla',
              icon: PhosphorIconsBold.arrowClockwise,
              variant: _ActionVariant.primary,
              onTap: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _Reason {
  final String code;
  final String label;

  const _Reason(this.code, this.label);
}

List<_Reason> _deleteReasons(Map<String, String> content) {
  const defaults = {
    'plans_changed': 'Planlarım dəyişdi',
    'found_another': 'Başqa variant tapdım',
    'no_longer_needed': 'Artıq lazım deyil',
    'created_by_mistake': 'Səhvən yaratdım',
    'other': 'Digər',
  };
  return [
    for (final entry in defaults.entries)
      _Reason(
        entry.key,
        _t(content, 'enum.listing_delete_reason.${entry.key}', entry.value),
      )
  ];
}

List<_Reason> _reportReasons(Map<String, String> content) {
  const defaults = {
    'spam': 'Spam',
    'fraud': 'Fırıldaq',
    'abuse': 'Təhqir',
    'fake': 'Saxta',
    'inappropriate': 'Uyğunsuz',
    'other': 'Digər',
  };
  return [
    for (final entry in defaults.entries)
      _Reason(
        entry.key,
        _t(content, 'enum.report_reason_code.${entry.key}', entry.value),
      )
  ];
}

BoxDecoration _cardDecoration(BuildContext context, {double radius = 22}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    color: cCard(isDark),
    borderRadius: BorderRadius.circular(radius),
    border: isDark
        ? Border.all(color: WawatDark.border)
        : Border.all(color: _ink900.withValues(alpha: 0.06)),
    boxShadow: isDark
        ? null
        : [
            BoxShadow(
              color: _ink900.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
  );
}

IconData _packageIcon(String code) {
  switch (code) {
    case 'documents':
      return PhosphorIconsFill.fileText;
    case 'small_parcel':
      return PhosphorIconsRegular.cube;
    case 'electronics':
      return PhosphorIconsRegular.deviceMobile;
    case 'clothing':
      return PhosphorIconsRegular.shoppingBag;
    case 'food':
      return PhosphorIconsRegular.forkKnife;
    default:
      return PhosphorIconsRegular.package;
  }
}

Color _statusColor(String status, [bool isDark = false]) {
  switch (status) {
    case 'active':
    case 'partially_booked':
    case 'fully_booked':
      return isDark ? WawatDark.success : const Color(0xFF10B981);
    case 'moderation':
      return isDark ? WawatDark.warning : _amber;
    case 'rejected':
      return isDark ? WawatDark.dangerText : const Color(0xFFEF4444);
    case 'paused':
    case 'expired':
      return isDark ? WawatDark.textMuted : _ink500;
    default:
      return isDark ? WawatDark.brandText : _brand;
  }
}

IconData _statusIcon(String status) {
  switch (status) {
    case 'active':
      return PhosphorIconsFill.circle;
    case 'partially_booked':
    case 'fully_booked':
      return PhosphorIconsFill.hourglassMedium;
    case 'moderation':
      return PhosphorIconsFill.hourglass;
    case 'rejected':
      return PhosphorIconsFill.xCircle;
    case 'paused':
      return PhosphorIconsFill.pauseCircle;
    case 'expired':
      return PhosphorIconsFill.clockCountdown;
    default:
      return PhosphorIconsFill.info;
  }
}

bool _isMutedOwnerStatus(String? status) {
  return status == 'paused' || status == 'expired';
}

_OwnerInfoBanner? _ownerTopBanner(String status) {
  switch (status) {
    case 'moderation':
      return const _OwnerInfoBanner(
        icon: PhosphorIconsFill.hourglass,
        color: _amber,
        background: _amber50,
        darkColor: WawatDark.warning,
        darkBackground: WawatDark.warningBg,
        title: 'Moderasiyada',
        message: 'Elanınız yoxlanılır. Təsdiqlənəndən sonra lentdə görünəcək.',
      );
    case 'rejected':
      return const _OwnerInfoBanner(
        icon: PhosphorIconsFill.xCircle,
        color: Color(0xFFEF4444),
        background: Color(0xFFFEF2F2),
        darkColor: WawatDark.dangerText,
        darkBackground: WawatDark.dangerSoftBg,
        title: 'Rədd edildi',
        message:
            'Səbəb: elan qaydalara uyğun deyil. Düzəliş edib yenidən göndərə bilərsiniz.',
      );
    case 'paused':
      return const _OwnerInfoBanner(
        icon: PhosphorIconsFill.pauseCircle,
        color: _ink600,
        background: Color(0xFFF3F4F6),
        darkColor: WawatDark.textSecondary,
        darkBackground: WawatDark.surfaceAlt,
        title: 'Dayandırılıb',
        message:
            'Bu elan lentdə görünmür. İstənilən vaxt yenidən aktivləşdirə bilərsiniz.',
      );
    case 'expired':
      return const _OwnerInfoBanner(
        icon: PhosphorIconsFill.clockCountdown,
        color: _ink600,
        background: Color(0xFFF3F4F6),
        darkColor: WawatDark.textSecondary,
        darkBackground: WawatDark.surfaceAlt,
        title: 'Vaxtı keçib',
        message:
            'Uçuş tarixi keçdiyi üçün elan lentdən çıxıb. Yeni tarixlə yenidən paylaşa bilərsiniz.',
      );
    default:
      return null;
  }
}

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'W';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}

String? _countryFallback(String? city) {
  if (city == null) return null;
  final lower = city.toLowerCase();
  if (lower.contains('dubai')) return 'BƏƏ';
  if (lower.contains('istanbul')) return 'Türkiyə';
  if (lower.contains('berlin')) return 'Almaniya';
  if (lower.contains('moscow')) return 'Rusiya';
  return 'Azərbaycan';
}

String _formatDate(String? value) {
  if (value == null || value.isEmpty) return '';
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  const months = [
    'Yan',
    'Fev',
    'Mar',
    'Apr',
    'May',
    'İyun',
    'İyul',
    'Avq',
    'Sen',
    'Okt',
    'Noy',
    'Dek'
  ];
  return '${date.day} ${months[date.month - 1]}';
}

/// Normalises any time-ish string to `HH:mm` (drops seconds).
String? _formatTime(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final raw = value.trim();
  final dt = DateTime.tryParse(raw);
  if (dt != null) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
  final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(raw);
  if (match != null) {
    return '${match.group(1)!.padLeft(2, '0')}:${match.group(2)}';
  }
  return raw;
}

String _formatDateRange(String? from, String? to) {
  final start = _formatDate(from);
  final end = _formatDate(to);
  if (start.isEmpty) return end;
  if (end.isEmpty || end == start) return start;
  return '$start – $end';
}

String _relativeDate(String? value) {
  if (value == null || value.isEmpty) return '-';
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  final diff = DateTime.now().difference(date);
  if (diff.inDays <= 0) return 'bugün';
  if (diff.inDays == 1) return 'dünən';
  return '${diff.inDays} gün əvvəl';
}

String _num(double? value) {
  if (value == null) return '0';
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

double _progress(double? reserved, double? max) {
  if (reserved == null || max == null || max <= 0) return 0;
  return (reserved / max).clamp(0, 1);
}
