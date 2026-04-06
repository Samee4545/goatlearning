import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/app_sizes.dart';
import 'package:goatlearning/core/global_widegts/app_text_button.dart';
import 'package:goatlearning/core/global_widegts/custom_submit_button.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/global_widegts/custom_textfield.dart';
import 'package:goatlearning/feature/auth/forget_password/view/sent_email_screen.dart';
import 'package:goatlearning/feature/auth/login/controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.appColor),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: getHeight(180),
            horizontal: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CustomText(
                  text: 'welcome_message'.tr,
                  color: AppColors.appColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 37),
              CustomText(
                text: 'username_email'.tr,
                color: AppColors.appColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 15),
              CustomTextfield(
                controller: loginController.userNameController,
                hintext: 'username_email'.tr,
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
                  obsecureText: loginController.obscureText.value,
                  controller: loginController.passwordController,
                  hintext: 'password'.tr,
                  suffixIcon: IconButton(
                    onPressed: () {
                      loginController.obscureText.value =
                          !loginController.obscureText.value;
                    },
                    icon:
                        loginController.obscureText.value
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
              SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: AppTextButton(
                  text: 'forgot_password'.tr,
                  onTap: () {
                    Get.to(() => SentEmail());
                  },
                  textColor: AppColors.textPrimaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 27),
              CustomSubmitButton(
                onTap: () async {
                  loginController.login();
                },
                height: 50,
                text: 'login'.tr,
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
    );
  }
}
