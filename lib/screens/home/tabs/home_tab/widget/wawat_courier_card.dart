import 'package:buking/presentation/resourses/wawat_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../data/network/api/chat_api.dart';
import '../../../../../data/network/response/offer_models.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../generated/l10n.dart';
import '../../../../../main.dart';
import '../../../../../services/theme_manager.dart';
import '../courier_screen/courier_screen.dart';
import 'auth_modal_utils.dart';
import 'start_chat_modal.dart';

class WawatCourierCard extends StatefulWidget {
  final OfferModel courier;
  final bool detailsActiv;
  final bool sendMessageActiv;

  final Function(bool)? onFavoriteToggle;
  final Function(bool)? onVisibilityToggle;

  const WawatCourierCard({
    Key? key,
    required this.courier,
    this.onFavoriteToggle,
    this.onVisibilityToggle,
    this.detailsActiv = true,
    this.sendMessageActiv = true,
  }) : super(key: key);

  @override
  State<WawatCourierCard> createState() => _WawatCourierCardState();
}

class _WawatCourierCardState extends State<WawatCourierCard> {
  late bool isFavorite;
  late bool isVisible;
  bool _isExpanded = false;
  bool _isPackageTypeExpanded = false;
  bool _isUpdating = false; // Флаг для предотвращения повторных нажатий

  @override
  void initState() {
    super.initState();
    _syncStateFromWidget();
  }

  @override
  void didUpdateWidget(covariant WawatCourierCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Синхронизируем состояние при обновлении виджета
    if (oldWidget.courier.id != widget.courier.id ||
        oldWidget.courier.status != widget.courier.status ||
        oldWidget.courier.isFavourite != widget.courier.isFavourite) {
      _syncStateFromWidget();
    }
  }

  void _syncStateFromWidget() {
    isFavorite = widget.courier.isFavourite ?? false;
    isVisible = widget.courier.status == "active";
    _isPackageTypeExpanded = false;
    _isUpdating = false;
  }

  void _toggleFavorite() async {
    try {
      final isLogged = await sl.get<AuthRepository>().isLogged();

      if (!mounted) return;

      if (!isLogged) {
        AuthModalUtils.showAuthRequiredModal(context);
        return;
      }

      setState(() {
        isFavorite = !isFavorite;
      });

      widget.onFavoriteToggle?.call(isFavorite);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).veferv3e4ver + ' ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleVisibility() async {
    // Предотвращаем повторные нажатия пока идёт обновление
    if (_isUpdating) return;

    final isLogged = await sl.get<AuthRepository>().isLogged();
    if (!isLogged) {
      return AuthModalUtils.showAuthRequiredModal(context);
    }

    setState(() {
      _isUpdating = true;
    });

    // Вызываем callback, НЕ меняя локальное состояние
    // Состояние обновится автоматически через didUpdateWidget после обновления списка
    final newVisibility = !isVisible;
    widget.onVisibilityToggle?.call(newVisibility);
  }

