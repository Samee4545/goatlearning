import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/app_sizes.dart';
import 'package:goatlearning/core/const/image_path.dart';
import 'package:goatlearning/core/global_widegts/custom_submit_button.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/route/routes.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: getHeight(136)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 52),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomText(
                    text: 'get_started'.tr,
                    color: AppColors.textBlack,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 16),
                  CustomText(
                    text: 'onboarding_description'.tr,
                    textAlign: TextAlign.center,
                    color: Color(0xffA3B0C2),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
            SizedBox(height: getHeight(67)),
            Image.asset(
              ImagePath.appImg,
              height: getHeight(240),
              width: getWidth(212.13),
            ),

            Padding(
              padding: EdgeInsets.only(
                top: getHeight(81),
                left: 22,
                right: 22,
                bottom: 51,
              ),
              child: Column(
                children: [
                  CustomSubmitButton(
                    onTap: () {
                      Get.offAllNamed(AppRoutes.userNavBar);
                    },
                    text: 'continue'.tr,
                    fontSize: 14,
                    textColor: Colors.white,
                    fontWeight: FontWeight.w600,
                    bgColor: AppColors.textPrimaryColor,
                    radius: 12,
                  ),
                  SizedBox(height: 16),
                  CustomSubmitButton(
                    onTap: () {
                      Get.offAllNamed(AppRoutes.userNavBar);
                    },
                    text: 'explore_without_account'.tr,
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
          ],
        ),
      ),
    );
  }
}
