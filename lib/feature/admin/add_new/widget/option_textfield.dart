// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class OptionTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintext;

  const OptionTextfield({
    super.key,
    required this.controller,
    required this.hintext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.questionBorder, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: TextField(
          autofocus: false,
          controller: controller,

          enableInteractiveSelection: false,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textBlack,
          ),
          decoration: InputDecoration(
            hintText: hintext,

            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textBlack,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(4),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(4),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }
}
