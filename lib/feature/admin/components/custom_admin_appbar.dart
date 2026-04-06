// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_sizes.dart';
import 'package:goatlearning/core/const/image_path.dart';
import 'package:goatlearning/core/global_widegts/custom_error_text.dart';
import 'package:goatlearning/core/global_widegts/custom_shimmer_image.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/route/routes.dart';
import 'package:goatlearning/feature/admin/profile/controller/admin_profile_controller.dart';

class CustomAdminAppbar extends StatelessWidget {
  const CustomAdminAppbar({super.key, required this.adminProfileController});

  final AdminProfileController adminProfileController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (adminProfileController.profile.value == null) {
        return SizedBox.shrink(); // Removed loading text
      }
      if (adminProfileController.profile.value!.username!.isEmpty) {
        return CustomErrorText(text: "N/A");
      }
      final profile = adminProfileController.profile.value!;

      return Container(
        margin: const EdgeInsets.only(top: 30),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                if (profile.role == "SUPER_ADMIN") {
                  Get.toNamed(AppRoutes.adminEditProfile);
                } else {
                  print("only super admin go edit profile");
                }
                print(profile.role);
              },
              child: CustomShimmerImage(
                height: 40,
                width: 40,
                borderWidth: 0,
                color: Colors.transparent,
                image: profile.profileImage ?? "N?A",
                errorImage: Image.asset(ImagePath.profile),
              ),
            ),
            SizedBox(width: 6),
            SizedBox(
              width: screenWidth() * 0.5,
              height: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: profile.username ?? "N/A",
                    color: Color(0xffEFF5FD),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                  CustomText(
                    text: profile.role ?? "N/A",
                    color: Color(0xffA3B0C2),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
