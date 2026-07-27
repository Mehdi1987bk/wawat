import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:buking/presentation/common/app_bottom_sheet.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../presentation/bloc/base_screen.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/wawat_content.dart';
import '../new_profile/profile_models.dart';
import 'blocked_users_bloc.dart';

const _brand = Color(0xFF017BFE);
const _brand50 = Color(0xFFEAF3FE);
const _ink900 = Color(0xFF0F172A);
const _ink700 = Color(0xFF334155);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);
const _ink300 = Color(0xFFCBD5E1);
const _ink200 = Color(0xFFE2E8F0);
const _screen = Color(0xFFF4F6F9);
const _amber50 = Color(0xFFFEF6E7);
const _amber600 = Color(0xFFB67C00);
const _emerald = Color(0xFF34D399);

String _text(
  Map<String, String> content,
  String key,
  String fallback,
) {
  return WawatContent.text(content, key, fallback);
}

String _template(
  Map<String, String> content,
  String key,
  String fallback,
  Map<String, Object?> values,
) {
  var value = _text(content, key, fallback);
  for (final entry in values.entries) {
    value = value.replaceAll(':${entry.key}', '${entry.value ?? ''}');
  }
  return value;
}

class BlockedUsersScreen extends BaseScreen<BlockedUsersBloc> {
  BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState
    extends BaseState<BlockedUsersScreen, BlockedUsersBloc> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 180) {
      bloc.loadMore();
    }
  }

  @override
  BlockedUsersBloc provideBloc() => BlockedUsersBloc();

  @override
  Color? backgroundColor() =>
      Theme.of(context).brightness == Brightness.dark ? WawatDark.bg : _screen;

  @override
  PreferredSizeWidget appBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDark ? WawatDark.surface : Colors.white,
      surfaceTintColor: isDark ? WawatDark.surface : Colors.white,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: 56,
      automaticallyImplyLeading: false,
      titleSpacing: 10,
      title: StreamBuilder<BlockedUsersState>(
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
                  child: Icon(
                    PhosphorIconsBold.caretLeft,
                    color: isDark ? WawatDark.icon : _ink700,
                    size: 23,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _text(
                    content,
                    'block.title',
                    'Bloklanmış istifadəçilər',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? WawatDark.textPrimary : _ink900,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: isDark ? WawatDark.divider : _ink900.withValues(alpha: 0.06),
        ),
      ),
    );
  }

  @override
  Widget body() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: isDark ? WawatDark.bg : _screen,
      child: StreamBuilder<BlockedUsersState>(
        stream: bloc.state,
        initialData: bloc.value,
        builder: (context, snapshot) {
          final state = snapshot.data ?? const BlockedUsersState.initial();
          if (state.loading && state.users.isEmpty) {
            return const _BlockedUsersSkeleton();
          }
          if (state.error != null && state.users.isEmpty) {
            return _LoadError(
              content: state.content,
              onRetry: bloc.loadInitial,
            );
          }
          if (state.users.isEmpty) {
            return _EmptyState(content: state.content);
          }
          return RefreshIndicator(
            color: _brand,
            onRefresh: bloc.loadInitial,
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    _text(
                      state.content,
                      'block.subtitle',
                      'Blokladığınız istifadəçilər sizə mesaj yaza və elanlarınıza baxa bilməz.',
                    ),
                    style: TextStyle(
                      color: isDark ? WawatDark.textMuted : _ink400,
                      fontSize: 12.5,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: isDark ? WawatDark.surface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: isDark ? Border.all(color: WawatDark.border) : null,
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: _ink900.withValues(alpha: 0.08),
                              blurRadius: 24,
                              spreadRadius: -12,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: _ink900.withValues(alpha: 0.04),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                  ),
                  child: Column(
                    children: [
                      for (var index = 0; index < state.users.length; index++)
                        _BlockedUserRow(
                          user: state.users[index],
                          content: state.content,
                          showDivider: index != state.users.length - 1,
                          onUnblock: () => _openUnblockSheet(
                            state.users[index],
                            state.content,
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    _template(
                      state.content,
                      'block.count',
                      'Cəmi :count istifadəçi',
                      {'count': state.total},
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? WawatDark.textMuted : _ink400,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (state.loadingMore)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SpinningIcon(
                          icon: PhosphorIconsRegular.spinnerGap,
                          color: isDark ? WawatDark.textMuted : _ink400,
                          size: 17,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _text(
                            state.content,
                            'block.loading_more',
                            'Yüklənir…',
                          ),
                          style: TextStyle(
                            color: isDark ? WawatDark.textMuted : _ink400,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openUnblockSheet(
    WawatProfileUser user,
    Map<String, String> content,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final message = await showAppBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: _ink900.withValues(alpha: 0.45),
      builder: (_) => _UnblockSheet(
        user: user,
        content: content,
        onConfirm: () => bloc.unblock(user),
      ),
    );
    if (!mounted || message == null || message.trim().isEmpty) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                PhosphorIconsFill.checkCircle,
                color: _emerald,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isDark ? WawatDark.elevated : _ink900,
          width: math.min(MediaQuery.sizeOf(context).width - 48, 360),
          shape: const StadiumBorder(),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  bool get showProgressIndicator => false;

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }
}

class _BlockedUserRow extends StatelessWidget {
  final WawatProfileUser user;
  final Map<String, String> content;
  final bool showDivider;
  final VoidCallback onUnblock;

  const _BlockedUserRow({
    required this.user,
    required this.content,
    required this.showDivider,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: isDark
                      ? WawatDark.divider
                      : _ink900.withValues(alpha: 0.05),
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          _BlockedAvatar(user: user, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.safeFullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? WawatDark.textPrimary : _ink900,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (user.isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        PhosphorIconsFill.sealCheck,
                        color: _brand,
                        size: 14,
                      ),
                    ],
                  ],
                ),
                if (user.username != null && user.username!.trim().isNotEmpty)
                  Text(
                    '@${user.username}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? WawatDark.textMuted : _ink400,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onUnblock,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: isDark ? WawatDark.surfaceAlt : Colors.white,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: isDark ? WawatDark.border : _ink200),
              ),
              child: Text(
                _text(
                  content,
                  'block.unblock',
                  'Blokdan çıxar',
                ),
                style: TextStyle(
                  color: isDark ? WawatDark.textSecondary : _ink700,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockedAvatar extends StatelessWidget {
  final WawatProfileUser user;
  final double size;

  const _BlockedAvatar({
    required this.user,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = user.avatarThumbUrl ?? user.avatarUrl;
    final colors = _avatarColors(user.id);
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: imageUrl != null && imageUrl.trim().isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _AvatarInitials(user: user),
            )
          : _AvatarInitials(user: user),
    );
  }
}

class _AvatarInitials extends StatelessWidget {
  final WawatProfileUser user;

  const _AvatarInitials({required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        user.initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _UnblockSheet extends StatefulWidget {
  final WawatProfileUser user;
  final Map<String, String> content;
  final Future<String> Function() onConfirm;

  const _UnblockSheet({
    required this.user,
    required this.content,
    required this.onConfirm,
  });

  @override
  State<_UnblockSheet> createState() => _UnblockSheetState();
}

class _UnblockSheetState extends State<_UnblockSheet> {
  bool _loading = false;
  String? _error;

  Future<void> _confirm() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final message = await widget.onConfirm();
      if (!mounted) return;
      Navigator.of(context).pop(message);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _errorMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final body = _template(
      widget.content,
      'block.confirm.body',
      ':name yenidən sizə mesaj yaza və elanlarınıza baxa biləcək.',
      {'name': widget.user.safeFullName},
    );
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        decoration: BoxDecoration(
          color: isDark ? WawatDark.surface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? WawatDark.divider : _ink200,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 13),
            _BlockedAvatar(user: widget.user, size: 64),
            const SizedBox(height: 12),
            Text(
              _text(
                widget.content,
                'block.confirm.title',
                'Bloku açmaq?',
              ),
              style: TextStyle(
                color: isDark ? WawatDark.textPrimary : _ink900,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            _ConfirmationBody(
              body: body,
              highlightedText: widget.user.safeFullName,
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _loading ? null : _confirm,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _loading ? 0.70 : 1,
                child: Container(
                  width: double.infinity,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _brand,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _brand.withValues(alpha: 0.55),
                        blurRadius: 18,
                        spreadRadius: -8,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _text(
                            widget.content,
                            'block.confirm.action',
                            'Bloku aç',
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _loading ? null : () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                height: 38,
                alignment: Alignment.center,
                child: Text(
                  _text(
                    widget.content,
                    'block.cancel',
                    'İmtina et',
                  ),
                  style: TextStyle(
                    color: isDark
                        ? (_loading ? WawatDark.iconMuted : WawatDark.textMuted)
                        : (_loading ? _ink300 : _ink400),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmationBody extends StatelessWidget {
  final String body;
  final String highlightedText;

  const _ConfirmationBody({
    required this.body,
    required this.highlightedText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseStyle = TextStyle(
      color: isDark ? WawatDark.textSecondary : _ink500,
      fontSize: 13,
      height: 1.35,
      fontWeight: FontWeight.w500,
    );
    final index = body.indexOf(highlightedText);
    if (highlightedText.isEmpty || index < 0) {
      return Text(
        body,
        textAlign: TextAlign.center,
        style: baseStyle,
      );
    }
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: body.substring(0, index)),
          TextSpan(
            text: highlightedText,
            style: TextStyle(
              color: isDark ? WawatDark.textPrimary : _ink900,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: body.substring(index + highlightedText.length)),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Map<String, String> content;

  const _EmptyState({required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? WawatDark.brandSoft : _brand50,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                PhosphorIconsRegular.prohibit,
                color: _brand,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _text(
                content,
                'block.empty.title',
                'Bloklanmış istifadəçi yoxdur',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? WawatDark.textPrimary : _ink900,
                fontSize: 16.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _text(
                content,
                'block.empty.body',
                'Kimisə bloklasanız, burada görünəcək. Söhbətdə və ya profildə «Blokla» ilə bloklaya bilərsiniz.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? WawatDark.textSecondary : _ink500,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final Map<String, String> content;
  final VoidCallback onRetry;

  const _LoadError({
    required this.content,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3A2A12) : _amber50,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                PhosphorIconsRegular.wifiSlash,
                color: isDark ? WawatDark.warning : _amber600,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _text(content, 'block.error.title', 'Yüklənmədi'),
              style: TextStyle(
                color: isDark ? WawatDark.textPrimary : _ink900,
                fontSize: 16.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _text(
                content,
                'block.error.body',
                'İnternet bağlantısını yoxlayıb yenidən cəhd edin.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? WawatDark.textSecondary : _ink500,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRetry,
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: _brand,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _brand.withValues(alpha: 0.55),
                      blurRadius: 18,
                      spreadRadius: -8,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      PhosphorIconsBold.arrowClockwise,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _text(
                        content,
                        'block.retry',
                        'Yenidən cəhd et',
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockedUsersSkeleton extends StatelessWidget {
  const _BlockedUsersSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(14, 14, 14, 5),
          child: _ShimmerBox(width: 160, height: 12),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark ? WawatDark.surface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isDark ? Border.all(color: WawatDark.border) : null,
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: _ink900.withValues(alpha: 0.08),
                      blurRadius: 24,
                      spreadRadius: -12,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: const Column(
            children: [
              _SkeletonRow(showDivider: true, nameWidth: 128, userWidth: 80),
              _SkeletonRow(showDivider: true, nameWidth: 112, userWidth: 96),
              _SkeletonRow(showDivider: true, nameWidth: 144, userWidth: 64),
              _SkeletonRow(showDivider: false, nameWidth: 96, userWidth: 80),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  final bool showDivider;
  final double nameWidth;
  final double userWidth;

  const _SkeletonRow({
    required this.showDivider,
    required this.nameWidth,
    required this.userWidth,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: isDark
                      ? WawatDark.divider
                      : _ink900.withValues(alpha: 0.05),
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          const _ShimmerBox(width: 44, height: 44, radius: 99),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(width: nameWidth, height: 14),
                const SizedBox(height: 8),
                _ShimmerBox(width: userWidth, height: 10),
              ],
            ),
          ),
          const _ShimmerBox(width: 96, height: 32, radius: 99),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-2 + (_controller.value * 4), 0),
              end: Alignment(0 + (_controller.value * 4), 0),
              colors: isDark
                  ? const [
                      WawatDark.surfaceAlt,
                      WawatDark.elevated,
                      WawatDark.surfaceAlt,
                    ]
                  : const [
                      Color(0xFFEEF2F7),
                      Color(0xFFE2E8F0),
                      Color(0xFFEEF2F7),
                    ],
              stops: const [0.25, 0.50, 0.75],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _SpinningIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _SpinningIcon({
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  State<_SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<_SpinningIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(
        widget.icon,
        color: widget.color,
        size: widget.size,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

List<Color> _avatarColors(String seed) {
  const palettes = [
    [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    [Color(0xFFF59E0B), Color(0xFFB45309)],
    [Color(0xFF10B981), Color(0xFF047857)],
    [Color(0xFF0EA5E9), Color(0xFF0369A1)],
    [Color(0xFFEC4899), Color(0xFFBE185D)],
  ];
  final index = seed.codeUnits.fold<int>(0, (sum, value) => sum + value);
  return palettes[index % palettes.length];
}

String _errorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message']?.toString();
      if (message != null && message.trim().isNotEmpty) return message;
    }
  }
  return error.toString().replaceFirst('Exception: ', '');
}
