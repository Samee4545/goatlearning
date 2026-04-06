import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/network_caller/endpoints.dart';
import 'package:goatlearning/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:goatlearning/feature/admin/edit/controller/admin_edit_controller.dart';
import 'package:goatlearning/feature/user/home/controller/home_controller.dart';
import 'package:goatlearning/feature/user/profile/controller/user_profile_controller.dart';
import 'package:http/http.dart' as http;

class FolderDetailsController extends GetxController {
  late HomeController homeController;
  var chapters = <dynamic>[].obs;
  var filteredChapters = <dynamic>[].obs;
  var isLoading = true.obs;
  var isSearchActive = false.obs;
  final searchController = TextEditingController();
  late String folderId;
  late String folderName;
  late String folderType;
  late bool isAdmin;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    folderId = arguments['folderId'];
    folderName = arguments['folderName'];
    folderType = arguments['foldertype'];
    isAdmin = arguments['isAdmin'] ?? false;
    // Ensure HomeController is available. If not registered (e.g. when navigated
    // from admin screens), register it lazily so FolderDetailsController
    // creation doesn't throw.
    homeController =
        Get.isRegistered<HomeController>()
            ? Get.find()
            : Get.put(HomeController());
    _initAndFetch();
  }

  Future<void> _initAndFetch() async {
    // Ensure favorites are loaded first so we can merge them with chapter data
    if (!isAdmin) {
      await homeController.favouriteController.fetchFavourite();
    }
    await fetchChapters();
  }

  Future<void> fetchChapters() async {
    try {
      isLoading(true);
      final String? token = await SharePref.getSavedToken();
      final bool savedGuest = (await SharePref.getSavedGuest()) == true;
      final bool isGuest = savedGuest || token == null || token.isEmpty;
      final uri = Uri.parse(
        '${Urls.baseUrl}/content/folder/$folderId/chapters',
      );
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = token;
      }

      final response = await http.get(uri, headers: headers);
      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> rawChapters = data['data'];

          // Build a set of favorite chapter IDs for quick lookup
          Set<String> favoriteIds = {};

          // Always include locally cached favourites so stars persist after restart.
          final localFavs = await SharePref.getLocalFavourites();
          favoriteIds.addAll(localFavs);

          if (isGuest) {
            // Guest mode: use local guest favorites
            favoriteIds = Set.from(homeController.guestFavouriteIds);
            favoriteIds.addAll(localFavs);
          } else {
            // Authenticated user: get favorites from FavouriteController
            for (final fav in homeController.favouriteController.favourite) {
              final favId = fav is Map ? fav['id'] : (fav.id ?? '');
              if (favId.isNotEmpty) {
                favoriteIds.add(favId);
              }
            }
          }

          if (kDebugMode) {
            print('Favorite IDs for merge: $favoriteIds');
          }

          // Merge isFavorite status into each chapter.
          // Important: some backends always return `isFavorite: false` for folder chapters,
          // so we must derive it from the favourites list instead of trusting the response.
          final List<Map<String, dynamic>> mergedChapters =
              rawChapters.map((chapter) {
                final chapterMap = Map<String, dynamic>.from(chapter);
                final String chapterId =
                    (chapterMap['id'] ??
                            chapterMap['_id'] ??
                            chapterMap['chapterId'] ??
                            '')
                        .toString();

                // Normalize id so the rest of the UI always uses `id`.
                if (chapterId.isNotEmpty) {
                  chapterMap['id'] = chapterId;
                }

                // Source of truth: local favourites (guest) or fetched favourites (auth).
                chapterMap['isFavorite'] = favoriteIds.contains(chapterId);
                return chapterMap;
              }).toList();

          if (kDebugMode) {
            print('Merged chapters with favorites:');
            for (final ch in mergedChapters) {
              print('  ${ch['id']}: isFavorite=${ch['isFavorite']}');
            }
          }

          chapters.value = mergedChapters;
          filteredChapters.value = List.from(mergedChapters);
        } else {
          Get.snackbar('Error', data['message'] ?? 'Failed to fetch chapters');
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch chapters');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading(false);
    }
  }

  void filterList(String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (query.isEmpty) {
      filteredChapters.value = chapters;
    } else {
      filteredChapters.value =
          chapters.where((chapter) {
            final chapterName =
                (chapter['chapterName'] ?? '').toString().toLowerCase();
            final matchesTheory =
                _matchesPdfQuery(chapter['theory'], normalizedQuery) ||
                (chapter['theoryFileName'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(normalizedQuery);
            // Also check exercise PDFs for this chapter
            final chapterId =
                (chapter['id'] ?? chapter['chapterId'] ?? '').toString();
            final matchesExercisePdf = homeController.allExercises.any(
              (ex) =>
                  ex.chapterId == chapterId &&
                  (_matchesPdfQuery(ex.problemUrl, normalizedQuery) ||
                      _matchesPdfQuery(ex.solutionUrl, normalizedQuery) ||
                      (ex.problemFileName ?? '').toLowerCase().contains(
                        normalizedQuery,
                      ) ||
                      (ex.solutionFileName ?? '').toLowerCase().contains(
                        normalizedQuery,
                      )),
            );
            return chapterName.contains(normalizedQuery) ||
                matchesTheory ||
                matchesExercisePdf;
          }).toList();
    }
  }

  bool _matchesPdfQuery(dynamic url, String normalizedQuery) {
    if (normalizedQuery.isEmpty) return false;
    for (final candidate in _extractPdfSearchCandidates(url)) {
      if (candidate.contains(normalizedQuery)) return true;
    }
    return false;
  }

  List<String> _extractPdfSearchCandidates(dynamic url) {
    final raw = (url ?? '').toString().trim();
    if (raw.isEmpty) return const [];

    final candidates = <String>{};

    void addCandidate(String value) {
      final normalized = value.trim().toLowerCase();
      if (normalized.isNotEmpty) candidates.add(normalized);
    }

    addCandidate(raw);

    try {
      final uri = Uri.parse(raw);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final last = Uri.decodeComponent(segments.last);
        addCandidate(last);
        if (last.toLowerCase().endsWith('.pdf')) {
          addCandidate(last.substring(0, last.length - 4));
        }
      }

      addCandidate(Uri.decodeFull(raw));

      for (final values in uri.queryParametersAll.values) {
        for (final value in values) {
          final decoded = Uri.decodeComponent(value);
          addCandidate(decoded);
          if (decoded.toLowerCase().endsWith('.pdf')) {
            addCandidate(decoded.substring(0, decoded.length - 4));
          }
        }
      }
    } catch (_) {
      final sanitized = raw.split('?').first;
      if (sanitized.isNotEmpty) {
        final parts = sanitized.split('/');
        if (parts.isNotEmpty) {
          final last = parts.last;
          addCandidate(last);
          if (last.toLowerCase().endsWith('.pdf')) {
            addCandidate(last.substring(0, last.length - 4));
          }
        }
      }
    }

    return candidates.toList();
  }

  void showSearchBar() {
    isSearchActive(true);
  }

  void clearSearch() {
    searchController.clear();
    filteredChapters.value = chapters;
    isSearchActive(false);
  }

  Future<void> toggleFavorite(String chapterId) async {
    final String? token = await SharePref.getSavedToken();
    final bool savedGuest = (await SharePref.getSavedGuest()) == true;
    final bool isGuest = savedGuest || token == null || token.isEmpty;

    // Find the chapter and get current favorite state
    final index = chapters.indexWhere((chapter) => chapter['id'] == chapterId);
    if (index == -1) {
      if (kDebugMode) print('Chapter not found in folder: $chapterId');
      return;
    }

    final currentFavoriteState = chapters[index]['isFavorite'] == true;
    final newFavoriteState = !currentFavoriteState;

    // Always persist locally so favourites survive restarts.
    if (newFavoriteState) {
      await SharePref.addLocalFavourite(chapterId);
    } else {
      await SharePref.removeLocalFavourite(chapterId);
    }

    if (kDebugMode) {
      print(
        'Folder toggleFavorite: $chapterId, current: $currentFavoriteState, new: $newFavoriteState',
      );
    }

    // Create updated chapter map and replace in lists for proper reactivity
    final updatedChapter = Map<String, dynamic>.from(chapters[index]);
    updatedChapter['isFavorite'] = newFavoriteState;
    chapters[index] = updatedChapter;
    chapters.refresh();

    // Also update filteredChapters
    final filteredIndex = filteredChapters.indexWhere(
      (ch) => ch['id'] == chapterId,
    );
    if (filteredIndex != -1) {
      filteredChapters[filteredIndex] = updatedChapter;
      filteredChapters.refresh();
    }

    try {
      if (isGuest) {
        // Handle guest favorites
        if (newFavoriteState) {
          homeController.guestFavouriteIds.add(chapterId);
        } else {
          homeController.guestFavouriteIds.remove(chapterId);
        }
        await homeController.saveGuestFavouritesPublic();
        await homeController.favouriteController.fetchFavourite();
        if (kDebugMode) {
          print(
            'Guest favorite toggled in folder: $chapterId -> $newFavoriteState',
          );
        }
        return;
      }

      // Get userId if available (required by some backends)
      String? userId;
      if (Get.isRegistered<UserProfileController>()) {
        final prof = Get.find<UserProfileController>().profile.value;
        userId = prof?.id;
      }

      if (kDebugMode) {
        print('Making API call to: ${Urls.toggleFavourite}');
        print('Token: ${token?.substring(0, 20)}...');
        print('ChapterId: $chapterId, UserId: $userId');
      }

      // Make the API call directly for authenticated users
      final response = await http.post(
        Uri.parse(Urls.toggleFavourite),
        headers: {"Content-Type": "application/json", 'Authorization': token},
        body: jsonEncode({
          "chapterId": chapterId,
          if (userId != null && userId.isNotEmpty) "userId": userId,
        }),
      );

      if (kDebugMode) {
        print("Folder favorite toggle Status code: ${response.statusCode}");
        print("Folder favorite toggle Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success - refresh favorites list
        await homeController.favouriteController.fetchFavourite();

        // Also update the chapter in homeController's lists if it exists there
        final userChapterIndex = homeController.userChapter.indexWhere(
          (c) => c.id == chapterId,
        );
        if (userChapterIndex != -1) {
          homeController.userChapter[userChapterIndex] = homeController
              .userChapter[userChapterIndex]
              .copyWith(isFavorite: newFavoriteState);
          homeController.userChapter.refresh();
        }

        final filterChapterIndex = homeController.filterChapter.indexWhere(
          (c) => c.id == chapterId,
        );
        if (filterChapterIndex != -1) {
          homeController.filterChapter[filterChapterIndex] = homeController
              .filterChapter[filterChapterIndex]
              .copyWith(isFavorite: newFavoriteState);
          homeController.filterChapter.refresh();
        }

        if (kDebugMode) {
          print(
            'Folder favorite toggle success: $chapterId -> $newFavoriteState',
          );
        }
      } else {
        // Revert on failure - create new map for proper reactivity
        // Also revert local cache write-through.
        if (currentFavoriteState) {
          await SharePref.addLocalFavourite(chapterId);
        } else {
          await SharePref.removeLocalFavourite(chapterId);
        }
        final revertedChapter = Map<String, dynamic>.from(chapters[index]);
        revertedChapter['isFavorite'] = currentFavoriteState;
        chapters[index] = revertedChapter;
        chapters.refresh();

        if (filteredIndex != -1) {
          filteredChapters[filteredIndex] = revertedChapter;
          filteredChapters.refresh();
        }

        if (kDebugMode) {
          print('API failed, reverted to: $currentFavoriteState');
        }

        try {
          final responseData = jsonDecode(response.body);
          Get.snackbar(
            'Error',
            responseData["message"] ?? "Failed to toggle favorite",
            snackPosition: SnackPosition.BOTTOM,
          );
        } catch (_) {
          Get.snackbar(
            'Error',
            "Failed to toggle favorite",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      // Revert on exception - create new map for proper reactivity
      // Also revert local cache write-through.
      if (currentFavoriteState) {
        await SharePref.addLocalFavourite(chapterId);
      } else {
        await SharePref.removeLocalFavourite(chapterId);
      }
      final revertedChapter = Map<String, dynamic>.from(chapters[index]);
      revertedChapter['isFavorite'] = currentFavoriteState;
      chapters[index] = revertedChapter;
      chapters.refresh();

      final filteredIndex2 = filteredChapters.indexWhere(
        (ch) => ch['id'] == chapterId,
      );
      if (filteredIndex2 != -1) {
        filteredChapters[filteredIndex2] = revertedChapter;
        filteredChapters.refresh();
      }

      if (kDebugMode) {
        print('Error toggling favorite in folder: $e');
      }
      Get.snackbar(
        'Error',
        'Failed to update favorite',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void reorderChapters(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final chapter = filteredChapters.removeAt(oldIndex);
    filteredChapters.insert(newIndex, chapter);
    chapters.value = filteredChapters.toList();
    // homeController.sendUpdatedOrderToApi();
  }

  Future<void> removeChapterFromFolder(String chapterId) async {
    final String? token = await SharePref.getSavedToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) print('Guest user: skip removeChapterFromFolder');
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('${Urls.baseUrl}/chapter/out/$chapterId'),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      if (kDebugMode) {
        print('Remove chapter response status: ${response.statusCode}');
        print('Remove chapter response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        // Update local state
        final index = chapters.indexWhere(
          (chapter) => chapter['id'] == chapterId,
        );
        if (index != -1) {
          chapters.removeAt(index);
          filteredChapters.value = chapters.toList();
        }

        // Refresh home controller for user side
        homeController.getAllChapter();
        homeController.getMixedContent();

        // If admin, navigate back and refresh admin controller
        if (isAdmin) {
          Get.back();
          // Refresh AdminEditController if registered
          if (Get.isRegistered<AdminEditController>()) {
            final adminController = Get.find<AdminEditController>();
            adminController.isDataLoaded.value = false;
            await adminController.loadAllData(forceRefresh: true);
          }
        } else {
          // Show success message only for regular users
          Get.snackbar(
            'Success',
            'Chapter removed from folder successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        final responseData = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          responseData['message'] ?? 'Failed to remove chapter',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing chapter: $e');
      }
      Get.snackbar('Error', 'An error occurred while removing chapter');
    }
  }
}
