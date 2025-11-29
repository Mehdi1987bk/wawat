import 'package:buking/presentation/resourses/wawat_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../data/network/response/offer_models.dart';
import 'package:buking/presentation/resourses/wawat_colors.dart';
import 'package:flutter/material.dart';
import '../../../../../data/network/response/offer_models.dart';

class WawatCourierCard extends StatefulWidget {
  final OfferModel courier;
  final VoidCallback? onDetails;
  final VoidCallback? onMessage;
  final Function(bool)? onFavoriteToggle;

  const WawatCourierCard({
    Key? key,
    required this.courier,
    this.onDetails,
    this.onMessage,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  State<WawatCourierCard> createState() => _WawatCourierCardState();
}

class _WawatCourierCardState extends State<WawatCourierCard> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.courier.isFavourite ?? false;
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
    widget.onFavoriteToggle?.call(isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
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
                              child: Text(
                                widget.courier.user?.fullname ??
                                    'Пользователь',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                                overflow: TextOverflow.ellipsis,
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
                                    Text(
                                      (widget.courier.user?.ratingAvg ?? 0)
                                          .toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A1A1A),
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
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFD4E8FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.flight,
                                      size: 16,
                                      color: Color(0xFF2196F3),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      widget.courier.offerType!.title,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2196F3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (widget.courier.user?.isVerified ?? false)
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
                                      'Проверен',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF4CAF50),
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
                Text(
                  widget.courier.description!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              SizedBox(height: 24),
              Column(
                children: [
                  _buildDetailRow(
                    'Маршрут:',
                    '${widget.courier.cityFrom?.name ?? '-'} → ${widget.courier.cityTo?.name ?? '-'}',
                  ),
                  if (widget.courier.mainDate != null)
                    _buildDetailRow(
                      'Дата:',
                      _formatDate(widget.courier.mainDate!),
                    ),
                  if (widget.courier.maxWeightKg != null)
                    _buildDetailRow(
                      'Вес:',
                      '${widget.courier.maxWeightKg} кг',
                    ),
                  if (widget.courier.mainTime != null)
                    _buildDetailRow(
                      'Время:',
                      _formatTime(widget.courier.mainTime!),
                    ),
                  if (widget.courier.pricePerKg != null)
                    _buildDetailRow(
                      'Цена:',
                      '${widget.courier.pricePerKg} ₼/кг',
                    ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
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
                          onTap: widget.onDetails,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Text(
                              'Подробнее',
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
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFF5B5FFF),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onMessage,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Text(
                              'Написать',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF5B5FFF),
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
        Positioned(
          top: 15,
          right: 35,
          child: Material(
            color: Colors.white,
            shape: CircleBorder(),
            child: InkWell(
              onTap: _toggleFavorite,
              borderRadius: BorderRadius.circular(28),
              child: Center(
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? Colors.red
                      : Color(0xFF5B5FFF),
                  size: 24,
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: WawatColors.textPrimary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
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
        'янв',
        'фев',
        'мар',
        'апр',
        'май',
        'июн',
        'июл',
        'авг',
        'сен',
        'окт',
        'ноя',
        'дек'
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




























