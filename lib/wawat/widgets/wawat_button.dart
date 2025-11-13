import 'package:flutter/material.dart';
import '../../presentation/resourses/wawat_colors.dart';

class WawatButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final bool isOutlined;

  const WawatButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null
              ? Colors.grey
              : (isOutlined ? Colors.white : WawatColors.primary),
          foregroundColor: isOutlined ? WawatColors.primary : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isOutlined
                ? BorderSide(color: WawatColors.primary, width: 1.5)
                : BorderSide.none,
          ),
          elevation: isOutlined ? 0 : 2,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
