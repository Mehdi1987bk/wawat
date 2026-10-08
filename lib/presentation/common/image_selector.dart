import 'package:flutter/cupertino.dart';
import 'package:buking/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


Future<ImageSource> showSelectImageSourceAlert(
  BuildContext context,
) async {
  ImageSource source = await showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
            title: Text(t('picker.image_title')),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text(t('picker.gallery')),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true)
                      .pop(ImageSource.gallery);
                },
              ),
              CupertinoActionSheetAction(
                child: Text(t('picker.camera')),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true)
                      .pop(ImageSource.camera);
                },
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text(t('common.cancel')),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ));
  return source;
}
