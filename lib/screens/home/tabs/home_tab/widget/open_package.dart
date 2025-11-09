import 'package:flutter/material.dart';

import '../../../../../data/network/response/all_request_response.dart';
import '../../../../../data/network/response/package.dart';
import '../../../../../presentation/resourses/app_colors.dart';
import 'clouse_package.dart';

class OpenPackage extends StatelessWidget {
  final AllRequestResponse package;

  const OpenPackage({Key? key, required this.package}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 30,),
          child: ClousePackage(
            package: package,
          ),
        ),
        Text("Kredit haqqında",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18,color: AppColors.textColor),)
      ],
    );
  }
}
