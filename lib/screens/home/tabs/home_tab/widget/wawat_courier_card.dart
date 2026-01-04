import 'package:buking/presentation/resourses/wawat_colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    isFavorite = widget.courier.isFavourite ?? false;
    isVisible = widget.courier.status == "active" ? true : false;
  }

  void _toggleFavorite() async {
    try {
      final isLogged = await sl.get<AuthRepository>().isLogged();

      // Проверяем, что виджет все еще в дереве
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
      // Обрабатываем ошибку
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
    final isLogged = await sl.get<AuthRepository>().isLogged();
    if (!isLogged) {
      return AuthModalUtils.showAuthRequiredModal(context);
    } else {
      setState(() {
        isVisible = !isVisible;
      });
      widget.onVisibilityToggle?.call(isVisible);
    }
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
            // Создаем ChatApi
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

    // Fallback to main_date
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

        return Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
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
                        child: widget.courier.user?.avatar != null
                            ? ClipOval(
                                child: Image.network(
                                  widget.courier.user!.avatar!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
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
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
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
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? Colors.white
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
                                          ? const Color(0xFF1E3A5F)
                                          : const Color(0xFFD4E8FF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.flight,
                                          size: 16,
                                          color: const Color(0xFF2196F3),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          widget.courier.offerType!.title,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF2196F3),
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
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF4CAF50),
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
                            isDark ? const Color(0xFFB0B0B0) : Colors.black87,
                      ),
                      maxLines: 20,
                      overflow: TextOverflow.ellipsis,
                      child: Text(widget.courier.description!),
                    ),
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
                          '${widget.courier.maxWeightKg} кг',
                          isDark,
                        ),
                      if (widget.courier.pricePerKg != null)
                        _buildDetailRow(
                          S.of(context).rggre5egre,
                          '${widget.courier.pricePerKg} \$/кг',
                          isDark,
                        ), if (widget.courier.packageType != null)
                        _buildDetailRow(
                          S.of(context).nhgnhg4,
                          '${widget.courier.packageType?.code}',
                          isDark,
                        ),
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
                                      fontWeight: FontWeight.w700,
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
                                      fontWeight: FontWeight.w700,
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
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
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
            if (widget.sendMessageActiv == false)
              Positioned(
                top: 15,
                right: 35,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
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
                                ? const Color(0xFFB0B0B0)
                                : Colors.black87,
                          ),
                          child: Text(isVisible == true
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
              color: isDark ? const Color(0xFF9CA3AF) : WawatColors.textPrimary,
            ),
            child: Text(label),
          ),
          Flexible(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.right,
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
    if (time == null) return '-';

    try {
      final DateTime parsedTime = DateTime.parse(time);
      final hours = parsedTime.hour.toString().padLeft(2, '0');
      final minutes = parsedTime.minute.toString().padLeft(2, '0');
      return '$hours:$minutes';
    } catch (e) {
      return time;
    }
  }
}
