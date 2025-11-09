import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../data/network/response/user.dart';
import '../../../../../presentation/resourses/app_colors.dart';

class UserDetailsWidget extends StatelessWidget {
  final User userDetailsResponse;

  const UserDetailsWidget({Key? key, required this.userDetailsResponse}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50), border: Border.all(color: Colors.grey)),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: /* userDetailsResponse. == null ?*/
                        const CachedNetworkImageProvider(
                            "https://w7.pngwing.com/pngs/442/17/png-transparent-computer-icons-user-profile-male-user-heroes-head-silhouette.png")
                    // : CachedNetworkImageProvider(userDetailsResponse.imageUrl ?? ""),
                    ),
              ),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Xoş gəldin",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                userDetailsResponse.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,color: AppColors.textColor),
              ),
            ],
          )
        ],
      ),
    );
  }
}
