import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/feature/user/exercise/view/exercise_view.dart';
import 'package:goatlearning/feature/user/home/controller/home_controller.dart';
import 'package:goatlearning/feature/user/home/folder_details/controller/folder_details_controller.dart';
import 'package:goatlearning/generated/assets.dart';
import 'package:shimmer/shimmer.dart';

class CustomExerciseWidget extends StatelessWidget {
  final FolderDetailsController controller;
  final HomeController homeController;

  const CustomExerciseWidget({
    super.key,
    required this.controller,
    required this.homeController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                Obx(() {
                  if (controller.isLoading.value) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 14),
                                    Container(
                                      width: 100,
                                      height: 18,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 24,
                                  height: 24,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        );
                      }, childCount: 10),
                    );
                  }

                  if (controller.filteredChapters.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: CustomText(
                          text: "No exercise found",
                          color: AppColors.textBlack,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      var chapter = controller.filteredChapters[index];
                      return GestureDetector(
                        onTap: () {
                          homeController.calculatorPercent(chapter['id'], 5.0);
                          Get.to(
                            () => ExerciseView(
                              chapterTitle: chapter['chapterName'],
                              chapterId: chapter['id'],
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color:
                                index % 2 == 0
                                    ? const Color(0xFFDEF5F2)
                                    : const Color(0xFFF8DEE5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Image.asset(
                                      Assets.imagesChapterIcon,
                                      color:
                                          index % 2 == 0
                                              ? const Color(0xFF4AAD92)
                                              : const Color(0xFF944753),
                                      height: 24,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            text: chapter['chapterName'],
                                            fontSize: 18,
                                            color: AppColors.textBlack,
                                            textOverflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          CustomText(
                                            text:
                                                '${chapter['exerciseCount']} Exercise${chapter['exerciseCount'] == 1 ? '' : 's'}',
                                            fontSize: 14,
                                            color: AppColors.textBlack,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  if (!controller.isAdmin)
                                    Obx(() {
                                      // Re-read the chapter from filteredChapters to get reactive updates
                                      final currentChapter = controller
                                          .filteredChapters
                                          .firstWhere(
                                            (ch) => ch['id'] == chapter['id'],
                                            orElse: () => chapter,
                                          );
                                      final isFav =
                                          currentChapter['isFavorite'] == true;
                                      return GestureDetector(
                                        onTap:
                                            () => controller.toggleFavorite(
                                              chapter['id'],
                                            ),
                                        child: Image.asset(
                                          isFav
                                              ? IconsPath.starFill
                                              : IconsPath.starOutline,
                                          height: 24,
                                        ),
                                      );
                                    })
                                  else
                                    GestureDetector(
                                      onTap: () async {
                                        final confirmed = await Get.dialog<
                                          bool
                                        >(
                                          AlertDialog(
                                            title: Text('Remove Chapter'),
                                            content: Text(
                                              'Are you sure you want to remove this chapter from the folder? It will become a standalone chapter.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Get.back(result: false),
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Get.back(result: true),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                                child: Text('Remove'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmed == true) {
                                          controller.removeChapterFromFolder(
                                            chapter['id'],
                                          );
                                        }
                                      },
                                      child: Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red,
                                        size: 24,
                                      ),
                                    ),
                                  const SizedBox(width: 16),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: controller.filteredChapters.length),
                  );
                }),
                const SliverToBoxAdapter(child: SizedBox(height: 60)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
