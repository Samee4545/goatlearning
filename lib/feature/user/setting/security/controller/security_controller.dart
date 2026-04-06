import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/network_caller/endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SecurityController extends GetxController {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  RxBool obscureText = true.obs;
  RxBool obscureText2 = true.obs;

  Future<void> changePassword() async {
    String currentPassword = currentPasswordController.text.trim();
    String newPassword = newPasswordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString('token');

    if (currentPassword.isEmpty) {
      EasyLoading.showToast('enter_current_password'.tr);
      return;
    }

    if (newPassword.isEmpty) {
      EasyLoading.showToast('enter_new_password'.tr);
      return;
    } else if (newPassword.length < 8) {
      EasyLoading.showToast('password_min_length'.tr);
      return;
    }

    if (confirmPassword.isEmpty) {
      EasyLoading.showToast('confirm_new_password'.tr);
      return;
    } else if (newPassword != confirmPassword) {
      EasyLoading.showToast('password_mismatch'.tr);
      return;
    } else if (currentPassword == newPassword) {
      EasyLoading.showToast('password_different'.tr);
      return;
    }

    // Add changed password logic here
    try {
      EasyLoading.show(status: 'loading'.tr);

      final body = json.encode({
        "oldPassword": currentPassword,
        "newPassword": newPassword,
      });

      final response = await http.put(
        Uri.parse(Urls.changePassword),
        body: body,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "$token",
        },
      );

      if (kDebugMode) {
        print("Response Body: ${response.body}");
      }

      if (response.statusCode == 201) {
        EasyLoading.showSuccess('password_change_success'.tr);
        Get.back();
      } else {
        var errorData = jsonDecode(response.body);
        EasyLoading.showError(
          errorData['message'] ?? 'password_change_failed'.tr,
        );
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
