import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/app_sizes.dart';
import 'package:goatlearning/core/global_widegts/app_text_button.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/style/global_text_style.dart';
import 'package:goatlearning/feature/auth/forget_password/controller/forget_password_controller.dart';
import 'package:pinput/pinput.dart';

class ForgotOtpScreen extends StatelessWidget {
  // final String email;

  ForgotOtpScreen({super.key});

  final ForgetPasswordController controller = Get.put(
    ForgetPasswordController(),
    permanent: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: getHeight(219), left: 16, right: 16),
          child: Column(
            children: [
              SizedBox(height: 10),
              Text(
                "Email Verification",
                style: globalTextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text.rich(
                TextSpan(
                  text: 'Code has been send to ',
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(
                      // text: controller.forgetEmailController.text,
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    TextSpan(
                      text: controller.emailController.text,
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.0),
              Pinput(
                length: 4,
                controller: controller.otpController,
                defaultPinTheme: PinTheme(
                  margin: EdgeInsets.only(right: 15),
                  width: 50,
                  height: 50,
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.textPrimaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: getHeight(38)),

              ElevatedButton(
                onPressed: () async {
                  // Get.toNamed(AppRoutes.forgetPassword);
                  controller.resendOtp(controller.emailController.text);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: AppColors.textPrimaryColor,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'Verification',
                  style: globalTextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: getHeight(38)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomText(
                    text: "Didn’t get the otp ",
                    color: AppColors.appColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  AppTextButton(
                    onTap: () {
                      controller.sendOTP();
                    },
                    text: "Resend",
                    textColor: AppColors.textPrimaryColor,
                    fontWeight: FontWeight.w700,
                    //textDecoration: TextDecoration.underline,
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
