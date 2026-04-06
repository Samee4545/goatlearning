import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/app_sizes.dart';
import 'package:goatlearning/core/global_widegts/app_text_button.dart';
import 'package:goatlearning/core/global_widegts/custom_submit_button.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/global_widegts/custom_textfield.dart';
import 'package:goatlearning/feature/auth/register/controller/register_controller.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final RegisterController registerController = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: getHeight(128),
            left: 20,
            right: 20,
            bottom: getHeight(128),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CustomText(
                  text: 'register'.tr,
                  color: AppColors.appColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              CustomText(
                text: 'username'.tr,
                color: AppColors.appColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),

              SizedBox(height: 15),
              CustomTextfield(
                controller: registerController.userNameController,
                hintext: 'username'.tr,
              ),
              SizedBox(height: 15),
              CustomText(
                text: 'email_address'.tr,
                color: AppColors.appColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 15),
              CustomTextfield(
                controller: registerController.emailAddressController,
                hintext: 'email_address'.tr,
              ),

              SizedBox(height: 17),
              CustomText(
                text: 'password'.tr,
                color: AppColors.appColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 15),
              Obx(
                () => CustomTextfield(
                  obsecureText: registerController.obscureText.value,
                  controller: registerController.passwordController,
                  hintext: 'password'.tr,
                  suffixIcon: IconButton(
                    onPressed: () {
                      registerController.obscureText.value =
                          !registerController.obscureText.value;
                    },
                    icon:
                        registerController.obscureText.value
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
                color: AppColors.appColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 15),
              Obx(
                () => CustomTextfield(
                  obsecureText: registerController.obscureText2.value,
                  controller: registerController.conPasswordController,
                  hintext: 'confirm_password'.tr,
                  suffixIcon: IconButton(
                    onPressed: () {
                      registerController.obscureText2.value =
                          !registerController.obscureText2.value;
                    },
                    icon:
                        registerController.obscureText2.value
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

              SizedBox(height: getHeight(27)),
              CustomSubmitButton(
                onTap: () {
                  registerController.register();
                },
                height: 50,
                text: 'register'.tr,
                fontSize: 14,
                textColor: Colors.white,
                fontWeight: FontWeight.w600,
                bgColor: AppColors.textPrimaryColor,
                radius: 12,
              ),
              SizedBox(height: getHeight(42)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomText(
                    text: 'already_have_account'.tr,
                    color: AppColors.appColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  AppTextButton(
                    onTap: () {
                      Get.back();
                    },
                    text: 'login_here'.tr,
                    textColor: AppColors.textPrimaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
