import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/app_sizes.dart';
import 'package:goatlearning/core/global_widegts/app_base_widget.dart';
import 'package:goatlearning/core/global_widegts/custom_submit_button.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/global_widegts/custom_textfield.dart';
import 'package:goatlearning/feature/admin/profile/controller/admin_profile_controller.dart';
import 'package:goatlearning/feature/admin/setting/manage_admin/controller/add_admin_controller.dart';

class AddAdminScreen extends StatelessWidget {
  AddAdminScreen({super.key});

  final AddAdminController addAdminController = Get.find();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.5),
              child: CustomText(
                text: 'add_admin'.tr,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryColor,
              ),
            ),

            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'name'.tr,
                    color: const Color(0xffA3B0C2),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),

                  SizedBox(height: 15),
                  CustomTextfield(
                    controller: addAdminController.adminNameController,
                    hintext: 'admin_name'.tr,
                  ),
                  SizedBox(height: 17),

                  CustomText(
                    text: 'email'.tr,
                    color: const Color(0xffA3B0C2),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),

                  SizedBox(height: 15),
                  CustomTextfield(
                    controller: addAdminController.emailController,
                    hintext: 'email'.tr,
                  ),
                  SizedBox(height: 17),

                  CustomText(
                    text: 'password'.tr,
                    color: const Color(0xffA3B0C2),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),

                  SizedBox(height: 15),
                  Obx(
                    () => CustomTextfield(
                      obsecureText: addAdminController.obscureText.value,
                      controller: addAdminController.passwordController,
                      hintext: 'password'.tr,
                      suffixIcon: IconButton(
                        onPressed: () {
                          addAdminController.obscureText.value =
                              !addAdminController.obscureText.value;
                        },
                        icon:
                            addAdminController.obscureText.value
                                ? const Icon(
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
                      addAdminController.addAdmin();
                    },
                    height: 50,
                    text: 'add_admin'.tr,
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
    );
  }
}
