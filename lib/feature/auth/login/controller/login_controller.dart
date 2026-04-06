// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/network_caller/endpoints.dart';
import 'package:goatlearning/core/route/routes.dart';
import 'package:goatlearning/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  RxBool obscureText = true.obs;

  Future<void> login() async {
    try {
      EasyLoading.show(status: 'loading'.tr);
      final url = Urls.login;
      String email = userNameController.text.trim();
      String password = passwordController.text.trim();
      if (email.isEmpty) {
        EasyLoading.showToast('enter_username_email'.tr);
        return;
      } else if (password.isEmpty) {
        EasyLoading.showToast('enter_password'.tr);
        return;
      } else if (password.length < 8) {
        EasyLoading.showToast('password_min_length_login'.tr);
        return;
      }
      final Map<String, String> inputData = {
        "email": email,
        "password": password,
      };

      log('Request URL: $url');
      log('Input Data (JSON): ${jsonEncode(inputData)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(inputData),
      );

      log("Response Status Code: ${response.statusCode}");
      log("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        String accessToken = responseData["data"]["token"];
        String role = responseData["data"]["role"];
        log("Access Token: $accessToken");
        log("Access role: $role");
        await SharePref.saveToken(accessToken);
        await SharePref.saveRole(role);
        await SharePref.saveGuest(false);
        if (role == "USER") {
          Get.offAllNamed(AppRoutes.userNavBar);
        } else {
          Get.offAllNamed(AppRoutes.adminNavBar);
        }
      } else {
        var responseData = jsonDecode(response.body);
        EasyLoading.showError(responseData["message"]);
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
      log("Unexpected error: $e");
      EasyLoading.showError('generic_error'.tr);
    } finally {
      EasyLoading.dismiss();
    }
  }

  void guestLogin() async {
    try {
      final url = "${Urls.baseUrl}/auth/gest-login";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );

      log("Response Status Code: ${response.statusCode}");
      log("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        String accessToken = responseData["data"]["token"];
        String role = responseData["data"]["role"];
        log("Access Token: $accessToken");
        log("Access role: $role");
        await SharePref.saveToken(accessToken);
        await SharePref.saveRole(role);
        await SharePref.saveGuest(true);
        Get.offAllNamed(AppRoutes.userNavBar);
      } else {
        var responseData = jsonDecode(response.body);
        EasyLoading.showError(responseData["message"]);
      }
    } catch (e) {
      log("Error during guest login: $e");
      EasyLoading.showError('try_again_later'.tr);
    } finally {
      // Dismiss any loading indicator if needed
    }
  }
}
