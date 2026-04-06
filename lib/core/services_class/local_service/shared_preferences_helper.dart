// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharePref {
  static const String _userDataKey = 'user-data';
  static const String _rememberMeKey = 'remember-me';
  static const String _emailKey = 'email';
  static const String _nameKey = 'name';
  static const String _passwordKey = 'password';
  static const String _tokenKey = 'token';
  static const String _idKey = 'id';
  static const String _fcmTokenKey = 'fcm-token';
  static const String _subcriptionKey = 'subcription';
  static const String _roleKey = 'role';
  static const String _uid = 'uid';
  static const String _accessGroupKey = 'accessGroup';
  static const String _guestKey = 'guest';
  static const String _localFavouritesKey = 'local_favourites';

  static bool rememberMe = false;
  static String? savedEmail;
  static String? savedName;
  // static String? savedPassword;
  static String? token;

  static Future<void> saveFcmToken(String token) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(_fcmTokenKey, token);
  }

  // Method to get FCM token
  static Future<String?> getFcmToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(_fcmTokenKey);
  }

  static Future<void> storeUserData(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save userData as JSON string
    String userDataString = json.encode(userData);
    await prefs.setString('userData', userDataString);

    print("UserData Stored: $userDataString"); // Add this line to verify data
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');

    if (userDataString != null) {
      try {
        // Decode the JSON string into a map
        return Map<String, dynamic>.from(json.decode(userDataString));
      } catch (e) {
        print("Error decoding userData: $e");
      }
    }
    return null;
  }

  // Get saved email
  static Future<String?> getSavedEmail() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(_emailKey);
  }

  static Future<String?> getSavedName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(_nameKey); // Retrieve the name
  }

  static Future<void> saveToken(String token) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(_tokenKey, token);
  }

  // Get saved token
  static Future<String?> getSavedToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(_tokenKey); // Retrieve token
  }

  static Future<void> saveAccessGroup(List<String> accessGroup) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setStringList(_accessGroupKey, accessGroup);
  }

  // Retrieve saved access group as a list of strings
  static Future<List<String>?> getAccessGroup() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getStringList(_accessGroupKey); // Retrieve list
  }

  static Future<void> saveSubcription(bool subscription) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(_subcriptionKey, subscription);
  }

  static Future<bool?> getSavedSubcription() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(_subcriptionKey); // Retrieve subscription
  }

  static Future<void> saveRole(String role) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(_roleKey, role);
    print("Role saved: $role"); // Add this to verify the role is saved
  }

  static Future<String?> getSavedRole() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? role = sharedPreferences.getString(_roleKey);
    print("Fetched role: $role"); // Add this to verify the fetched role
    return role;
  }

  static Future<void> saveUserId(String id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(_idKey, id);
  }

  static Future<String?> getSavedUserId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(_idKey);
  }

  // Method to clear all saved preferences (clearAll)
  static Future<void> saveGuest(bool isGuest) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(_guestKey, isGuest);
  }

  static Future<bool?> getSavedGuest() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(_guestKey);
  }

  static Future<void> clearAll() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove(_userDataKey);
    await sharedPreferences.remove(_rememberMeKey);
    await sharedPreferences.remove(_emailKey);
    await sharedPreferences.remove(_passwordKey);
    await sharedPreferences.remove(_tokenKey);
    await sharedPreferences.remove(_fcmTokenKey);
    await sharedPreferences.remove(_subcriptionKey);
    await sharedPreferences.remove(_roleKey);
    await sharedPreferences.remove(_uid);
    await sharedPreferences.remove(_idKey);
    await sharedPreferences.remove(_guestKey);
    // Note: guest_favourites is intentionally NOT removed to persist local favourites
  }

  // Persistent local favourites cache (chapter IDs).
  // Used to keep favourites visible after app restarts and as a fallback
  // when the remote favourites endpoint is unavailable.
  static Future<List<String>> getLocalFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_localFavouritesKey) ?? <String>[];
  }

  static Future<void> saveLocalFavourites(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    // Store unique, non-empty IDs
    final unique = <String>{};
    for (final id in ids) {
      final v = id.trim();
      if (v.isNotEmpty) unique.add(v);
    }
    await prefs.setStringList(_localFavouritesKey, unique.toList());
  }

  static Future<void> addLocalFavourite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final v = id.trim();
    if (v.isEmpty) return;
    final current = (prefs.getStringList(_localFavouritesKey) ?? <String>[])
        .map((e) => e.toString())
        .toSet();
    current.add(v);
    await prefs.setStringList(_localFavouritesKey, current.toList());
  }

  static Future<void> removeLocalFavourite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final v = id.trim();
    if (v.isEmpty) return;
    final current = (prefs.getStringList(_localFavouritesKey) ?? <String>[])
        .map((e) => e.toString())
        .toSet();
    current.remove(v);
    await prefs.setStringList(_localFavouritesKey, current.toList());
  }
}
