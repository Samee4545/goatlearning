// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/network_caller/endpoints.dart';
import 'package:goatlearning/core/route/routes.dart';
import 'package:goatlearning/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:goatlearning/feature/user/favorite/controller/favourite_controller.dart';
import 'package:goatlearning/feature/user/home/controller/home_controller.dart';
import 'package:goatlearning/feature/user/profile/model/complete_model.dart';
import 'package:goatlearning/feature/user/profile/model/profile_model.dart';
import 'package:goatlearning/feature/user/profile/model/time_model.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileController extends GetxController {
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController proffessionController = TextEditingController();
  TextEditingController classController = TextEditingController();

  var profileImage = Rx<File?>(null);
  var networkImage = Rx<String?>(null);

  var percentage = Rxn<CompleteModel>();

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
      networkImage.value = null;
    }
  }

  Future<void> updateProfile() async {
    EasyLoading.show(status: 'loading'.tr);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString('token');

    var dataFields = {
      "data": jsonEncode({
        "username": userNameController.text.trim(),
        "email": emailController.text.trim(),
        "phoneNumber": phoneNumberController.text.trim(),
        "profession": proffessionController.text.trim(),
        "class": classController.text.trim(),
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
        EasyLoading.showSuccess('profile_update_success'.tr);
        Get.back();
        fetchProfile();
      } else {
        EasyLoading.showError('profile_update_failed'.tr);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      EasyLoading.showError('generic_error'.tr);
    } finally {
      EasyLoading.dismiss();
    }
  }

  var profile = Rxn<ProfileModel>();

  Future<void> fetchProfile() async {
    try {
      final String? token = await SharePref.getSavedToken();

      // Skip profile fetch if no token (guest user)
      if (token == null || token.isEmpty) {
        if (kDebugMode) print("No token found, skipping profile fetch");
        return;
      }

      final url = Urls.profile;
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": token, "Content-Type": "application/json"},
      );

      if (kDebugMode) {
        print("Access token: $token");
        print("user profile ${response.body}");
      }

      if (response.statusCode == 201) {
        var responseBody = json.decode(response.body);
        profile.value = ProfileModel.fromJson(responseBody['data']);
      }
    } catch (e) {
      if (kDebugMode) print("user profile $e");
      // Don't show error to user for profile fetch failures
    } finally {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }

  Future<void> completePercentage() async {
    try {
      final String? token = await SharePref.getSavedToken();
      final url = Urls.userPercentage;

      if (token == null || token.isEmpty) {
        if (kDebugMode) print("No token found, skipping percentage fetch");
        return;
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": token, "Content-Type": "application/json"},
      );

      print("Access token: $token");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        print("Decoded Response: $responseBody");
        percentage.value = CompleteModel.fromJson(responseBody);
        percentage.refresh();
      } else {
        print("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching user percentage: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> logout() async {
    try {
      await SharePref.clearAll();

      // Delete user controllers to clear their state
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.userChapter.clear();
        homeController.filterChapter.clear();
        homeController.allExercises.clear();
        homeController.exerciseGroups.clear();
        homeController.contentList.clear();
        homeController.filteredContent.clear();
      }

      if (Get.isRegistered<FavouriteController>()) {
        Get.delete<FavouriteController>();
      }

      // After logout, return to main app screen (guest user view)
      Get.offAllNamed(AppRoutes.userNavBar);
      
      // Re-initialize FavouriteController for guest mode
      Get.put(FavouriteController());
      EasyLoading.showSuccess('logout_success'.tr);
    } catch (e) {
      if (kDebugMode) print("logout $e");
      EasyLoading.showError('generic_error'.tr);
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    completePercentage();

    ever(profile, (ProfileModel? newProfile) {
      if (newProfile != null) {
        userNameController.text = newProfile.username ?? 'unknown'.tr;
        emailController.text = newProfile.email ?? 'default_email'.tr;
        phoneNumberController.text =
            newProfile.phoneNumber ?? 'not_available'.tr;
        proffessionController.text =
            newProfile.profession ?? 'not_available'.tr;
        classController.text = newProfile.sector ?? 'not_available'.tr;
        networkImage.value = newProfile.profileImage;
      }
    });
  }

  Rx<StatusTimeModel?> percentages = Rx<StatusTimeModel?>(null);

  Future<void> percent() async {
    try {
      EasyLoading.show(status: 'loading'.tr);

      final String? token = await SharePref.getSavedToken();
      if (token == null) {
        print("Token is null");
        EasyLoading.dismiss();
        return;
      }

      final url = "${Urls.baseUrl}/users/get-time-status";

      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": token, "Content-Type": "application/json"},
      );

      print("Response Status: ${response.statusCode}");
      print("Response Bodyjhghfghg: ${response.body}");

      if (response.statusCode == 200) {
        try {
          percentages.value = StatusTimeModel.fromJson(response.body);
          percentages.refresh();
        } catch (e) {
          print("JSON Parsing Error: $e");
        }
      } else {
        print("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching user percentage: $e");
    } finally {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    }
  }
}
