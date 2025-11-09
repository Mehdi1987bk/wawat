import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import '../../../../../data/network/response/all_request_response.dart';
import 'clouse_package.dart';
import 'open_package.dart';

class PackageItem extends StatelessWidget {
  final AllRequestResponse package;

  const PackageItem({Key? key, required this.package}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      // <-- Provides ExpandableController to its children
      child: Column(
        children: [
          Expandable(
            collapsed: ExpandableButton(
              child: _BorderItem(
                widget: ClousePackage(
                  package: package,
                ),
              ),
            ),
            expanded: Column(children: [
              ExpandableButton(
                child: _BorderItem(
                  widget: OpenPackage(
                    package: package,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _BorderItem extends StatelessWidget {
  final Widget widget;

  const _BorderItem({Key? key, required this.widget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
      padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: widget,
    );
  }
}
