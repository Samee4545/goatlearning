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

class AdminSecurityController extends GetxController {
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
      EasyLoading.showToast("Please enter your current password");
      return;
    }

    if (newPassword.isEmpty) {
      EasyLoading.showToast("Please enter a new password");
      return;
    } else if (newPassword.length < 8) {
      EasyLoading.showToast("Password must be at least 8 characters long");
      return;
    }

    if (confirmPassword.isEmpty) {
      EasyLoading.showToast("Please confirm your new password");
      return;
    } else if (newPassword != confirmPassword) {
      EasyLoading.showToast("New password and confirm password do not match");
      return;
    } else if (currentPassword == newPassword) {
      EasyLoading.showToast("New password must be different from the old one.");
      return;
    }

    // Add changed password logic here
    try {
      EasyLoading.show(status: 'Loading...');

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
        EasyLoading.showSuccess("Password changed successfully.");
        Get.back();
      } else {
        var errorData = jsonDecode(response.body);
        EasyLoading.showError(
          errorData['message'] ?? "Failed to change password",
        );
      }
    } on SocketException {
      log("No Internet connection");
      EasyLoading.showError(
        "No Internet connection. Please check your network.",
      );
    } on TimeoutException {
      log("Request timed out");
      EasyLoading.showError(
        "Server is taking too long to respond. Please try again later.",
      );
    } on HttpException {
      log("HTTP Exception occurred");
      EasyLoading.showError("Something went wrong. Please try again.");
    } on FormatException {
      log("Invalid JSON format");
      EasyLoading.showError("Server response was not in the expected format.");
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    } finally {
      EasyLoading.dismiss();
    }
  }
}
