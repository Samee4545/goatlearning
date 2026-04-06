class AdminPercentageModel {
  String? chapterId;
  String? chapterName;
  DateTime? createdAt;
  double? percent;

  AdminPercentageModel({
    this.chapterId,
    this.chapterName,
    this.createdAt,
    this.percent,
  });

  factory AdminPercentageModel.fromJson(Map<String, dynamic> json) {
    return AdminPercentageModel(
      chapterId: json['chapterId'],
      chapterName: json['chapterName'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      percent: json['percent']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapterId': chapterId,
      'chapterName': chapterName,
      'createdAt': createdAt?.toIso8601String(),
      'percent': percent,
    };
  }
}
