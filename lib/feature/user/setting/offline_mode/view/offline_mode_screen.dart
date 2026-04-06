import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/app_sizes.dart';
import 'package:goatlearning/core/global_widegts/custom_background.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/feature/user/profile/controller/user_profile_controller.dart';
import 'package:goatlearning/feature/user/setting/offline_mode/controller/offline_controller.dart';

class OfflineModeScreen extends StatelessWidget {
  OfflineModeScreen({super.key});

  final UserProfileController userProfileController = Get.find();
  final OfflineController offlineController = Get.put(OfflineController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        topCild: SizedBox.shrink(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 16.5, right: 15.5),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimaryColor,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  CustomText(
                    text: 'offline_mode'.tr,
                    color: AppColors.textPrimaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.appColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.appColor,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: CustomText(
                              text: 'offline_description'.tr,
                              color: AppColors.textPrimaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Cache Info
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.folder,
                              label: 'cached_files'.tr,
                              value:
                                  '${offlineController.cachedFileCount.value}',
                            ),
                            SizedBox(height: 12),
                            _buildInfoRow(
                              icon: Icons.storage,
                              label: 'cache_size'.tr,
                              value: offlineController.cacheSize.value,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Download Progress
                    Obx(() {
                      if (offlineController.isDownloading.value) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(
                                    text: 'download_progress'.tr,
                                    color: AppColors.textPrimaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  CustomText(
                                    text:
                                        '${offlineController.currentDownloadIndex.value}/${offlineController.totalFilesToDownload.value}',
                                    color: AppColors.appColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              if (offlineController
                                  .currentFileName
                                  .value
                                  .isNotEmpty)
                                CustomText(
                                  text: offlineController.currentFileName.value,
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                  maxLines: 1,
                                ),
                              SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: offlineController.downloadProgress.value,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.appColor,
                                ),
                                minHeight: 8,
                              ),
                              SizedBox(height: 8),
                              CustomText(
                                text:
                                    '${(offlineController.downloadProgress.value * 100).toStringAsFixed(1)}%',
                                color: AppColors.textGrey,
                                fontSize: 12,
                              ),
                            ],
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    }),
                    SizedBox(height: 24),

                    // Download Button
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed:
                              offlineController.isDownloading.value
                                  ? offlineController.cancelDownload
                                  : offlineController.downloadAllPDFs,
                          icon: Icon(
                            offlineController.isDownloading.value
                                ? Icons.cancel
                                : Icons.download,
                            color: Colors.white,
                          ),
                          label: CustomText(
                            text:
                                offlineController.isDownloading.value
                                    ? 'cancel_download'.tr
                                    : 'download_all_pdfs'.tr,
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                offlineController.isDownloading.value
                                    ? Colors.red
                                    : AppColors.appColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Clear Cache Button
                    Obx(
                      () =>
                          offlineController.cachedFileCount.value > 0
                              ? SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton.icon(
                                  onPressed:
                                      offlineController.isDownloading.value
                                          ? null
                                          : () {
                                            Get.defaultDialog(
                                              title: 'clear_cache'.tr,
                                              middleText:
                                                  'Are you sure you want to clear all cached PDFs?',
                                              textConfirm: 'Yes',
                                              textCancel: 'No',
                                              confirmTextColor: Colors.white,
                                              onConfirm: () {
                                                Get.back();
                                                offlineController
                                                    .clearAllCache();
                                              },
                                            );
                                          },
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  label: CustomText(
                                    text: 'clear_cache'.tr,
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              )
                              : SizedBox.shrink(),
                    ),
                    SizedBox(height: getHeight(20)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.appColor, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: CustomText(
            text: label,
            color: AppColors.textPrimaryColor,
            fontSize: 14,
          ),
        ),
        CustomText(
          text: value,
          color: AppColors.appColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }
}
