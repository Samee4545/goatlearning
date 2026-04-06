import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/network_caller/endpoints.dart';
import 'package:goatlearning/core/route/routes.dart';
import 'package:goatlearning/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:goatlearning/feature/admin/add_new/model/exercise_model.dart';
import 'package:goatlearning/feature/admin/edit/controller/admin_edit_controller.dart';
import 'package:goatlearning/feature/user/home/controller/home_controller.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class AdminAddNewController extends GetxController {
  RxList<ExerciseModel> exercises = <ExerciseModel>[].obs;
  RxString coverImageUrl = ''.obs;
  RxString theoryPdfUrl = ''.obs;
  RxString theoryFileName = ''.obs;
  bool _isImagePicking = false; // guard against concurrent picker launches

  TextEditingController exerciseAddedController = TextEditingController();
  TextEditingController chapterNameController = TextEditingController();
  RxString exerciseAddedMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    addNewExercise();
  }

  void addNewExercise() {
    exercises.add(ExerciseModel());
  }

  // Upload single file to server and return URL
  Future<String?> uploadSingleFile(File file) async {
    try {
      EasyLoading.show(status: "Uploading...");
      String? token = await SharePref.getSavedToken();
      if (token == null) {
        EasyLoading.showError("Authentication token not found");
        return null;
      }

      final Uri url = Uri.parse(Urls.uploadSingle);
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll({'Authorization': token});

      // Determine file type based on extension
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

      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData['data']['url'] as String?;
        } else {
          EasyLoading.showError("Failed to upload file");
          return null;
        }
      } else {
        EasyLoading.showError(
          "Failed to upload file. Status: ${response.statusCode}",
        );
        return null;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError("An error occurred during upload: $e");
      return null;
    }
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
      File file = File(result.files.single.path!);
      exercises[index].problemFileName.value = result.files.single.name;
      String? url = await uploadSingleFile(file);
      if (url != null) {
        exercises[index].problemUrl.value = url;
      }
    }
  }

  Future<void> pickSolutionPDF(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      exercises[index].solutionFileName.value = result.files.single.name;
      String? url = await uploadSingleFile(file);
      if (url != null) {
        exercises[index].solutionUrl.value = url;
      }
    }
  }

  Future<void> pickImage() async {
    if (_isImagePicking) return; // prevent re-entry
    _isImagePicking = true;
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        File file = File(pickedFile.path);
        String? url = await uploadSingleFile(file);
        if (url != null) {
          coverImageUrl.value = url;
        }
      }
    } on PlatformException catch (e) {
      if (e.code == 'already_active') {
        if (kDebugMode) print('Image picker already active - ignored');
      } else {
        EasyLoading.showError('Failed to pick image');
      }
    } catch (e) {
      if (kDebugMode) print('Unexpected image pick error: $e');
    } finally {
      _isImagePicking = false;
    }
  }

  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      theoryFileName.value = result.files.single.name;
      String? url = await uploadSingleFile(file);
      if (url != null) {
        theoryPdfUrl.value = url;
      }
    }
  }

  void saveData() {
    bool allFieldsFilled = exercises.every(
      (e) => e.problemUrl.value.isNotEmpty && e.solutionUrl.value.isNotEmpty,
    );

    if (!allFieldsFilled) {
      EasyLoading.showError(
        "Please upload both Problem and Solution PDFs for all exercise pairs.",
      );
      return;
    }

    exerciseAddedMessage.value = "Exercise PDFs Added";
    exerciseAddedController.text = exerciseAddedMessage.value;
    Get.back();
  }

  Future<void> saveNewBook() async {
    EasyLoading.show(status: "Loading...");
    try {
      // Validate required fields
      if (chapterNameController.text.trim().isEmpty) {
        EasyLoading.showError("Chapter name is required");
        return;
      }

      if (theoryPdfUrl.value.isEmpty) {
        EasyLoading.showError("Theory PDF is required");
        return;
      }

      // Validate that all exercises have both URLs
      if (exercises.any(
        (e) => e.problemUrl.value.isEmpty || e.solutionUrl.value.isEmpty,
      )) {
        EasyLoading.showError(
          "Please upload both Problem and Solution PDFs for all exercise pairs.",
        );
        return;
      }

      String? token = await SharePref.getSavedToken();
      if (token == null) {
        EasyLoading.showError("Authentication token not found");
        return;
      }

      final Uri url = Uri.parse(Urls.addChapter);

      // Prepare exercises array
      final List<Map<String, String>> exercisesData =
          exercises.map((e) {
            return {
              "problemUrl": e.problemUrl.value,
              "solutionUrl": e.solutionUrl.value,
              "problemFileName": e.problemFileName.value,
              "solutionFileName": e.solutionFileName.value,
            };
          }).toList();

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        "chapterName": chapterNameController.text.trim(),
        "theory": theoryPdfUrl.value,
        "theoryFileName": theoryFileName.value,
        "isStandalone": true,
        "exercises": exercisesData,
      };

      final response = await http.post(
        url,
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          EasyLoading.showSuccess("New Chapter Created Successfully!");
          chapterNameController.clear();
          theoryPdfUrl.value = '';
          exerciseAddedMessage.value = "";
          exercises.clear();
          addNewExercise();
          final AdminEditController adminEditController = Get.put(
            AdminEditController(),
          );
          adminEditController.fetchChapter();
        } else {
          EasyLoading.showError("Failed to create the chapter.");
        }
      } else {
        EasyLoading.showError(
          "Failed to create the chapter. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      EasyLoading.showError("An error occurred: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> deleteChapter(String id) async {
    try {
      EasyLoading.show(status: "loading..");
      final String? token = await SharePref.getSavedToken();
      final url = "${Urls.deleteChapter}/$id";
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          "Authorization": "$token",
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        EasyLoading.showSuccess(responseBody["message"]);

        // Refresh admin edit list
        final adminEditController =
            Get.isRegistered<AdminEditController>()
                ? Get.find<AdminEditController>()
                : Get.put(AdminEditController());
        await adminEditController.fetchChapter();

        // Refresh user-side data if HomeController exists
        if (Get.isRegistered<HomeController>()) {
          final homeController = Get.find<HomeController>();

          // CRITICAL: Re-fetch exercises from backend to get updated list without deleted chapter's exercises
          await homeController.getAllExercises();

          // Also refresh chapters and other content
          await homeController.getMixedContent();
          await homeController.getFolderList();
          await homeController.getAllChapter();
          await homeController.fetchChaptersInFolders();
          await homeController.updateAllowedChapters();
        }
      }
    } catch (e) {
      EasyLoading.showError("Try after some time");
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> addExercise(String id) async {
    try {
      EasyLoading.show(status: "Loading...");

      // Validate that all fields are filled
      if (exercises.any(
        (e) => e.problemUrl.value.isEmpty || e.solutionUrl.value.isEmpty,
      )) {
        EasyLoading.showError(
          "Please upload both Problem and Solution PDFs for all exercise pairs.",
        );
        return;
      }

      final url = "${Urls.addExercise}/$id";
      final String? token = await SharePref.getSavedToken();

      // Prepare exercises array
      final List<Map<String, String>> exercisesData =
          exercises.map((e) {
            return {
              "problemUrl": e.problemUrl.value,
              "solutionUrl": e.solutionUrl.value,
            };
          }).toList();

      // Prepare request body
      final Map<String, dynamic> requestBody = {"exercises": exercisesData};

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      log("add exercise ${response.statusCode}");
      log("add exercise: ${response.body}");

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        exercises.clear();
        addNewExercise(); // Add a new empty exercise pair
        final AdminEditController adminEditController = Get.put(
          AdminEditController(),
        );
        adminEditController.fetchChapter();
        Get.toNamed(AppRoutes.adminNavBar);
        EasyLoading.showSuccess(responseData["message"]);
      } else {
        var responseData = jsonDecode(response.body);
        EasyLoading.showError(responseData["message"]);
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
      log("add exercise error: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }
}
