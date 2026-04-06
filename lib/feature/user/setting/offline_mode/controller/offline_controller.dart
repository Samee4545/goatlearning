import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/network_caller/endpoints.dart';
import 'package:goatlearning/core/services_class/local_service/pdf_cache_service.dart';
import 'package:goatlearning/feature/user/home/controller/home_controller.dart';
import 'package:http/http.dart' as http;

class OfflineController extends GetxController {
  final PdfCacheService _cacheService = PdfCacheService();
  final HomeController _homeController = Get.find<HomeController>();

  // Observable variables
  var isDownloading = false.obs;
  var downloadProgress = 0.0.obs;
  var currentDownloadIndex = 0.obs;
  var totalFilesToDownload = 0.obs;
  var downloadedFilesCount = 0.obs;
  var cacheSize = '0 B'.obs;
  var cachedFileCount = 0.obs;
  var currentFileName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    updateCacheInfo();
  }

  /// Update cache information
  Future<void> updateCacheInfo() async {
    try {
      final size = await _cacheService.getCacheSize();
      cacheSize.value = _cacheService.formatBytes(size);
      cachedFileCount.value = await _cacheService.getCachedFileCount();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating cache info: $e');
      }
    }
  }

  /// Download all PDFs for offline access
  Future<void> downloadAllPDFs() async {
    if (isDownloading.value) {
      EasyLoading.showInfo('download_in_progress'.tr);
      return;
    }

    try {
      isDownloading.value = true;
      downloadProgress.value = 0.0;
      currentDownloadIndex.value = 0;
      downloadedFilesCount.value = 0;

      // Collect all PDF URLs
      List<Map<String, String>> pdfUrls = [];

      // Get all chapters for theory PDFs
      final chapters = _homeController.userChapter;

      if (chapters.isEmpty) {
        EasyLoading.showInfo('no_chapters_to_download'.tr);
        isDownloading.value = false;
        return;
      }

      // Add theory PDFs
      for (var chapter in chapters) {
        if (chapter.theory.isNotEmpty) {
          pdfUrls.add({
            'url': chapter.theory,
            'name': '${chapter.chapterName} - Theory',
            'type': 'theory',
          });
        }
      }

      // Get all exercises with solutions from the new API
      final exercisesData = await _getAllExercisesWithSolutions();
      
      if (exercisesData != null) {
        final exercisesByChapter = exercisesData['exercisesByChapter'] as List? ?? [];
        
        for (var chapterData in exercisesByChapter) {
          final chapterName = chapterData['chapterName'] ?? 'Unknown';
          final exercises = chapterData['exercises'] as List? ?? [];
          
          for (var exercise in exercises) {
            final exerciseNumber = exercise['exerciseNumber'] ?? 0;
            
            // Add problem PDF
            final problemUrl = exercise['problemUrl'];
            if (problemUrl != null && problemUrl.toString().isNotEmpty) {
              pdfUrls.add({
                'url': problemUrl.toString(),
                'name': '$chapterName - Exercise $exerciseNumber Problem',
                'type': 'problem',
              });
            }
            
            // Add solution PDF
            final solutionUrl = exercise['solutionUrl'];
            if (solutionUrl != null && solutionUrl.toString().isNotEmpty) {
              pdfUrls.add({
                'url': solutionUrl.toString(),
                'name': '$chapterName - Exercise $exerciseNumber Solution',
                'type': 'solution',
              });
            }
          }
        }
      }

      totalFilesToDownload.value = pdfUrls.length;

      if (pdfUrls.isEmpty) {
        EasyLoading.showInfo('no_pdfs_to_download'.tr);
        isDownloading.value = false;
        return;
      }

      EasyLoading.show(status: 'downloading_pdfs'.tr);

      // Download each PDF
      for (int i = 0; i < pdfUrls.length; i++) {
        if (!isDownloading.value) {
          // Download cancelled
          break;
        }

        currentDownloadIndex.value = i + 1;
        currentFileName.value = pdfUrls[i]['name']!;

        final url = pdfUrls[i]['url']!;
        
        // Check if already cached
        final isCached = await _cacheService.isCached(url);
        if (isCached) {
          if (kDebugMode) {
            print('Already cached: ${pdfUrls[i]['name']}');
          }
          downloadedFilesCount.value++;
          downloadProgress.value = (i + 1) / pdfUrls.length;
          continue;
        }

        // Download the PDF
        final result = await _cacheService.downloadAndCache(
          url,
          onProgress: (received, total) {
            if (total != -1) {
              final fileProgress = received / total;
              final overallProgress = (i + fileProgress) / pdfUrls.length;
              downloadProgress.value = overallProgress;
            }
          },
        );

        if (result != null) {
          downloadedFilesCount.value++;
          if (kDebugMode) {
            print('Downloaded: ${pdfUrls[i]['name']}');
          }
        } else {
          if (kDebugMode) {
            print('Failed to download: ${pdfUrls[i]['name']}');
          }
        }

        downloadProgress.value = (i + 1) / pdfUrls.length;
      }

      await updateCacheInfo();

      if (isDownloading.value) {
        EasyLoading.showSuccess(
          'download_complete'.tr.replaceAll(
            '@count',
            downloadedFilesCount.value.toString(),
          ),
        );
      } else {
        EasyLoading.showInfo('download_cancelled'.tr);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading PDFs: $e');
      }
      EasyLoading.showError('download_failed'.tr);
    } finally {
      isDownloading.value = false;
      downloadProgress.value = 0.0;
      currentDownloadIndex.value = 0;
      currentFileName.value = '';
    }
  }

  /// Get all exercises with solutions from API
  Future<Map<String, dynamic>?> _getAllExercisesWithSolutions() async {
    try {
      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/exercise/all-solutions'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Get all exercises response status: ${response.statusCode}');
        print('Get all exercises response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>?;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching all exercises: $e');
      }
      return null;
    }
  }

  /// Cancel ongoing download
  void cancelDownload() {
    isDownloading.value = false;
    EasyLoading.dismiss();
  }

  /// Clear all cached PDFs
  Future<void> clearAllCache() async {
    try {
      EasyLoading.show(status: 'clearing_cache'.tr);
      await _cacheService.clearCache();
      await updateCacheInfo();
      EasyLoading.showSuccess('cache_cleared'.tr);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cache: $e');
      }
      EasyLoading.showError('failed_to_clear_cache'.tr);
    }
  }

}

