import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:goatlearning/core/network_caller/endpoints.dart';
import 'package:goatlearning/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:http/http.dart' as http;

class UserBootstrapService {
  UserBootstrapService._();
  static final UserBootstrapService instance = UserBootstrapService._();

  /// Initializes a unique user ID on first app launch and registers it
  /// to the backend via `/auth/register-by-userid`.
  Future<void> ensureUserRegistered() async {
    // Try to load existing local userId
    String? userId = await SharePref.getSavedUserId();
    bool? isPremium = await SharePref.getSavedSubcription();

    if (userId == null || userId.isEmpty) {
      userId = _generateUuidV4();
      await SharePref.saveUserId(userId);
      if (kDebugMode) {
        print('Generated new userId: $userId');
      }
    }

    // Attempt server registration (idempotent upsert according to spec)
    try {
      final body = {'userId': userId, if (isPremium == true) 'isPayment': true};

      final response = await http.post(
        Uri.parse('${Urls.baseUrl}/auth/register-by-userid'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (kDebugMode) {
        print('register-by-userid status: ${response.statusCode}');
        print('register-by-userid body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Persist any returned user data if present
        try {
          final jsonRes = jsonDecode(response.body);
          if (jsonRes is Map<String, dynamic> && jsonRes['data'] != null) {
            final data = jsonRes['data'] as Map<String, dynamic>;
            await SharePref.storeUserData(data);
          }
        } catch (_) {}
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error calling register-by-userid: $e');
      }
    }
  }

  /// Update server-side isPayment flag based on local premium state.
  Future<void> syncPaymentStatus() async {
    final userId = await SharePref.getSavedUserId();
    final isPremium = await SharePref.getSavedSubcription();
    if (userId == null || userId.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('${Urls.baseUrl}/auth/register-by-userid'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'isPayment': isPremium == true}),
      );
      if (kDebugMode) {
        print('syncPaymentStatus status: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error syncing payment: $e');
    }
  }

  String _generateUuidV4() {
    final rand = Random.secure();
    String gen(int bytes) {
      final list = List<int>.generate(bytes, (_) => rand.nextInt(256));
      return list.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    }

    final a = gen(4);
    final b = gen(2);
    final c = (rand.nextInt(16) & 0x0f | 0x40).toRadixString(16); // version 4
    final d = gen(1);
    final e = ((rand.nextInt(64) & 0x3f) | 0x80).toRadixString(16); // variant
    final f = gen(1);
    final g = gen(6);
    return '$a-$b-$c$d-$e$f-$g';
  }
}
