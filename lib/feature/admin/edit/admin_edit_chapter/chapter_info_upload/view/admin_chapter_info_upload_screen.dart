import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/core/global_widegts/custom_submit_button.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/global_widegts/custom_textfield.dart';
import 'package:goatlearning/feature/admin/edit/admin_edit_chapter/edit_exercise_screen.dart';
import 'package:goatlearning/feature/admin/edit/controller/admin_edit_controller.dart';
import 'package:goatlearning/feature/admin/edit/model/chapter_model.dart';

class AdminChapterInfoUploadScreen extends StatelessWidget {
  AdminChapterInfoUploadScreen({super.key});

  final AdminEditController controller = Get.put(AdminEditController());

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments = Get.arguments;
    String chapterName = arguments?['chapterName'] ?? "N/A";
    String id = arguments?['id'] ?? "";
    String theory = arguments?['theory'] ?? ""; // Added theory
    List<Exercise> exercise = arguments?['exercise'] ?? [];

    // Fetch complete chapter details including all exercises
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getChapterById(id);
    });

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 60, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    controller.image.value = null;
                    Get.back();
                  },
                  child: Image.asset(IconsPath.cross, height: 48, width: 48),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Color(0xff5EAEB5).withValues(alpha: 0.11),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Image.asset(
                        IconsPath.cloud,
                        height: 28,
                        width: 28,
                      ),
                    ),
                    SizedBox(width: 12),
                    CustomText(
                      text: 'add_documents'.tr,
                      color: Color(0xff173156),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 19),
              CustomText(
                text: 'edit_chapter_name'.tr,
                color: AppColors.appColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 15),
              CustomTextfield(
                controller: controller.chapterNameController,
                hintext: "Chapter 1",
              ),
              SizedBox(height: 19),
              CustomText(
                text: 'upload_theory'.tr,
                color: AppColors.appColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 15),
              DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  color: Color(0xff5EAEB5),
                  dashPattern: [8, 4],
                  strokeWidth: 1,
                  radius: Radius.circular(4),
                  //borderType: BorderType.RRect,           // if required by options class
                  padding: EdgeInsets.zero, // if needed
                ),
                child: GestureDetector(
                  onTap: () async {
                    await controller.pickPDF();
                  },
                  child: Container(
                    height: 50,
                    color: Color(0xFFF5F9FA),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(IconsPath.upload, height: 24, width: 24),
                          SizedBox(width: 12),
                          Obx(
                            () => Flexible(
                              child: CustomText(
                                text:
                                    controller.pdfFile.value == null
                                        ? (theory.isNotEmpty
                                            ? "${'file'.tr}: ${theory.split('/').last}"
                                            : 'upload'.tr)
                                        : "${'file'.tr}: ${controller.pdfFile.value!.path.split('/').last}",
                                textOverflow: TextOverflow.ellipsis,
                                color: Color(0xff173156),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 19),
              CustomText(
                text: 'edit_exercise'.tr,
                color: AppColors.appColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 15),
              DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  color: Color(0xff5EAEB5),
                  dashPattern: [8, 4],
                  strokeWidth: 1,
                  radius: Radius.circular(4),
                  // borderType is implied by using RoundedRect*
                ),
                child: GestureDetector(
                  onTap: () {
                    Get.to(
                      () => EditExerciseScreen(),
                      arguments: {
                        "id": id,
                        "chapterName": chapterName,
                        "theory": theory,
                        "exercise": exercise,
                      },
                    );
                  },
                  child: Container(
                    height: 50,
                    color: Color(0xFFF5F9FA),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            IconsPath.editBg,
                            height: 24,
                            width: 24,
                            color: Colors.black,
                          ),
                          SizedBox(width: 12),
                          CustomText(
                            text: 'edit_exercise'.tr,
                            color: Color(0xff173156),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 19),
              CustomSubmitButton(
                onTap: () {
                  controller.updateChapterCollective(id);
                },
                text: 'update'.tr,
                fontSize: 14,
                textColor: Colors.white,
                fontWeight: FontWeight.w600,
                bgColor: AppColors.textPrimaryColor,
                radius: 12,
              ),
              SizedBox(height: 16),
              CustomSubmitButton(
                onTap: () {
                  Get.back();
                },
                text: 'discard'.tr,
                fontSize: 14,
                textColor: AppColors.textPrimaryColor,
                fontWeight: FontWeight.w600,
                bgColor: Colors.white,
                border: AppColors.textPrimaryColor,
                radius: 12,
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
