import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/app_sizes.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/core/global_widegts/custom_submit_button.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/global_widegts/custom_textfield.dart';
import 'package:goatlearning/feature/auth/forget_password/controller/forget_password_controller.dart';

class ForgetPasswordScreen extends StatelessWidget {
  ForgetPasswordScreen({super.key});

  final ForgetPasswordController forgetPasswordController = Get.put(
    ForgetPasswordController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: getHeight(229),
            horizontal: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "Forgot password",
                color: Color(0xff173156),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 24),
              CustomText(
                text: "New Password",
                color: AppColors.textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 15),
              Obx(
                () => CustomTextfield(
                  obsecureText: forgetPasswordController.obscureText.value,
                  controller: forgetPasswordController.newPasswordController,
                  hintext: "New Password",
                  suffixIcon: IconButton(
                    onPressed: () {
                      forgetPasswordController.obscureText.value =
                          !forgetPasswordController.obscureText.value;
                    },
                    icon:
                        forgetPasswordController.obscureText.value
                            ? Image.asset(
                              IconsPath.lock,
                              height: 14.25,
                              width: 16.5,
                            )
                            : const Icon(
                              Icons.visibility,
                              size: 16,
                              color: Colors.grey,
                            ),
                  ),
                ),
              ),
              SizedBox(height: 17),
              CustomText(
                text: "Confirm Password",
                color: AppColors.textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 15),
              Obx(
                () => CustomTextfield(
                  obsecureText: forgetPasswordController.obscureText2.value,
                  controller: forgetPasswordController.conPasswordController,
                  hintext: "Confirm Password",
                  suffixIcon: IconButton(
                    onPressed: () {
                      forgetPasswordController.obscureText2.value =
                          !forgetPasswordController.obscureText2.value;
                    },
                    icon:
                        forgetPasswordController.obscureText2.value
                            ? Image.asset(
                              IconsPath.lock,
                              height: 14.25,
                              width: 16.5,
                            )
                            : const Icon(
                              Icons.visibility,
                              size: 16,
                              color: Colors.grey,
                            ),
                  ),
                ),
              ),

              SizedBox(height: 27),
              CustomSubmitButton(
                onTap: () async {
                  forgetPasswordController.changePassword();
                },
                height: 50,
                text: "Save",
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
