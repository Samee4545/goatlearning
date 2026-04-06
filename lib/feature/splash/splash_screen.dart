// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/app_sizes.dart';
import 'package:goatlearning/core/const/image_path.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/route/routes.dart';
import 'package:goatlearning/core/services_class/local_service/shared_preferences_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isGuestLoading = false;

  @override
  void initState() {
    super.initState();
    _moveToNextScreen();
  }

  Future<void> _moveToNextScreen() async {
    String? accessToken = await SharePref.getSavedToken();
    String? role = await SharePref.getSavedRole();
    bool? isGuest = await SharePref.getSavedGuest();
    print("role $role, isGuest $isGuest");

    if (accessToken != null) {
      if (role == "USER") {
        Get.offAllNamed(AppRoutes.userNavBar);
      } else {
        Get.offAllNamed(AppRoutes.adminNavBar);
      }
    } else {
      // No access token: proceed to app as guest without calling login
      Get.offAllNamed(AppRoutes.userNavBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appColor,
      body: Stack(
        children: [
          // Global SafeArea already applied, but splash wants full bleed color.
          // Use SafeArea only for its content padding without affecting background color.
          Padding(
            padding: EdgeInsets.only(top: 92, left: 22, right: 22, bottom: 68),
            child: SizedBox.expand(
              child: Column(
                children: [
                  Image.asset(ImagePath.appImg, height: getHeight(374.48)),
                  SizedBox(height: 28),
                  CustomText(
                    text: "Ready to Learn?\nLet’s Go!",
                    textAlign: TextAlign.center,
                    color: AppColors.titleTextColor,
                    fontSize: getHeight(42),
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 12),
                  CustomText(
                    text:
                        "Expand your mind, explore endless knowledge, and unlock new possibilities every day.",
                    textAlign: TextAlign.center,
                    color: AppColors.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ),
          if (isGuestLoading)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
