// // ignore_for_file: unnecessary_to_list_in_spreads, avoid_print

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:goatlearning/core/const/app_colors.dart';
// import 'package:goatlearning/core/const/icons_path.dart';
// import 'package:goatlearning/core/global_widegts/custom_background.dart';
// import 'package:goatlearning/core/global_widegts/custom_submit_button.dart';
// import 'package:goatlearning/core/global_widegts/custom_text.dart';
// import 'package:goatlearning/feature/admin/add_new/controller/admin_add_new_controller.dart';
// import 'package:goatlearning/feature/admin/add_new/widget/option_textfield.dart';
// import 'package:goatlearning/feature/admin/add_new/widget/question_textfield.dart';

// class AddExerciseScreen2 extends StatelessWidget {
//   AddExerciseScreen2({super.key});
//   final AdminAddNewController controller = Get.find();

//   @override
//   Widget build(BuildContext context) {
//     final Map<String, dynamic>? arguments = Get.arguments;
//     String id = arguments?['id'] ?? "N/A";
//     String chapterName = arguments?['chapterName'] ?? "N/A";
//     print("id $id");
//     return Scaffold(
//       body: CustomBackground(
//         topCild: Row(
//           children: [
//             InkWell(
//               onTap: () {
//                 Get.back();
//               },
//               child: Image.asset(
//                 IconsPath.arrowback,
//                 color: AppColors.titleTextColor,
//                 height: 16,
//               ),
//             ),
//             SizedBox(width: 10),
//             Image.asset(
//               IconsPath.bookIcon,
//               color: AppColors.titleTextColor,
//               height: 24,
//             ),
//             SizedBox(width: 10),
//             CustomText(
//               text: chapterName,
//               color: AppColors.titleTextColor,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               textOverflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.only(left: 16, right: 16),
//           child: Obx(
//             () => SingleChildScrollView(
//               child: Column(
//                 children: [
//                   SizedBox(height: 16),
//                   CustomText(
//                     text: '🔹 Multiple Choice (MCQ)',
//                     fontSize: 16,
//                     color: AppColors.textBlack,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   SizedBox(height: 16),

//                   ...controller.questions.map((q) {
//                     int index = controller.questions.indexOf(q);
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         CustomText(
//                           text: 'Question: ${index + 1}',
//                           fontSize: 14,
//                           color: AppColors.textBlack,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         SizedBox(height: 8),
//                         QuestionTextfield(controller: q.questionController),
//                         SizedBox(height: 16),
//                         CustomText(
//                           text: '✅ Options:',
//                           fontSize: 14,
//                           color: AppColors.textBlack,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: OptionTextfield(
//                                 controller: q.optionController1,
//                                 hintext: "A)",
//                               ),
//                             ),
//                             SizedBox(width: 10),
//                             Expanded(
//                               child: OptionTextfield(
//                                 controller: q.optionController2,
//                                 hintext: "B)",
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: OptionTextfield(
//                                 controller: q.optionController3,
//                                 hintext: "C)",
//                               ),
//                             ),
//                             SizedBox(width: 10),
//                             Expanded(
//                               child: OptionTextfield(
//                                 controller: q.optionController4,
//                                 hintext: "D)",
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 8),
//                         CustomText(
//                           text: 'Correct Answer:',
//                           fontSize: 14,
//                           color: AppColors.textBlack,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         SizedBox(height: 8),
//                         QuestionTextfield(controller: q.answerController),
//                         SizedBox(height: 8),
//                         CustomText(
//                           text: 'Solution:',
//                           fontSize: 14,
//                           color: AppColors.textBlack,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         SizedBox(height: 8),
//                         QuestionTextfield(controller: q.solutionController),
//                         SizedBox(height: 16),
//                       ],
//                     );
//                   }).toList(),

//                   SizedBox(height: 20),

//                   CustomSubmitButton(
//                     text: "Add +",
//                     onTap: () {
//                       controller.addNewQuestion();
//                     },
//                     bgColor: AppColors.questionBorder,
//                     radius: 12,
//                     textColor: AppColors.white,
//                     fontWeight: FontWeight.w500,
//                     fontSize: 14,
//                   ),

//                   SizedBox(height: 22),

//                   CustomSubmitButton(
//                     text: "Save",
//                     onTap: () {
//                       controller.addExercise(id);
//                     },
//                     bgColor: AppColors.questionBorder,
//                     radius: 12,
//                     textColor: AppColors.white,
//                     fontWeight: FontWeight.w500,
//                     fontSize: 14,
//                   ),
//                   SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// ///
