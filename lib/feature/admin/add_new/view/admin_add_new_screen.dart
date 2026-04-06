import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/app_sizes.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/core/global_widegts/custom_background.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/route/routes.dart';
import 'package:goatlearning/core/style/global_text_style.dart';
import 'package:goatlearning/feature/admin/add_new/controller/admin_add_new_controller.dart';

class AdminAddNewScreen extends StatelessWidget {
  AdminAddNewScreen({super.key});
  final AdminAddNewController controller = Get.put(AdminAddNewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        topCild: Container(
          margin: const EdgeInsets.only(top: 25),
          child: Row(
            children: [
              Image.asset(
                IconsPath.bookIcon,
                color: AppColors.titleTextColor,
                height: 24,
              ),
              SizedBox(width: 5),
              CustomText(
                text: 'add_chapter'.tr,
                color: AppColors.titleTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 0, left: 16.5, right: 16.5),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30),
                TextFormField(
                  controller: controller.chapterNameController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    hintText: 'add_chapter_name'.tr,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.appColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Obx(
                  () => TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                      hintText:
                          controller.theoryFileName.value.isNotEmpty
                              ? "${'file'.tr}: ${controller.theoryFileName.value}"
                              : (controller.theoryPdfUrl.value.isNotEmpty
                                  ? "${'file'.tr}: ${controller.theoryPdfUrl.value.split('/').last}"
                                  : 'add_theory_pdf'.tr),
                      suffixIcon: GestureDetector(
                        onTap: () async {
                          await controller.pickPDF();
                        },
                        child: Icon(Icons.add),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.appColor,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: controller.exerciseAddedController,
                  readOnly: true,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                    hintText:
                        controller.exerciseAddedMessage.value.isEmpty
                            ? 'add_exercise_pdfs'.tr
                            : controller.exerciseAddedMessage.value,
                    suffixIcon: GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.addExercise);
                      },
                      child: Icon(Icons.add),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.appColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 55,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff5EAEB5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      if (controller.chapterNameController.text.isEmpty) {
                        EasyLoading.showError('chapter_name_required'.tr);
                      } else if (controller.theoryPdfUrl.value.isEmpty) {
                        EasyLoading.showError('theory_pdf_required'.tr);
                      } else if (controller
                          .exerciseAddedMessage
                          .value
                          .isEmpty) {
                        EasyLoading.showError('exercise_pdfs_required'.tr);
                      } else {
                        controller.saveNewBook();
                      }
                    },
                    child: Text(
                      'save_new_book'.tr,
                      style: globalTextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: getHeight(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
