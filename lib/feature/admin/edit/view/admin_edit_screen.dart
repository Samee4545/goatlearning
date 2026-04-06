// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/core/global_widegts/custom_background.dart';
import 'package:goatlearning/core/global_widegts/custom_error_text.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/route/routes.dart';
import 'package:goatlearning/feature/admin/add_new/controller/admin_add_new_controller.dart';
import 'package:goatlearning/feature/admin/edit/controller/admin_edit_controller.dart';
import 'package:goatlearning/feature/admin/profile/controller/admin_profile_controller.dart';

class AdminEditScreen extends StatelessWidget {
  final AdminEditController controller = Get.put(AdminEditController());
  final AdminProfileController adminProfileController = Get.find();
  final AdminAddNewController adminAddNewController = Get.find();

  AdminEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        topCild: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              onTap: () {
                controller.showSearchBar();
              },
              child: Container(
                height: 35,
                width: 35,
                margin: const EdgeInsets.only(top: 25),
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image.asset(IconsPath.search),
              ),
            ),
          ],
        ),

        child: Obx(
          () => Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 15),
            child: Column(
              children: [
                if (controller.isSearchActive.value)
                  TextField(
                    controller: controller.searchController,
                    onChanged: (value) {
                      controller.filterList(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'search'.tr,
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          controller.clearSearch();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.questionBorder),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.questionBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.questionBorder),
                      ),
                    ),
                  ),
                if (controller.isSearchActive.value) SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    if (controller.filteredItems.isEmpty) {
                      return CustomErrorText(text: 'no_chapters_found'.tr);
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 20),
                      itemCount: controller.filteredItems.length,
                      separatorBuilder: (_, __) => SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        var chapter =
                            controller.filteredItems.reversed.toList()[index];
                        return SizedBox(
                          height: 56,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 150,
                                              child: CustomText(
                                                text:
                                                    chapter.chapterName ??
                                                    "N/A",
                                                color: AppColors.appColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Get.toNamed(
                                                  AppRoutes
                                                      .adminChapterInfoUpload,
                                                  arguments: {
                                                    'chapterName':
                                                        chapter.chapterName,
                                                    'coverImage':
                                                        chapter.coverImage,
                                                    'id': chapter.id,
                                                    "exercise":
                                                        chapter.exercises,
                                                  },
                                                );
                                              },
                                              child: Container(
                                                height: 36,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 10,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Color(
                                                    0xff1DB4DA,
                                                  ).withValues(alpha: .11),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Image.asset(
                                                      IconsPath.edit,
                                                      height: 14,
                                                      width: 14,
                                                      color: Colors.black87,
                                                    ),
                                                    SizedBox(width: 3),
                                                    CustomText(
                                                      text: 'edit'.tr,
                                                      color: Colors.black87,
                                                      fontSize: 12,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            InkWell(
                                              onTap: () {
                                                print(chapter.id);
                                                adminAddNewController
                                                    .deleteChapter(
                                                      chapter.id ?? "no id",
                                                    );
                                              },
                                              child: Image.asset(
                                                IconsPath.delete,
                                                height: 24,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
