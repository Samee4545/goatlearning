import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/network_caller/endpoints.dart';
import 'package:goatlearning/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:goatlearning/feature/admin/edit/model/content_item_model.dart';
import 'package:goatlearning/feature/user/favorite/controller/favourite_controller.dart';
import 'package:goatlearning/feature/user/home/model/folder_model.dart';
import 'package:goatlearning/feature/user/home/model/user_chapter_model.dart';
import 'package:goatlearning/feature/user/profile/controller/user_profile_controller.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goatlearning/feature/user/home/model/chapter_exercise_summary.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final TabController tabController;
  final FavouriteController favouriteController = Get.put(
    FavouriteController(),
  );
  final TextEditingController searchController = TextEditingController();
  var isLoading = false.obs;
  var isFolderLoading = false.obs;
  // Indicates whether the initial mixed content fetch completed at least once
  var hasLoadedContent = false.obs;
  var isSearchActive = false.obs;
  var userChapter = <UserChapter>[].obs;
  var filterChapter = <UserChapter>[].obs;
  var allExercises = <Exercise>[].obs;
  var exerciseGroups = <ChapterExerciseSummary>[].obs;
  var folders = <Folder>[].obs;
  var contentList = <ContentItemModel>[].obs;
  var filteredContent = <ContentItemModel>[].obs;
  // Cache of folderId -> chapterIds contained in the folder
  final Map<String, List<String>> folderChapterIds = {};
  // Cache of folderId -> chapters list for expanded folders
  final Map<String, RxList<dynamic>> folderChaptersCache = {};
  // The set of chapter IDs allowed for non-premium (based on first four theory items)
  RxSet<String> allowedChapterIds = <String>{}.obs;
  // Guest-mode favourites persisted locally
  final RxSet<String> guestFavouriteIds = <String>{}.obs;
  // Track which folders are expanded
  final RxSet<String> expandedFolders = <String>{}.obs;
  // Track which folders are expanded in the exercise tab (independent from theory)
  final RxSet<String> expandedFoldersExercise = <String>{}.obs;

  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    super.onInit();
    _loadGuestFavourites();
    // Use the same API as admin: GET /content/my-content for folders + standalone chapters
    // Preload mixed content, folder list and all chapters so the Exercise tab
    // has data ready when the user opens it.
    getMixedContent();
    // Load folders used by the exercise tab
    getFolderList();
    // Load all chapters so `userChapter` / `filterChapter` are populated
    getAllChapter();
    // Load aggregated exercises for dashboard Exercise tab
    getAllExercises();
  }

  Future<void> _loadGuestFavourites() async {
    try {
      final rawPrefs = await SharedPreferences.getInstance();
      final raw = rawPrefs.getString('guest_favourites') ?? '[]';
      final List list = jsonDecode(raw);
      guestFavouriteIds.assignAll(list.map((e) => e.toString()));
    } catch (_) {
      guestFavouriteIds.clear();
    }
  }

  // Public method for other controllers to (re)load guest favourites on demand.
  Future<void> loadGuestFavouritesPublic() async {
    await _loadGuestFavourites();
  }

  Future<void> _saveGuestFavourites() async {
    try {
      final rawPrefs = await SharedPreferences.getInstance();
      await rawPrefs.setString(
        'guest_favourites',
        jsonEncode(guestFavouriteIds.toList()),
      );
    } catch (_) {}
  }

  // Public method for FolderDetailsController to save guest favourites
  Future<void> saveGuestFavouritesPublic() async {
    await _saveGuestFavourites();
  }

  Future<void> getAllExercises() async {
    // Public endpoint - returns all exercises across chapters
    try {
      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/exercise'),
        headers: {'Content-Type': 'application/json'},
      );

      if (kDebugMode) {
        print('getAllExercises status: ${response.statusCode}');
        print('getAllExercises body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final list = jsonData['data'] as List? ?? [];
        allExercises.value = list.map((e) => Exercise.fromJson(e)).toList();

        // Group exercises by chapterId to show per-chapter counts on dashboard
        final Map<String, List<Exercise>> groups = {};
        for (var ex in allExercises) {
          groups.putIfAbsent(ex.chapterId, () => []).add(ex);
        }

        final List<ChapterExerciseSummary> summaries = [];
        groups.forEach((chapterId, exercises) {
          // Try to get chapterName from userChapter if available
          final matched = userChapter.where((c) => c.id == chapterId).toList();
          final chapterName =
              matched.isNotEmpty
                  ? matched.first.chapterName
                  : (exercises.isNotEmpty
                      ? exercises.first.chapterName ?? chapterId
                      : chapterId);
          summaries.add(
            ChapterExerciseSummary(
              chapterId: chapterId,
              chapterName: chapterName,
              count: exercises.length,
              exercises: exercises,
            ),
          );
        });

        exerciseGroups.value = summaries;
      } else {
        if (kDebugMode)
          print('Failed to fetch exercises: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching exercises: $e');
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> calculatorPercent(String id, double percent) async {
    if (id.isEmpty) return;
    final String? token = await SharePref.getSavedToken();

    // Skip if no token (guest user)
    if (token == null || token.isEmpty) {
      if (kDebugMode) print('Cannot update progress: not authenticated');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${Urls.baseUrl}/complete"),
        headers: {"Content-Type": "application/json", 'Authorization': token},
        body: jsonEncode({"chapterId": id, "completePercent": percent}),
      );

      if (kDebugMode) {
        print("completePercent: ${response.statusCode}");
        print("Body completePercent: ${response.body}");
      }

      if (response.statusCode != 201) {
        if (kDebugMode)
          print("Failed to update progress: ${response.statusCode}");
        // Don't show error to user - progress tracking is optional for guest users
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating percent: $e");
      }
      // Don't show error to user - progress tracking is optional
    }
  }

  Future<void> fetchChaptersInFolders() async {
    try {
      final String? token = await SharePref.getSavedToken();
      // Iterate over contentList and find folders
      for (var item in contentList) {
        if (item.isFolder &&
            item.folderId != null &&
            item.folderId!.isNotEmpty) {
          final folderId = item.folderId!;
          final response = await http.get(
            Uri.parse('${Urls.baseUrl}/content/folder/$folderId/chapters'),
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty) 'Authorization': token,
            },
          );

          if (kDebugMode) {
            print('Folder $folderId chapters status: ${response.statusCode}');
            print('Folder $folderId chapters body: ${response.body}');
          }

          if (response.statusCode == 200) {
            final jsonData = json.decode(response.body);
            final data = jsonData['data'] as List? ?? [];
            // Map each chapter into UserChapter and add if not present
            for (var ch in data) {
              final chapter = UserChapter.fromJson(ch as Map<String, dynamic>);
              final exists = userChapter.any((c) => c.id == chapter.id);
              if (!exists) {
                userChapter.add(chapter);
              }
            }
          }
        }
      }

      // Ensure filterChapter mirrors userChapter
      filterChapter.value = userChapter.toList();

      // Rebuild grouped exercise summaries since we may now have more chapters
      buildExerciseGroups();
    } catch (e) {
      if (kDebugMode) print('Error fetching chapters in folders: $e');
    }
  }

  void buildExerciseGroups() {
    try {
      final Map<String, List<Exercise>> groups = {};
      for (var ex in allExercises) {
        groups.putIfAbsent(ex.chapterId, () => []).add(ex);
      }

      final List<ChapterExerciseSummary> summaries = [];
      groups.forEach((chapterId, exercises) {
        final matched = userChapter.where((c) => c.id == chapterId).toList();
        final chapterName =
            matched.isNotEmpty
                ? matched.first.chapterName
                : (exercises.isNotEmpty
                    ? exercises.first.chapterName ?? chapterId
                    : chapterId);
        summaries.add(
          ChapterExerciseSummary(
            chapterId: chapterId,
            chapterName: chapterName,
            count: exercises.length,
            exercises: exercises,
          ),
        );
      });

      exerciseGroups.value = summaries;
    } catch (e) {
      if (kDebugMode) print('Error building exercise groups: $e');
    }
  }

  /// Recompute which chapter IDs are allowed for non-premium users, based on
  /// the first four items shown in the Theory tab (folders count as one item).
  Future<void> updateAllowedChapters() async {
    // If premium, allow all chapters
    // Note: We don't import BillingManager here to avoid coupling; the UI will
    // apply gating using this set only when not premium.
    final List<ContentItemModel> source = filteredContent.toList();
    final Set<String> allow = {};
    int taken = 0;
    for (final item in source) {
      if (taken >= 4) break;
      if (item.isFolder == true && (item.folderId?.isNotEmpty ?? false)) {
        final fid = item.folderId!;
        // Fetch folder chapters if not cached
        if (!folderChapterIds.containsKey(fid)) {
          try {
            final String? token = await SharePref.getSavedToken();
            final headers = <String, String>{
              'Content-Type': 'application/json',
            };
            if (token != null && token.isNotEmpty)
              headers['Authorization'] = token;
            final response = await http.get(
              Uri.parse('${Urls.baseUrl}/content/folder/$fid/chapters'),
              headers: headers,
            );
            if (response.statusCode == 200) {
              final jsonData = json.decode(response.body);
              final data = jsonData['data'] as List? ?? [];
              final ids = <String>[];
              for (var ch in data) {
                final map = ch as Map<String, dynamic>;
                final id = (map['id'] ?? map['_id'] ?? '').toString();
                if (id.isNotEmpty) ids.add(id);
              }
              folderChapterIds[fid] = ids;
            } else {
              folderChapterIds[fid] = const [];
            }
          } catch (_) {
            folderChapterIds[fid] = const [];
          }
        }
        allow.addAll(folderChapterIds[fid] ?? const []);
        taken++;
      } else {
        final id = item.chapterId ?? item.id ?? '';
        if (id.isNotEmpty) {
          allow.add(id);
          taken++;
        }
      }
    }
    allowedChapterIds.assignAll(allow);
  }

  Future<void> getMixedContent() async {
    isLoading.value = true;
    final String? token = await SharePref.getSavedToken();

    try {
      // Build headers - only include Authorization if token exists
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = token;
      }

      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/content/my-content'),
        headers: headers,
      );

      if (kDebugMode) {
        print('Mixed content status: ${response.statusCode}');
        print('Mixed content body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'] as List;

        contentList.value =
            data.map((item) => ContentItemModel.fromJson(item)).toList();
        filteredContent.value = contentList;

        // Apply guest favourites flag in UI
        for (final item in contentList) {
          if (item.isChapter) {
            final id = item.chapterId ?? item.id;
            if (id != null && guestFavouriteIds.contains(id)) {
              item.isFavorite = true;
            }
          }
        }
        contentList.refresh();

        if (kDebugMode) {
          print('Mixed content loaded: ${contentList.length} items');
        }
        // Update allowed chapters for non-premium after content changes
        await updateAllowedChapters();

        // Pre-fetch folder chapters in background so PDF search works
        // without requiring users to expand folders first.
        _preFetchAllFolderChapters(data, headers);
      } else if (response.statusCode == 401 &&
          (token == null || token.isEmpty)) {
        // Guest user hitting auth-only endpoint: suppress error
        if (kDebugMode)
          print('Guest user: 401 on /content/my-content suppressed');
      } else {
        EasyLoading.showError('Error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching mixed content: $e");
      }
      EasyLoading.showError('Failed to load content');
    } finally {
      isLoading.value = false;
      hasLoadedContent.value = true;
    }
  }

  /// Simple fetch for chapters and folders using their individual GET APIs
  /// This can be used when `/content/my-content` is not available or
  /// when a simpler client-side merge is desired.
  Future<void> getChaptersAndFoldersSimple() async {
    isLoading.value = true;
    final String? token = await SharePref.getSavedToken();

    try {
      // Build headers - only include Authorization if token exists
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = token;
      }

      // Fetch chapters
      final chaptersResponse = await http.get(
        Uri.parse('${Urls.baseUrl}/chapter'),
        headers: headers,
      );

      List<ContentItemModel> items = [];

      if (chaptersResponse.statusCode == 200) {
        final apiResponse = parseApiResponse(chaptersResponse.body);
        if (apiResponse.success) {
          final chapters = apiResponse.data as List<UserChapter>? ?? [];
          for (var c in chapters) {
            items.add(ContentItemModel.fromChapterModel(c));
          }
        }
      }

      // Fetch folders
      final folderResponse = await http.get(
        Uri.parse('${Urls.baseUrl}/folder/my'),
        headers: headers,
      );

      if (folderResponse.statusCode == 200) {
        final folderApi = FolderApiResponse.fromJson(
          jsonDecode(folderResponse.body),
        );
        if (folderApi.success) {
          for (var f in folderApi.data) {
            items.add(ContentItemModel.fromFolderModel(f));
          }
        }
      }

      // Set combined list
      contentList.value = items;
      filteredContent.value = items;
    } catch (e) {
      if (kDebugMode) print('Error fetching chapters/folders: $e');
      EasyLoading.showError('Failed to load content');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAllChapter() async {
    isLoading.value = true;
    final String? token = await SharePref.getSavedToken();

    try {
      // Build headers - only include Authorization if token exists
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = token;
      }

      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/chapter'),
        headers: headers,
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final apiResponse = parseApiResponse(response.body);
        if (apiResponse.success) {
          userChapter.value = apiResponse.data;
          filterChapter.value = apiResponse.data;
          // Apply guest favourites to chapter lists
          for (var i = 0; i < userChapter.length; i++) {
            final id = userChapter[i].id;
            if (id.isNotEmpty && guestFavouriteIds.contains(id)) {
              userChapter[i] = userChapter[i].copyWith(isFavorite: true);
            }
          }
          for (var i = 0; i < filterChapter.length; i++) {
            final id = filterChapter[i].id;
            if (id.isNotEmpty && guestFavouriteIds.contains(id)) {
              filterChapter[i] = filterChapter[i].copyWith(isFavorite: true);
            }
          }
          if (kDebugMode) {
            print(
              'Chapters data successfully updated: ${userChapter.length} chapters',
            );
          }
        } else {
          EasyLoading.showError(apiResponse.message);
        }
      } else if (response.statusCode == 401 &&
          (token == null || token.isEmpty)) {
        // Guest user unauthorized: suppress error
        if (kDebugMode) print('Guest user: 401 on /chapter suppressed');
      } else {
        EasyLoading.showError('Error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching chapters: $e");
      }
      EasyLoading.showError('Failed to load chapters');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavourite(String id) async {
    final String? token = await SharePref.getSavedToken();
    final bool savedGuest = (await SharePref.getSavedGuest()) == true;
    final bool isGuest = savedGuest || token == null || token.isEmpty;

    // Find index in userChapter/filterChapter and also content list to update Theory UI immediately
    final userChapterIndex = userChapter.indexWhere((c) => c.id == id);
    final filterChapterIndex = filterChapter.indexWhere((c) => c.id == id);
    final contentIndex = contentList.indexWhere(
      (item) => (item.id == id || item.chapterId == id) && item.isChapter,
    );
    final filteredContentIndex = filteredContent.indexWhere(
      (item) => (item.id == id || item.chapterId == id) && item.isChapter,
    );

    // Optimistic UI update: toggle favorite locally first
    // Determine current favorite state from multiple sources
    bool oldFavUser = false;
    if (userChapterIndex != -1) {
      oldFavUser = userChapter[userChapterIndex].isFavorite;
    } else if (contentIndex != -1) {
      oldFavUser = contentList[contentIndex].isFavorite ?? false;
    } else if (isGuest) {
      oldFavUser = guestFavouriteIds.contains(id);
    }

    bool newFavoriteStatus = !oldFavUser;

    // Always write-through to a persistent local cache so favourites survive restarts.
    // This also acts as a fallback when the remote favourites endpoint is unavailable.
    if (newFavoriteStatus) {
      await SharePref.addLocalFavourite(id);
    } else {
      await SharePref.removeLocalFavourite(id);
    }

    if (kDebugMode) {
      print(
        'Toggle favourite: $id, oldState: $oldFavUser, newState: $newFavoriteStatus',
      );
    }

    if (userChapterIndex != -1) {
      userChapter[userChapterIndex] = userChapter[userChapterIndex].copyWith(
        isFavorite: newFavoriteStatus,
      );
    }
    if (filterChapterIndex != -1) {
      filterChapter[filterChapterIndex] = filterChapter[filterChapterIndex]
          .copyWith(isFavorite: newFavoriteStatus);
    }
    if (contentIndex != -1) {
      contentList[contentIndex].isFavorite = newFavoriteStatus;
    }
    if (filteredContentIndex != -1) {
      filteredContent[filteredContentIndex].isFavorite = newFavoriteStatus;
    }
    userChapter.refresh();
    filterChapter.refresh();
    contentList.refresh();
    filteredContent.refresh();

    try {
      if (isGuest) {
        // Persist guest favourite locally and bail out before API call
        if (newFavoriteStatus) {
          guestFavouriteIds.add(id);
        } else {
          guestFavouriteIds.remove(id);
        }
        await _saveGuestFavourites();
        if (kDebugMode) {
          print('Guest favourite updated locally: $id -> $newFavoriteStatus');
          print('Guest favourites set: ${guestFavouriteIds.toList()}');
        }
        // Refresh FavouriteController to update Favorites page immediately
        await favouriteController.fetchFavourite();
        return;
      }
      // Optionally include userId if profile is loaded (server should infer from token)
      String? userId;
      if (Get.isRegistered<UserProfileController>()) {
        final prof = Get.find<UserProfileController>().profile.value;
        userId = prof?.id;
      }
      final response = await http.post(
        Uri.parse(Urls.toggleFavourite),
        headers: {"Content-Type": "application/json", 'Authorization': token},
        body: jsonEncode({
          "chapterId": id,
          if (userId != null && userId.isNotEmpty) "userId": userId,
        }),
      );

      if (kDebugMode) {
        print("Favourite toggle Status code: ${response.statusCode}");
        print("Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success: refresh favourites list
        if (kDebugMode)
          print('Auth favourite toggle success: $id -> $newFavoriteStatus');
        await favouriteController.fetchFavourite();
      } else {
        // Revert local cache write-through on API failure.
        if (oldFavUser) {
          await SharePref.addLocalFavourite(id);
        } else {
          await SharePref.removeLocalFavourite(id);
        }
        // Revert UI if API failed
        if (userChapterIndex != -1) {
          userChapter[userChapterIndex] = userChapter[userChapterIndex]
              .copyWith(isFavorite: oldFavUser);
        }
        if (filterChapterIndex != -1) {
          filterChapter[filterChapterIndex] = filterChapter[filterChapterIndex]
              .copyWith(isFavorite: oldFavUser);
        }
        if (contentIndex != -1) {
          contentList[contentIndex].isFavorite = oldFavUser;
        }
        if (filteredContentIndex != -1) {
          filteredContent[filteredContentIndex].isFavorite = oldFavUser;
        }
        userChapter.refresh();
        filterChapter.refresh();
        contentList.refresh();
        filteredContent.refresh();

        final responseData = jsonDecode(response.body);
        EasyLoading.showError(
          responseData["message"] ?? "Failed to toggle favourite",
        );
      }
    } catch (e) {
      // Revert local cache write-through on exception.
      if (oldFavUser) {
        await SharePref.addLocalFavourite(id);
      } else {
        await SharePref.removeLocalFavourite(id);
      }
      // Revert on exception
      if (userChapterIndex != -1) {
        userChapter[userChapterIndex] = userChapter[userChapterIndex].copyWith(
          isFavorite: oldFavUser,
        );
      }
      if (filterChapterIndex != -1) {
        filterChapter[filterChapterIndex] = filterChapter[filterChapterIndex]
            .copyWith(isFavorite: oldFavUser);
      }
      if (contentIndex != -1) {
        contentList[contentIndex].isFavorite = oldFavUser;
      }
      if (filteredContentIndex != -1) {
        filteredContent[filteredContentIndex].isFavorite = oldFavUser;
      }
      userChapter.refresh();
      filterChapter.refresh();
      contentList.refresh();
      filteredContent.refresh();

      if (kDebugMode) {
        print("Error toggling favourite: $e");
      }
      EasyLoading.showError("An error occurred");
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// Fire-and-forget: fetch chapters for every folder so `filterList` can
  /// search folder contents by chapter name or PDF URL without the user
  /// having to expand each folder first.
  void _preFetchAllFolderChapters(
    List<dynamic> contentData,
    Map<String, String> headers,
  ) {
    for (final item in contentData) {
      if ((item['type'] ?? '') == 'folder') {
        final folderId = (item['folderId'] ?? item['id'] ?? '').toString();
        if (folderId.isNotEmpty && !folderChaptersCache.containsKey(folderId)) {
          _fetchFolderChaptersForSearch(folderId, headers);
        }
      }
    }
  }

  Future<void> _fetchFolderChaptersForSearch(
    String folderId,
    Map<String, String> headers,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/content/folder/$folderId/chapters'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'] as List? ?? [];
        if (!folderChaptersCache.containsKey(folderId)) {
          final cached = <dynamic>[].obs;
          cached.addAll(data);
          folderChaptersCache[folderId] = cached;
        }
        // Also populate folderChapterIds for premium gating
        if (!folderChapterIds.containsKey(folderId)) {
          final ids = <String>[];
          for (final ch in data) {
            final id = (ch['id'] ?? ch['_id'] ?? '').toString();
            if (id.isNotEmpty) ids.add(id);
          }
          folderChapterIds[folderId] = ids;
        }
      }
    } catch (_) {}
  }

  void filterList(String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (query.isEmpty) {
      filteredContent.value = contentList;
    } else {
      filteredContent.value =
          contentList.where((item) {
            if (item.isFolder) {
              final folderName = (item.name ?? '').toLowerCase();
              if (folderName.contains(normalizedQuery)) return true;

              // Also search chapters inside this folder by name and PDF URL
              final folderId = item.folderId ?? item.id ?? '';
              final folderChapters = folderChaptersCache[folderId];
              if (folderChapters != null) {
                return folderChapters.any((ch) {
                  final map = ch as Map<String, dynamic>;
                  final chName =
                      (map['chapterName'] ?? '').toString().toLowerCase();
                  if (chName.contains(normalizedQuery)) return true;
                  if (_matchesPdfQuery(
                    map['theory'] as String?,
                    normalizedQuery,
                  ))
                    return true;
                  if ((map['theoryFileName'] ?? '')
                      .toString()
                      .toLowerCase()
                      .contains(normalizedQuery))
                    return true;
                  // Exercise PDFs for this folder chapter
                  final chId = (map['id'] ?? map['chapterId'] ?? '').toString();
                  return allExercises.any(
                    (ex) =>
                        ex.chapterId == chId &&
                        (_matchesPdfQuery(ex.problemUrl, normalizedQuery) ||
                            _matchesPdfQuery(ex.solutionUrl, normalizedQuery) ||
                            (ex.problemFileName ?? '').toLowerCase().contains(
                              normalizedQuery,
                            ) ||
                            (ex.solutionFileName ?? '').toLowerCase().contains(
                              normalizedQuery,
                            )),
                  );
                });
              }
              return false;
            } else {
              final chapterName = (item.chapterName ?? '').toLowerCase();
              final matchesTheory =
                  _matchesPdfQuery(item.theory, normalizedQuery) ||
                  (item.theoryFileName ?? '').toLowerCase().contains(
                    normalizedQuery,
                  );

              final chapterId = (item.id ?? item.chapterId ?? '').toString();
              final matchesExercisePdf = allExercises.any(
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
            }
          }).toList();
    }
    // Recompute allowed set when theory list changes
    updateAllowedChapters();
  }

  bool _matchesPdfQuery(String? url, String normalizedQuery) {
    if (normalizedQuery.isEmpty) return false;

    for (final candidate in _extractPdfSearchCandidates(url)) {
      if (candidate.contains(normalizedQuery)) return true;
    }
    return false;
  }

  List<String> _extractPdfSearchCandidates(String? url) {
    if (url == null || url.trim().isEmpty) return const [];

    final rawUrl = url.trim();
    final candidates = <String>{};

    void addCandidate(String value) {
      final normalized = value.trim().toLowerCase();
      if (normalized.isNotEmpty) candidates.add(normalized);
    }

    addCandidate(rawUrl);

    try {
      final uri = Uri.parse(rawUrl);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final last = Uri.decodeComponent(segments.last);
        addCandidate(last);
        if (last.toLowerCase().endsWith('.pdf')) {
          addCandidate(last.substring(0, last.length - 4));
        }
      }

      addCandidate(Uri.decodeFull(rawUrl));

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
      final sanitized = rawUrl.split('?').first;
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
    isSearchActive.value = true;
  }

  void clearSearch() {
    searchController.clear();
    filteredContent.value = contentList;
    isSearchActive.value = false;
  }

  void reorderChapters(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // Get the IDs before reordering
    final item1Id = filteredContent[oldIndex].id ?? '';
    final item2Id = filteredContent[newIndex].id ?? '';

    // Perform local reorder
    final item = filteredContent.removeAt(oldIndex);
    filteredContent.insert(newIndex, item);
    contentList.value = filteredContent.toList();

    // Call swap API
    swapContent(item1Id, item2Id);
  }

  Future<void> swapContent(String item1Id, String item2Id) async {
    try {
      final String? token = await SharePref.getSavedToken();
      // Reordering is an authenticated feature; ignore silently for guests
      if (token == null || token.isEmpty) {
        if (kDebugMode) print('Guest user: skip swapContent');
        return;
      }

      final response = await http.post(
        Uri.parse('${Urls.baseUrl}/content/swap-content'),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: jsonEncode({'item1Id': item1Id, 'item2Id': item2Id}),
      );

      if (kDebugMode) {
        print('Swap content response status: ${response.statusCode}');
      }

      if (response.statusCode != 200) {
        EasyLoading.showError("Failed to update order");
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error swapping content: $e');
      }
    }
  }

  void reorderFolders(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final folder = folders.removeAt(oldIndex);
    folders.insert(newIndex, folder);
    sendUpdatedFolderOrderToApi();
  }

  Future<void> sendUpdatedOrderToApi() async {
    final String? token = await SharePref.getSavedToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) print('Guest user: skip chapter order update');
      return;
    }

    final chapterIds = filterChapter.map((chapter) => chapter.id).toList();

    try {
      final response = await http.post(
        Uri.parse("${Urls.baseUrl}/chapter/swipe"),
        headers: {"Content-Type": "application/json", 'Authorization': token},
        body: jsonEncode({"chapterIds": chapterIds}),
      );

      if (kDebugMode) {
        print("Swipe API Status code: ${response.statusCode}");
        print("Swipe API Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        // Success
      } else {
        EasyLoading.showError("Failed to update chapter order");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating chapter order: $e");
      }
    }
  }

  Future<void> sendUpdatedFolderOrderToApi() async {
    final String? token = await SharePref.getSavedToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) print('Guest user: skip folder order update');
      return;
    }

    final folderIds = folders.map((folder) => folder.id).toList();

    try {
      final response = await http.post(
        Uri.parse("${Urls.baseUrl}/folder/swap"),
        headers: {"Content-Type": "application/json", 'Authorization': token},
        body: jsonEncode({"folderIds": folderIds}),
      );

      if (kDebugMode) {
        print("Folder Swap API Status code: ${response.statusCode}");
        print("Folder Swap API Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        // Success
      } else {
        EasyLoading.showError("Failed to update folder order");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating folder order: $e");
      }
      EasyLoading.showError("Error updating folder order");
    }
  }

  void confirmDeleteFolder(BuildContext context, String folderId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete this folder?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  deleteFolder(folderId);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void deleteFolder(String folderId) async {
    try {
      EasyLoading.show(status: 'Deleting folder...');
      final String? token = await SharePref.getSavedToken();
      if (token == null || token.isEmpty) {
        if (kDebugMode) print('Guest user: skip deleteFolder');
        EasyLoading.dismiss();
        return;
      }

      // First, fetch all chapters in the folder and move them to main page
      final chaptersResponse = await http.get(
        Uri.parse('${Urls.baseUrl}/content/folder/$folderId/chapters'),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      if (kDebugMode) {
        print('Fetch chapters response status: ${chaptersResponse.statusCode}');
        print('Fetch chapters response body: ${chaptersResponse.body}');
      }

      List<String> chapterIds = [];
      if (chaptersResponse.statusCode == 200) {
        final chaptersData = jsonDecode(chaptersResponse.body);
        if (chaptersData['success'] == true && chaptersData['data'] != null) {
          final chapters = chaptersData['data'] as List;
          chapterIds =
              chapters.map((chapter) => chapter['id'] as String).toList();

          if (kDebugMode) {
            print('Found ${chapterIds.length} chapters to move to main page');
          }
        }
      }

      // Move chapters out of the folder (make them standalone on main page)
      for (String chapterId in chapterIds) {
        try {
          final moveChapterResponse = await http.delete(
            Uri.parse('${Urls.baseUrl}/chapter/out/$chapterId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': token,
            },
          );

          if (kDebugMode) {
            print(
              'Move chapter $chapterId to main page response status: ${moveChapterResponse.statusCode}',
            );
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error moving chapter $chapterId: $e');
          }
          // Continue moving other chapters even if one fails
        }
      }

      // Now delete the folder itself
      final response = await http.delete(
        Uri.parse('${Urls.baseUrl}/folder/$folderId'),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      if (kDebugMode) {
        print('Delete folder response status: ${response.statusCode}');
        print('Delete folder response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        EasyLoading.showSuccess('Folder deleted. Chapters moved to main page.');
        await getFolderList();
        await getAllChapter();
      } else {
        throw Exception('Failed to delete folder: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting folder: $e');
      }
      EasyLoading.showError('Error deleting folder: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> createFolder(String folderName) async {
    try {
      EasyLoading.show(status: 'Creating folder...');
      final String? token = await SharePref.getSavedToken();
      if (token == null || token.isEmpty) {
        if (kDebugMode) print('Guest user: skip createFolder');
        EasyLoading.dismiss();
        return;
      }

      final response = await http.post(
        Uri.parse('${Urls.baseUrl}/folder'),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: jsonEncode({'name': folderName}),
      );

      if (kDebugMode) {
        print('Create folder response status: ${response.statusCode}');
        print('Create folder response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        EasyLoading.showSuccess('Folder created successfully');
        await getMixedContent();
      } else {
        throw Exception('Failed to create folder: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating folder: $e');
      }
      EasyLoading.showError('Error creating folder: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> getFolderList() async {
    isFolderLoading.value = true;
    try {
      final String? token = await SharePref.getSavedToken();
      if (token == null || token.isEmpty) {
        // Guest user: skip fetching folders; leave list empty without error UI
        if (kDebugMode) print('Guest user: skip getFolderList');
        return;
      }

      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/folder/my'),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      if (kDebugMode) {
        print('Folder response status: ${response.statusCode}');
        print('Folder response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final apiResponse = FolderApiResponse.fromJson(
          jsonDecode(response.body),
        );
        if (apiResponse.success) {
          folders.value = apiResponse.data;
          if (kDebugMode) {
            print('Folders fetched successfully: ${folders.length} folders');
          }
        } else {
          EasyLoading.showError(apiResponse.message);
        }
      } else {
        EasyLoading.showError(
          'Failed to fetch folders: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching folders: $e');
      }
      EasyLoading.showError('Error fetching folders: $e');
    } finally {
      isFolderLoading.value = false;
    }
  }

  Future<void> moveChapterToFolder(String chapterId, String folderId) async {
    final String? token = await SharePref.getSavedToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) print('Guest user: skip moveChapterToFolder');
      return;
    }

    try {
      userChapter.removeWhere((chapter) => chapter.id == chapterId);
      filterChapter.removeWhere((chapter) => chapter.id == chapterId);
      final response = await http.post(
        Uri.parse('${Urls.baseUrl}/folder/add-chapter-folder'),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: jsonEncode({'folderId': folderId, 'chapterId': chapterId}),
      );

      if (kDebugMode) {
        print('Move chapter response status: ${response.statusCode}');
        print('Move chapter response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
      } else {
        final responseData = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          responseData['message'] ?? 'Failed to move chapter',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error moving chapter: $e');
      }
      Get.snackbar('Error', 'An error occurred while moving chapter');
    }
  }

  /// Unified refresh method used by pull-to-refresh on Theory, Exercise tabs
  /// and other places needing a full data reload. It chains the existing
  /// granular fetch calls in an order that preserves dependencies:
  /// 1. Mixed content (populates contentList / filteredContent)
  /// 2. Folder list (for authenticated users)
  /// 3. All chapters (userChapter / filterChapter)
  /// 4. All exercises (exercise list)
  /// 5. Chapters inside folders (may augment chapter list)
  /// 6. Recompute allowed chapter gating and rebuild exercise groups
  ///
  /// Any individual fetch failure is logged but does not abort the sequence
  /// so the UI still gets as much fresh data as possible.
  Future<void> refreshAllContent({bool showLoader = true}) async {
    if (showLoader) {
      EasyLoading.show(status: 'Refreshing...');
    }
    try {
      await getMixedContent();
      await getFolderList();
      await getAllChapter();
      await getAllExercises();
      await fetchChaptersInFolders();
      await updateAllowedChapters();
      buildExerciseGroups();
    } catch (e) {
      if (kDebugMode) {
        print('Unified refresh error: $e');
      }
      // Non-fatal: partial data may still be updated by successful calls.
    } finally {
      if (showLoader) EasyLoading.dismiss();
    }
  }

  /// Toggle folder expansion state
  Future<void> toggleFolderExpansion(String folderId) async {
    if (expandedFolders.contains(folderId)) {
      expandedFolders.remove(folderId);
    } else {
      expandedFolders.add(folderId);
      // Load chapters for this folder if not cached
      await loadFolderChapters(folderId);
    }
  }

  Future<void> toggleFolderExpansionExercise(String folderId) async {
    if (expandedFoldersExercise.contains(folderId)) {
      expandedFoldersExercise.remove(folderId);
    } else {
      expandedFoldersExercise.add(folderId);
      // Reuse the same chapter cache as the theory tab
      await loadFolderChapters(folderId);
    }
  }

  /// Load chapters for a specific folder
  Future<void> loadFolderChapters(String folderId) async {
    if (folderChaptersCache.containsKey(folderId)) {
      return; // Already cached
    }

    try {
      final String? token = await SharePref.getSavedToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = token;
      }

      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/content/folder/$folderId/chapters'),
        headers: headers,
      );

      if (kDebugMode) {
        print('Folder $folderId chapters status: ${response.statusCode}');
        print('Folder $folderId chapters body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'] as List? ?? [];

        // Create observable list and cache it
        final chapters = <dynamic>[].obs;
        chapters.addAll(data);
        folderChaptersCache[folderId] = chapters;

        // Also update folderChapterIds for premium gating
        final ids = <String>[];
        for (var ch in data) {
          final map = ch as Map<String, dynamic>;
          final id = (map['id'] ?? map['_id'] ?? '').toString();
          if (id.isNotEmpty) ids.add(id);
        }
        folderChapterIds[folderId] = ids;

        // Trigger UI refresh to show the chapters
        expandedFolders.refresh();
      }
    } catch (e) {
      if (kDebugMode) print('Error loading folder chapters: $e');
    }
  }
}
