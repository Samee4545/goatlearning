import 'dart:convert';

import 'package:get/get_rx/src/rx_types/rx_types.dart';

class UserChapter {
  final String id;
  final String chapterName;
  final String coverImage;
  final String theory;
  final String? theoryFileName;
  final int exerciseCount;
  final bool isFavorite;
  final double percent;

  UserChapter({
    required this.id,
    required this.chapterName,
    required this.coverImage,
    required this.theory,
    this.theoryFileName,
    required this.exerciseCount,
    required this.isFavorite,
    required this.percent,
  });

  factory UserChapter.fromJson(Map<String, dynamic> json) {
    return UserChapter(
      id: json['id'] ?? '',
      chapterName: json['chapterName'] ?? '',
      coverImage: json['coverImage'] ?? '',
      theory: json['theory'] ?? '',
      theoryFileName: json['theoryFileName'],
      exerciseCount: json['exerciseCount'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      percent:
          (json['percent'] is int)
              ? (json['percent'] as int).toDouble()
              : (json['percent']?.toDouble() ?? 0.0),
    );
  }

  UserChapter copyWith({
    String? id,
    String? chapterName,
    String? coverImage,
    String? theory,
    String? theoryFileName,
    int? exerciseCount,
    bool? isFavorite,
    double? percent,
  }) {
    return UserChapter(
      id: id ?? this.id,
      chapterName: chapterName ?? this.chapterName,
      coverImage: coverImage ?? this.coverImage,
      theory: theory ?? this.theory,
      theoryFileName: theoryFileName ?? this.theoryFileName,
      exerciseCount: exerciseCount ?? this.exerciseCount,
      isFavorite: isFavorite ?? this.isFavorite,
      percent: percent ?? this.percent,
    );
  }
}

class Exercise {
  final String id;
  final String chapterId;
  final String? chapterName;
  final String problemUrl;
  final String solutionUrl;
  final String? problemFileName;
  final String? solutionFileName;
  final RxBool isSolutionVisible = false.obs;

  Exercise({
    required this.id,
    required this.chapterId,
    this.chapterName,
    required this.problemUrl,
    required this.solutionUrl,
    this.problemFileName,
    this.solutionFileName,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? '',
      chapterId: json['chapterId'] ?? '',
      chapterName: json['chapterName'] ?? null,
      problemUrl: json['problemUrl'] ?? '',
      solutionUrl: json['solutionUrl'] ?? '',
      problemFileName: json['problemFileName'],
      solutionFileName: json['solutionFileName'],
    )..isSolutionVisible.value = false;
  }
}

class ApiResponse {
  final bool success;
  final String message;
  final List<UserChapter> data;

  ApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List? ?? [];
    List<UserChapter> chaptersList =
        list.map((i) => UserChapter.fromJson(i)).toList();
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: chaptersList,
    );
  }
}

class ChapterDetailResponse {
  final bool success;
  final String message;
  final ChapterDetail data;

  ChapterDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ChapterDetailResponse.fromJson(Map<String, dynamic> json) {
    return ChapterDetailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ChapterDetail.fromJson(json['data'] ?? {}),
    );
  }
}

class ChapterDetail {
  final String id;
  final String chapterName;
  final String coverImage;
  final String theory;
  final List<Exercise> exercises;

  ChapterDetail({
    required this.id,
    required this.chapterName,
    required this.coverImage,
    required this.theory,
    required this.exercises,
  });

  factory ChapterDetail.fromJson(Map<String, dynamic> json) {
    var exerciseList = json['exercises'] as List? ?? [];
    List<Exercise> exercises =
        exerciseList.map((i) => Exercise.fromJson(i)).toList();
    return ChapterDetail(
      id: json['id'] ?? '',
      chapterName: json['chapterName'] ?? '',
      coverImage: json['coverImage'] ?? '',
      theory: json['theory'] ?? '',
      exercises: exercises,
    );
  }
}

ApiResponse parseApiResponse(String jsonString) {
  final jsonData = json.decode(jsonString);
  return ApiResponse.fromJson(jsonData);
}

ChapterDetailResponse parseChapterDetailResponse(String jsonString) {
  final jsonData = json.decode(jsonString);
  return ChapterDetailResponse.fromJson(jsonData);
}
