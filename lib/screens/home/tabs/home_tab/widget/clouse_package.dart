import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../../../data/network/response/all_request_response.dart';
import '../../../../../data/network/response/package.dart';
import '../../../../../presentation/resourses/app_colors.dart';

class ClousePackage extends StatelessWidget {
  final AllRequestResponse package;

  const ClousePackage({Key? key, required this.package}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM, y, hh:mm');

    return Row(
      children: [
        SvgPicture.asset(package.status == "completed"?
          "asset/packIcon2.svg" :
          "asset/packIcon1.svg" ,
          fit: BoxFit.cover,
        ),
        SizedBox(
          width: 15,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nağd kredit",
              style: TextStyle(
                  color: AppColors.textColor, fontSize: 20, fontWeight: FontWeight.w400),
            ),
            Text(
              dateFormat.format(package.createdAt),
              style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Spacer(),
        Text(
          package.paidAmount.toString(),
          style: TextStyle(color: AppColors.textColor, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 3),
          child: Image.asset(
            "asset/azn_icon_two.png",
            color: AppColors.textColor,
            width: 10,
          ),
        ),
        SizedBox(
          width: 15,
        ),
        Icon(Icons.arrow_forward_ios,size: 18,color: Colors.grey,)
      ],
    );;
  }
}
