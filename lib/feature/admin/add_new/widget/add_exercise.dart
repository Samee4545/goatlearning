import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/global_widegts/app_base_widget.dart';
import 'package:goatlearning/core/global_widegts/custom_submit_button.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/feature/admin/add_new/controller/admin_add_new_controller.dart';
import 'package:goatlearning/generated/assets.dart';

class AddExerciseScreen extends StatelessWidget {
  AddExerciseScreen({super.key});
  final AdminAddNewController controller = Get.put(AdminAddNewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBaseWidget(
        needBackButton: true,
        needCallBackForBackButton: () {
          Get.back();
        },
        needChapterLeadingIcon: true,
        chapterAssetsPath: Assets.imagesChapterIcon,
        needChapterTitle: true,
        title: 'add_exercise_pdfs'.tr,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Obx(
            () => SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 16),
                  CustomText(
                    text: 'exercise_problem_solution_pdfs'.tr,
                    fontSize: 16,
                    color: AppColors.textBlack,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 16),
                  ...controller.exercises.map((e) {
                    int index = controller.exercises.indexOf(e);
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
                              e.problemUrl.value.isEmpty
                                  ? 'tap_upload_problem_pdf'.tr
                                  : (e.problemFileName.value.isNotEmpty
                                      ? "${'file'.tr}: ${e.problemFileName.value}"
                                      : "${'file'.tr}: ${e.problemUrl.value.split('/').last}"),
                              style: TextStyle(
                                color:
                                    e.problemUrl.value.isEmpty
                                        ? Colors.grey
                                        : AppColors.textBlack,
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
                              e.solutionUrl.value.isEmpty
                                  ? 'tap_upload_solution_pdf'.tr
                                  : (e.solutionFileName.value.isNotEmpty
                                      ? "${'file'.tr}: ${e.solutionFileName.value}"
                                      : "${'file'.tr}: ${e.solutionUrl.value.split('/').last}"),
                              style: TextStyle(
                                color:
                                    e.solutionUrl.value.isEmpty
                                        ? Colors.grey
                                        : AppColors.textBlack,
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
                      controller.saveData();
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
