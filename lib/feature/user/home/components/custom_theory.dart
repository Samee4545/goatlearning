import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/services_class/billing/billing_manager.dart';
import 'package:goatlearning/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:goatlearning/feature/user/home/controller/home_controller.dart';
import 'package:goatlearning/feature/user/home/purcess_scrren/purchase_screen.dart';
import 'package:goatlearning/feature/user/home/view/pdf_view_screen.dart';
import 'package:goatlearning/feature/user/profile/controller/user_profile_controller.dart';
import 'package:shimmer/shimmer.dart';

class CustomTheoryWidget extends StatelessWidget {
  const CustomTheoryWidget({super.key});

  Future<void> _showMoveToFolderDialog(
      BuildContext context,
      String chapterId,
      ) async {
    final HomeController controller = Get.find();
    return showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'move_to_folder'.tr,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5EAEB5),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (controller.folders.isEmpty) {
                  return Text(
                    'no_folders_available'.tr,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  );
                }
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.folders.length,
                    itemBuilder: (context, index) {
                      final folder = controller.folders[index];
                      return ListTile(
                        title: Text(
                          folder.name,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textBlack,
                          ),
                        ),
                        onTap: () {
                          controller.moveChapterToFolder(chapterId, folder.id);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('cancel'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();
    final UserProfileController profileController = Get.find();

    return ValueListenableBuilder<bool>(
      valueListenable: BillingManager.instance.isPremium,
      builder: (context, isPremium, _) {
        return Obx(() {
          // ── Single source of truth ───────────────────────────────────────
          final bool isFullyUnlocked =
              isPremium || (profileController.profile.value?.isPayment == true);

          // ── Build display list ───────────────────────────────────────────
          final source = controller.filteredContent;
          final List displayItems = isFullyUnlocked
              ? List.from(source)
              : source.take(4).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // ── Loading shimmer ──────────────────────────────────
                      if (controller.isLoading.value)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (_, __) => _TheoryShimmerTile(),
                            childCount: 10,
                          ),
                        )

                      // ── Empty state ──────────────────────────────────────
                      else if (controller.filteredContent.isEmpty &&
                          controller.hasLoadedContent.value)
                        SliverToBoxAdapter(
                          child: Center(
                            child: CustomText(
                              text: 'no_theory_found'.tr,
                              color: AppColors.textBlack,
                              fontSize: 16,
                            ),
                          ),
                        )

                      // ── Content list ─────────────────────────────────────
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              final item = displayItems[index];
                              if (item.isFolder) {
                                return _TheoryFolderTile(
                                  item: item,
                                  controller: controller,
                                );
                              }
                              return _TheoryChapterTile(
                                item: item,
                                controller: controller,
                              );
                            },
                            childCount: displayItems.length,
                          ),
                        ),

                      // ── Premium upsell ───────────────────────────────────
                      if (!isFullyUnlocked)
                        SliverToBoxAdapter(
                          child: _TheoryPremiumUpsell(
                            profileController: profileController,
                          ),
                        ),

                      const SliverToBoxAdapter(child: SizedBox(height: 60)),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer tile
// ─────────────────────────────────────────────────────────────────────────────

class _TheoryShimmerTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(width: 24, height: 24, color: Colors.white),
                const SizedBox(width: 14),
                Container(width: 100, height: 18, color: Colors.white),
              ],
            ),
            Container(width: 24, height: 24, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Folder tile
// ─────────────────────────────────────────────────────────────────────────────

class _TheoryFolderTile extends StatelessWidget {
  const _TheoryFolderTile({required this.item, required this.controller});

  final dynamic item;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded =
      controller.expandedFolders.contains(item.folderId);
      final folderChapters = controller.folderChaptersCache[item.folderId];

      return Column(
        key: ValueKey(item.folderId),
        children: [
          // Folder header
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () =>
                    controller.toggleFolderExpansion(item.folderId ?? ''),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        tween: Tween(begin: 0, end: isExpanded ? 0.5 : 0),
                        curve: Curves.easeInOutCubic,
                        builder: (_, value, __) => Transform.rotate(
                          angle: value * 3.14159,
                          child: Icon(
                            isExpanded ? Icons.folder_open : Icons.folder,
                            color: const Color(0xFFFF9800),
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: CustomText(
                          text: item.name ?? '',
                          fontSize: 16,
                          color: AppColors.textBlack,
                          fontWeight: FontWeight.w700,
                          maxLines: 3,
                          textOverflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Chapter count badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9800), Color(0xFFFF6F00)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF9800)
                                  .withValues(alpha: 0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${item.chapterCount ?? 0}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        tween: Tween(begin: 0, end: isExpanded ? 1.0 : 0),
                        curve: Curves.easeInOutCubic,
                        builder: (_, value, __) => Transform.rotate(
                          angle: value * 3.14159,
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFFFF9800),
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Expandable chapters list
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            child: (isExpanded && folderChapters != null)
                ? Column(
              children: folderChapters.asMap().entries.map((entry) {
                final chIndex = entry.key;
                final chapter = entry.value;
                return TweenAnimationBuilder<double>(
                  duration:
                  Duration(milliseconds: 300 + (chIndex * 50)),
                  tween: Tween(begin: 0, end: 1),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, child) => Transform.translate(
                    offset: Offset(20 * (1 - value), 0),
                    child: Opacity(opacity: value, child: child),
                  ),
                  child: _TheoryFolderChapterTile(
                    chapter: chapter,
                    controller: controller,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Chapter tile inside a folder
// ─────────────────────────────────────────────────────────────────────────────

class _TheoryFolderChapterTile extends StatelessWidget {
  const _TheoryFolderChapterTile({
    required this.chapter,
    required this.controller,
  });

  final Map<String, dynamic> chapter;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final chapterId = (chapter['id'] ?? chapter['_id'] ?? '').toString();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 24, bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFE8F5E9),
        border: const Border(
          left: BorderSide(color: Color(0xFF4CAF50), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.15),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => Get.to(
                () => PdfViewScreen(
              title: chapter['chapterName'] ?? '',
              pdfUrl: chapter['theory'] ?? '',
              id: chapterId,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: Color(0xFF4CAF50),
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomText(
                          text: chapter['chapterName'] ?? '',
                          fontSize: 16,
                          color: AppColors.textBlack,
                          maxLines: 2,
                          textOverflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() {
                  bool isFav = false;
                  final contentItem = controller.contentList.where(
                        (ci) =>
                    (ci.id == chapterId || ci.chapterId == chapterId) &&
                        ci.isChapter,
                  );
                  if (contentItem.isNotEmpty) {
                    isFav = contentItem.first.isFavorite ?? false;
                  } else {
                    isFav =
                        controller.guestFavouriteIds.contains(chapterId);
                  }
                  return GestureDetector(
                    onTap: () => controller.toggleFavourite(chapterId),
                    child: Image.asset(
                      isFav ? IconsPath.starFill : IconsPath.starOutline,
                      height: 22,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Standalone chapter tile
// ─────────────────────────────────────────────────────────────────────────────

class _TheoryChapterTile extends StatelessWidget {
  const _TheoryChapterTile({required this.item, required this.controller});

  final dynamic item;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(item.chapterId),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(12),
          onTap: () => Get.to(
                () => PdfViewScreen(
              title: item.chapterName ?? '',
              pdfUrl: item.theory ?? '',
              id: item.chapterId ?? '',
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          text: item.chapterName ?? '',
                          fontSize: 17,
                          color: AppColors.textBlack,
                          fontWeight: FontWeight.w600,
                          maxLines: 2,
                          textOverflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.toggleFavourite(item.chapterId!),
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
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium upsell — single unified block
// ─────────────────────────────────────────────────────────────────────────────

class _TheoryPremiumUpsell extends StatelessWidget {
  const _TheoryPremiumUpsell({required this.profileController});

  final UserProfileController profileController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          CustomText(
            text: 'full_access_message'.tr,
            fontSize: 16,
            color: AppColors.textBlack,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // IAP button (Google Play / App Store)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5EAEB5),
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.lock_open, color: Colors.white),
            onPressed: () async => BillingManager.instance.buyPremium(),
            label: Text(
              'purchase_now'.tr,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),

          const SizedBox(height: 8),

          // Web/backend purchase fallback
          Obx(() {
            final needsWebPurchase =
                profileController.profile.value?.isPayment == false;
            if (!needsWebPurchase) return const SizedBox.shrink();
            return TextButton(
              onPressed: () async {
                final String? token = await SharePref.getSavedToken();
                if (token == null) {
                  Get.snackbar(
                    'error'.tr,
                    'login_to_purchase'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else {
                  Get.to(() => PurchasePage(userToken: token));
                }
              },
              child: Text(
                'purchase_via_web'.tr,
                style: const TextStyle(
                  color: Color(0xFF5EAEB5),
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}