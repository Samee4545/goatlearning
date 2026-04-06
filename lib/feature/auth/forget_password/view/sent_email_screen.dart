import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/style/global_text_style.dart';
import 'package:goatlearning/feature/auth/forget_password/controller/forget_password_controller.dart';

class SentEmail extends StatelessWidget {
  SentEmail({super.key});
  final ForgetPasswordController controller = Get.put(
    ForgetPasswordController(),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Find Your Account',
              style: globalTextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Email",
                style: globalTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 10),
            TextFormField(
              controller: controller.emailController,
              decoration: InputDecoration(
                fillColor: Color(0xffF5F9FA),
                filled: true,
                border: InputBorder.none,

                hintText: 'Email',
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: Color(0xff5EAEB5),
                ),
                onPressed: () {
                  controller.forgetPassword();
                },
                child: Text(
                  'Send',
                  style: globalTextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Color(0xff5EAEB5), width: 1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  Get.back();
                },
                child: Text(
                  'Cancel',
                  style: globalTextStyle(
                    color: Color(0xff5EAEB5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
