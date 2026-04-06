import 'package:goatlearning/feature/user/home/model/folder_model.dart';
import 'package:goatlearning/feature/user/home/model/user_chapter_model.dart';

class ContentItemModel {
  String? id;
  String type; // 'chapter' or 'folder'
  int? order;
  String? createdAt;

  // Chapter specific fields
  String? chapterName;
  String? coverImage;
  String? theory;
  String? theoryFileName;
  String? chapterId;
  int? exerciseCount;
  double? percent;
  bool? isFavorite;

  // Folder specific fields
  String? name;
  String? folderId;
  int? chapterCount;

  ContentItemModel({
    this.id,
    required this.type,
    this.order,
    this.createdAt,
    this.chapterName,
    this.coverImage,
    this.theory,
    this.theoryFileName,
    this.chapterId,
    this.exerciseCount,
    this.percent,
    this.isFavorite,
    this.name,
    this.folderId,
    this.chapterCount,
  });

  factory ContentItemModel.fromJson(Map<String, dynamic> json) {
    return ContentItemModel(
      id: json['id'],
      type: json['type'] ?? 'chapter',
      order: json['order'],
      createdAt: json['createdAt'],
      chapterName: json['chapterName'],
      coverImage: json['coverImage'],
      theory: json['theory'],
      theoryFileName: json['theoryFileName'],
      chapterId: json['chapterId'],
      exerciseCount: json['exerciseCount'],
      percent:
          (json['percent'] is int)
              ? (json['percent'] as int).toDouble()
              : json['percent']?.toDouble(),
      isFavorite: json['isFavorite'],
      name: json['name'],
      folderId: json['folderId'],
      chapterCount: json['chapterCount'],
    );
  }

  bool get isFolder => type == 'folder';
  bool get isChapter => type == 'chapter';

  /// Create a ContentItemModel from a UserChapter instance
  factory ContentItemModel.fromChapterModel(UserChapter c) {
    return ContentItemModel(
      id: c.id,
      type: 'chapter',
      chapterName: c.chapterName,
      coverImage: c.coverImage,
      theory: c.theory,
      theoryFileName: c.theoryFileName,
      chapterId: c.id,
      exerciseCount: c.exerciseCount,
      percent: c.percent,
      isFavorite: c.isFavorite,
    );
  }

  /// Create a ContentItemModel from a Folder instance
  factory ContentItemModel.fromFolderModel(Folder f) {
    return ContentItemModel(
      id: f.id,
      type: 'folder',
      name: f.name,
      folderId: f.id,
      chapterCount: 0,
      createdAt: f.createdAt.toIso8601String(),
    );
  }
}
