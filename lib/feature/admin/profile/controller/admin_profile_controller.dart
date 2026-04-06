// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/network_caller/endpoints.dart';
import 'package:goatlearning/core/route/routes.dart';
import 'package:goatlearning/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:goatlearning/feature/admin/edit/controller/admin_edit_controller.dart';
import 'package:goatlearning/feature/user/favorite/controller/favourite_controller.dart';
import 'package:goatlearning/feature/user/profile/model/profile_model.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminProfileController extends GetxController {
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var profileImage = Rx<File?>(null);
  var networkImage = Rx<String?>(null);

  var profile = Rxn<ProfileModel>();

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
      networkImage.value = null;
    }
  }

  Future<void> fetchProfile() async {
    try {
      final String? token = await SharePref.getSavedToken();
      final url = Urls.profile;
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "$token",
          "Content-Type": "application/json",
        },
      );
      print("Acess token $token");
      print("admin profile ${response.body}");
      if (response.statusCode == 201) {
        var responseBody = json.decode(response.body);
        profile.value = ProfileModel.fromJson(responseBody['data']);
      }
    } catch (e) {
      print("admin profile $e");
    }
  }

  Future<void> logout() async {
    try {
      await SharePref.clearAll();

      // Delete admin controllers to clear their state
      if (Get.isRegistered<AdminEditController>()) {
        Get.delete<AdminEditController>();
      }

      // Delete FavouriteController so it reinitializes properly
      if (Get.isRegistered<FavouriteController>()) {
        Get.delete<FavouriteController>();
      }

      // After logout, return to main app screen (guest user view)
      Get.offAllNamed(AppRoutes.userNavBar);
      
      // Re-initialize FavouriteController for guest mode
      Get.put(FavouriteController());
      
      EasyLoading.showSuccess("Logged out successfully");
    } catch (e) {
      print("logout $e");
    }
  }

  // admin update profile
  Future<void> adminUpdateProfile() async {
    EasyLoading.show(status: 'Loading..');

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString('token');

    var dataFields = {
      "data": jsonEncode({
        "username": nameController.text.trim(),
        "email": emailController.text.trim(),
        "phoneNumber": phoneNumberController.text.trim(),
      }),
    };

    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse(Urls.userUpdateProfile),
      );

      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': "$token",
      });

      request.fields.addAll(dataFields);

      if (profileImage.value != null) {
        var imageBytes = await profileImage.value!.readAsBytes();
        var imageFile = http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: profileImage.value!.path.split('/').last,
        );
        request.files.add(imageFile);
      }

      final response = await request.send();
      if (kDebugMode) {
        print("Response body: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        EasyLoading.showSuccess('Admin profile updated successfully.');
        Get.back();
        fetchProfile();
      } else {
        EasyLoading.showError('Failed to admin update profile.');
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
        print(e);
      }
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    ever(profile, (ProfileModel? newProfile) {
      if (newProfile != null) {
        nameController.text = newProfile.username ?? "Unknown";
        emailController.text = newProfile.email ?? "xyz@gmail.com";
        phoneNumberController.text = newProfile.phoneNumber ?? "N/A";
        networkImage.value = newProfile.profileImage;
      }
    });
  }
}
