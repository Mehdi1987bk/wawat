import 'package:flutter/material.dart';
import '../../presentation/resourses/wawat_colors.dart';
import '../../presentation/resourses/wawat_dimensions.dart';
import '../../presentation/resourses/wawat_text_styles.dart';
import 'wawat_button.dart';
import 'wawat_chip.dart';

/// Модель данных курьера
class CourierData {
  final String name;
  final String role;
  final bool isVerified;
  final double rating;
  final String description;
  final String route;
  final String date;
  final String time;
  final String weight;
  final String price;
  final String? avatarUrl;

  CourierData({
    required this.name,
    required this.role,
    this.isVerified = false,
    required this.rating,
    required this.description,
    required this.route,
    required this.date,
    required this.time,
    required this.weight,
    required this.price,
    this.avatarUrl,
  });
}

/// Карточка курьера для приложения Wawat
class WawatCourierCard extends StatelessWidget {
  final CourierData courier;
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
      margin: EdgeInsets.symmetric(
        horizontal: WawatDimensions.spacingMd,
        vertical: WawatDimensions.spacingSm,
      ),
      padding: EdgeInsets.all(WawatDimensions.cardPadding),
      decoration: BoxDecoration(
        color: WawatColors.backgroundWhite,
        borderRadius: BorderRadius.circular(WawatDimensions.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: WawatColors.shadowLight,
            blurRadius: WawatDimensions.shadowBlurLight,
            offset: Offset(0, WawatDimensions.shadowOffsetY),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header с именем и аватаром
          Row(
            children: [
              // Avatar
              Container(
                width: WawatDimensions.avatarSize,
                height: WawatDimensions.avatarSize,
                decoration: BoxDecoration(
                  color: WawatColors.primary,
                  borderRadius: BorderRadius.circular(
                    WawatDimensions.avatarBorderRadius,
                  ),
                ),
                child: Center(
                  child: Text(
                    courier.name.substring(0, 1).toUpperCase(),
                    style: WawatTextStyles.h3.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: WawatDimensions.spacingSm),
              // Name
              Expanded(
                child: Text(
                  courier.name,
                  style: WawatTextStyles.h3,
                ),
              ),
            ],
          ),
          SizedBox(height: WawatDimensions.spacingSm),

          // Chips (роль, проверен, рейтинг)
          Wrap(
            spacing: WawatDimensions.spacingSm,
            runSpacing: WawatDimensions.spacingXs,
            children: [
              WawatRoleChip(role: courier.role),
              if (courier.isVerified) WawatVerifiedChip(),
              WawatRatingChip(rating: courier.rating),
            ],
          ),
          SizedBox(height: WawatDimensions.spacingMd),

          // Description
          Text(
            courier.description,
            style: WawatTextStyles.body.copyWith(
              color: WawatColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: WawatDimensions.spacingMd),

          // Details (маршрут, дата, вес, цена, время)
          _buildDetailsRow(
            'Маршрут:',
            courier.route,
            'Дата:',
            courier.date,
          ),
          SizedBox(height: WawatDimensions.spacingXs),
          _buildDetailsRow(
            'Вес:',
            courier.weight,
            'Время:',
            courier.time,
          ),
          SizedBox(height: WawatDimensions.spacingXs),
          _buildDetailsRow(
            'Цена:',
            courier.price,
            null,
            null,
          ),
          SizedBox(height: WawatDimensions.spacingMd),

          // Buttons
          Row(
            children: [
              Expanded(
                child: WawatOutlineButton(
                  text: 'Подробнее',
                  onPressed: onDetails,
                  height: 36,
                ),
              ),
              SizedBox(width: WawatDimensions.spacingSm),
              Expanded(
                child: WawatButton(
                  text: 'Написать',
                  onPressed: onMessage,
                  height: 36,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsRow(
    String label1,
    String value1,
    String? label2,
    String? value2,
  ) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                label1,
                style: WawatTextStyles.caption,
              ),
              SizedBox(width: WawatDimensions.spacingXs),
              Expanded(
                child: Text(
                  value1,
                  style: WawatTextStyles.captionBold.copyWith(
                    color: WawatColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (label2 != null && value2 != null) ...[
          SizedBox(width: WawatDimensions.spacingSm),
          Expanded(
            child: Row(
              children: [
                Text(
                  label2,
                  style: WawatTextStyles.caption,
                ),
                SizedBox(width: WawatDimensions.spacingXs),
                Expanded(
                  child: Text(
                    value2,
                    style: WawatTextStyles.captionBold.copyWith(
                      color: WawatColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
