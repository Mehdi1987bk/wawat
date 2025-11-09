//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class AuthorImage extends StatelessWidget {
//   final Widget image;
//   final double radius;
//
//   const AuthorImage({required Key key,required this.image, this.radius = 36}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return CircleAvatar(
//       backgroundColor: Colors.transparent,
//       radius: radius,
//       backgroundImage: image != null
//           ? CachedNetworkImageProvider(image)
//           : AssetImage('asset/man.png'),
//     );
//   }
// }