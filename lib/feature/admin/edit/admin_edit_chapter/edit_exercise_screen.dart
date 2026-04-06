import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/global_widegts/app_base_widget.dart';
import 'package:goatlearning/core/global_widegts/custom_submit_button.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/feature/admin/edit/controller/admin_edit_controller.dart';
import 'package:goatlearning/feature/admin/edit/model/chapter_model.dart';
import 'package:goatlearning/feature/admin/edit/model/exercise_model.dart';
import 'package:goatlearning/generated/assets.dart';

class EditExerciseScreen extends StatelessWidget {
  EditExerciseScreen({super.key});

  final AdminEditController controller = Get.put(AdminEditController());

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments = Get.arguments;
    String id = arguments?['id'] ?? "";
    String theory = arguments?['theory'] ?? "";
    List<Exercise> existingExercises = arguments?['exercise'] ?? [];

    // Initialize exercises with existing ones
    if (controller.exercises.isEmpty) {
      controller.initializeExercises(existingExercises);
    }

    return Scaffold(
      body: AppBaseWidget(
        needBackButton: true,
        needCallBackForBackButton: () {
          controller.exercises.clear();
          Get.back();
        },
        needChapterLeadingIcon: true,
        chapterAssetsPath: Assets.imagesChapterIcon,
        needChapterTitle: true,
        title: 'edit_exercise'.tr,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Obx(
            () => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16),
                  if (theory.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'theory_file'.tr,
                          fontSize: 14,
                          color: AppColors.textBlack,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.questionBorder),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${'file'.tr}: ${theory.split('/').last}",
                            style: TextStyle(
                              color: AppColors.textBlack,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  CustomText(
                    text: 'exercise_problem_solution_pdfs'.tr,
                    fontSize: 16,
                    color: AppColors.textBlack,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 16),
                  ...controller.exercises.asMap().entries.map((entry) {
                    int index = entry.key;
                    ExerciseModel exercise = entry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: 'exercise_number'.tr.replaceAll(
                                '@number',
                                (index + 1).toString(),
                              ),
                              fontSize: 14,
                              color: AppColors.textBlack,
                              fontWeight: FontWeight.w600,
                            ),
                            if (controller.exercises.length > 1)
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  controller.deleteExercise(index);
                                },
                              ),
                          ],
                        ),
                        SizedBox(height: 8),
                        CustomText(
                          text: 'problem_pdf'.tr,
                          fontSize: 14,
                          color: AppColors.textBlack,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            controller.pickProblemPDF(index);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.questionBorder,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              exercise.problemPDF.value != null
                                  ? "${'file'.tr}: ${exercise.problemPDF.value!.path.split('/').last}"
                                  : exercise.problemUrl.value.isNotEmpty
                                  ? "${'file'.tr}: ${exercise.problemUrl.value.split('/').last}"
                                  : 'tap_upload_problem_pdf'.tr,
                              style: TextStyle(
                                color:
                                    exercise.problemPDF.value != null ||
                                            exercise.problemUrl.value.isNotEmpty
                                        ? AppColors.textBlack
                                        : Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        CustomText(
                          text: 'solution_pdf'.tr,
                          fontSize: 14,
                          color: AppColors.textBlack,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            controller.pickSolutionPDF(index);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.questionBorder,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              exercise.solutionPDF.value != null
                                  ? "${'file'.tr}: ${exercise.solutionPDF.value!.path.split('/').last}"
                                  : exercise.solutionUrl.value.isNotEmpty
                                  ? "${'file'.tr}: ${exercise.solutionUrl.value.split('/').last}"
                                  : 'tap_upload_solution_pdf'.tr,
                              style: TextStyle(
                                color:
                                    exercise.solutionPDF.value != null ||
                                            exercise
                                                .solutionUrl
                                                .value
                                                .isNotEmpty
                                        ? AppColors.textBlack
                                        : Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    );
                    // ignore: unnecessary_to_list_in_spreads
                  }).toList(),
                  SizedBox(height: 20),
                  CustomSubmitButton(
                    text: 'add_plus'.tr,
                    onTap: () {
                      controller.addNewExercise();
                    },
                    bgColor: AppColors.questionBorder,
                    radius: 12,
                    textColor: AppColors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  SizedBox(height: 22),
                  CustomSubmitButton(
                    text: 'save'.tr,
                    onTap: () {
                      controller.updateChapterCollective(id);
                    },
                    bgColor: AppColors.questionBorder,
                    radius: 12,
                    textColor: AppColors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
