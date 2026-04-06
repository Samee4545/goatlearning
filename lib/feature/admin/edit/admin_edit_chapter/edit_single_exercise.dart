// ignore_for_file: unnecessary_to_list_in_spreads, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/core/global_widegts/custom_background.dart';
import 'package:goatlearning/core/global_widegts/custom_submit_button.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/feature/admin/add_new/controller/admin_add_new_controller.dart';
import 'package:goatlearning/feature/admin/add_new/widget/option_textfield.dart';
import 'package:goatlearning/feature/admin/add_new/widget/question_textfield.dart';

class EditSingleExercise extends StatefulWidget {
  const EditSingleExercise({super.key});

  @override
  State<EditSingleExercise> createState() => _EditSingleExerciseState();
}

class _EditSingleExerciseState extends State<EditSingleExercise> {
  final AdminAddNewController controller = Get.find();

  late TextEditingController editQuestionController;
  late TextEditingController editOptionController1;
  late TextEditingController editOptionController2;
  late TextEditingController editOptionController3;
  late TextEditingController editOptionController4;
  late TextEditingController editCorrectAnswerController;
  late TextEditingController editSolutionController;
  int index = 0;
  @override
  void initState() {
    super.initState();

    // Retrieve arguments
    final Map<String, dynamic>? arguments = Get.arguments;

    String id = arguments?['id'] ?? "N/A";
    String chapterName = arguments?['chapterName'] ?? "N/A";
    String question = arguments?['question'] ?? "";
    List<String> options = List<String>.from(arguments?['options'] ?? []);
    String correctAnswer = arguments?['correctAnswer'] ?? "";
    String solution = arguments?['solution'] ?? "";

    print("Question ID: $id");
    print("Chapter Name: $chapterName");
    print("cor $correctAnswer");

    // Initialize controllers with existing values
    editQuestionController = TextEditingController(text: question);
    editOptionController1 = TextEditingController(
      text: options.isNotEmpty ? options[0] : "",
    );
    editOptionController2 = TextEditingController(
      text: options.length > 1 ? options[1] : "",
    );
    editOptionController3 = TextEditingController(
      text: options.length > 2 ? options[2] : "",
    );
    editOptionController4 = TextEditingController(
      text: options.length > 3 ? options[3] : "",
    );
    editCorrectAnswerController = TextEditingController(text: correctAnswer);
    editSolutionController = TextEditingController(text: solution);
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    editQuestionController.dispose();
    editOptionController1.dispose();
    editOptionController2.dispose();
    editOptionController3.dispose();
    editOptionController4.dispose();
    editCorrectAnswerController.dispose();
    editSolutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments = Get.arguments;
    String chapterName = arguments?['chapterName'] ?? "N/A";
    int index = arguments?['index'] ?? -1;
    //String id = arguments?['id'] ?? -1;

    return Scaffold(
      body: CustomBackground(
        topCild: Row(
          children: [
            InkWell(
              onTap: () {
                Get.back();
              },
              child: Image.asset(
                IconsPath.arrowback,
                color: AppColors.titleTextColor,
                height: 16,
              ),
            ),
            SizedBox(width: 10),
            Image.asset(
              IconsPath.bookIcon,
              color: AppColors.titleTextColor,
              height: 24,
            ),
            SizedBox(width: 10),
            CustomText(
              text: chapterName,
              color: AppColors.titleTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              textOverflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 16),
                CustomText(
                  text: 'multiple_choice_mcq'.tr,
                  fontSize: 16,
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomText(
                      text: 'question_number'.tr.replaceAll('@number', index.toString()),
                      fontSize: 14,
                      color: AppColors.textBlack,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: 8),
                    QuestionTextfield(controller: editQuestionController),
                    SizedBox(height: 16),
                    CustomText(
                      text: 'options'.tr,
                      fontSize: 14,
                      color: AppColors.textBlack,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OptionTextfield(
                            controller: editOptionController1,
                            hintext: "A)",
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: OptionTextfield(
                            controller: editOptionController2,
                            hintext: "B)",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OptionTextfield(
                            controller: editOptionController3,
                            hintext: "C)",
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: OptionTextfield(
                            controller: editOptionController4,
                            hintext: "D)",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    CustomText(
                      text: 'correct_answer'.tr,
                      fontSize: 14,
                      color: AppColors.textBlack,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: 8),
                    QuestionTextfield(controller: editCorrectAnswerController),
                    SizedBox(height: 8),
                    CustomText(
                      text: 'solution'.tr,
                      fontSize: 14,
                      color: AppColors.textBlack,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: 8),
                    QuestionTextfield(controller: editSolutionController),
                    SizedBox(height: 16),
                  ],
                ),

                SizedBox(height: 20),

                CustomSubmitButton(
                  text: 'save'.tr,
                  onTap: () {
                    // Future.delayed(Duration.zero, () {
                    //   // Call the controller's editExercise method
                    //   controller.editExercise(
                    //     questionId: id,
                    //     question: editQuestionController.text,
                    //     a: editOptionController1.text,
                    //     b: editOptionController2.text,
                    //     c: editOptionController3.text,
                    //     d: editOptionController4.text,
                    //     solution: editSolutionController.text,
                    //     answer: editCorrectAnswerController.text,
                    //   );
                    // });
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
    );
  }
}
