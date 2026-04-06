import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/app_sizes.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/core/const/image_path.dart';
import 'package:goatlearning/core/global_widegts/app_base_widget.dart';
import 'package:goatlearning/core/global_widegts/custom_submit_button.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/global_widegts/custom_textfield.dart';
import 'package:goatlearning/feature/admin/edit/admin_complete_profile/controller/admin_complete_profile_controller.dart';

class AdminCompleteProfileScreen extends StatelessWidget {
  AdminCompleteProfileScreen({super.key});

  final AdminCompleteProfileController adminCompleteProfileController = Get.put(
    AdminCompleteProfileController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: AppBaseWidget(
          needBackButton: false,
          needProfileTitle: true,
          title: "Complete Your Profile",
          child: Padding(
            padding: EdgeInsets.only(
              top: getHeight(50),
              left: 16.5,
              right: 15.5,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CustomText(
                          text: 'add_profile_photo'.tr,
                          color: Color(0xff1C1C1E),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        SizedBox(height: 11),
                        Stack(
                          children: [
                            Container(
                              height: 140,
                              width: 139,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xff173156),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Image.asset(ImagePath.profile),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                height: 40,
                                width: 40,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Color(0xff5EAEB5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.asset(IconsPath.editBg),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25),
                  CustomText(
                    text: 'name'.tr,
                    color: AppColors.appColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 5),
                  CustomTextfield(
                    controller: adminCompleteProfileController.nameController,
                    hintext: 'name'.tr,
                  ),
                  SizedBox(height: 15),

                  CustomText(
                    text: 'email'.tr,
                    color: AppColors.appColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 5),
                  CustomTextfield(
                    controller: adminCompleteProfileController.emailController,
                    hintext: 'email'.tr,
                  ),
                  SizedBox(height: 15),

                  CustomText(
                    text: 'phone_number'.tr,
                    color: AppColors.appColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 5),
                  CustomTextfield(
                    controller:
                        adminCompleteProfileController.phoneNumberController,
                    hintext: 'phone_number'.tr,
                  ),

                  SizedBox(height: 20),
                  CustomSubmitButton(
                    onTap: () async {},
                    height: 50,
                    text: 'save'.tr,
                    fontSize: 14,
                    textColor: Colors.white,
                    fontWeight: FontWeight.w600,
                    bgColor: AppColors.textPrimaryColor,
                    radius: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
