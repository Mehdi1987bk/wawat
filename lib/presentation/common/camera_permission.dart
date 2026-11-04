import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../services/localization_service.dart';
import '../../services/theme_manager.dart';
import '../resourses/wawat_dark.dart';

Future<bool> ensureCameraPermission(BuildContext context) async {
  var status = await Permission.camera.status;
  if (status.isGranted || status.isLimited) return true;

  if (!status.isRestricted) {
    status = await Permission.camera.request();
    if (status.isGranted || status.isLimited) return true;
  }

  if ((status.isPermanentlyDenied || status.isRestricted) && context.mounted) {
    await _showOpenSettingsDialog(context);
  }
  return false;
}

Future<void> _showOpenSettingsDialog(BuildContext context) async {
  final isDark = context.read<ThemeManager>().isDarkMode;
  final bg = isDark ? WawatDark.surface : Colors.white;
  final titleColor = isDark ? WawatDark.textPrimary : const Color(0xFF111827);
  final bodyColor = isDark ? WawatDark.textSecondary : const Color(0xFF4B5563);
  const brand = Color(0xFF017BFE);

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        tr('permission.camera_title', 'Kamera icazəsi lazımdır'),
        style: TextStyle(
          color: titleColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        tr(
          'permission.camera_body',
          'Şəkil çəkmək üçün Parametrlərdə kameraya icazə verin.',
        ),
        style: TextStyle(color: bodyColor, fontSize: 14.5, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(
            tr('common.cancel', 'Ləğv et'),
            style: TextStyle(color: bodyColor, fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            openAppSettings();
          },
          child: Text(
            tr('permission.open_settings', 'Parametrləri aç'),
            style: const TextStyle(color: brand, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
