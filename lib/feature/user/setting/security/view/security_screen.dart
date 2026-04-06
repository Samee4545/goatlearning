import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/app_sizes.dart';
import 'package:goatlearning/core/global_widegts/app_base_widget.dart';
import 'package:goatlearning/core/global_widegts/custom_submit_button.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/global_widegts/custom_textfield.dart';
import 'package:goatlearning/feature/user/profile/controller/user_profile_controller.dart';
import 'package:goatlearning/feature/user/setting/security/controller/security_controller.dart';

class SecurityScreen extends StatelessWidget {
  SecurityScreen({super.key});

  final SecurityController securityController = Get.put(SecurityController());
  final UserProfileController userProfileController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBaseWidget(
        needBackButton: false,
        needProfileLeadingIcon: true,
        profileAssetsPath: userProfileController.profile.value?.profileImage,
        needProfileTitle: true,
        title: userProfileController.profile.value?.username,
        needChapterSubtitle: true,
        subtitle: userProfileController.profile.value?.profession,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.5),
                child: CustomText(
                  text: 'security'.tr,
                  color: AppColors.textPrimaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: getHeight(39)),
              //
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.5),
                child: CustomText(
                  text: 'change_password'.tr,
                  color: AppColors.textBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'current_password'.tr,
                      color: const Color(0xffA3B0C2),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),

                    SizedBox(height: 15),
                    CustomTextfield(
                      controller: securityController.currentPasswordController,
                      hintext: 'current_password'.tr,
                    ),
                    SizedBox(height: 17),

                    CustomText(
                      text: 'new_password'.tr,
                      color: const Color(0xffA3B0C2),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),

                    SizedBox(height: 15),
                    Obx(
                      () => CustomTextfield(
                        obsecureText: securityController.obscureText.value,
                        controller: securityController.newPasswordController,
                        hintext: 'new_password'.tr,
                        suffixIcon: IconButton(
                          onPressed: () {
                            securityController.obscureText.value =
                                !securityController.obscureText.value;
                          },
                          icon:
                              securityController.obscureText.value
                                  ? Icon(
                                    Icons.visibility_off,
                                    size: 18,
                                    color: Colors.grey,
                                  )
                                  : const Icon(
                                    Icons.visibility,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                        ),
                      ),
                    ),

                    SizedBox(height: 17),
                    CustomText(
                      text: 'confirm_password'.tr,
                      color: const Color(0xffA3B0C2),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),

                    SizedBox(height: 15),
                    Obx(
                      () => CustomTextfield(
                        obsecureText: securityController.obscureText2.value,
                        controller:
                            securityController.confirmPasswordController,
                        hintext: 'confirm_password'.tr,
                        suffixIcon: IconButton(
                          onPressed: () {
                            securityController.obscureText2.value =
                                !securityController.obscureText2.value;
                          },
                          icon:
                              securityController.obscureText2.value
                                  ? Icon(
                                    Icons.visibility_off,
                                    size: 18,
                                    color: Colors.grey,
                                  )
                                  : const Icon(
                                    Icons.visibility,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                        ),
                      ),
                    ),
                    SizedBox(height: getHeight(60)),
                    CustomSubmitButton(
                      onTap: () {
                        securityController.changePassword();
                      },
                      height: 50,
                      text: 'save'.tr,
                      fontSize: 14,
                      textColor: Colors.white,
                      fontWeight: FontWeight.w500,
                      bgColor: AppColors.textPrimaryColor,
                      radius: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
