import 'package:goatlearning/feature/user/home/model/user_chapter_model.dart';

class ChapterExerciseSummary {
  final String chapterId;
  final String chapterName;
  final int count;
  final List<Exercise> exercises;

  ChapterExerciseSummary({
    required this.chapterId,
    required this.chapterName,
    required this.count,
    required this.exercises,
  });
}
