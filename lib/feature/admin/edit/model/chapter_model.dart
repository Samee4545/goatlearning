class ChapterModel {
  String? id;
  String? chapterName;
  String? coverImage;
  String? theory;
  String? theoryFileName;
  double? percent;
  bool? isFavorite;
  int? exerciseCount;
  List<Exercise>? exercises;

  ChapterModel({
    this.id,
    this.chapterName,
    this.coverImage,
    this.theory,
    this.theoryFileName,
    this.percent,
    this.isFavorite,
    this.exerciseCount,
    this.exercises,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'],
      chapterName: json['chapterName'],
      coverImage: json['coverImage'],
      theory: json['theory'],
      theoryFileName: json['theoryFileName'],
      percent:
          (json['percent'] is int)
              ? (json['percent'] as int).toDouble()
              : json['percent']?.toDouble(),
      isFavorite: json['isFavorite'],
      exerciseCount: json['exerciseCount'],
      exercises:
          json['exercises'] != null
              ? (json['exercises'] as List)
                  .map((e) => Exercise.fromJson(e))
                  .toList()
              : null,
    );
  }
}

class Exercise {
  String? id;
  String? chapterId;
  String? problemUrl;
  String? solutionUrl;
  String? problemFileName;
  String? solutionFileName;

  Exercise({
    this.id,
    this.chapterId,
    this.problemUrl,
    this.solutionUrl,
    this.problemFileName,
    this.solutionFileName,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      chapterId: json['chapterId'],
      problemUrl: json['problemUrl'],
      solutionUrl: json['solutionUrl'],
      problemFileName: json['problemFileName'],
      solutionFileName: json['solutionFileName'],
    );
  }
}
