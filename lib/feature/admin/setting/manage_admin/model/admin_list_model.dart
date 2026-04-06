class AdminListModel {
  final bool? success;
  final String? message;
  final List<AdminData>? data;

  AdminListModel({this.success, this.message, this.data});

  factory AdminListModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return AdminListModel();

    return AdminListModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data:
          (json['data'] as List?)
              ?.map((e) => AdminData.fromJson(e as Map<String, dynamic>?))
              .toList(),
    );
  }
}

class AdminData {
  final String? id;
  final String? username;
  final String? email;
  final String? profileImage;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AdminData({
    this.id,
    this.username,
    this.email,
    this.profileImage,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return AdminData();

    return AdminData(
      id: json['id'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      profileImage: json['profileImage'] as String?,
      role: json['role'] as String?,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
    );
  }
}
