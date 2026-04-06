// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/core/global_widegts/custom_background.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/global_widegts/custom_submit_button.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/feature/admin/edit/model/chapter_model.dart';
import 'package:goatlearning/generated/assets.dart';

class AdminExerciseDetails extends StatefulWidget {
  const AdminExerciseDetails({super.key});

  @override
  State<AdminExerciseDetails> createState() => _AdminExerciseDetailsState();
}

class _AdminExerciseDetailsState extends State<AdminExerciseDetails> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments = Get.arguments;
    String id = arguments?['id'] ?? "N/A";
    String chapterName = arguments?['chapterName'] ?? "N/A";
    // ignore: unused_local_variable
    List<Exercise> exercise = arguments?['exercise'] ?? [];
    print("id $id");

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.textPrimaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 18),
                    Image.asset(
                      Assets.imagesChapterIcon,
                      color: Colors.white,
                      height: 24,
                    ),
                    SizedBox(width: 12),
                    CustomText(
                      text: chapterName,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18),
              CustomText(
                text: '🔹 1. Multiple Choice (MCQ)',
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 30),
                child: CustomSubmitButton(
                  text: "Add Exercise",
                  onTap: () {
                    // Get.to(
                    //   AddExerciseScreen2(),
                    //   arguments: {"id": id, "chapterName": chapterName},
                    // );
                  },
                  radius: 10,
                  bgColor: AppColors.questionBorder,
                  textColor: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 16),
      //   child: CustomSubmitButton(
      //     text: "Add Exercise",
      //     onTap: () {
      //       Get.to(
      //         AddExerciseScreen2(),
      //         arguments: {"id": id, "chapterName": chapterName},
      //       );
      //     },
      //     radius: 10,
      //     bgColor: AppColors.questionBorder,
      //     textColor: AppColors.white,
      //     fontWeight: FontWeight.w600,
      //   ),
      // ),
    );
  }
}
/////