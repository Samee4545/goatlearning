import 'dart:io';

import 'package:get/get.dart';

class ExerciseModel {
  Rx<String> problemUrl = Rx<String>('');
  Rx<String> solutionUrl = Rx<String>('');
  RxString problemFileName = ''.obs;
  RxString solutionFileName = ''.obs;
  Rx<File?> problemPDF = Rx<File?>(null);
  Rx<File?> solutionPDF = Rx<File?>(null);
}
