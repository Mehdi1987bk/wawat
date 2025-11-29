import 'package:buking/presentation/resourses/wawat_colors.dart';
import 'package:flutter/material.dart';
import '../../../../../data/network/response/offer_models.dart';

class WawatCourierCard extends StatelessWidget {
  final OfferModel courier;
  final VoidCallback? onDetails;
  final VoidCallback? onMessage;

  const WawatCourierCard({
    Key? key,
    required this.courier,
    this.onDetails,
    this.onMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Header: Avatar + Name + Chips
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
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
                child: courier.user?.avatar != null
                    ? ClipOval(
                  child: Image.network(
                    courier.user!.avatar!,
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
                    // Name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            courier.user?.fullname ?? 'Пользователь',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        // Rating chip
                        if ((courier.user?.ratingAvg ?? 0) > 0)
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
                                  (courier.user?.ratingAvg ?? 0).toStringAsFixed(1),
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
                    // Chips
                    Wrap(
                      spacing: 5,
                      runSpacing: 8,
                      children: [
                        // Offer type chip
                        if (courier.offerType != null)
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
                                  courier.offerType!.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2196F3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Verified chip
                        if (courier.user?.isVerified ?? false)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF4CAF50),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 6),
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

          // Description
          if (courier.description?.isNotEmpty ?? false)
            Text(
              courier.description!,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9E9E9E),
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          SizedBox(height: 24),

          // Details Table
          Column(
            children: [
              _buildDetailRow(
                'Маршрут:',
                '${courier.cityFrom?.name ?? '-'} → ${courier.cityTo?.name ?? '-'}',
              ),
              if (courier.mainDate != null)
                _buildDetailRow(
                  'Дата:',
                  _formatDate(courier.mainDate!),
                ),
              if (courier.maxWeightKg != null)
                _buildDetailRow(
                  'Вес:',
                  '${courier.maxWeightKg} кг',
                ),
              if (courier.mainTime != null)
                _buildDetailRow(
                  'Время:',
                  _formatTime(courier.mainTime!),
                ),
              if (courier.pricePerKg != null)
                _buildDetailRow(
                  'Цена:',
                  '${courier.pricePerKg} ₼/кг',
                ),
            ],
          ),
          SizedBox(height: 10),

          // Buttons
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
                      onTap: onDetails,
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
                      onTap: onMessage,
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
