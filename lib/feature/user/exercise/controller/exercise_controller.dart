import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/network_caller/endpoints.dart';
import 'package:goatlearning/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:goatlearning/feature/user/home/model/user_chapter_model.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ExerciseController extends GetxController {
  var showQuestionView = false.obs;
  var currentQuestionIndex = 0.obs;
  var solutionVisible = <int, Rx<bool>>{}.obs;
  var problemTotalPages = <int, Rx<int>>{}.obs;
  var problemCurrentPage = <int, Rx<int>>{}.obs;
  var problemProgress = <int, Rx<double>>{}.obs;
  var problemHighestProgress = <int, Rx<double>>{}.obs;
  var solutionTotalPages = <int, Rx<int>>{}.obs;
  var solutionCurrentPage = <int, Rx<int>>{}.obs;
  var solutionProgress = <int, Rx<double>>{}.obs;
  var solutionHighestProgress = <int, Rx<double>>{}.obs;

  // Changed to nullable controllers with lazy creation
  final RxMap<int, PdfViewerController?> problemPdfControllers =
      <int, PdfViewerController?>{}.obs;
  final RxMap<int, PdfViewerController?> solutionPdfControllers =
      <int, PdfViewerController?>{}.obs;

  List<Exercise> exercises = [];
  String chapterId = '';

  Future<ChapterDetail?> getChapterDetails(String chapterId) async {
    if (kDebugMode) {
      print("Fetching chapter details...");
    }
    final String? token = await SharePref.getSavedToken();
    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) headers['Authorization'] = token;
      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/chapter/$chapterId'),
        headers: headers,
      );

      if (kDebugMode) {
        print('Chapter Details Response status: ${response.statusCode}');
        print('Chapter Details Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final chapterResponse = parseChapterDetailResponse(response.body);
        if (chapterResponse.success &&
            chapterResponse.data.exercises.isNotEmpty) {
          return chapterResponse.data;
        }
        // If the chapter response doesn't include exercises (or success false),
        // fall back to the public exercise-by-chapter endpoint which lists
        // exercises for a chapter and does not require authentication.
        if (kDebugMode) {
          print(
            'Falling back to /exercise/chapter/:chapterId to fetch exercises',
          );
        }
      } else if (response.statusCode == 401 && (token == null || token.isEmpty)) {
        if (kDebugMode) print('Guest user: 401 on chapter detail; will fall back to public exercises');
      } else {
        if (kDebugMode) {
          print('Primary chapter endpoint failed with status ${response.statusCode}, falling back');
        }
      }

      // Fallback: call public exercises endpoint for chapter
      try {
        final exResponse = await http.get(
          Uri.parse(
            '${Urls.baseUrl.replaceAll("/api/v1", "")}/api/v1/exercise/chapter/$chapterId',
          ),
          headers: {'Content-Type': 'application/json'},
        );

        if (kDebugMode) {
          print('Exercise by chapter status: ${exResponse.statusCode}');
          print('Exercise by chapter body: ${exResponse.body}');
        }

        if (exResponse.statusCode == 200) {
          final jsonData = json.decode(exResponse.body) as Map<String, dynamic>;
          // The exercise endpoint returns chapter + exercises under data
          final exercisesData = jsonData['data'] ?? {};
          // Build ChapterDetail from returned structure
          final chapterDetail = ChapterDetail(
            id: exercisesData['chapter']?['id'] ?? chapterId,
            chapterName: exercisesData['chapter']?['name'] ?? '',
            coverImage: exercisesData['chapter']?['coverImage'] ?? '',
            theory: exercisesData['chapter']?['theory'] ?? '',
            exercises:
                (exercisesData['exercises'] as List? ?? [])
                    .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
                    .toList(),
          );
          return chapterDetail;
        } else {
          EasyLoading.showError(
            'Error fetching exercises: ${exResponse.statusCode}',
          );
          return null;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Fallback exercise fetch error: $e');
        }
        EasyLoading.showError('Failed to load chapter exercises');
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching chapter details: $e");
      }
      EasyLoading.showError('Failed to load chapter details');
      return null;
    }
  }

  void initializeExercises(List<Exercise> newExercises, String newChapterId) {
    exercises = newExercises;
    chapterId = newChapterId;

    // Initialize your Rx variables and clear any existing controllers safely
    solutionVisible.clear();
    problemTotalPages.clear();
    problemCurrentPage.clear();
    problemProgress.clear();
    problemHighestProgress.clear();
    solutionTotalPages.clear();
    solutionCurrentPage.clear();
    solutionProgress.clear();
    solutionHighestProgress.clear();

    problemPdfControllers.forEach((key, controller) {
      controller?.dispose();
    });
    solutionPdfControllers.forEach((key, controller) {
      controller?.dispose();
    });
    problemPdfControllers.clear();
    solutionPdfControllers.clear();

    for (int i = 0; i < exercises.length; i++) {
      solutionVisible[i] = Rx<bool>(false);
      problemTotalPages[i] = Rx<int>(1);
      problemCurrentPage[i] = Rx<int>(1);
      problemProgress[i] = Rx<double>(0.0);
      problemHighestProgress[i] = Rx<double>(0.0);
      solutionTotalPages[i] = Rx<int>(1);
      solutionCurrentPage[i] = Rx<int>(1);
      solutionProgress[i] = Rx<double>(0.0);
      solutionHighestProgress[i] = Rx<double>(0.0);

      // Lazy initialization - don't create here, create on demand
    }
  }

  PdfViewerController getProblemPdfController(int index) {
    if (!problemPdfControllers.containsKey(index) ||
        problemPdfControllers[index] == null) {
      problemPdfControllers[index] = PdfViewerController();
    }
    return problemPdfControllers[index]!;
  }

  PdfViewerController getSolutionPdfController(int index) {
    if (!solutionPdfControllers.containsKey(index) ||
        solutionPdfControllers[index] == null) {
      solutionPdfControllers[index] = PdfViewerController();
    }
    return solutionPdfControllers[index]!;
  }

  void clearControllersExcept(int index) {
    // Dispose and remove all controllers except current index
    problemPdfControllers.keys.where((i) => i != index).toList().forEach((i) {
      problemPdfControllers[i]?.dispose();
      problemPdfControllers.remove(i);
    });
    solutionPdfControllers.keys.where((i) => i != index).toList().forEach((i) {
      solutionPdfControllers[i]?.dispose();
      solutionPdfControllers.remove(i);
    });
  }

  void toggleSolution(int index) {
    if (!solutionVisible[index]!.value) {
      final problemPercent = (problemHighestProgress[index]?.value ?? 0.0) * 50;
      final solutionPercent =
          (solutionHighestProgress[index]?.value ?? 0.0) * 50;
      final totalPercent =
          (problemPercent + solutionPercent).toInt().toDouble();
      calculatorPercent(chapterId, totalPercent);
    }
    solutionVisible[index]?.value = !solutionVisible[index]!.value;
  }

  void goToQuestion(int index) {
    currentQuestionIndex.value = index;
    clearControllersExcept(index);
    showQuestionView.value = true;
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < exercises.length - 1) {
      final index = currentQuestionIndex.value;
      final problemPercent = (problemHighestProgress[index]?.value ?? 0.0) * 50;
      final solutionPercent =
          (solutionHighestProgress[index]?.value ?? 0.0) * 50;
      final totalPercent =
          (problemPercent + solutionPercent).toInt().toDouble();
      calculatorPercent(chapterId, totalPercent);

      currentQuestionIndex.value++;
      clearControllersExcept(currentQuestionIndex.value);
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      final index = currentQuestionIndex.value;
      final problemPercent = (problemHighestProgress[index]?.value ?? 0.0) * 50;
      final solutionPercent =
          (solutionHighestProgress[index]?.value ?? 0.0) * 50;
      final totalPercent =
          (problemPercent + solutionPercent).toInt().toDouble();
      calculatorPercent(chapterId, totalPercent);

      currentQuestionIndex.value--;
      clearControllersExcept(currentQuestionIndex.value);
    }
  }

  void updateProblemProgress(int index, int currentPage, int totalPages) {
    problemCurrentPage[index]?.value = currentPage;
    problemTotalPages[index]?.value = totalPages;
    final progress = currentPage / totalPages;
    problemProgress[index]?.value = progress;
    if (progress > (problemHighestProgress[index]?.value ?? 0.0)) {
      problemHighestProgress[index]?.value = progress;
      if (kDebugMode) {
        print("🔥 Problem Progress: ${(progress * 100).toStringAsFixed(1)}%");
      }
    }
  }

  void updateSolutionProgress(int index, int currentPage, int totalPages) {
    solutionCurrentPage[index]?.value = currentPage;
    solutionTotalPages[index]?.value = totalPages;
    final progress = currentPage / totalPages;
    solutionProgress[index]?.value = progress;
    if (progress > (solutionHighestProgress[index]?.value ?? 0.0)) {
      solutionHighestProgress[index]?.value = progress;
      if (kDebugMode) {
        print("🔥 Solution Progress: ${(progress * 100).toStringAsFixed(1)}%");
      }
    }
  }

  Future<void> calculatorPercent(String id, double percent) async {
    if (id.isEmpty) return;
    final String? token = await SharePref.getSavedToken();
    
    // Skip progress update if no token (guest user)
    if (token == null || token.isEmpty) {
      if (kDebugMode) print('Cannot update progress: not authenticated');
      return;
    }
    
    try {
      final response = await http.post(
        Uri.parse("${Urls.baseUrl}/complete"),
        headers: {
          "Content-Type": "application/json",
          'Authorization': token,
        },
        body: jsonEncode({"chapterId": id, "completePercent": percent}),
      );

      if (kDebugMode) {
        print("completePercent: ${response.statusCode}");
        print("Body completePercent: ${response.body}");
      }

      if (response.statusCode != 201) {
        if (kDebugMode) print("Failed to update progress: ${response.statusCode}");
        // Don't show error to user - progress tracking is optional for guest users
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating percent: $e");
      }
      // Don't show error to user - progress tracking is optional
    }
  }

  @override
  void dispose() {
    for (var controller in problemPdfControllers.values) {
      controller?.dispose();
    }
    for (var controller in solutionPdfControllers.values) {
      controller?.dispose();
    }
    super.dispose();
  }
}
