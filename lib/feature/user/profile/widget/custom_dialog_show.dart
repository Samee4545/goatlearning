import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/core/const/image_path.dart';
import 'package:goatlearning/core/global_widegts/custom_submit_button.dart';
import 'package:google_fonts/google_fonts.dart';

void showFullScreenDialog() {
  Get.dialog(
    Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            SizedBox(height: 28),
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Image.asset(IconsPath.cross, height: 48, width: 48),
              ),
            ),

            SizedBox(height: 38),
            Image.asset(ImagePath.congratulations, height: 304),

            const SizedBox(height: 10),
            Text(
              "Congratulations!",
              style: GoogleFonts.inter(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryColor,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              "Correct Answers: 14 ✅",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.appColor,
              ),
            ),
            Text(
              "Incorrect Answers: 08 ❌",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.appColor,
              ),
            ),

            Text(
              "Score: 80%",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.appColor,
              ),
            ),

            const SizedBox(height: 38),
            CustomSubmitButton(
              onTap: () {},
              text: "View Answers",
              fontSize: 14,
              textColor: AppColors.textPrimaryColor,
              fontWeight: FontWeight.w600,
              bgColor: Colors.white,
              border: AppColors.textPrimaryColor,
              radius: 12,
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}
