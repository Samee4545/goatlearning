// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/network_caller/endpoints.dart';
import 'package:goatlearning/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:goatlearning/feature/admin/setting/manage_admin/model/admin_list_model.dart';
import 'package:http/http.dart' as http;

class AddAdminController extends GetxController {
  TextEditingController adminNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var adminList = Rx<AdminListModel?>(null);

  RxBool obscureText = true.obs;

  @override
  void onInit() {
    fetchAdminList();
    super.onInit();
  }

  Future<void> fetchAdminList() async {
    try {
      final String? token = await SharePref.getSavedToken();
      final url = Urls.getAdminList;
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "$token",
          "Content-Type": "application/json",
        },
      );
      print("Acess token $token");
      print("admin list ${response.body}");
      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        adminList.value = AdminListModel.fromJson(responseBody);
      }
    } catch (e) {
      print("admin list $e");
    }
  }

  Future<void> addAdmin() async {
    try {
      EasyLoading.show(status: "Loading...");
      final url = Urls.addAdmin;
      String name = adminNameController.text.trim();
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      if (email.isEmpty) {
        EasyLoading.showToast("Please enter admin name");
        return;
      } else if (email.isEmpty) {
        EasyLoading.showToast("Please enter admin email");
        return;
      } else if (password.isEmpty) {
        EasyLoading.showToast("Please enter admin password");
        return;
      } else if (password.length < 8) {
        EasyLoading.showToast("Password can't be less than 8 character");
        return;
      }
      final String? token = await SharePref.getSavedToken();
      final Map<String, String> inputData = {
        "username": name,
        "email": email,
        "password": password,
      };

      log('Request URL: $url');
      log('Input Data (JSON): ${jsonEncode(inputData)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "$token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(inputData),
      );

      log("Response Status Code: ${response.statusCode}");
      log("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        fetchAdminList();
        adminNameController.clear();
        emailController.clear();
        passwordController.clear();
        Get.back();
        EasyLoading.showSuccess(responseData["message"]);
      } else {
        var responseData = jsonDecode(response.body);
        EasyLoading.showError(responseData["message"]);
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
      log("Unexpected error: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> deleteAdmin(String id) async {
    try {
      EasyLoading.show(status: "loading..");
      final String? token = await SharePref.getSavedToken();
      final url = "${Urls.deleteAdmin}/$id";

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          "Authorization": "$token",
          "Content-Type": "application/json",
        },
      );

      print("admin delete url $url");
      print("admin delete ${response.body}");
      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        EasyLoading.showSuccess(responseBody["message"]);
        fetchAdminList();
      }
    } catch (e) {
      print("delete admin $e");
    } finally {
      EasyLoading.dismiss();
    }
  }
}
