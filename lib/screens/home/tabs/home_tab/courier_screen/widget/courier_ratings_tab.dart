import 'package:flutter/material.dart';

import '../../../../../../data/network/response/partner_user_response.dart';

class CourierRatingsTab extends StatelessWidget {
  final Data data;

  const CourierRatingsTab({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          if (data.reviewsReceived.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Отзывов нет',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            )
          else
            ...data.reviewsReceived.asMap().entries.map((entry) {
              int index = entry.key;
              Review review = entry.value;
              return _buildReviewCard(review);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B5BFF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.author.fullname[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.author.fullname,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star,
                size: 14,
                color: index < int.parse(review.rating)
                    ? Colors.amber
                    : Colors.grey[300],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _getDaysAgo(String createdAt) {
    try {
      DateTime dateTime = DateTime.parse(createdAt);
      DateTime now = DateTime.now();
      Duration difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} янв ${dateTime.year}';
      } else if (difference.inHours > 0) {
        return 'Сегодня';
      } else {
        return 'Сейчас';
      }
    } catch (e) {
      return 'недавно';
    }
  }
}
