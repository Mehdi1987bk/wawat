import 'package:flutter/material.dart';

import '../../../../../data/network/response/all_request_response.dart';
import '../../../../../presentation/resourses/app_colors.dart';

class BalanceWidget extends StatelessWidget {
  final AllRequestResponse package;

  const BalanceWidget({Key? key, required this.package}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = /*package.payment - package.creditAmount*/ 5;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15,),
          child: Text(
            "Ümumi borc",
            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 25),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              status.toString(),
              style:
                  TextStyle(color: AppColors.textColor, fontSize: 40, fontWeight: FontWeight.w500),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 11, left: 3),
              child: Image.asset(
                "asset/azn_icon_two.png",
                color: AppColors.textColor,
                width: 19,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 40, left: 20,bottom: 35),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Son müraciətlər",
              style: TextStyle(color: AppColors.textColor, fontSize: 25, fontWeight: FontWeight.w500),
            ),
          ),
        )
      ],
    );
  }
}
