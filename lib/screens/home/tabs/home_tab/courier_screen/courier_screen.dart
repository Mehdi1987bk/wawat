
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../data/network/response/offer_models.dart';

class CourierDetailsScreen extends StatelessWidget {
  final OfferModel courier;

  const CourierDetailsScreen({
    Key? key,
    required this.courier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(courier.user?.fullname ?? 'Курьер'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A1A1A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
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
                      return Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      );
                    },
                  ),
                )
                    : Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 24),

            Center(
              child: Column(
                children: [
                  Text(
                    courier.user?.fullname ?? 'Пользователь',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 8),
                  if ((courier.user?.ratingAvg ?? 0) > 0)
                    Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '⭐',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${(courier.user?.ratingAvg ?? 0).toStringAsFixed(1)} из 5.0',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 32),

            if (courier.description?.isNotEmpty ?? false)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'О себе',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      courier.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9E9E9E),
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),

            Text(
              'Детали маршрута',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 12),
            _buildDetailItem(
              'Маршрут',
              '${courier.cityFrom?.name ?? '-'} → ${courier.cityTo?.name ?? '-'}',
            ),
            _buildDetailItem(
              'Дата',
              _formatDate(courier.mainDate ?? ''),
            ),
            _buildDetailItem(
              'Время',
              _formatTime(courier.mainTime),
            ),
            _buildDetailItem(
              'Максимальный вес',
              '${courier.maxWeightKg ?? '-'} кг',
            ),
            _buildDetailItem(
              'Цена за кг',
              '${courier.pricePerKg ?? '-'} ₼',
            ),
            SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 56,
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
                        onTap: () {
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Center(
                          child: Text(
                            'Назад',
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9E9E9E),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '-';
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
    if (time == null || time.isEmpty) return '-';
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
