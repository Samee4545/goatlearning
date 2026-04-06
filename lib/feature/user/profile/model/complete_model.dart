class CompleteModel {
  final bool success;
  final String message;
  final List<ChapterData> data;

  CompleteModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CompleteModel.fromJson(Map<String, dynamic> json) {
    return CompleteModel(
      success: json['success'],
      message: json['message'],
      data: List<ChapterData>.from(
        json['data'].map((item) => ChapterData.fromJson(item)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class ChapterData {
  final String id;
  final String chapterId;
  final int completePercent;
  final Chapter chapter;

  ChapterData({
    required this.id,
    required this.chapterId,
    required this.completePercent,
    required this.chapter,
  });

  factory ChapterData.fromJson(Map<String, dynamic> json) {
    return ChapterData(
      id: json['id'],
      chapterId: json['chapterId'],
      completePercent: json['completePercent'],
      chapter: Chapter.fromJson(json['chapter']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapterId': chapterId,
      'completePercent': completePercent,
      'chapter': chapter.toJson(),
    };
  }
}

class Chapter {
  final String id;
  final String chapterName;
  final String coverImage;
  final DateTime createdAt;

  Chapter({
    required this.id,
    required this.chapterName,
    required this.coverImage,
    required this.createdAt,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      chapterName: json['chapterName'],
      coverImage: json['coverImage'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapterName': chapterName,
      'coverImage': coverImage,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
