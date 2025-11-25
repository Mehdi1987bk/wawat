import 'package:buking/presentation/resourses/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../../data/network/response/offer_models.dart';
import '../widgte/delivery_card.dart';
import '../widgte/delivery_history_widget.dart';

class DeliveryFullListScreen extends StatelessWidget {
  final List<OfferModel> offers;

  const DeliveryFullListScreen({Key? key, required this.offers})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Все доставки',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5B5BFF),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: offers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final offer = offers[index];
          return DeliveryCard(
            icon: DeliveryUtils.getIconByType(offer.offerType?.code ?? ''),
            role: offer.offerType?.code ?? '',
            status: DeliveryUtils.getStatusText(offer.status ?? 'active'),
            statusColor:
                DeliveryUtils.getStatusColor(offer.offerType?.code ?? ''),
            statusBgColor:
                DeliveryUtils.getStatusBgColor(offer.offerType?.code ?? ''),
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
          );
        },
      ),
    );
  }
}
