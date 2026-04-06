// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/network_caller/endpoints.dart';
import 'package:goatlearning/core/services_class/local_service/shared_preferences_helper.dart';

import 'package:http/http.dart' as http;

class HelpSupportController extends GetxController {
  var helpController = TextEditingController();

  Future<void> helpSupport() async {
    try {
      EasyLoading.show(status: 'loading'.tr);
      final url = Urls.helpSupport;

      final String? token = await SharePref.getSavedToken();

      final Map<String, String> inputData = {
        "text": helpController.text.trim(),
      };

      log('add exercise: $url');
      log('Input Data (JSON): ${jsonEncode(inputData)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "$token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(inputData),
      );

      log("add exercise ${response.statusCode}");
      log("add exercise: ${response.body}");

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        helpController.clear();
        Get.back();
        EasyLoading.showSuccess(responseData["message"]);
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
      log("add exercise error: $e");
      EasyLoading.showError('generic_error'.tr);
    } finally {
      EasyLoading.dismiss();
    }
  }
}
