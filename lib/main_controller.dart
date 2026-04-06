// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get.dart';
import 'package:goatlearning/core/network_caller/endpoints.dart';
import 'package:goatlearning/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UsageController extends GetxController {
  DateTime? _startTime;
  var launchCount = 0.obs;
  var totalActiveTimeMin = 0.obs; // Store active time in minutes

  @override
  void onInit() {
    super.onInit();
    _loadAppData();
  }

  Future<void> _loadAppData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    launchCount.value = (prefs.getInt('launchCount') ?? 0) + 1;
    await prefs.setInt('launchCount', launchCount.value);

    totalActiveTimeMin.value = (prefs.getInt('totalActiveTime') ?? 0) ~/ 60;

    _startTime = DateTime.now();

    print("App Started at: $_startTime");
    print("Total Launch Count: ${launchCount.value}");
  }

  Future<void> saveUsageTime() async {
    if (_startTime == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int previousActiveTime = prefs.getInt('totalActiveTime') ?? 0;

    int sessionTime = DateTime.now().difference(_startTime!).inSeconds;

    int updatedActiveTime = previousActiveTime + sessionTime;
    totalActiveTimeMin.value = updatedActiveTime ~/ 60;

    await prefs.setInt('totalActiveTime', updatedActiveTime);

    print("App Closed at: ${DateTime.now()}");
    print("Session Time: ${sessionTime ~/ 60} min");
    print("Total Active Time: ${totalActiveTimeMin.value} min");

    try {
      final String? token = await SharePref.getSavedToken();

      final response = await http.post(
        Uri.parse("${Urls.baseUrl}/users/add-time"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "$token",
        },
        body: json.encode({'time': totalActiveTimeMin.value}),
      );

      var data = json.decode(response.body);

      print("Response time: $data");
    } catch (e) {
      print('Error saving usage time: $e');
    }
  }
}
