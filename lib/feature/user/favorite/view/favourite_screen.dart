// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/core/global_widegts/custom_background.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/feature/user/favorite/controller/favourite_controller.dart';
import 'package:goatlearning/feature/user/home/view/pdf_view_screen.dart';
import 'package:goatlearning/feature/user/profile/controller/user_profile_controller.dart';
import 'package:shimmer/shimmer.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen>
    with AutomaticKeepAliveClientMixin {
  final UserProfileController profileController = Get.find();
  late final FavouriteController controller;

  @override
  void initState() {
    super.initState();
    controller =
        Get.isRegistered<FavouriteController>()
            ? Get.find<FavouriteController>()
            : Get.put(FavouriteController());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh favourites every time the page becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchFavourite();
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: CustomBackground(
        topCild: SizedBox.shrink(),
        child: Column(
          children: [
            SizedBox(height: 18),
            Expanded(
              child: Obx(() {
                // Show shimmer loading effect
                if (controller.isLoading.value) {
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: 10,
                    itemBuilder: (context, index) {
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
                                    width: 140,
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
                    },
                  );
                }

                if (controller.favourite == null ||
                    controller.favourite.isEmpty) {
                  return Center(
                    child: CustomText(
                      text: 'no_favorites_found'.tr,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: controller.favourite.length,
                  itemBuilder: (context, index) {
                    var item = controller.favourite[index];
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFDEF5F2), Color(0xFFB2EBF2)],
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
                              () => PdfViewScreen(
                                title: item.chapterName,
                                pdfUrl: item.theory,
                                id: item.id,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
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
                                        child: CustomText(
                                          text: item.chapterName,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textBlack,
                                          maxLines: 2,
                                          textOverflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    controller.toggleFavourite(item.id);
                                  },
                                  child: Image.asset(
                                    item.isFavorite
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
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
