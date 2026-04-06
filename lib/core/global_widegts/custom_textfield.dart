// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintext;
  final Widget? suffixIcon;
  final double? height;
  final double? radius;

  final ValueChanged<String>? onChanged;
  final bool obsecureText;
  final TextInputType? textInputType;

  const CustomTextfield({
    super.key,
    required this.controller,
    required this.hintext,

    this.suffixIcon,
    this.onChanged,
    this.obsecureText = false,
    this.textInputType,
    this.height,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),

        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(radius ?? 12),
      ),
      child: Center(
        child: TextField(
          autofocus: false,
          controller: controller,
          obscureText: obsecureText,
          keyboardType: textInputType,
          onChanged: onChanged,
          enableInteractiveSelection: false,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textBlack,
          ),
          decoration: InputDecoration(
            hintText: hintext,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Color(0xFFF5F9FA),
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textColor,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }
}
