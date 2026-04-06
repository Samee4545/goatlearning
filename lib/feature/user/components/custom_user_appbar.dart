import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_sizes.dart';
import 'package:goatlearning/core/const/image_path.dart';
import 'package:goatlearning/core/global_widegts/custom_shimmer_image.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/route/routes.dart';
import 'package:goatlearning/feature/user/profile/controller/user_profile_controller.dart';

class CustomUserAppbar extends StatelessWidget {
  const CustomUserAppbar({super.key, required this.profileController});

  final UserProfileController profileController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // For local users (no profile), show minimal app bar without profile icon and student text
      if (profileController.profile.value == null) {
        return Container(margin: const EdgeInsets.only(top: 30), height: 50);
      }

      final profile = profileController.profile.value!;

      return Container(
        margin: const EdgeInsets.only(top: 30),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                Get.toNamed(AppRoutes.userProfile);
              },
              child: CustomShimmerImage(
                height: 40,
                width: 40,
                borderWidth: 0,
                color: Colors.transparent,
                image: profile.profileImage ?? "N/A",
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
                    text: profile.username ?? "",
                    color: Color(0xffEFF5FD),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                  CustomText(
                    text: "Student",
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
