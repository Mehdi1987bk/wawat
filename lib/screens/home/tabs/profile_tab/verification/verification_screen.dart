import 'dart:io';
import 'package:dio/dio.dart';
import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/presentation/bloc/error_dispatcher.dart';
import 'package:buking/presentation/resourses/app_colors.dart';
import 'package:buking/screens/home/tabs/profile_tab/verification/verification_bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../data/network/response/document_type.dart';
import '../../../../../data/network/response/user.dart';
import '../../../../../data/network/response/verification_state.dart';
import '../../../../../generated/l10n.dart';
import '../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/localization_service.dart';
import '../../../../../services/theme_manager.dart';
import '../new_profile/profile_api.dart';
import '../settings/experience_tab/experience_tab_screen.dart';

class VerificationScreen extends BaseScreen {
  final User user;

  VerificationScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState
    extends BaseState<VerificationScreen, VerificationBloc>
    with ErrorDispatcher {
  File? _idImage;
  File? _selfieImage;
  bool _isLoading = false;
  bool _isLoadingStatus = true;
  bool _isPaying = false;

  /// Current verification request (null when never submitted).
  VerificationState? _state;

  /// Activation fee to advertise on the intro screen (from the request's
  /// payment, or a top-level hint when there's no request yet). Null → intro
  /// shows "paid" without a number.
  double? _feeAmount;
  String? _feeCurrency;

  /// The document-upload step is a pushed sub-view reached from the intro
  /// («Send documents») or the rejected screen («Resubmit»). Back returns to
  /// the underlying state screen rather than leaving verification.
  bool _showUpload = false;

  /// Whether the account is verified, from ANY authoritative source: an
  /// approved-and-paid request OR the profile's `is_verified` flag. Admin-
  /// verified accounts often have no verification *request*, so the state
  /// endpoint says unpaid while the profile is already verified.
  bool _isVerified = false;

  /// Accepted ID-document types from /document-types. Currently filtered to
  /// passport only, so the type picker is hidden and the passport upload is the
  /// single flow. Names still arrive localized from the backend.
  List<DocumentType> _idDocTypes = const [];
  String? _selectedType;
  bool _typesLoadFailed = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
    _loadDocumentTypes();
  }

  Future<void> _loadDocumentTypes() async {
    try {
      final types = await bloc.loadDocumentTypes();
      if (!mounted) return;
      // Only passport is accepted for now → single option, no type picker shown.
      final idTypes = types.where((t) => t.isPassport).toList();
      setState(() {
        _idDocTypes = idTypes;
        _selectedType ??= idTypes.isNotEmpty ? idTypes.first.code : null;
        _typesLoadFailed = idTypes.isEmpty;
      });
    } catch (_) {
      if (mounted) setState(() => _typesLoadFailed = true);
    }
  }

  Future<void> _loadVerificationStatus() async {
    // Seed from the profile we were opened with — a verified account should
    // never land on the upload flow.
    var verified = widget.user.isVerified ?? false;
    // Seed from what we already know so a transient GET /verification failure
    // (500/timeout) doesn't wipe a submitted/approved/just-paid request back to
    // null → the paid intro. Only a SUCCESSFUL fetch overwrites these.
    VerificationState? state = _state;
    double? fee = _feeAmount;
    String? currency = _feeCurrency;
    try {
      final snapshot = await bloc.getVerification();
      state = snapshot.state;
      fee = snapshot.feeAmount;
      currency = snapshot.currency;
      if (state?.isPaidVerified ?? false) verified = true;
    } catch (_) {
      /* keep the last known state/fee; profile flag still decides */
    }
    // Fresh profile flag: catches admin-verified accounts that have no
    // verification request (state endpoint → still unpaid).
    try {
      final me = await WawatProfileApi().me();
      verified = verified || me.isVerified;
    } catch (_) {/* offline / failed — fall back to what we already have */}
    if (!mounted) return;
    setState(() {
      _state = state;
      _feeAmount = fee;
      _feeCurrency = currency;
      _isVerified = verified;
      _isLoadingStatus = false;
    });
  }

