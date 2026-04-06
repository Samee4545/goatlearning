import 'package:flutter/material.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSubmitButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Widget? icon;
  final double? radius;
  final Color? bgColor;
  final Color? border;
  final Color? textColor;
  final double? fontSize;
  final double? height;
  final FontWeight? fontWeight;

  const CustomSubmitButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.bgColor,
    this.border,
    this.textColor,
    this.radius,
    this.fontSize,
    this.height,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor ?? AppColors.primaryColor,

      borderRadius: BorderRadius.circular(radius ?? 24),
      child: InkWell(
        splashColor: Colors.white.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(radius ?? 24),
        onTap: onTap,
        child: Container(
          height: height ?? 56,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius ?? 24),
            border: Border.all(
              color: border ?? Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: fontSize ?? 16,
                    fontWeight: fontWeight ?? FontWeight.w700,
                    color: textColor ?? AppColors.textBlack,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 5),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: icon),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
