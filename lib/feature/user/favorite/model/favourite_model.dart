import 'dart:convert';

class FavouriteModel {
  bool success;
  String message;
  List<FavouriteChapter> data;

  FavouriteModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FavouriteModel.fromJson(String str) =>
      FavouriteModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory FavouriteModel.fromMap(Map<String, dynamic> json) => FavouriteModel(
    success: json["success"] ?? false,
    message: json["message"] ?? "",
    data:
        json["data"] == null
            ? []
            : List<FavouriteChapter>.from(
              json["data"].map((x) => FavouriteChapter.fromMap(x)),
            ),
  );

  Map<String, dynamic> toMap() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toMap())),
  };
}

class FavouriteChapter {
  String id;
  String chapterName;
  String coverImage;
  bool isFavorite;
  String? theory;
  String? theoryFileName;

  FavouriteChapter({
    required this.id,
    required this.chapterName,
    required this.coverImage,
    required this.isFavorite,
    this.theory,
    this.theoryFileName,
  });

  factory FavouriteChapter.fromJson(String str) =>
      FavouriteChapter.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory FavouriteChapter.fromMap(Map<String, dynamic> json) =>
      FavouriteChapter(
        id: json["id"] ?? "",
        chapterName: json["chapterName"] ?? "",
        coverImage: json["coverImage"] ?? "",
        isFavorite: json["isFavorite"] ?? false,
        theory: json["theory"],
        theoryFileName: json["theoryFileName"],
      );

  Map<String, dynamic> toMap() => {
    "id": id,
    "chapterName": chapterName,
    "coverImage": coverImage,
    "isFavorite": isFavorite,
    "theory": theory,
    "theoryFileName": theoryFileName,
  };
}
