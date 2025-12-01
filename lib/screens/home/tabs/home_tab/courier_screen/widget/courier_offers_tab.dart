import 'package:flutter/material.dart';
import '../../../../../../data/network/response/partner_user_response.dart';
import '../../widget/wawat_courier_card.dart';

class CourierOffersTab extends StatelessWidget {
  final Data data;

  const CourierOffersTab({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.offers.active.length,
      itemBuilder: (BuildContext context, int index) {
        if (data.offers.active != []) {
          return WawatCourierCard(
            detailsActiv: false,
            courier: data.offers.active[index]!,
          );
        }
        return SizedBox();
      },
    );
  }
}
