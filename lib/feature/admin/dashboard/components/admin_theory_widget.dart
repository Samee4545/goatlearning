// ignore_for_file: invalid_use_of_protected_member, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/global_widegts/custom_error_text.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/feature/admin/dashboard/view/admin_pdf_viewer.dart';
import 'package:goatlearning/feature/admin/edit/controller/admin_edit_controller.dart';
import 'package:shimmer/shimmer.dart';

class AdminTheoryWidget extends StatelessWidget {
  AdminTheoryWidget({super.key});
  final AdminEditController adminEditController = Get.find();

  Future<void> showMoveToFolderDialog(
    BuildContext context,
    String chapterId,
  ) async {
    // Fetch all folders when dialog opens
    final folders = await adminEditController.getAllFolders();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(maxHeight: 500),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select Folder',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5EAEB5),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child:
                        folders.isEmpty
                            ? Center(
                              child: Text(
                                'No folders available. Create one first!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              itemCount: folders.length,
                              itemBuilder: (context, index) {
                                final folder = folders[index];
                                return ListTile(
                                  leading: Icon(
                                    Icons.folder,
                                    color: Color(0xFF5EAEB5),
                                  ),
                                  title: Text(
                                    folder['name'] ?? 'Untitled',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.add_circle_outline,
                                    color: Color(0xFF5EAEB5),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    adminEditController.addChapterToFolder(
                                      folder['id'] ?? '',
                                      chapterId,
                                    );
                                  },
                                );
                              },
                            ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('close'.tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _refreshData() async {
    await adminEditController.fetchChapter();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 15),
        child: Column(
          children: [
            if (adminEditController.isSearchActive.value)
              TextField(
                controller: adminEditController.searchController,
                onChanged: (value) {
                  adminEditController.filterList(value);
                },
                decoration: InputDecoration(
                  hintText: 'search'.tr,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      adminEditController.clearSearch();
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
            if (adminEditController.isSearchActive.value) SizedBox(height: 16),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: Obx(() {
                  if (adminEditController.isLoading.value ||
                      !adminEditController.isDataLoaded.value) {
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: 6,
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
                  if (adminEditController.filteredContent.isEmpty &&
                      adminEditController.isDataLoaded.value) {
                    return CustomErrorText(
                      text:
                          'no_content_found'.tr.isEmpty
                              ? 'No content found'
                              : 'no_content_found'.tr,
                      color: AppColors.textBlack,
                    );
                  }
                  return ReorderableListView.builder(
                    padding: EdgeInsets.zero,
                    buildDefaultDragHandles: true,
                    itemCount: adminEditController.filteredContent.length,
                    onReorder: (oldIndex, newIndex) {
                      // Avoid persisting reorder from a filtered subset.
                      if (adminEditController.isSearchActive.value &&
                          adminEditController.searchController.text
                              .trim()
                              .isNotEmpty) {
                        return;
                      }
                      adminEditController.reorderChapters(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      var item = adminEditController.filteredContent[index];

                      // Folder tile with expandable content
                      if (item.isFolder) {
                        return Obx(() {
                          final isExpanded = adminEditController.expandedFolders
                              .contains(item.id);
                          final folderChapters =
                              adminEditController.folderChaptersCache[item.id];

                          return Column(
                            key: ValueKey(item.id),
                            children: [
                              // Folder header
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
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
                                    borderRadius: BorderRadius.circular(12.0),
                                    onTap: () {
                                      adminEditController.toggleFolderExpansion(
                                        item.id ?? '',
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          // Animated folder icon
                                          TweenAnimationBuilder<double>(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            tween: Tween<double>(
                                              begin: 0,
                                              end: isExpanded ? 0.5 : 0,
                                            ),
                                            curve: Curves.easeInOutCubic,
                                            builder: (context, value, child) {
                                              return Transform.rotate(
                                                angle: value * 3.14159,
                                                child: Icon(
                                                  isExpanded
                                                      ? Icons.folder_open
                                                      : Icons.folder,
                                                  color: Color(0xFFFF9800),
                                                  size: 32,
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: CustomText(
                                              text:
                                                  item.name ??
                                                  "Untitled Folder",
                                              fontSize: 16,
                                              color: AppColors.textBlack,
                                              fontWeight: FontWeight.w700,
                                              maxLines: 3,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ),
                                          // Chapter count badge
                                          if (item.chapterCount != null &&
                                              item.chapterCount! > 0)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFFFF9800),
                                                    Color(0xFFFF6F00),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color(
                                                      0xFFFF9800,
                                                    ).withValues(alpha: 0.4),
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                '${item.chapterCount}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          const SizedBox(width: 8),
                                          // Delete folder button
                                          GestureDetector(
                                            onTap: () async {
                                              final confirmed = await showDialog<
                                                bool
                                              >(
                                                context: context,
                                                builder:
                                                    (ctx) => AlertDialog(
                                                      title: const Text(
                                                        'Delete Folder',
                                                      ),
                                                      content: const Text(
                                                        'Are you sure you want to delete this folder?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    ctx,
                                                                    false,
                                                                  ),
                                                          child: const Text(
                                                            'Cancel',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    ctx,
                                                                    true,
                                                                  ),
                                                          child: const Text(
                                                            'Delete',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                              if (confirmed == true) {
                                                await adminEditController
                                                    .deleteFolder(
                                                      item.id ?? '',
                                                    );
                                              }
                                            },
                                            child: Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Animated chevron
                                          TweenAnimationBuilder<double>(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            tween: Tween<double>(
                                              begin: 0,
                                              end: isExpanded ? 1.0 : 0,
                                            ),
                                            curve: Curves.easeInOutCubic,
                                            builder: (context, value, child) {
                                              return Transform.rotate(
                                                angle: value * 3.14159,
                                                child: Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Color(0xFFFF9800),
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
                              // Expandable chapters list
                              AnimatedSize(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOutCubic,
                                child:
                                    isExpanded && folderChapters != null
                                        ? Column(
                                          children:
                                              folderChapters.asMap().entries.map((
                                                entry,
                                              ) {
                                                final chIndex = entry.key;
                                                final chapter = entry.value;
                                                return TweenAnimationBuilder<
                                                  double
                                                >(
                                                  duration: Duration(
                                                    milliseconds:
                                                        300 + (chIndex * 50),
                                                  ),
                                                  tween: Tween<double>(
                                                    begin: 0,
                                                    end: 1,
                                                  ),
                                                  curve: Curves.easeOutCubic,
                                                  builder: (
                                                    context,
                                                    value,
                                                    child,
                                                  ) {
                                                    return Transform.translate(
                                                      offset: Offset(
                                                        20 * (1 - value),
                                                        0,
                                                      ),
                                                      child: Opacity(
                                                        opacity: value,
                                                        child: child,
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    width: double.infinity,
                                                    margin: EdgeInsets.only(
                                                      left: 24,
                                                      right: 0,
                                                      bottom: 10,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10.0,
                                                          ),
                                                      color: const Color(
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
                                                          color: Colors.green
                                                              .withValues(
                                                                alpha: 0.15,
                                                              ),
                                                          spreadRadius: 1,
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                            0,
                                                            2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10.0,
                                                            ),
                                                        onTap: () {
                                                          Get.to(
                                                            () => AdminPdfViewer(
                                                              title:
                                                                  chapter['chapterName'] ??
                                                                  "N/A",
                                                              pdfUrl:
                                                                  chapter['theory'] ??
                                                                  "",
                                                              id: chapter['id'],
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
                                                                    Icon(
                                                                      Icons
                                                                          .description_outlined,
                                                                      color: Color(
                                                                        0xFF4CAF50,
                                                                      ),
                                                                      size: 22,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Expanded(
                                                                      child: CustomText(
                                                                        text:
                                                                            chapter['chapterName'] ??
                                                                            "N/A",
                                                                        fontSize:
                                                                            16,
                                                                        color:
                                                                            AppColors.textBlack,
                                                                        maxLines:
                                                                            2,
                                                                        textOverflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              // Remove from folder icon
                                                              GestureDetector(
                                                                onTap: () async {
                                                                  final confirmed = await Get.dialog<
                                                                    bool
                                                                  >(
                                                                    AlertDialog(
                                                                      title: Text(
                                                                        'Remove Chapter',
                                                                      ),
                                                                      content: Text(
                                                                        'Remove this chapter from the folder? It will become a standalone chapter.',
                                                                      ),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed:
                                                                              () => Get.back(
                                                                                result:
                                                                                    false,
                                                                              ),
                                                                          child: Text(
                                                                            'Cancel',
                                                                          ),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed:
                                                                              () => Get.back(
                                                                                result:
                                                                                    true,
                                                                              ),
                                                                          style: TextButton.styleFrom(
                                                                            foregroundColor:
                                                                                Colors.red,
                                                                          ),
                                                                          child: Text(
                                                                            'Remove',
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                  if (confirmed ==
                                                                      true) {
                                                                    await adminEditController
                                                                        .removeChapterFromFolder(
                                                                          chapter['id'] ??
                                                                              '',
                                                                        );
                                                                  }
                                                                },
                                                                child: Icon(
                                                                  Icons
                                                                      .remove_circle_outline,
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                  size: 22,
                                                                ),
                                                              ),
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
                        }, key: ValueKey('folder-${item.id}'));
                      }

                      // Standalone chapter tile
                      return Container(
                        key: ValueKey(item.id),
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
                                () => AdminPdfViewer(
                                  title: item.chapterName ?? "N/A",
                                  pdfUrl: item.theory ?? "",
                                  id: item.id,
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
                                        Icon(
                                          Icons.menu_book_rounded,
                                          color: Color(0xFF00897B),
                                          size: 26,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: CustomText(
                                            text: item.chapterName ?? "N/A",
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
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap:
                                            () => showMoveToFolderDialog(
                                              context,
                                              item.id ?? "",
                                            ),
                                        child: Icon(
                                          Icons.drive_file_move_outline,
                                          color: Color(0xFF5EAEB5),
                                          size: 24,
                                        ),
                                      ),
                                    ],
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
            ),
          ],
        ),
      ),
    );
  }
}
