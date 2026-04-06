import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/network_caller/endpoints.dart';
import 'package:goatlearning/feature/auth/forget_password/view/forget_password_screen.dart';
import 'package:goatlearning/feature/auth/forget_password/view/otp_screen.dart';
import 'package:goatlearning/feature/auth/login/view/login_screen.dart';
import 'package:http/http.dart' as http;

class ForgetPasswordController extends GetxController {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController conPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  RxBool obscureText = true.obs;
  RxBool obscureText2 = true.obs;

  Future<bool> register() async {
    String newPassword = newPasswordController.text.trim();
    String confirmPassword = conPasswordController.text.trim();

    if (newPassword.isEmpty) {
      EasyLoading.showToast("Please enter your password");
      return false;
    } else if (newPassword.length < 8) {
      EasyLoading.showToast("Password must be at least 8 characters long");
      return false;
    }

    if (confirmPassword.isEmpty) {
      EasyLoading.showToast("Please confirm your password");
      return false;
    } else if (newPassword != confirmPassword) {
      EasyLoading.showToast("Passwords do not match");
      return false;
    }

    return true;
  }

  TextEditingController otpController = TextEditingController();

  var countdown = 300.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  void startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    countdown.value = 300;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown.value == 0) {
        timer.cancel();
      } else {
        countdown.value--;
      }
    });
  }

  String get timerText {
    int minutes = countdown.value ~/ 60;
    int seconds = countdown.value % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  //================================== Forget password ===================================
  Future<void> forgetPassword() async {
    String email = emailController.text.trim();

    if (kDebugMode) {
      print("Email: $email");
    }

    if (email.isEmpty) {
      EasyLoading.showError("Please Enter Your Email");
      return;
    }

    try {
      EasyLoading.show(status: "loading");

      var response = await http.post(
        Uri.parse("${Urls.baseUrl}/auth/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (kDebugMode) {
        print("Forget password Statu code: ${response.statusCode}");
      }

      if (kDebugMode) {
        print("Body: ${response.body}");
      }

      var responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        EasyLoading.showSuccess("Otp Sent Successfully".tr);
        Get.to(() => ForgotOtpScreen());
      } else {
        EasyLoading.showError(
          responseData["message"] ?? "failed to send otp".tr,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    } finally {
      EasyLoading.dismiss();
    }
  }

  //==================================== otp screen ====================================
  Future<void> resendOtp(String email) async {
    if (kDebugMode) {
      print("Sending OTP verification for email: '$email'");
    }

    int otp = int.tryParse(otpController.text.trim()) ?? -1;

    if (otp < 0) {
      EasyLoading.showError("invalid Otp Please Enter a valid number");
      return;
    }
    try {
      EasyLoading.show(status: 'loading');
      final body = json.encode({"email": email, "otp": otp});

      if (kDebugMode) {
        print("///////////////////////otpfgdhfgh$body");
      }

      final response = await http.post(
        Uri.parse("${Urls.baseUrl}/auth/verify-otp"),
        body: body,
        headers: {"Content-Type": "application/json"},
      );

      if (kDebugMode) {
        print("////////////////////fgfgg${response.body}");
      }
      if (response.statusCode == 200) {
        Get.to(() => ForgetPasswordScreen());
      } else {
        if (kDebugMode) {
          print('Failed to resend otp!');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      EasyLoading.dismiss();
    }
  }

  //===============================Change password===============================
  Future<void> changePassword() async {
    try {
      EasyLoading.show(status: 'loading');
      final body = json.encode({
        "email": emailController.text.trim(),
        "password": newPasswordController.text.trim(),
      });

      final response = await http.post(
        Uri.parse("${Urls.baseUrl}/auth/reset-password"),
        body: body,
        headers: {"Content-Type": "application/json"},
      );

      if (kDebugMode) {
        print("////////////////////${response.body}");
      }
      if (response.statusCode == 200) {
        Get.offAll(() => LoginScreen());
      } else {
        if (kDebugMode) {
          print('Failed to resend otp!');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      EasyLoading.dismiss();
    }
  }

  //===============================Resend OTP===============================
  Future<void> sendOTP() async {
    try {
      EasyLoading.show(status: 'loading');
      final body = json.encode({"email": emailController.text.trim()});

      final response = await http.post(
        Uri.parse(Urls.resendOtp),
        body: body,
        headers: {"Content-Type": "application/json"},
      );

      if (kDebugMode) {
        print("Resend OTP${response.body}");
      }
      if (response.statusCode == 200) {
      } else {
        if (kDebugMode) {
          print('Failed to resend otp!');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      EasyLoading.dismiss();
    }
  }
}
