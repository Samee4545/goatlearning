// lib/feature/user/home/model/folder_model.dart
class Folder {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSwapped;

  Folder({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.isSwapped,
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      isSwapped: json['isSwapped'] ?? false,
    );
  }
}

class FolderApiResponse {
  final bool success;
  final String message;
  final List<Folder> data;

  FolderApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FolderApiResponse.fromJson(Map<String, dynamic> json) {
    var folderList = json['data'] as List<dynamic>? ?? [];
    List<Folder> folders =
        folderList.map((item) => Folder.fromJson(item)).toList();

    return FolderApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: folders,
    );
  }
}
