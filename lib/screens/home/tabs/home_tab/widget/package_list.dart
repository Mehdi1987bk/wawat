import 'package:flutter/material.dart';
import '../../../../../data/network/response/all_request_data.dart';
import 'package_item.dart';

const productItemHeight = 290.0;
const bigProductItemHeight = 350.0;

class PackageList extends StatelessWidget {
  final AllrequestData data;

  const PackageList(
    this.data,
  );

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate((_, index) {
      return PackageItem( package: data.data[index],);
    }, childCount: data.data.length));
  }
}
