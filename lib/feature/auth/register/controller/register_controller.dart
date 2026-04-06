import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/network_caller/endpoints.dart';
import 'package:goatlearning/core/route/routes.dart';
import 'package:http/http.dart' as http;

class RegisterController extends GetxController {
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController conPasswordController = TextEditingController();

  RxBool obscureText = true.obs;
  RxBool obscureText2 = true.obs;

  Future<void> register() async {
    String userName = userNameController.text.trim();
    String email = emailAddressController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = conPasswordController.text.trim();

    if (userName.isEmpty) {
      EasyLoading.showToast('enter_username'.tr);
      return;
    }

    if (email.isEmpty) {
      EasyLoading.showToast('enter_email'.tr);
      return;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      EasyLoading.showToast('enter_valid_email'.tr);
      return;
    }

    if (password.isEmpty) {
      EasyLoading.showToast('enter_password'.tr);
      return;
    } else if (password.length < 8) {
      EasyLoading.showToast('password_min_length'.tr);
      return;
    }

    if (confirmPassword.isEmpty) {
      EasyLoading.showToast('confirm_password'.tr);
      return;
    } else if (password != confirmPassword) {
      EasyLoading.showToast('passwords_not_match'.tr);
      return;
    }

    // Add registration logic here
    try {
      EasyLoading.show(status: 'loading'.tr);
      String url = Urls.register;

      if (kDebugMode) {
        print(
          "Sending data: email=$email, userName=$userName, password=$password",
        );
      }

      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": userName,
          "email": email,
          "password": password,
        }),
      );
      if (kDebugMode) {
        print("register: ${response.statusCode}");
      }
      var responseData = jsonDecode(response.body);
      if (kDebugMode) {
        print("register: ${response.body}");
      }
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (kDebugMode) {
          print("Registration Successful: $data");
        }
        EasyLoading.showSuccess('registration_success'.tr);
        // After successful registration, proceed to app as logged-in or guest as appropriate
        Get.offAllNamed(AppRoutes.userNavBar);
      } else if (response.statusCode == 400) {
        EasyLoading.showError("${responseData['message']}");
      } else {
        EasyLoading.showError('registration_failed'.tr);
        if (kDebugMode) {
          print(
            "Registration Failed: ${response.statusCode} - ${response.body}",
          );
        }
      }
    } on SocketException {
      log("No Internet connection");
      EasyLoading.showError('no_internet_error'.tr);
    } on TimeoutException {
      log("Request timed out");
      EasyLoading.showError('timeout_error'.tr);
    } on HttpException {
      log("HTTP Exception occurred");
      EasyLoading.showError('generic_error'.tr);
    } on FormatException {
      log("Invalid JSON format");
      EasyLoading.showError('format_error'.tr);
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
      EasyLoading.showError('generic_error'.tr);
    } finally {
      EasyLoading.dismiss();
    }
  }
}