  @override
  Widget body() {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        if (_isLoadingStatus) {
          return Scaffold(
            backgroundColor: isDark ? WawatDark.bg : const Color(0xFFF5F7FA),
            body: Center(
              child: CircularProgressIndicator(
                color: isDark ? WawatDark.brandText : const Color(0xFF00B4A6),
              ),
            ),
          );
        }

        // Profile already verified (incl. admin-verified without a request).
        if (_isVerified) {
          return _buildVerifiedScreen(isDark);
        }

        // The document-upload sub-view (first submit or free resubmit).
        if (_showUpload) {
          return _buildUploadDocumentsScreen(isDark);
        }

        final state = _state;

        // Never submitted → paid intro that explains the two steps.
        if (state == null) {
          return _buildIntroScreen(isDark);
        }

        // Rejected → show the reason, offer a free resubmit.
        if (state.isRejected) {
          return _buildRejectedScreen(isDark, state);
        }

        // Documents under review → waiting, no payment yet.
        if (state.isPending) {
          return _buildPendingScreen(isDark);
        }

        // Approved: pay to activate the badge, else already verified.
        if (state.isApproved) {
          if (state.awaitingPayment) {
            return _buildPaymentScreen(isDark, state);
          }
          return _buildVerifiedScreen(isDark);
        }

        // Unknown/transitional status → treat as under review.
        return _buildPendingScreen(isDark);
      },
    );
  }

  Widget _buildVerifiedScreen(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? WawatDark.bg : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: isDark ? WawatDark.textPrimary : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isDark ? WawatDark.textPrimary : Colors.black,
                    ),
                    child: Text(S.of(context).bd3435fvd),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                  child: Column(
                    children: [
                      // Gradient "verified" badge with a soft halo and a gentle
                      // entrance pop — the celebratory centrepiece of the screen.
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 520),
                        curve: Curves.easeOutBack,
                        tween: Tween(begin: 0.7, end: 1),
                        builder: (_, scale, child) =>
                            Transform.scale(scale: scale, child: child),
                        child: SizedBox(
                          width: 140,
                          height: 140,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF22C55E)
                                      .withValues(alpha: isDark ? 0.10 : 0.07),
                                ),
                              ),
                              Container(
                                width: 112,
                                height: 112,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF22C55E)
                                      .withValues(alpha: isDark ? 0.16 : 0.12),
                                ),
                              ),
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF14B8A6),
                                      Color(0xFF22C55E),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(26),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF22C55E).withValues(
                                          alpha: isDark ? 0.45 : 0.35),
                                      blurRadius: 26,
                                      spreadRadius: -2,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.verified_user_rounded,
                                  color: Colors.white,
                                  size: 46,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? WawatDark.textPrimary : Colors.black87,
                        ),
                        child: Text(S.of(context).vfdfv22434),
                      ),
                      const SizedBox(height: 16),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? WawatDark.textSecondary
                              : Colors.grey[600],
                          height: 1.5,
                        ),
                        child: Text(
                          S.of(context).vfdvfdvfvfdewr44,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 40),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? WawatDark.surface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: cCardBorder(isDark),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.45)
                                  : Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.task_alt,
                              iconColor: const Color(0xFF4CAF50),
                              iconBgColor: const Color(0xFFE8F5E9),
                              title: S.of(context).vfdvfdr3r34,
                              subtitle: S.of(context).vfvfd443r43,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            Divider(
                              color:
                                  isDark ? WawatDark.divider : Colors.grey[200],
                              height: 1,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              icon: Icons.check_circle,
                              iconColor: const Color(0xFF4CAF50),
                              iconBgColor: const Color(0xFFE8F5E9),
                              title: S.of(context).gttbr42435t345,
                              subtitle: S.of(context).bdfdw432534vfd,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? WawatDark.successBg
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified,
                              color: isDark
                                  ? WawatDark.success
                                  : const Color(0xFF4CAF50),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? WawatDark.textSecondary
                                      : Colors.grey[700],
                                ),
                                child: Text(
                                  S.of(context).dfbdf424fdv,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingScreen(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? WawatDark.bg : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: isDark ? WawatDark.textPrimary : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isDark ? WawatDark.textPrimary : Colors.black,
                    ),
                    child: Text(S.of(context).vfdgfdvfd42343),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5A623).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: const Icon(
                          Icons.pending_outlined,
                          color: Color(0xFFF5A623),
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 32),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? WawatDark.textPrimary : Colors.black87,
                        ),
                        child: Text(S.of(context).vdfvfd42422),
                      ),
                      const SizedBox(height: 16),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? WawatDark.textSecondary
                              : Colors.grey[600],
                          height: 1.5,
                        ),
                        child: Text(
                          S.of(context).n13vdf43,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 40),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? WawatDark.surface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: cCardBorder(isDark),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.45)
                                  : Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.task_alt,
                              iconColor: const Color(0xFF4CAF50),
                              iconBgColor: const Color(0xFFE8F5E9),
                              title: S.of(context).vfdvfd22343,
                              subtitle: S.of(context).vfd233424,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            Divider(
                              color:
                                  isDark ? WawatDark.divider : Colors.grey[200],
                              height: 1,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              icon: Icons.schedule,
                              iconColor: const Color(0xFFF5A623),
                              iconBgColor: const Color(0xFFFFF3E0),
                              title: S.of(context).juty4545,
                              subtitle: S.of(context).hy4345,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? WawatDark.brandChip
                              : const Color(0xFFE8F2FC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: isDark
                                  ? WawatDark.brandText
                                  : const Color(0xFF4A90D9),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? WawatDark.textSecondary
                                      : Colors.grey[700],
                                ),
                                child: Text(
                                  S.of(context).gtrgtr34343,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    final effectiveIconBg = isDark ? _darkIconBg(iconColor) : iconBgColor;
    final effectiveIconColor = isDark ? _darkIconColor(iconColor) : iconColor;
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: effectiveIconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: effectiveIconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? WawatDark.textPrimary : Colors.black87,
                ),
                child: Text(title),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? WawatDark.textSecondary : Colors.grey[600],
                ),
                child: Text(subtitle),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Pay the activation fee (mock for now — always succeeds server-side). On
  /// success the badge is active; refresh the authoritative flags and land on
  /// the verified screen.
  Future<void> _pay() async {
    if (_isPaying) return;
    setState(() => _isPaying = true);
    try {
      final result = await bloc.payVerification();
      if (!mounted) return;
      setState(() => _state = result.state);
      final message = result.message;
      if (message != null && message.isNotEmpty) {
        showIOSStyleMessage(context, message);
      }
      await _loadVerificationStatus();
    } catch (e) {
      if (!mounted) return;
      // Surface the server's localized reason (e.g. not_payable) when present.
      var message =
          tr('verification.pay_failed', 'Ödəniş alınmadı. Yenidən cəhd et.');
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map &&
            data['message'] is String &&
            (data['message'] as String).trim().isNotEmpty) {
          message = data['message'] as String;
        }
      }
      _snack(message, Colors.red);
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  String _feeText(double amount, String currency) {
    final value = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    return '$value $currency';
  }

  /// Shared back-arrow header for the intro / payment / rejected screens (back
  /// leaves verification).
  Widget _buildHeader(bool isDark, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              size: 24,
              color: isDark ? WawatDark.textPrimary : Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? WawatDark.textPrimary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onTap,
    bool loading = false,
    Color? color,
  }) {
    final base = color ?? AppColors.appColor;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: base,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          disabledBackgroundColor: base.withOpacity(0.6),
        ),
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }

  Widget _buildStepRow({
    required int number,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark ? WawatDark.brandChip : const Color(0xFFEAF3FE),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? WawatDark.brandText : const Color(0xFF017BFE),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? WawatDark.textPrimary : Colors.black87,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: isDark ? WawatDark.textSecondary : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Paid intro (data == null): says verification is a paid service, shows the
  /// fee, explains the two steps, then sends the user to upload documents.
  Widget _buildIntroScreen(bool isDark) {
    final fee = _feeAmount;
    final currency = _feeCurrency ?? 'AZN';
    return Scaffold(
      backgroundColor: isDark ? WawatDark.bg : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              isDark,
              tr('verification.intro.title', 'Hesab doğrulaması'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 18),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B4A6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.verified_user_outlined,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      tr('verification.intro.headline', 'Hesabını doğrula'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: isDark ? WawatDark.textPrimary : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tr(
                        'verification.intro.subtitle',
                        'Profilinə etibar nişanı əlavə et. Sənədlərini təsdiqlət və aktivləşdir.',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: isDark ? WawatDark.textSecondary : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Paid callout — amount is from payment.fee_amount, never
                    // hardcoded; falls back to just "paid service" if unknown.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? WawatDark.warningBg
                            : const Color(0xFFFFF6E5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              const Color(0xFFF5A623).withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? WawatDark.warning.withValues(alpha: 0.18)
                                  : const Color(0xFFFFE8BF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.payments_outlined,
                              color: isDark
                                  ? WawatDark.warning
                                  : const Color(0xFFB4791A),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr('verification.intro.paid_label',
                                      'Ödənişli xidmət'),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? WawatDark.textPrimary
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tr('verification.intro.paid_hint',
                                      'Nişan yalnız ödənişdən sonra aktivləşir.'),
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.3,
                                    color: isDark
                                        ? WawatDark.textSecondary
                                        : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (fee != null) ...[
                            const SizedBox(width: 12),
                            Text(
                              _feeText(fee, currency),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? WawatDark.textPrimary
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Two-step checklist.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? WawatDark.surface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: cCardBorder(isDark),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.45)
                                : Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildStepRow(
                            number: 1,
                            title: tr('verification.intro.step1_title',
                                'Sənədləri göndər'),
                            subtitle: tr('verification.intro.step1_hint',
                                'Pasport və selfi yüklə, yoxlamaya göndər.'),
                            isDark: isDark,
                          ),
                          const SizedBox(height: 18),
                          _buildStepRow(
                            number: 2,
                            title: tr('verification.intro.step2_title',
                                'Ödə və aktivləşdir'),
                            subtitle: tr('verification.intro.step2_hint',
                                'Sənədlər təsdiqləndikdən sonra ödə — nişan aktiv olur.'),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildPrimaryButton(
                      label: tr('verification.intro.cta', 'Sənədləri göndər'),
                      onTap: () => setState(() => _showUpload = true),
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

  /// Payment step (approved & payment.required): documents approved, pay the
  /// fee to activate the badge. Payment is mock now — the button just calls
  /// /verification/pay. A placeholder marks where the real provider widget goes.
  Widget _buildPaymentScreen(bool isDark, VerificationState state) {
    final green = isDark ? WawatDark.success : const Color(0xFF22C55E);
    return Scaffold(
      backgroundColor: isDark ? WawatDark.bg : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              isDark,
              tr('verification.payment.title', 'Ödəniş'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: green.withValues(alpha: isDark ? 0.16 : 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.task_alt, color: green, size: 50),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      tr('verification.payment.approved_title',
                          'Sənədlər təsdiqləndi'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: isDark ? WawatDark.textPrimary : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tr(
                        'verification.awaiting_payment',
                        'Sənədlər təsdiqləndi. Nişanı aktivləşdirmək üçün ödə.',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: isDark ? WawatDark.textSecondary : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Amount to pay — from payment.fee_amount.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 22),
                      decoration: BoxDecoration(
                        color: isDark ? WawatDark.surface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: cCardBorder(isDark),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.45)
                                : Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            tr('verification.payment.amount_label',
                                'Ödəniləcək məbləğ'),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? WawatDark.textSecondary
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _feeText(
                              state.payment.feeAmount,
                              state.payment.currency,
                            ),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? WawatDark.brandText
                                  : const Color(0xFF017BFE),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: isDark
                              ? WawatDark.textSecondary
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tr('verification.payment.activates_note',
                                'Ödəniş doğrulama nişanını dərhal aktivləşdirir.'),
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.35,
                              color: isDark
                                  ? WawatDark.textSecondary
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Placeholder where the real payment-provider widget will
                    // mount once integrated. For now paying is a mock call.
                    if (state.payment.mock)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? WawatDark.surfaceAlt
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? WawatDark.border
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.build_circle_outlined,
                              size: 20,
                              color: isDark
                                  ? WawatDark.textMuted
                                  : Colors.grey[500],
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                tr('verification.payment.mock_note',
                                    'Ödəniş provayderi tezliklə qoşulacaq — hazırda sınaq (mock) rejimidir.'),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.35,
                                  color: isDark
                                      ? WawatDark.textSecondary
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 28),
                    _buildPrimaryButton(
                      label:
                          '${tr('verification.payment.cta', 'Ödə')} · ${_feeText(state.payment.feeAmount, state.payment.currency)}',
                      loading: _isPaying,
                      onTap: _pay,
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

  /// Rejected: show the reason and offer a free resubmit (POST /submit again).
  Widget _buildRejectedScreen(bool isDark, VerificationState state) {
    final red = isDark ? WawatDark.danger : const Color(0xFFEF4444);
    final reason = state.rejectionReason;
    return Scaffold(
      backgroundColor: isDark ? WawatDark.bg : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              isDark,
              tr('verification.rejected.title', 'Doğrulama'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: red.withValues(alpha: isDark ? 0.16 : 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.highlight_off, color: red, size: 52),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      tr('verification.rejected.headline',
                          'Doğrulama rədd edildi'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: isDark ? WawatDark.textPrimary : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tr(
                        'verification.rejected.subtitle',
                        'Sənədlər təsdiqlənmədi. Səbəbə bax və yenidən göndər.',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: isDark ? WawatDark.textSecondary : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? WawatDark.danger.withValues(alpha: 0.12)
                            : const Color(0xFFFEECEC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: red.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('verification.rejected.reason_label', 'Səbəb'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: red,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            reason != null && reason.isNotEmpty
                                ? reason
                                : tr('verification.rejected.no_reason',
                                    'Səbəb göstərilməyib.'),
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: isDark
                                  ? WawatDark.textPrimary
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      tr('verification.rejected.free_note',
                          'Yenidən göndərmək pulsuzdur.'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            isDark ? WawatDark.textSecondary : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildPrimaryButton(
                      label: tr('verification.rejected.cta', 'Yenidən göndər'),
                      onTap: () => setState(() => _showUpload = true),
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

  Widget _buildUploadDocumentsScreen(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? WawatDark.bg : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      // The upload view is a sub-step: back returns to the intro
                      // / rejected screen it was opened from, not out of KYC.
                      onTap: () => _showUpload
                          ? setState(() => _showUpload = false)
                          : Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: isDark ? WawatDark.textPrimary : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: isDark ? WawatDark.textPrimary : Colors.black,
                      ),
                      child: Text(S.of(context).gregrere4334),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 30),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF00B4A6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: Colors.white,
                  size: 45,
                ),
              ),
              const SizedBox(height: 24),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: isDark ? WawatDark.textPrimary : Colors.black87,
                ),
                child: Text(S.of(context).gre43fbd4t3),
              ),
              const SizedBox(height: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? WawatDark.textSecondary : Colors.grey,
                  height: 1.4,
                ),
                child: Text(
                  S.of(context).ngre24532vfds,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? WawatDark.surface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: cCardBorder(isDark),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.45)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: isDark ? WawatDark.textPrimary : Colors.black87,
                      ),
                      child: Text(S.of(context).gdfgdf4343gre),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isDark ? WawatDark.textSecondary : Colors.grey[600],
                      ),
                      child: Text(S.of(context).get42fvfdvs),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Type picker only makes sense with more than one option; with a
              // single accepted type (passport) it's hidden.
              if (_idDocTypes.length > 1)
                _buildTypePicker(isDark)
              else if (_typesLoadFailed)
                _buildTypesRetry(isDark),
              _buildDocumentCard(
                icon: Icons.description_outlined,
                iconColor: const Color(0xFF4A90D9),
                iconBgColor: const Color(0xFFE8F2FC),
                title: _selectedTypeName(),
                subtitle: S.of(context).vdfvbfd34,
                status: _idImage != null
                    ? S.of(context).gdf43gf
                    : S.of(context).fbdbdf3434,
                statusColor: _idImage != null ? Colors.green : Colors.grey,
                uploadText: S.of(context).bdf234rffd,
                image: _idImage,
                onTap: _pickIdImage,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildDocumentCard(
                icon: Icons.camera_alt_outlined,
                iconColor: const Color(0xFF4CAF50),
                iconBgColor: const Color(0xFFE8F5E9),
                title: S.of(context).gfdfd3434,
                subtitle: S.of(context).bfxvdg34,
                status: _selfieImage != null
                    ? S.of(context).hrgrs434
                    : S.of(context).yghtrdf4343,
                statusColor: _selfieImage != null ? Colors.green : Colors.grey,
                uploadText: S.of(context).fdggg35tr34g,
                image: _selfieImage,
                onTap: _pickSelfieImage,
                showUploadIcon: true,
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? WawatDark.textSecondary : Colors.grey[600],
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: S.of(context).gbdgb3434 + " ",
                      style: TextStyle(
                        color: isDark
                            ? WawatDark.brandText
                            : const Color(0xFF4A90D9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: S.of(context).grgdfgdfg34t343t,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    disabledBackgroundColor:
                        AppColors.appColor.withOpacity(0.6),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          S.of(context).bfdbffd24343vfd,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  VerificationBloc provideBloc() {
    return VerificationBloc();
  }

  Future<void> _pickIdImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _idImage = File(image.path);
      });
    }
  }

  Future<void> _pickSelfieImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selfieImage = File(image.path);
      });
    }
  }

  String _selectedTypeName() {
    for (final t in _idDocTypes) {
      if (t.code == _selectedType) return t.name;
    }
    return S.of(context).vfd43vfd;
  }

  Widget _buildTypePicker(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _idDocTypes.map((t) {
          final selected = t.code == _selectedType;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _selectedType = t.code),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: selected
                    ? (isDark ? WawatDark.brandChip : const Color(0xFFEAF3FE))
                    : (isDark ? WawatDark.surfaceAlt : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(12),
                border: selected
                    ? Border.all(
                        color: const Color(0xFF017BFE).withValues(alpha: 0.6),
                        width: 1.4)
                    : null,
              ),
              child: Text(
                t.name,
                style: TextStyle(
                  color: selected
                      ? (isDark ? WawatDark.brandText : const Color(0xFF017BFE))
                      : (isDark
                          ? WawatDark.textSecondary
                          : const Color(0xFF475569)),
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _snack(String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _submitVerification() async {
    if (_idImage == null || _selfieImage == null) {
      _snack(S.of(context).bgfbgd3ttgtebdsdf, Colors.orange);
      return;
    }
    // Document type may be missing only because /document-types didn't load —
    // retry once, then surface a clear (not "upload both") message.
    if (_selectedType == null) {
      await _loadDocumentTypes();
      if (_selectedType == null) {
        _snack(
            tr('verification.doc_types_load_failed',
                'Sənəd növləri yüklənə bilmədi. Yenidən cəhd et.'),
            Colors.red);
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await bloc.submitVerification(
        idType: _selectedType!,
        idFile: _idImage!,
        selfie: _selfieImage!,
      );

      if (mounted) {
        showIOSStyleMessage(context, S.of(context).yhtjkuyil43);
        await _loadVerificationStatus();
        // Leave the upload sub-view → land on the "under review" screen.
        if (mounted) setState(() => _showUpload = false);
      }
    } catch (e) {
      // ErrorDispatcher уже показал 422 верхним снекбаром — причём текстом
      // сервера («You already have a pending verification request»), который
      // куда полезнее общей фразы. Своя плашка нужна только для остальных
      // ошибок, иначе пользователь видит два уведомления об одном и том же.
      final alreadyShownByDispatcher =
          e is DioException && e.response?.statusCode == 422;
      if (mounted && !alreadyShownByDispatcher) {
        _snack(
            tr('verification.submit_failed',
                'Göndərmək alınmadı. Yenidən cəhd et.'),
            Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTypesRetry(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _loadDocumentTypes,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isDark ? WawatDark.surfaceAlt : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.refresh,
                  size: 18,
                  color:
                      isDark ? WawatDark.brandText : const Color(0xFF017BFE)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tr('verification.doc_types_load_failed_retry',
                      'Sənəd növləri yüklənmədi. Yenidən cəhd et.'),
                  style: TextStyle(
                    color: isDark
                        ? WawatDark.textSecondary
                        : const Color(0xFF475569),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required String uploadText,
    required File? image,
    required VoidCallback onTap,
    required bool isDark,
    bool showUploadIcon = false,
  }) {
    final effectiveIconBg = isDark ? _darkIconBg(iconColor) : iconBgColor;
    final effectiveIconColor = isDark ? _darkIconColor(iconColor) : iconColor;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? WawatDark.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: cCardBorder(isDark),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.45)
                : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: effectiveIconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: effectiveIconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? WawatDark.textPrimary : Colors.black87,
                      ),
                      child: Text(title),
                    ),
                    const SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? WawatDark.textMuted : Colors.grey[500],
                      ),
                      child: Text(subtitle),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (image == null)
                    Icon(
                      Icons.upload_outlined,
                      size: 18,
                      color: isDark ? WawatDark.iconMuted : Colors.grey[400],
                    ),
                  if (image != null)
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: statusColor,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: isDark ? WawatDark.surfaceAlt : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? WawatDark.border : Colors.grey[300]!,
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
              ),
              child: CustomPaint(
                painter: DashedBorderPainter(
                  color: isDark ? WawatDark.border : Colors.grey[350]!,
                  strokeWidth: 1.5,
                  gap: 6,
                ),
                child: image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.upload_outlined,
                            size: 32,
                            color:
                                isDark ? WawatDark.iconMuted : Colors.grey[400],
                          ),
                          const SizedBox(height: 10),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? WawatDark.textSecondary
                                  : Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                            child: Text(uploadText),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Мягкая плашка под иконку в тёмной теме по цвету самой иконки.
Color _darkIconBg(Color iconColor) {
  if (iconColor == const Color(0xFF4CAF50)) return WawatDark.successBg;
  if (iconColor == const Color(0xFFF5A623)) return WawatDark.warningBg;
  if (iconColor == const Color(0xFF4A90D9)) return WawatDark.brandChip;
  return WawatDark.surfaceAlt;
}

/// Цвет иконки в тёмной теме (мягкие статусные/бренд-токены).
Color _darkIconColor(Color iconColor) {
  if (iconColor == const Color(0xFF4CAF50)) return WawatDark.success;
  if (iconColor == const Color(0xFFF5A623)) return WawatDark.warning;
  if (iconColor == const Color(0xFF4A90D9)) return WawatDark.brandText;
  return WawatDark.icon;
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.gap = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final dashWidth = 8.0;
    final radius = 12.0;

    double x = radius;
    while (x < size.width - radius) {
      path.moveTo(x, 0);
      path.lineTo(x + dashWidth, 0);
      x += dashWidth + gap;
    }

    double y = radius;
    while (y < size.height - radius) {
      path.moveTo(size.width, y);
      path.lineTo(size.width, y + dashWidth);
      y += dashWidth + gap;
    }

    x = radius;
    while (x < size.width - radius) {
      path.moveTo(x, size.height);
      path.lineTo(x + dashWidth, size.height);
      x += dashWidth + gap;
    }

    y = radius;
    while (y < size.height - radius) {
      path.moveTo(0, y);
      path.lineTo(0, y + dashWidth);
      y += dashWidth + gap;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
