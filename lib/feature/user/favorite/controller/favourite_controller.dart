import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/network_caller/endpoints.dart';
import 'package:goatlearning/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:goatlearning/feature/user/favorite/model/favourite_model.dart';
import 'package:goatlearning/feature/user/home/controller/home_controller.dart';
import 'package:http/http.dart' as http;

class FavouriteController extends GetxController {
  RxList<dynamic> favourite = <dynamic>[].obs;
  var isLoading = false.obs;

  bool _guestHydrating = false;

  String _authHeaderValue(String token, {required bool bearer}) {
    final trimmed = token.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.toLowerCase().startsWith('bearer ')) return trimmed;
    return bearer ? 'Bearer $trimmed' : trimmed;
  }

  @override
  void onInit() {
    super.onInit();
    fetchFavourite();
  }

  // get all Favourite
  Future<void> fetchFavourite() async {
    isLoading.value = true;
    try {
      final String? token = await SharePref.getSavedToken();
      final bool savedGuest = (await SharePref.getSavedGuest()) == true;
      final bool isGuest = savedGuest || token == null || token.isEmpty;
      if (isGuest) {
        // Guest user: build favourites list locally from stored IDs.
        // Note: guest login still has a token, so we must rely on the saved guest flag.
        if (kDebugMode) print('FavouriteController: Guest mode detected');

        final HomeController home =
            Get.isRegistered<HomeController>()
                ? Get.find<HomeController>()
                : Get.put(HomeController());

        // Ensure guest favourite IDs are loaded from storage.
        await home.loadGuestFavouritesPublic();

        final Set<String> favIds = Set<String>.from(home.guestFavouriteIds);
        if (kDebugMode) {
          print('HomeController guest favourites IDs: ${favIds.toList()}');
        }

        if (favIds.isEmpty) {
          favourite.clear();
          return;
        }

        // If the app just restarted and HomeController hasn't finished fetching
        // chapters yet, hydrate them once so the favourites page can show data.
        if (!_guestHydrating && home.userChapter.isEmpty) {
          _guestHydrating = true;
          try {
            await home.getAllChapter();
            // Also load chapters from folders so folder favorites appear
            await home.fetchChaptersInFolders();
          } finally {
            _guestHydrating = false;
          }
        }

        final Map<String, FavouriteChapter> byId = {};

        // Prefer full chapter details from `userChapter` (covers chapters inside folders too).
        for (final ch in home.userChapter) {
          if (favIds.contains(ch.id)) {
            byId[ch.id] = FavouriteChapter(
              id: ch.id,
              chapterName: ch.chapterName,
              coverImage: ch.coverImage,
              isFavorite: true,
              theory: ch.theory,
            );
          }
        }

        // Also merge from contentList (standalone chapters) in case userChapter is not hydrated yet.
        for (final item in home.contentList) {
          final id = (item.chapterId ?? item.id ?? '').toString();
          if (id.isEmpty) continue;
          if (!favIds.contains(id)) continue;
          byId[id] = FavouriteChapter(
            id: id,
            chapterName: item.chapterName ?? '',
            coverImage: item.coverImage ?? '',
            isFavorite: true,
            theory: item.theory,
          );
        }

        // Only show items that we can resolve to a real chapter (name/image).
        favourite.assignAll(byId.values.toList());
        if (kDebugMode) {
          print('Guest favourites hydrated: ${favourite.length} chapters');
        }
        return;
      }

      final url = Urls.fetchFavourite;
      http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': _authHeaderValue(token!, bearer: false),
          'Content-Type': 'application/json',
        },
      );

      // Some backends require `Authorization: Bearer <token>`.
      // If we get 401/403, retry once with Bearer.
      if (response.statusCode == 401 || response.statusCode == 403) {
        if (kDebugMode) {
          print('fetchFavourite: retrying with Bearer token');
        }
        response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': _authHeaderValue(token, bearer: true),
            'Content-Type': 'application/json',
          },
        );
      }

      if (kDebugMode) {
        print("Access token: $token");
        print("Favourite status: ${response.statusCode}");
        print("Favourite: ${response.body}");
      }

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        if (kDebugMode)
          print('Auth favourites raw response: ${responseBody['data']}');
        List<Map<String, dynamic>> resultArray =
            List<Map<String, dynamic>>.from(responseBody['data']);

        if (resultArray.isEmpty) {
          if (kDebugMode) {
            print(
              "Auth favourites: Server returned empty list, checking local cache",
            );
          }

          // Use local cache as fallback when server returns empty
          final localIds = (await SharePref.getLocalFavourites()).toSet();
          if (localIds.isEmpty) {
            favourite.clear();
            return;
          }

          if (kDebugMode) {
            print("Using local cache with ${localIds.length} favorites");
          }

          final HomeController home =
              Get.isRegistered<HomeController>()
                  ? Get.find<HomeController>()
                  : Get.put(HomeController());

          // Ensure chapter details are available, including chapters inside folders.
          if (!_guestHydrating && home.userChapter.isEmpty) {
            _guestHydrating = true;
            try {
              await home.getAllChapter();
              // Also load chapters from folders so folder favorites appear
              await home.fetchChaptersInFolders();
            } finally {
              _guestHydrating = false;
            }
          }

          final Map<String, FavouriteChapter> byId = {};
          for (final ch in home.userChapter) {
            if (localIds.contains(ch.id)) {
              byId[ch.id] = FavouriteChapter(
                id: ch.id,
                chapterName: ch.chapterName,
                coverImage: ch.coverImage,
                isFavorite: true,
                theory: ch.theory,
              );
            }
          }
          for (final item in home.contentList) {
            final id = (item.chapterId ?? item.id ?? '').toString();
            if (id.isEmpty) continue;
            if (!localIds.contains(id)) continue;
            byId[id] = FavouriteChapter(
              id: id,
              chapterName: item.chapterName ?? '',
              coverImage: item.coverImage ?? '',
              isFavorite: true,
              theory: item.theory,
            );
          }
          favourite.assignAll(byId.values.toList());
          if (kDebugMode) {
            print(
              'Favourites hydrated from local cache: ${favourite.length} chapters',
            );
          }
        } else {
          // Map only chapter items; folders are not displayed in this screen
          List<FavouriteChapter> favouriteList =
              resultArray
                  .where((map) => (map['type'] ?? 'chapter') == 'chapter')
                  .map(
                    (map) => FavouriteChapter(
                      id: map['id'] ?? map['chapterId'] ?? '',
                      chapterName: map['chapterName'] ?? '',
                      coverImage: map['coverImage'] ?? '',
                      isFavorite: map['isFavorite'] ?? true,
                      theory: map['theory'],
                    ),
                  )
                  .toList();

          favourite.assignAll(favouriteList);
          if (kDebugMode)
            print('Auth favourites hydrated: ${favouriteList.length} chapters');

          // Sync local cache with server truth so favourites survive restart.
          final ids =
              favouriteList
                  .map((e) => e.id)
                  .where((e) => e.isNotEmpty)
                  .toList();
          await SharePref.saveLocalFavourites(ids);
        }
      } else {
        // Handle non-200 response
        if (kDebugMode) {
          print("fetchFavourite failed. Status: ${response.statusCode}");
          print("Body: ${response.body}");
        }

        // Fallback to local cache if server fetch fails.
        final localIds = (await SharePref.getLocalFavourites()).toSet();
        if (localIds.isEmpty) {
          favourite.clear();
          return;
        }

        final HomeController home =
            Get.isRegistered<HomeController>()
                ? Get.find<HomeController>()
                : Get.put(HomeController());

        // Ensure chapter details are available, including chapters inside folders.
        if (!_guestHydrating && home.userChapter.isEmpty) {
          _guestHydrating = true;
          try {
            await home.getAllChapter();
            // Also load chapters from folders so folder favorites appear
            await home.fetchChaptersInFolders();
          } finally {
            _guestHydrating = false;
          }
        }

        final Map<String, FavouriteChapter> byId = {};
        for (final ch in home.userChapter) {
          if (localIds.contains(ch.id)) {
            byId[ch.id] = FavouriteChapter(
              id: ch.id,
              chapterName: ch.chapterName,
              coverImage: ch.coverImage,
              isFavorite: true,
              theory: ch.theory,
            );
          }
        }
        for (final item in home.contentList) {
          final id = (item.chapterId ?? item.id ?? '').toString();
          if (id.isEmpty) continue;
          if (!localIds.contains(id)) continue;
          byId[id] = FavouriteChapter(
            id: id,
            chapterName: item.chapterName ?? '',
            coverImage: item.coverImage ?? '',
            isFavorite: true,
            theory: item.theory,
          );
        }
        favourite.assignAll(byId.values.toList());
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
        print("Error fetching favourite: $e");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavourite(String id) async {
    final String? token = await SharePref.getSavedToken();
    final bool savedGuest = (await SharePref.getSavedGuest()) == true;
    final bool isGuest = savedGuest || token == null || token.isEmpty;
    if (isGuest) {
      // Guest user: delegate to HomeController which handles local storage
      if (kDebugMode)
        print(
          'FavouriteController: Guest toggle, delegating to HomeController',
        );
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().toggleFavourite(id);
        // fetchFavourite will be called by HomeController after toggle
      }
      return;
    }

    try {
      EasyLoading.show(status: "Updating favourite...");
      final response = await http.post(
        Uri.parse(Urls.toggleFavourite),
        headers: {"Content-Type": "application/json", 'Authorization': token},
        body: jsonEncode({"chapterId": id}),
      );

      if (kDebugMode) {
        print("Favourite toggle Status code: ${response.statusCode}");
        print("Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchFavourite();
        final responseData = jsonDecode(response.body);
        EasyLoading.showSuccess(
          responseData["message"] ?? "Favourite updated successfully",
        );
      } else {
        EasyLoading.showError("Failed to update favourite");
      }
    } catch (e) {
      if (kDebugMode) print("Error toggling favourite: $e");
      EasyLoading.showError("An error occurred");
    } finally {
      EasyLoading.dismiss();
    }
  }
}
