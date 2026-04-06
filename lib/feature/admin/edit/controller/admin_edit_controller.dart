import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/network_caller/endpoints.dart';
import 'package:goatlearning/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:goatlearning/feature/admin/edit/model/admin_parcentage_model.dart';
import 'package:goatlearning/feature/admin/edit/model/chapter_model.dart';
import 'package:goatlearning/feature/admin/edit/model/content_item_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goatlearning/feature/admin/edit/model/exercise_model.dart';

class AdminEditController extends GetxController {
  ChapterModel? selectedChapter;

  TextEditingController chapterNameController = TextEditingController();
  final searchController = TextEditingController();
  var isSearchActive = false.obs;
  var isLoading = false.obs;
  var isDataLoaded = false.obs;
  var lastFetchTime = DateTime(2000).obs;

  final Rx<File?> image = Rx<File?>(null);
  final Rx<File?> pdfFile = Rx<File?>(null);
  RxString theoryFileName = ''.obs;
  RxList<ExerciseModel> exercises = <ExerciseModel>[].obs;
  RxList<ChapterModel> chapterList = <ChapterModel>[].obs;
  RxList<ChapterModel> filteredItems = <ChapterModel>[].obs;
  RxList<ContentItemModel> contentList = <ContentItemModel>[].obs;
  RxList<ContentItemModel> filteredContent = <ContentItemModel>[].obs;
  var percentageList = <AdminPercentageModel>[].obs;
  bool _imagePickerActive = false; // guard against concurrent image picker use

  // Track expanded folders for hierarchical UI
  final RxSet<String> expandedFolders = <String>{}.obs;
  // Track expanded folders in the exercise tab (independent)
  final RxSet<String> expandedFoldersExercise = <String>{}.obs;
  // Cache of folderId -> chapters list for expanded folders
  final Map<String, RxList<dynamic>> folderChaptersCache = {};

  // Cache duration - 5 minutes
  static const cacheDuration = Duration(minutes: 5);

