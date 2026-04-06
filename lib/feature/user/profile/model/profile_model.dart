class ProfileModel {
  final String? id;
  final String? username;
  final String? email;
  final String? profileImage;
  final String? phoneNumber;
  final String? profession;
  final String? sector;
  final String? role;
  final bool? isPayment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProfileModel({
    this.id,
    this.username,
    this.email,
    this.profileImage,
    this.phoneNumber,
    this.profession,
    this.sector,
    this.role,
    this.isPayment,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profileImage: json['profileImage'],
      phoneNumber: json['phoneNumber'],
      profession: json['profession'],
      sector: json["sector"] ?? json["class"] ?? "",
      role: json['role'],
      isPayment: json['isPayment'] ?? false,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