  void _handleStartChat() async {
    final isLogged = await sl.get<AuthRepository>().isLogged();
    if (!isLogged) {
      return AuthModalUtils.showAuthRequiredModal(context);
    } else {
      StartChatModal.show(
        context,
        userId: widget.courier.user?.id ?? 0,
        userName: widget.courier.user?.fullname ?? S.of(context).vfewrerewec,
        onSuccess: (message) async {
          try {
            final chatApi = ChatApi(sl.get<Dio>());

            chatApi.startChat({
              'user_id': widget.courier.user?.id,
              'body': message,
            });
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(S.of(context).vreevrrvrrvrevre + ' ${e.toString()}'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
        },
      );
    }
  }

  String _getDateLabel() {
    final offerType = widget.courier.offerType?.code;

    if (offerType == 'courier') {
      return S.of(context).bbrgtrewrg3v;
    } else if (offerType == 'sender') {
      return S.of(context).btegw4er4tgwr45g;
    } else if (offerType == 'buyer') {
      return S.of(context).ger4w53g3tgsg;
    }
    return S.of(context).te3g35grfgsg;
  }

  String _getDateValue() {
    final offerType = widget.courier.offerType?.code;

    if (offerType == 'courier') {
      return widget.courier.flightDate != null
          ? _formatDate(widget.courier.flightDate!)
          : '-';
    } else if (offerType == 'sender') {
      if (widget.courier.deliveryDateFrom != null &&
          widget.courier.deliveryDateTo != null) {
        return '${_formatDate(widget.courier.deliveryDateFrom!)} - ${_formatDate(widget.courier.deliveryDateTo!)}';
      } else if (widget.courier.deliveryDateFrom != null) {
        return _formatDate(widget.courier.deliveryDateFrom!);
      }
      return '-';
    } else if (offerType == 'buyer') {
      if (widget.courier.purchaseDate != null &&
          widget.courier.purchaseTime != null) {
        return '${_formatDate(widget.courier.purchaseDate!)} - ${_formatDate(widget.courier.purchaseTime!)}';
      } else if (widget.courier.purchaseDate != null) {
        return _formatDate(widget.courier.purchaseDate!);
      }
      return '-';
    }

    return widget.courier.mainDate != null
        ? _formatDate(widget.courier.mainDate!)
        : '-';
  }

  String? _getTimeValue() {
    final offerType = widget.courier.offerType?.code;

    if (offerType == 'courier') {
      return widget.courier.flightTime != null
          ? _formatTime(widget.courier.flightTime)
          : null;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        final description = widget.courier.description ?? "";
        final showButton = description.length > 120;

        return Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                color: cCard(isDark),
                borderRadius: BorderRadius.circular(28),
                border: cCardBorder(isDark),
                boxShadow: isDark
                    ? WawatDark.cardShadow
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
              ),
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF5B5FFF), Color(0xFFB74CFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: (widget.courier.user?.avatarThumbUrl ??
                                    widget.courier.user?.avatar) !=
                                null
                            ? ClipOval(
                                // Card avatar → cached thumbnail.
                                child: CachedNetworkImage(
                                  imageUrl:
                                      widget.courier.user!.avatarThumbUrl ??
                                          widget.courier.user!.avatar ??
                                          '',
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) {
                                    return Center(
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? WawatDark.textPrimary
                                          : const Color(0xFF1A1A1A),
                                    ),
                                    child: Text(
                                      widget.courier.user?.fullname ??
                                          S.of(context).gte34rte5rg5er,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                if ((widget.courier.user?.ratingAvg ?? 0) > 0)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '⭐',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(width: 6),
                                        AnimatedDefaultTextStyle(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? WawatDark.textPrimary
                                                : const Color(0xFF1A1A1A),
                                          ),
                                          child: Text(
                                            (widget.courier.user?.ratingAvg ??
                                                    0)
                                                .toStringAsFixed(1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Wrap(
                              spacing: 5,
                              runSpacing: 8,
                              children: [
                                if (widget.courier.offerType != null)
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? WawatDark.brandChip
                                          : const Color(0xFFD4E8FF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.flight,
                                          size: 16,
                                          color: isDark
                                              ? WawatDark.brandText
                                              : const Color(0xFF2196F3),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          widget.courier.offerType!.title,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? WawatDark.brandText
                                                : const Color(0xFF2196F3),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (widget.courier.user?.isVerified == true)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          "asset/prof_3.png",
                                          width: 16,
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          S.of(context).ge35e5g3gerg3,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? WawatDark.success
                                                : const Color(0xFF4CAF50),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (widget.courier.description?.isNotEmpty ?? false)
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color:
                            isDark ? WawatDark.textSecondary : Colors.black87,
                      ),
                      maxLines: _isExpanded ? null : 3,
                      overflow: _isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      child: Text(description),
                    ),
                  if (showButton) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Text(
                        _isExpanded
                            ? S.of(context).fgsdgsgdfs
                            : S.of(context).bgfdbssdbd,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isDark ? WawatDark.brandText : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 24),
                  Column(
                    children: [
                      _buildDetailRow(
                        S.of(context).getgrw35g3egeg3eg,
                        '${widget.courier.cityFrom?.name ?? '-'} → ${widget.courier.cityTo?.name ?? '-'}',
                        isDark,
                      ),
                      _buildDetailRow(
                        _getDateLabel(),
                        _getDateValue(),
                        isDark,
                      ),
                      if (_getTimeValue() != null)
                        _buildDetailRow(
                          S.of(context).gerg3g3ge,
                          _getTimeValue()!,
                          isDark,
                        ),
                      if (widget.courier.maxWeightKg != null)
                        _buildDetailRow(
                          S.of(context).gerg3g53grg,
                          '${widget.courier.maxWeightKg} ' + S.of(context).kq,
                          isDark,
                        ),
                      if (widget.courier.pricePerKg != null)
                        _buildDetailRow(
                          S.of(context).rggre5egre,
                          '${widget.courier.pricePerKg} \$/' + S.of(context).kq,
                          isDark,
                        ),
                      if (widget.courier.flightNumber != null)
                        _buildDetailRow(
                          S.of(context).flightNumber + ":",
                          '${widget.courier.flightNumber}',
                          isDark,
                        ),
                      if (widget.courier.packageType != null) ...[
                        SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final packageTypeText = widget.courier.packageType
                                    ?.map((value) => value.title)
                                    .join(', ') ??
                                'N/A';

                            final labelText = S.of(context).nhgnhg4;
                            final labelStyle = TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? WawatDark.textSecondary
                                  : WawatColors.textPrimary,
                            );
                            final labelPainter = TextPainter(
                              text:
                                  TextSpan(text: labelText, style: labelStyle),
                              maxLines: 1,
                              textDirection: TextDirection.ltr,
                            )..layout();

                            final spacerWidth =
                                MediaQuery.of(context).size.width * 0.2;
                            final availableWidth = constraints.maxWidth -
                                labelPainter.width -
                                spacerWidth -
                                16;

                            final valueStyle = TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? WawatDark.textPrimary
                                  : const Color(0xFF1A1A1A),
                            );
                            final valuePainter = TextPainter(
                              text: TextSpan(
                                  text: packageTypeText, style: valueStyle),
                              maxLines: 1,
                              textDirection: TextDirection.ltr,
                            )..layout();

                            final isOverflowing =
                                valuePainter.width > availableWidth;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AnimatedDefaultTextStyle(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        style: labelStyle,
                                        child: Text(labelText),
                                      ),
                                      SizedBox(width: spacerWidth),
                                      Flexible(
                                        child: AnimatedDefaultTextStyle(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          style: valueStyle,
                                          textAlign: TextAlign.right,
                                          maxLines:
                                              _isPackageTypeExpanded ? null : 1,
                                          overflow: _isPackageTypeExpanded
                                              ? TextOverflow.visible
                                              : TextOverflow.ellipsis,
                                          child: Text(packageTypeText),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isOverflowing)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isPackageTypeExpanded =
                                            !_isPackageTypeExpanded;
                                      });
                                    },
                                    child: Text(
                                      _isPackageTypeExpanded
                                          ? S.of(context).fgsdgsgdfs
                                          : S.of(context).bgfdbssdbd,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? WawatDark.brandText
                                            : Colors.blue,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      if (widget.detailsActiv == true)
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF5B5FFF), Color(0xFFB74CFF)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x335B5FFF),
                                  blurRadius: 16,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  final isLogged =
                                      await sl.get<AuthRepository>().isLogged();
                                  if (!isLogged) {
                                    return AuthModalUtils.showAuthRequiredModal(
                                        context);
                                  } else {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (BuildContext context) {
                                          return CourierDetailsScreen(
                                            courierId:
                                                widget.courier.user?.id ?? 0,
                                          );
                                        },
                                      ),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Center(
                                  child: Text(
                                    S.of(context).etg5g43gdg,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (widget.detailsActiv == true) SizedBox(width: 12),
                      if (widget.sendMessageActiv == true)
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 48,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF5B5FFF),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              color: isDark
                                  ? const Color(0xFF1E1E3F)
                                  : Colors.transparent,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _handleStartChat,
                                borderRadius: BorderRadius.circular(16),
                                child: Center(
                                  child: Text(
                                    S.of(context).grt4g4gdeg354,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF5B5FFF),
                                    ),
                                  ),
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
            if (widget.sendMessageActiv == true)
              Positioned(
                top: 15,
                right: 35,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: isDark ? WawatDark.surfaceAlt : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    shape: CircleBorder(),
                    child: InkWell(
                      onTap: _toggleFavorite,
                      borderRadius: BorderRadius.circular(28),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color:
                              isFavorite ? Colors.red : const Color(0xFF5B5FFF),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (widget.sendMessageActiv == false &&
                widget.courier.status != "expired")
              Positioned(
                top: 15,
                right: 35,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: isDark ? WawatDark.surfaceAlt : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(8),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: _toggleVisibility,
                          borderRadius: BorderRadius.circular(28),
                          child: Icon(
                            isVisible ? Icons.visibility : Icons.visibility_off,
                            color: WawatColors.primary,
                            size: 24,
                          ),
                        ),
                        SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? WawatDark.textSecondary
                                : Colors.black87,
                          ),
                          child: Text(isVisible
                              ? S.of(context).gdreg53ge
                              : S.of(context).grg34g54gdgdg),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDark ? WawatDark.textSecondary : WawatColors.textPrimary,
            ),
            child: Text(label),
          ),
          Flexible(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? WawatDark.textPrimary : const Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.justify,
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      final months = [
        S.of(context).frg4543gr3gwgr3,
        S.of(context).f434f3vgterf43,
        S.of(context).f3f43fr34g345g54h,
        S.of(context).d2edf3f34,
        S.of(context).ff3rfr34f3erf3r,
        S.of(context).f3rfr3vf3ref3d,
        S.of(context).f34f34f3r4fr3,
        S.of(context).f3f3r5gf34fr34,
        S.of(context).f3rf3r4fder3,
        S.of(context).frrf33frf34fr3,
        S.of(context).frefr3rf2343fr4,
        S.of(context).gregerrg33gr
      ];
      return '${parsedDate.day} ${months[parsedDate.month - 1]} ${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }

  String _formatTime(String? time) {
    if (time == null || time.trim().isEmpty) return '-';
    final raw = time.trim();
    // Full ISO datetime.
    final dt = DateTime.tryParse(raw);
    if (dt != null) {
      return '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    }
    // Bare time string like "09:15:00" or "9:15" → HH:mm (drop seconds).
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(raw);
    if (match != null) {
      return '${match.group(1)!.padLeft(2, '0')}:${match.group(2)}';
    }
    return raw;
  }
}
