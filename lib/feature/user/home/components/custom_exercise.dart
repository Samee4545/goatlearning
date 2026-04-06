import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/services_class/billing/billing_manager.dart';
import 'package:goatlearning/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:goatlearning/feature/user/exercise/view/exercise_view.dart';
import 'package:goatlearning/feature/user/home/controller/home_controller.dart';
import 'package:goatlearning/feature/user/home/purcess_scrren/purchase_screen.dart';
import 'package:goatlearning/feature/user/profile/controller/user_profile_controller.dart';
import 'package:shimmer/shimmer.dart';

class CustomExerciseWidget extends StatelessWidget {
  const CustomExerciseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();
    final UserProfileController profileController = Get.find();

    return ValueListenableBuilder<bool>(
      valueListenable: BillingManager.instance.isPremium,
      builder:
          (context, isPremium, _) => Obx(() {
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
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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

                          if (controller.filteredContent.isEmpty &&
                              controller.hasLoadedContent.value) {
                            return SliverToBoxAdapter(
                              child: Center(
                                child: CustomText(
                                  text: "no_exercise_found".tr,
                                  color: AppColors.textBlack,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }

                          // Build display list: first 4 items for non-premium
                          final source = controller.filteredContent;
                          final List displayItems = [];
                          if (isPremium) {
                            displayItems.addAll(source);
                          } else {
                            int taken = 0;
                            for (var item in source) {
                              if (taken >= 4) break;
                              displayItems.add(item);
                              taken++;
                            }
                          }

                          return SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              var item = displayItems[index];

                              // Folder tile – expandable with chapters
                              if (item.isFolder) {
                                return Obx(() {
                                  final isExpanded = controller
                                      .expandedFoldersExercise
                                      .contains(item.folderId);
                                  final folderChapters =
                                      controller.folderChaptersCache[item
                                          .folderId];
                                  return Column(
                                    key: ValueKey('ex_${item.folderId}'),
                                    children: [
                                      // Folder header (same style as theory)
                                      Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12.0,
                                          ),
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFFFFF3E0),
                                              const Color(0xFFFFE0B2),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.orange.withValues(
                                                alpha: 0.3,
                                              ),
                                              spreadRadius: 1,
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              12.0,
                                            ),
                                            onTap: () {
                                              controller
                                                  .toggleFolderExpansionExercise(
                                                    item.folderId ?? '',
                                                  );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                16.0,
                                              ),
                                              child: Row(
                                                children: [
                                                  TweenAnimationBuilder<double>(
                                                    duration: const Duration(
                                                      milliseconds: 300,
                                                    ),
                                                    tween: Tween<double>(
                                                      begin: 0,
                                                      end: isExpanded ? 0.5 : 0,
                                                    ),
                                                    curve:
                                                        Curves.easeInOutCubic,
                                                    builder: (
                                                      context,
                                                      value,
                                                      child,
                                                    ) {
                                                      return Transform.rotate(
                                                        angle: value * 3.14159,
                                                        child: Icon(
                                                          isExpanded
                                                              ? Icons
                                                                  .folder_open
                                                              : Icons.folder,
                                                          color: const Color(
                                                            0xFFFF9800,
                                                          ),
                                                          size: 32,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(width: 14),
                                                  Expanded(
                                                    child: CustomText(
                                                      text: item.name ?? '',
                                                      fontSize: 16,
                                                      color:
                                                          AppColors.textBlack,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      maxLines: 3,
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          const Color(
                                                            0xFFFF9800,
                                                          ),
                                                          const Color(
                                                            0xFFFF6F00,
                                                          ),
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            14,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: const Color(
                                                            0xFFFF9800,
                                                          ).withValues(
                                                            alpha: 0.4,
                                                          ),
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                            0,
                                                            2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Text(
                                                      '${item.chapterCount ?? 0}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  TweenAnimationBuilder<double>(
                                                    duration: const Duration(
                                                      milliseconds: 300,
                                                    ),
                                                    tween: Tween<double>(
                                                      begin: 0,
                                                      end: isExpanded ? 1.0 : 0,
                                                    ),
                                                    curve:
                                                        Curves.easeInOutCubic,
                                                    builder: (
                                                      context,
                                                      value,
                                                      child,
                                                    ) {
                                                      return Transform.rotate(
                                                        angle: value * 3.14159,
                                                        child: const Icon(
                                                          Icons
                                                              .keyboard_arrow_down,
                                                          color: Color(
                                                            0xFFFF9800,
                                                          ),
                                                          size: 28,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Expandable chapter list
                                      AnimatedSize(
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        curve: Curves.easeInOutCubic,
                                        child:
                                            isExpanded && folderChapters != null
                                                ? Column(
                                                  children:
                                                      folderChapters.asMap().entries.map((
                                                        entry,
                                                      ) {
                                                        final chIndex =
                                                            entry.key;
                                                        final chapter =
                                                            entry.value;
                                                        final chapterId =
                                                            (chapter['id'] ??
                                                                    chapter['_id'] ??
                                                                    '')
                                                                .toString();
                                                        final exerciseCount =
                                                            chapter['exerciseCount'] ??
                                                            0;
                                                        return TweenAnimationBuilder<
                                                          double
                                                        >(
                                                          duration: Duration(
                                                            milliseconds:
                                                                300 +
                                                                (chIndex * 50),
                                                          ),
                                                          tween: Tween<double>(
                                                            begin: 0,
                                                            end: 1,
                                                          ),
                                                          curve:
                                                              Curves
                                                                  .easeOutCubic,
                                                          builder: (
                                                            context,
                                                            value,
                                                            child,
                                                          ) {
                                                            return Transform.translate(
                                                              offset: Offset(
                                                                20 *
                                                                    (1 - value),
                                                                0,
                                                              ),
                                                              child: Opacity(
                                                                opacity: value,
                                                                child: child,
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            margin:
                                                                const EdgeInsets.only(
                                                                  left: 24,
                                                                  right: 0,
                                                                  bottom: 10,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10.0,
                                                                  ),
                                                              color:
                                                                  const Color(
                                                                    0xFFE8F5E9,
                                                                  ),
                                                              border: Border(
                                                                left: BorderSide(
                                                                  color: Color(
                                                                    0xFF4CAF50,
                                                                  ),
                                                                  width: 4,
                                                                ),
                                                              ),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .green
                                                                      .withValues(
                                                                        alpha:
                                                                            0.15,
                                                                      ),
                                                                  spreadRadius:
                                                                      1,
                                                                  blurRadius: 4,
                                                                  offset:
                                                                      const Offset(
                                                                        0,
                                                                        2,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Material(
                                                              color:
                                                                  Colors
                                                                      .transparent,
                                                              child: InkWell(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10.0,
                                                                    ),
                                                                onTap: () {
                                                                  Get.to(
                                                                    () => ExerciseView(
                                                                      chapterTitle:
                                                                          chapter['chapterName'] ??
                                                                          '',
                                                                      chapterId:
                                                                          chapterId,
                                                                    ),
                                                                  );
                                                                },
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                        14.0,
                                                                      ),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        child: Row(
                                                                          children: [
                                                                            const Icon(
                                                                              Icons.description_outlined,
                                                                              color: Color(
                                                                                0xFF4CAF50,
                                                                              ),
                                                                              size:
                                                                                  22,
                                                                            ),
                                                                            const SizedBox(
                                                                              width:
                                                                                  10,
                                                                            ),
                                                                            Expanded(
                                                                              child: Column(
                                                                                crossAxisAlignment:
                                                                                    CrossAxisAlignment.start,
                                                                                children: [
                                                                                  CustomText(
                                                                                    text:
                                                                                        chapter['chapterName'] ??
                                                                                        '',
                                                                                    fontSize:
                                                                                        16,
                                                                                    color:
                                                                                        AppColors.textBlack,
                                                                                    maxLines:
                                                                                        2,
                                                                                    textOverflow:
                                                                                        TextOverflow.ellipsis,
                                                                                  ),
                                                                                  if (exerciseCount >
                                                                                      0) ...[
                                                                                    const SizedBox(
                                                                                      height:
                                                                                          4,
                                                                                    ),
                                                                                    CustomText(
                                                                                      text:
                                                                                          '$exerciseCount Exercise${exerciseCount == 1 ? '' : 's'}',
                                                                                      fontSize:
                                                                                          13,
                                                                                      color: const Color(
                                                                                        0xFF4CAF50,
                                                                                      ),
                                                                                      fontWeight:
                                                                                          FontWeight.w500,
                                                                                    ),
                                                                                  ],
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Obx(() {
                                                                        bool
                                                                        isFav =
                                                                            false;
                                                                        final contentItem = controller.contentList.where(
                                                                          (
                                                                            ci,
                                                                          ) =>
                                                                              (ci.id ==
                                                                                      chapterId ||
                                                                                  ci.chapterId ==
                                                                                      chapterId) &&
                                                                              ci.isChapter,
                                                                        );
                                                                        if (contentItem
                                                                            .isNotEmpty) {
                                                                          isFav =
                                                                              contentItem.first.isFavorite ??
                                                                              false;
                                                                        } else {
                                                                          isFav = controller.guestFavouriteIds.contains(
                                                                            chapterId,
                                                                          );
                                                                        }
                                                                        return GestureDetector(
                                                                          onTap:
                                                                              () => controller.toggleFavourite(
                                                                                chapterId,
                                                                              ),
                                                                          child: Image.asset(
                                                                            isFav
                                                                                ? IconsPath.starFill
                                                                                : IconsPath.starOutline,
                                                                            height:
                                                                                22,
                                                                          ),
                                                                        );
                                                                      }),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                )
                                                : const SizedBox.shrink(),
                                      ),
                                    ],
                                  );
                                });
                              }

                              // Standalone chapter tile
                              return Container(
                                key: ValueKey(item.chapterId),
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFDEF5F2),
                                      const Color(0xFFB2EBF2),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.teal.withValues(alpha: 0.2),
                                      spreadRadius: 1,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12.0),
                                    onTap: () {
                                      Get.to(
                                        () => ExerciseView(
                                          chapterTitle: item.chapterName ?? '',
                                          chapterId: item.chapterId ?? '',
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.menu_book_rounded,
                                                  color: Color(0xFF00897B),
                                                  size: 26,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomText(
                                                        text:
                                                            item.chapterName ??
                                                            '',
                                                        fontSize: 17,
                                                        color:
                                                            AppColors.textBlack,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        maxLines: 2,
                                                        textOverflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                      if ((item.exerciseCount ??
                                                              0) >
                                                          0) ...[
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        CustomText(
                                                          text:
                                                              '${item.exerciseCount} Exercise${item.exerciseCount == 1 ? '' : 's'}',
                                                          fontSize: 13,
                                                          color: const Color(
                                                            0xFF00897B,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              controller.toggleFavourite(
                                                item.chapterId!,
                                              );
                                            },
                                            child: Image.asset(
                                              item.isFavorite == true
                                                  ? IconsPath.starFill
                                                  : IconsPath.starOutline,
                                              height: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }, childCount: displayItems.length),
                          );
                        }),
                        if (!isPremium)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 8.0,
                              ),
                              child: Column(
                                children: [
                                  CustomText(
                                    text: 'Unlock all exercises and chapters',
                                    fontSize: 16,
                                    color: AppColors.textBlack,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF5EAEB5),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.lock_open,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {
                                      await BillingManager.instance
                                          .buyPremium();
                                    },
                                    label: const Text(
                                      'Go Premium',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Obx(
                          () => SliverToBoxAdapter(
                            child:
                                profileController.profile.value?.isPayment ==
                                        false
                                    ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16.0,
                                        horizontal: 8.0,
                                      ),
                                      child: Column(
                                        children: [
                                          CustomText(
                                            text: 'full_access_message'.tr,
                                            fontSize: 16,
                                            color: AppColors.textBlack,
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 12),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFF5EAEB5,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 32,
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () async {
                                              final String? token =
                                                  await SharePref.getSavedToken();
                                              if (token == null) {
                                                Get.snackbar(
                                                  'error'.tr,
                                                  'login_to_purchase'.tr,
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                );
                                                return;
                                              } else {
                                                Get.to(
                                                  () => PurchasePage(
                                                    userToken: token,
                                                  ),
                                                );
                                              }
                                            },
                                            child: Text(
                                              'purchase_now'.tr,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 60)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