  Future<void> getChapterById(String id) async {
    try {
      isLoading.value = true;
      final String? token = await SharePref.getSavedToken();
      if (token == null) {
        EasyLoading.showError("Authentication token not found");
        return;
      }
      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/chapter/$id'),
        headers: {'Authorization': token},
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'];
        selectedChapter = ChapterModel.fromJson(data);
        chapterNameController.text = selectedChapter?.chapterName ?? '';

        // Reset file selections
        image.value = null;
        pdfFile.value = null;
        exercises.clear();

        // Populate exercises from fetched chapter
        if (selectedChapter?.exercises != null) {
          for (var exercise in selectedChapter!.exercises!) {
            final exerciseModel = ExerciseModel();
            exerciseModel.problemUrl.value = exercise.problemUrl ?? '';
            exerciseModel.solutionUrl.value = exercise.solutionUrl ?? '';
            exercises.add(exerciseModel);
          }
        } else {
          // Add empty exercise if none exist
          exercises.add(ExerciseModel());
        }
      } else {
        EasyLoading.showError('Failed to fetch chapter details');
      }
    } catch (e) {
      EasyLoading.showError('Error fetching chapter details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Upload single file and return URL
  Future<String?> uploadSingleFile(File file) async {
    try {
      String? token = await SharePref.getSavedToken();
      if (token == null) {
        EasyLoading.showError("Authentication token not found");
        return null;
      }

      final Uri url = Uri.parse(Urls.uploadSingle);
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll({'Authorization': token});

      final fileName = file.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();

      MediaType contentType;
      if (extension == 'pdf') {
        contentType = MediaType('application', 'pdf');
      } else if ([
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
        'bmp',
        'heic',
        'heif',
      ].contains(extension)) {
        String imageType = extension;
        if (extension == 'jpg') imageType = 'jpeg';
        if (extension == 'heif') imageType = 'heic';
        contentType = MediaType('image', imageType);
      } else {
        contentType = MediaType('application', 'octet-stream');
      }

      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: fileName,
        contentType: contentType,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData['data']['url'] as String?;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update chapter collectively with image, theory, and exercises
  Future<void> updateChapterCollective(String id) async {
    try {
      EasyLoading.show(status: "Updating...");
      final String? token = await SharePref.getSavedToken();
      if (token == null) {
        EasyLoading.showError("Authentication token not found");
        return;
      }

      // Validate: Must have selectedChapter data first
      if (selectedChapter == null) {
        EasyLoading.showError("Please wait for chapter data to load");
        return;
      }

      // Validate chapter name (required field)
      final chapterName = chapterNameController.text.trim();
      if (chapterName.isEmpty) {
        EasyLoading.showError("Chapter name is required");
        return;
      }

      // Upload new theory if selected, else use previous (required)
      String theoryUrl = selectedChapter!.theory ?? "";
      if (pdfFile.value != null) {
        EasyLoading.show(status: "Uploading theory...");
        final uploadedUrl = await uploadSingleFile(pdfFile.value!);
        if (uploadedUrl != null) {
          theoryUrl = uploadedUrl;
        } else {
          EasyLoading.showError("Failed to upload theory PDF");
          return;
        }
      }

      // Validate theory URL
      if (theoryUrl.isEmpty) {
        EasyLoading.showError("Theory PDF is required");
        return;
      }

      // Build exercises array (using updated or previous URLs)
      List<Map<String, String>> exercisesPayload = [];
      for (int i = 0; i < exercises.length; i++) {
        String problemUrl = exercises[i].problemUrl.value;
        String solutionUrl = exercises[i].solutionUrl.value;

        // Upload problem PDF if new file selected
        if (exercises[i].problemPDF.value != null) {
          EasyLoading.show(status: "Uploading exercise ${i + 1} problem...");
          final uploadedUrl = await uploadSingleFile(
            exercises[i].problemPDF.value!,
          );
          if (uploadedUrl != null) {
            problemUrl = uploadedUrl;
          } else {
            EasyLoading.showError(
              "Failed to upload problem PDF for exercise ${i + 1}",
            );
            return;
          }
        } else if (problemUrl.isEmpty &&
            selectedChapter!.exercises != null &&
            i < selectedChapter!.exercises!.length) {
          // Use previous problem URL
          problemUrl = selectedChapter!.exercises![i].problemUrl ?? "";
        }

        // Upload solution PDF if new file selected
        if (exercises[i].solutionPDF.value != null) {
          EasyLoading.show(status: "Uploading exercise ${i + 1} solution...");
          final uploadedUrl = await uploadSingleFile(
            exercises[i].solutionPDF.value!,
          );
          if (uploadedUrl != null) {
            solutionUrl = uploadedUrl;
          } else {
            EasyLoading.showError(
              "Failed to upload solution PDF for exercise ${i + 1}",
            );
            return;
          }
        } else if (solutionUrl.isEmpty &&
            selectedChapter!.exercises != null &&
            i < selectedChapter!.exercises!.length) {
          // Use previous solution URL
          solutionUrl = selectedChapter!.exercises![i].solutionUrl ?? "";
        }

        // Validate that both problem and solution URLs exist
        if (problemUrl.isEmpty || solutionUrl.isEmpty) {
          EasyLoading.showError(
            "Exercise ${i + 1} must have both problem and solution PDFs",
          );
          return;
        }

        exercisesPayload.add({
          "problemUrl": problemUrl,
          "solutionUrl": solutionUrl,
          "problemFileName":
              exercises[i].problemFileName.value.isNotEmpty
                  ? exercises[i].problemFileName.value
                  : (selectedChapter!.exercises != null &&
                          i < selectedChapter!.exercises!.length
                      ? (selectedChapter!.exercises![i].problemFileName ?? '')
                      : ''),
          "solutionFileName":
              exercises[i].solutionFileName.value.isNotEmpty
                  ? exercises[i].solutionFileName.value
                  : (selectedChapter!.exercises != null &&
                          i < selectedChapter!.exercises!.length
                      ? (selectedChapter!.exercises![i].solutionFileName ?? '')
                      : ''),
        });
      }

      // Validate exercises array
      if (exercisesPayload.isEmpty) {
        EasyLoading.showError("At least one exercise is required");
        return;
      }

      // Prepare request body - send ALL required fields
      final body = jsonEncode({
        "chapterName": chapterName,
        "theory": theoryUrl,
        "theoryFileName":
            theoryFileName.value.isNotEmpty
                ? theoryFileName.value
                : (selectedChapter?.theoryFileName ?? ''),
        "exercises": exercisesPayload,
      });

      log("Update request body: $body");

      EasyLoading.show(status: "Saving changes...");
      final response = await http.put(
        Uri.parse("${Urls.baseUrl}/chapter/$id"),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: body,
      );

      log("Update response status: ${response.statusCode}");
      log("Update response body: ${response.body}");

      if (response.statusCode == 200) {
        EasyLoading.showSuccess('Chapter updated successfully');
        // Clear image cache so refreshed content loads correctly
        try {
          PaintingBinding.instance.imageCache.clear();
          PaintingBinding.instance.imageCache.clearLiveImages();
        } catch (_) {}
        // Reset file selections
        pdfFile.value = null;
        theoryFileName.value = '';
        for (var ex in exercises) {
          ex.problemPDF.value = null;
          ex.solutionPDF.value = null;
        }
        // Invalidate cache to force refresh
        isDataLoaded.value = false;
        await loadAllData(forceRefresh: true);
        Get.back();
      } else {
        try {
          final errorData = jsonDecode(response.body);
          EasyLoading.showError(
            errorData['message'] ?? 'Failed to update chapter',
          );
        } catch (e) {
          EasyLoading.showError(
            'Failed to update chapter. Status: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      log("Error in updateChapterCollective: $e");
      EasyLoading.showError("An error occurred: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  // Check if cache is still valid
  bool get isCacheValid {
    final now = DateTime.now();
    return isDataLoaded.value &&
        now.difference(lastFetchTime.value) < cacheDuration;
  }

  // Main method to load all data efficiently
  Future<void> loadAllData({bool forceRefresh = false}) async {
    // Use cache if valid and not forcing refresh
    if (!forceRefresh && isCacheValid) {
      if (kDebugMode) print('Using cached data');
      return;
    }

    try {
      isLoading.value = true;
      final String? token = await SharePref.getSavedToken();
      if (token == null) {
        EasyLoading.showError("Authentication token not found");
        return;
      }

      // Fetch mixed content
      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/content/my-content'),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      if (kDebugMode) {
        print('Load all data response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'] as List;

        // Store content list for theory tab
        contentList.value =
            data.map((item) => ContentItemModel.fromJson(item)).toList();
        filteredContent.value = contentList;

        // Collect all chapter IDs
        List<String> chapterIds = [];
        for (var item in data) {
          if (item['type'] == 'chapter') {
            final chId = item['id'] ?? item['chapterId'];
            if (chId != null) chapterIds.add(chId);
          }
        }

        // Fetch folder chapters in parallel
        List<Future<void>> folderFutures = [];
        for (var item in data) {
          if (item['type'] == 'folder' && item['folderId'] != null) {
            folderFutures.add(
              _fetchFolderChapters(item['folderId'], token, chapterIds),
            );
          }
        }
        await Future.wait(folderFutures);

        // Fetch all chapter details in parallel (with exercises)
        List<Future<ChapterModel?>> chapterFutures =
            chapterIds.map((id) => _fetchChapterDetail(id, token)).toList();

        final chapters = await Future.wait(chapterFutures);

        // Filter out nulls and update lists
        chapterList.value = chapters.whereType<ChapterModel>().toList();
        filteredItems.value = chapterList;

        // Mark data as loaded and update cache time
        isDataLoaded.value = true;
        lastFetchTime.value = DateTime.now();

        if (kDebugMode) {
          print('Loaded ${chapterList.length} chapters with exercises');
        }
      } else {
        throw Exception('Failed to fetch content: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error loading data: $e');
      EasyLoading.showError('Failed to load data');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper to fetch folder chapters
  Future<void> _fetchFolderChapters(
    String folderId,
    String token,
    List<String> chapterIds,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/content/folder/$folderId/chapters'),
        headers: {'Authorization': token},
      );
      if (response.statusCode == 200) {
        final folderJson = json.decode(response.body);
        final folderData = folderJson['data'] as List? ?? [];

        // Pre-populate folderChaptersCache so PDF search works without
        // requiring the user to expand the folder first.
        if (!folderChaptersCache.containsKey(folderId)) {
          final cached = <dynamic>[].obs;
          cached.addAll(folderData);
          folderChaptersCache[folderId] = cached;
        }

        for (var ch in folderData) {
          final chId = ch['id'] ?? ch['chapterId'];
          if (chId != null && !chapterIds.contains(chId)) {
            chapterIds.add(chId);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching folder $folderId: $e');
    }
  }

  // Helper to fetch individual chapter with exercises
  Future<ChapterModel?> _fetchChapterDetail(
    String chapterId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/chapter/$chapterId'),
        headers: {'Authorization': token},
      );
      if (response.statusCode == 200) {
        final chapterJson = json.decode(response.body);
        return ChapterModel.fromJson(chapterJson['data']);
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching chapter $chapterId: $e');
    }
    return null;
  }

  // ...rest of the class unchanged...

  void initializeExercises(List<Exercise> existingExercises) {
    exercises.clear();
    for (var exercise in existingExercises) {
      final exerciseModel = ExerciseModel();
      exerciseModel.problemUrl.value = exercise.problemUrl ?? '';
      exerciseModel.solutionUrl.value = exercise.solutionUrl ?? '';
      exerciseModel.problemFileName.value = exercise.problemFileName ?? '';
      exerciseModel.solutionFileName.value = exercise.solutionFileName ?? '';
      exercises.add(exerciseModel);
    }
    if (exercises.isEmpty) {
      addNewExercise();
    }
  }

  void addNewExercise() {
    exercises.add(ExerciseModel());
  }

  void deleteExercise(int index) {
    if (exercises.length > 1) {
      exercises.removeAt(index);
    } else {
      EasyLoading.showError("At least one exercise pair is required.");
    }
  }

  Future<void> pickProblemPDF(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      exercises[index].problemPDF.value = File(result.files.single.path!);
      exercises[index].problemFileName.value = result.files.single.name;
      // Clear the old URL since we have a new file
      exercises[index].problemUrl.value = '';
      EasyLoading.showSuccess('Problem PDF selected');
    }
  }

  Future<void> pickSolutionPDF(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      exercises[index].solutionPDF.value = File(result.files.single.path!);
      exercises[index].solutionFileName.value = result.files.single.name;
      // Clear the old URL since we have a new file
      exercises[index].solutionUrl.value = '';
      EasyLoading.showSuccess('Solution PDF selected');
    }
  }

  Future<void> pickImage() async {
    // simple static flag to avoid concurrent picker invocations
    if (_imagePickerActive) return;
    _imagePickerActive = true;
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        image.value = File(pickedFile.path);
      }
    } on PlatformException catch (e) {
      if (e.code == 'already_active') {
        if (kDebugMode) print('Image picker already active (edit) - ignored');
      } else {
        EasyLoading.showError('Failed to pick image');
      }
    } catch (e) {
      if (kDebugMode) print('Unexpected image pick error (edit): $e');
    } finally {
      _imagePickerActive = false;
    }
  }

  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      pdfFile.value = File(result.files.single.path!);
      theoryFileName.value = result.files.single.name;
    }
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
                  // Check exercises of folder chapter via chapterList
                  final chId = (map['id'] ?? map['chapterId'] ?? '').toString();
                  final chapterDetail = chapterList.firstWhereOrNull(
                    (c) => (c.id ?? '') == chId,
                  );
                  return chapterDetail?.exercises?.any(
                        (ex) =>
                            _matchesPdfQuery(ex.problemUrl, normalizedQuery) ||
                            _matchesPdfQuery(ex.solutionUrl, normalizedQuery) ||
                            (ex.problemFileName ?? '').toLowerCase().contains(
                              normalizedQuery,
                            ) ||
                            (ex.solutionFileName ?? '').toLowerCase().contains(
                              normalizedQuery,
                            ),
                      ) ??
                      false;
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
              final chapter = chapterList.firstWhereOrNull(
                (ch) => (ch.id ?? '') == chapterId,
              );

              final matchesExercisePdf =
                  chapter?.exercises?.any(
                    (ex) =>
                        _matchesPdfQuery(ex.problemUrl, normalizedQuery) ||
                        _matchesPdfQuery(ex.solutionUrl, normalizedQuery) ||
                        (ex.problemFileName ?? '').toLowerCase().contains(
                          normalizedQuery,
                        ) ||
                        (ex.solutionFileName ?? '').toLowerCase().contains(
                          normalizedQuery,
                        ),
                  ) ??
                  false;

              return chapterName.contains(normalizedQuery) ||
                  matchesTheory ||
                  matchesExercisePdf;
            }
          }).toList();
    }
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
    if (oldIndex < 0 || oldIndex >= filteredContent.length) return;

    final originalOrder = filteredContent.toList();

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    if (newIndex < 0 || newIndex >= filteredContent.length) return;
    if (oldIndex == newIndex) return;

    // Perform local reorder for immediate UI update
    final item = filteredContent.removeAt(oldIndex);
    filteredContent.insert(newIndex, item);
    contentList.value = filteredContent.toList();
    filteredContent.refresh();

    // Persist exact move behavior to backend by replaying adjacent swaps.
    unawaited(_persistMoveOrder(originalOrder, oldIndex, newIndex));
  }

  String _resolveItemId(ContentItemModel item) {
    return (item.id ?? item.chapterId ?? item.folderId ?? '').toString();
  }

  Future<void> _persistMoveOrder(
    List<ContentItemModel> originalOrder,
    int oldIndex,
    int newIndex,
  ) async {
    try {
      if (oldIndex < newIndex) {
        for (int i = oldIndex; i < newIndex; i++) {
          final item1Id = _resolveItemId(originalOrder[i]);
          final item2Id = _resolveItemId(originalOrder[i + 1]);
          if (item1Id.isEmpty || item2Id.isEmpty) continue;
          await swapContent(item1Id, item2Id, refreshAfterSwap: false);
        }
      } else {
        for (int i = oldIndex; i > newIndex; i--) {
          final item1Id = _resolveItemId(originalOrder[i]);
          final item2Id = _resolveItemId(originalOrder[i - 1]);
          if (item1Id.isEmpty || item2Id.isEmpty) continue;
          await swapContent(item1Id, item2Id, refreshAfterSwap: false);
        }
      }

      isDataLoaded.value = false;
      await loadAllData(forceRefresh: true);
    } catch (e) {
      if (kDebugMode) {
        print('Error persisting moved order: $e');
      }
      EasyLoading.showError('Failed to save order changes');
      isDataLoaded.value = false;
      await loadAllData(forceRefresh: true);
    }
  }

  Future<void> sendUpdatedOrderToApi() async {
    final String? token = await SharePref.getSavedToken();
    if (token == null) {
      EasyLoading.showError("No token found");
      return;
    }

    final chapterIds = filteredItems.map((chapter) => chapter.id).toList();

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

  Future<void> toggleFavourite(String id) async {
    final String? token = await SharePref.getSavedToken();
    if (token == null) {
      EasyLoading.showError("No token found");
      return;
    }

    final contentIndex = contentList.indexWhere(
      (item) => item.id == id && item.isChapter,
    );
    final filterIndex = filteredContent.indexWhere(
      (item) => item.id == id && item.isChapter,
    );

    if (contentIndex == -1 || filterIndex == -1) {
      EasyLoading.showError("Chapter not found");
      return;
    }

    bool oldFavoriteStatus = contentList[contentIndex].isFavorite ?? false;
    bool newFavoriteStatus = !oldFavoriteStatus;

    contentList[contentIndex].isFavorite = newFavoriteStatus;
    filteredContent[filterIndex].isFavorite = newFavoriteStatus;

    contentList.refresh();
    filteredContent.refresh();

    try {
      final response = await http.post(
        Uri.parse(Urls.toggleFavourite),
        headers: {"Content-Type": "application/json", 'Authorization': token},
        body: jsonEncode({"chapterId": id}),
      );

      if (kDebugMode) {
        print("Favourite toggle Status code: ${response.statusCode}");
        print("Body: ${response.body}");
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        contentList[contentIndex].isFavorite = oldFavoriteStatus;
        filteredContent[filterIndex].isFavorite = oldFavoriteStatus;
        contentList.refresh();
        filteredContent.refresh();
        EasyLoading.showError("Failed to toggle favorite");
      }
    } catch (e) {
      contentList[contentIndex].isFavorite = oldFavoriteStatus;
      filteredContent[filterIndex].isFavorite = oldFavoriteStatus;
      contentList.refresh();
      filteredContent.refresh();
      if (kDebugMode) {
        print("Error toggling favorite: $e");
      }
    }
  }

  Future<void> createFolder(String folderName) async {
    try {
      EasyLoading.show(status: 'Creating folder...');
      final String? token = await SharePref.getSavedToken();
      if (token == null) {
        throw Exception('No authentication token found');
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
        isDataLoaded.value = false;
        await loadAllData(forceRefresh: true);
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

  Future<List<ChapterModel>> getAllChapters() async {
    try {
      final String? token = await SharePref.getSavedToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/chapter'),
        headers: {'Authorization': token},
      );

      if (kDebugMode) {
        print('Get all chapters response status: ${response.statusCode}');
        print('Get all chapters response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'] as List;
        return data.map((e) => ChapterModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch chapters: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching chapters: $e');
      }
      EasyLoading.showError('Error fetching chapters: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllFolders() async {
    try {
      final String? token = await SharePref.getSavedToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/folder/my'),
        headers: {'Authorization': token},
      );

      if (kDebugMode) {
        print('Get all folders response status: ${response.statusCode}');
        print('Get all folders response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'] as List;
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to fetch folders: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching folders: $e');
      }
      EasyLoading.showError('Error fetching folders: $e');
      return [];
    }
  }

  Future<void> deleteFolder(String folderId) async {
    try {
      EasyLoading.show(status: 'Deleting folder and chapters...');
      final String? token = await SharePref.getSavedToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // First, fetch all chapters in the folder
      final chaptersResponse = await http.get(
        Uri.parse('${Urls.baseUrl}/content/folder/$folderId/chapters'),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
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
              'Authorization': token,
              'Content-Type': 'application/json',
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
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      if (kDebugMode) {
        print('Delete folder response status: ${response.statusCode}');
        print('Delete folder response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        EasyLoading.showSuccess('Folder deleted. Chapters moved to main page.');
        isDataLoaded.value = false;
        await loadAllData(forceRefresh: true);
      } else {
        try {
          final body = jsonDecode(response.body);
          EasyLoading.showError(body['message'] ?? 'Failed to delete folder');
        } catch (_) {
          EasyLoading.showError('Failed to delete folder');
        }
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

  Future<void> addChapterToFolder(String folderId, String chapterId) async {
    try {
      EasyLoading.show(status: 'Adding chapter to folder...');
      final String? token = await SharePref.getSavedToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${Urls.baseUrl}/folder/add-chapter-folder'),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: jsonEncode({'folderId': folderId, 'chapterId': chapterId}),
      );

      if (kDebugMode) {
        print('Add chapter to folder response status: ${response.statusCode}');
        print('Add chapter to folder response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        EasyLoading.showSuccess('Chapter added to folder successfully');
        isDataLoaded.value = false;
        await loadAllData(forceRefresh: true);
      } else {
        throw Exception(
          'Failed to add chapter to folder: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding chapter to folder: $e');
      }
      EasyLoading.showError('Error adding chapter to folder: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> removeChapterFromFolder(String chapterId) async {
    try {
      EasyLoading.show(status: 'Removing chapter from folder...');
      final String? token = await SharePref.getSavedToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.delete(
        Uri.parse(Urls.removeChapterFromFolder(chapterId)),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      if (kDebugMode) {
        print(
          'Remove chapter from folder response status: ${response.statusCode}',
        );
        print('Remove chapter from folder response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        EasyLoading.showSuccess('Chapter removed from folder successfully');

        // Clear all folder caches since we don't know which folder the chapter was in
        folderChaptersCache.clear();
        expandedFolders.clear();
        expandedFoldersExercise.clear();

        isDataLoaded.value = false;
        await loadAllData(forceRefresh: true);
      } else {
        throw Exception(
          'Failed to remove chapter from folder: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing chapter from folder: $e');
      }
      EasyLoading.showError('Error removing chapter from folder: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> swapContent(
    String item1Id,
    String item2Id, {
    bool refreshAfterSwap = true,
  }) async {
    try {
      final String? token = await SharePref.getSavedToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${Urls.baseUrl}/content/swap-content'),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: jsonEncode({'item1Id': item1Id, 'item2Id': item2Id}),
      );

      if (kDebugMode) {
        print('Swap content response status: ${response.statusCode}');
        print('Swap content response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        if (!refreshAfterSwap) return;
        isDataLoaded.value = false;
        await loadAllData(forceRefresh: true);
      } else {
        throw Exception('Failed to swap content: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error swapping content: $e');
      }
      EasyLoading.showError('Error swapping content: $e');
    }
  }

  // Use loadAllData instead - this method now just ensures data is loaded
  Future<void> fetchMixedContent() async {
    await loadAllData();
  }

  // Use loadAllData instead - this method now just ensures data is loaded
  Future<void> fetchChapter() async {
    // Force refresh to bypass cache so deletions/updates propagate immediately
    await loadAllData(forceRefresh: true);
  }

  Future<void> updateChapterAndTheory(String id) async {
    try {
      EasyLoading.show(status: "Updating...");
      final String? token = await SharePref.getSavedToken();
      if (token == null) {
        EasyLoading.showError("Authentication token not found");
        return;
      }

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse("${Urls.baseUrl}/chapter/$id"),
      );

      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': token,
      });

      request.fields['chapterName'] = jsonEncode({
        "chapterName": chapterNameController.text.trim(),
      });

      if (image.value != null) {
        final imageStream = http.ByteStream(image.value!.openRead());
        final imageLength = await image.value!.length();
        final imageFile = http.MultipartFile(
          'cover',
          imageStream,
          imageLength,
          filename: image.value!.path.split('/').last,
          contentType: MediaType.parse('image/jpeg'),
        );
        request.files.add(imageFile);
      }

      if (pdfFile.value != null) {
        final pdfStream = http.ByteStream(pdfFile.value!.openRead());
        final pdfLength = await pdfFile.value!.length();
        final pdfMultipartFile = http.MultipartFile(
          'theory',
          pdfStream,
          pdfLength,
          filename: pdfFile.value!.path.split('/').last,
          contentType: MediaType.parse('application/pdf'),
        );
        request.files.add(pdfMultipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        pdfFile.value = null;
        EasyLoading.showSuccess('Updated theory and chapter successfully');
        isDataLoaded.value = false;
        await loadAllData(forceRefresh: true);
        Get.back();
      } else {
        EasyLoading.showError('Failed to update theory and chapter');
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
      EasyLoading.showError("An error occurred: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> updateExercises(String chapterId) async {
    try {
      EasyLoading.show(status: "Loading...");
      final String? token = await SharePref.getSavedToken();
      if (token == null) {
        EasyLoading.showError("Authentication token not found");
        return;
      }

      final url = "${Urls.baseUrl}/chapter/exercise/$chapterId";
      final request = http.MultipartRequest('PUT', Uri.parse(url))
        ..headers.addAll({
          "Authorization": token,
          "Content-Type": "multipart/form-data",
        });

      // Logging initial info

      // Add exercise PDFs or URLs
      for (int i = 0; i < exercises.length; i++) {
        if (exercises[i].problemPDF.value != null) {
          final problemStream = http.ByteStream(
            exercises[i].problemPDF.value!.openRead(),
          );
          final problemLength = await exercises[i].problemPDF.value!.length();
          final multipartProblem = http.MultipartFile(
            'exercise[$i][problem]',
            problemStream,
            problemLength,
            filename: exercises[i].problemPDF.value!.path.split('/').last,
            contentType: MediaType.parse('application/pdf'),
          );
          request.files.add(multipartProblem);
        } else if (exercises[i].problemUrl.value.isNotEmpty) {
          request.fields['exercise[$i][problem_url]'] =
              exercises[i].problemUrl.value;
        }

        if (exercises[i].solutionPDF.value != null) {
          final solutionStream = http.ByteStream(
            exercises[i].solutionPDF.value!.openRead(),
          );
          final solutionLength = await exercises[i].solutionPDF.value!.length();
          final multipartSolution = http.MultipartFile(
            'exercise[$i][solution]',
            solutionStream,
            solutionLength,
            filename: exercises[i].solutionPDF.value!.path.split('/').last,
            contentType: MediaType.parse('application/pdf'),
          );
          request.files.add(multipartSolution);
        } else if (exercises[i].solutionUrl.value.isNotEmpty) {
          request.fields['exercise[$i][solution_url]'] =
              exercises[i].solutionUrl.value;
        }
      }

      // Validation
      if (exercises.any(
        (e) =>
            (e.problemPDF.value == null && e.problemUrl.value.isEmpty) ||
            (e.solutionPDF.value == null && e.solutionUrl.value.isEmpty),
      )) {
        EasyLoading.showError(
          "Please provide both Problem and Solution PDFs or URLs for all exercise pairs.",
        );
        return;
      }

      // Print all fields before sending
      request.fields.forEach((key, value) {});

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log("✅ Update exercises status: ${response.statusCode}");
      log("📥 Update exercises response: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        exercises.clear();
        EasyLoading.showSuccess(
          responseData["message"] ?? "Exercises updated successfully!",
        );
        isDataLoaded.value = false;
        await loadAllData(forceRefresh: true);
        Get.back();
        Get.back();
      } else {
        final responseData = jsonDecode(response.body);
        EasyLoading.showError(
          responseData["error"] ?? "Failed to update exercises.",
        );
      }
    } on SocketException {
      log("❌ No Internet connection");
      EasyLoading.showError(
        "No Internet connection. Please check your network.",
      );
    } on TimeoutException {
      log("⏱️ Request timed out");
      EasyLoading.showError(
        "Server is taking too long to respond. Please try again later.",
      );
    } on HttpException {
      log("❗ HTTP Exception occurred");
      EasyLoading.showError("Something went wrong. Please try again.");
    } on FormatException {
      log("⚠️ Invalid JSON format");
      EasyLoading.showError("Server response was not in the expected format.");
    } catch (e) {
      log("🛑 Update exercises error: $e");
      EasyLoading.showError("An error occurred: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// Toggle folder expansion state for admin hierarchical UI
  Future<void> toggleFolderExpansion(String folderId) async {
    if (expandedFolders.contains(folderId)) {
      expandedFolders.remove(folderId);
    } else {
      expandedFolders.add(folderId);
      // Load chapters for this folder if not cached
      await loadFolderChapters(folderId);
    }
  }

  /// Toggle folder expansion state for admin exercise tab (independent from theory)
  Future<void> toggleFolderExpansionExercise(String folderId) async {
    if (expandedFoldersExercise.contains(folderId)) {
      expandedFoldersExercise.remove(folderId);
    } else {
      expandedFoldersExercise.add(folderId);
      // Reuse same cache as theory tab
      await loadFolderChapters(folderId);
    }
  }

  /// Load chapters for a specific folder (admin version)
  Future<void> loadFolderChapters(String folderId) async {
    if (folderChaptersCache.containsKey(folderId)) {
      return; // Already cached
    }

    try {
      final String? token = await SharePref.getSavedToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/content/folder/$folderId/chapters'),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      if (kDebugMode) {
        print('Admin folder $folderId chapters status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'] as List? ?? [];

        // Create observable list and cache it    
        final chapters = <dynamic>[].obs;
        chapters.addAll(data);
        folderChaptersCache[folderId] = chapters;

        // Trigger UI refresh to show the chapters
        expandedFolders.refresh();
      }
    } catch (e) {
      if (kDebugMode) print('Error loading admin folder chapters: $e');
    }
  }
}
