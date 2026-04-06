import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/app_sizes.dart';
import 'package:goatlearning/core/global_widegts/app_base_widget.dart';
import 'package:goatlearning/core/global_widegts/custom_submit_button.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/global_widegts/custom_textfield.dart';
import 'package:goatlearning/feature/admin/profile/controller/admin_profile_controller.dart';
import 'package:goatlearning/feature/admin/setting/security/controller/admin_security_controller.dart';

class AdminSecurityScreen extends StatelessWidget {
  AdminSecurityScreen({super.key});

  final AdminSecurityController adminSecurityController = Get.put(
    AdminSecurityController(),
  );
  final AdminProfileController adminProfileController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBaseWidget(
        needBackButton: false,
        needProfileLeadingIcon: true,
        profileAssetsPath: adminProfileController.profile.value?.profileImage,
        needProfileTitle: true,
        title: adminProfileController.profile.value?.username,
        needChapterSubtitle: true,
        subtitle: adminProfileController.profile.value?.role,
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
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w600,
                    ),

                    SizedBox(height: 15),
                    CustomTextfield(
                      controller:
                          adminSecurityController.currentPasswordController,
                      hintext: 'current_password'.tr,
                    ),
                    SizedBox(height: 17),

                    CustomText(
                      text: 'new_password'.tr,
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w600,
                    ),

                    SizedBox(height: 15),
                    Obx(
                      () => CustomTextfield(
                        obsecureText: adminSecurityController.obscureText.value,
                        controller:
                            adminSecurityController.newPasswordController,
                        hintext: 'new_password'.tr,
                        suffixIcon: IconButton(
                          onPressed: () {
                            adminSecurityController.obscureText.value =
                                !adminSecurityController.obscureText.value;
                          },
                          icon:
                              adminSecurityController.obscureText.value
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
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w600,
                    ),

                    SizedBox(height: 15),
                    Obx(
                      () => CustomTextfield(
                        obsecureText:
                            adminSecurityController.obscureText2.value,
                        controller:
                            adminSecurityController.confirmPasswordController,
                        hintext: 'confirm_password'.tr,
                        suffixIcon: IconButton(
                          onPressed: () {
                            adminSecurityController.obscureText2.value =
                                !adminSecurityController.obscureText2.value;
                          },
                          icon:
                              adminSecurityController.obscureText2.value
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
                    SizedBox(height: getHeight(40)),
                    CustomSubmitButton(
                      onTap: () {
                        adminSecurityController.changePassword();
                      },
                      height: 50,
                      text: 'save_change'.tr,
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
