import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../data/network/response/offer_models.dart';
import '../see_more_offers/see_more_offers_screen.dart';
import 'delivery_card.dart';

class DeliveryHistoryWidget extends StatelessWidget {
  final OfferListResponse response;

  const DeliveryHistoryWidget({Key? key, required this.response})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final offers = response.data ?? [];

    if (offers.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'История пуста',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
          ),
        ),
      );
    }

    final displayOffers = offers.take(10).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'История',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (BuildContext context) {
                        return DeliveryFullListScreen(
                          offers: response.data,
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B5BFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Показать все',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...displayOffers.map((offer) {
            return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DeliveryCard(
                  icon:
                      DeliveryUtils.getIconByType(offer.offerType?.code ?? ''),
                  role: offer.offerType?.code ?? '',
                  status: DeliveryUtils.getStatusText(offer.status ?? 'active'),
                  statusColor:
                      DeliveryUtils.getStatusColor(offer.offerType?.code ?? ''),
                  statusBgColor: DeliveryUtils.getStatusBgColor(
                      offer.offerType?.code ?? ''),
                  route:
                      '${offer.cityFrom?.name ?? "-"} → ${offer.cityTo?.name ?? "-"}',
                  date: DeliveryUtils.formatDate(offer.mainDate ?? ''),
                  weight: '${offer.maxWeightKg ?? 0} кг',
                  price: '${offer.pricePerKg ?? 0}/kg',
                  views: 0,
                  comments: 0,
                  onView: () {},
                  onEdit: () {},
                  onDelete: () {},
                ));
          }).toList(),
        ],
      ),
    );
  }
}

class DeliveryUtils {
  // Получение иконки по типу
  static IconData getIconByType(String type) {
    switch (type) {
      case 'courier':
        return Icons.flight_takeoff;
      case 'sender':
        return Icons.inventory_2;
      case 'buyer':
        return Icons.person;
      default:
        return Icons.help_outline;
    }
  }

  // Текст статуса
  static String getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return 'Активно';
      case 'completed':
        return 'Завершено';
      case 'cancelled':
        return 'Отменено';
      default:
        return 'Активно';
    }
  }

  // Цвет текста статуса
  static Color getStatusColor(String? offerTypeCode) {
    switch (offerTypeCode?.toLowerCase()) {
      case 'courier':
        return const Color(0xFF10B981);
      case 'sender':
        return const Color(0xFF3B82F6);
      case 'buyer':
        return const Color(0xFFFCD34D);
      default:
        return const Color(0xFF10B981);
    }
  }

  // Цвет фона статуса
  static Color getStatusBgColor(String? offerTypeCode) {
    switch (offerTypeCode?.toLowerCase()) {
      case 'courier':
        return const Color(0xFFD1FAE5);
      case 'sender':
        return const Color(0xFFDCEEFE);
      case 'buyer':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFD1FAE5);
    }
  }

  // Форматирование даты
  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Дата не указана';
    try {
      final date = DateTime.parse(dateString);
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
      return '${date.day} ${months[date.month - 1]}';
    } catch (e) {
      return 'Дата не указана';
    }
  }

  // Ограничение списка до N элементов
  static List<OfferModel> getDisplayOffers(List<OfferModel>? offers,
      {int limit = 10}) {
    if (offers == null || offers.isEmpty) return [];
    return offers.take(limit).toList();
  }
}
