import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PdfCacheService {
  static final PdfCacheService _instance = PdfCacheService._internal();
  factory PdfCacheService() => _instance;
  PdfCacheService._internal() {
    // Configure Dio with proper options
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status != null && status < 500, // Accept all non-server errors
      followRedirects: true,
      maxRedirects: 5,
    );
  }

  final Dio _dio = Dio();
  static const String _cacheMetadataKey = 'pdf_cache_metadata';

  /// Get the cache directory for PDFs
  Future<Directory> _getCacheDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final pdfCacheDir = Directory('${directory.path}/pdf_cache');
    if (!await pdfCacheDir.exists()) {
      await pdfCacheDir.create(recursive: true);
    }
    return pdfCacheDir;
  }

  /// Generate a safe filename from URL
  String _generateFileName(String url) {
    // Extract filename from URL or create hash
    final uri = Uri.parse(url);
    String filename = uri.pathSegments.last;
    
    // If filename doesn't end with .pdf, use hash
    if (!filename.toLowerCase().endsWith('.pdf')) {
      filename = '${url.hashCode.abs()}.pdf';
    }
    
    // Remove any invalid characters
    filename = filename.replaceAll(RegExp(r'[^\w\s\-\.]'), '_');
    return filename;
  }

  /// Check if a PDF is cached
  Future<bool> isCached(String url) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final filename = _generateFileName(url);
      final file = File('${cacheDir.path}/$filename');
      return await file.exists();
    } catch (e) {
      if (kDebugMode) {
        print('Error checking cache: $e');
      }
      return false;
    }
  }

  /// Get cached PDF file path
  Future<String?> getCachedFilePath(String url) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final filename = _generateFileName(url);
      final file = File('${cacheDir.path}/$filename');
      
      if (await file.exists()) {
        // Verify the cached file is a valid PDF
        if (await _isValidPdfFile(file)) {
          return file.path;
        } else {
          // Invalid cached file, delete it
          if (kDebugMode) {
            print('Cached file is invalid, deleting: $filename');
          }
          await file.delete();
          return null;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cached file: $e');
      }
      return null;
    }
  }

  /// Download and cache a PDF
  Future<String?> downloadAndCache(
    String url, {
    Function(int, int)? onProgress,
  }) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final filename = _generateFileName(url);
      final filePath = '${cacheDir.path}/$filename';
      final file = File(filePath);

      // If already cached, verify it's a valid PDF before returning
      if (await file.exists()) {
        if (await _isValidPdfFile(file)) {
          if (kDebugMode) {
            print('PDF already cached: $filename');
          }
          return filePath;
        } else {
          // Invalid cached file, delete it and re-download
          if (kDebugMode) {
            print('Cached file is invalid, deleting: $filename');
          }
          await file.delete();
        }
      }

      if (kDebugMode) {
        print('Downloading PDF: $url');
      }

      // Download the file
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received, total);
          }
          if (kDebugMode) {
            print('Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      // Verify the downloaded file is a valid PDF
      if (!await _isValidPdfFile(file)) {
        if (kDebugMode) {
          print('Downloaded file is not a valid PDF, deleting: $filename');
        }
        // Delete invalid file
        if (await file.exists()) {
          await file.delete();
        }
        return null;
      }

      // Save metadata
      await _saveCacheMetadata(url, filename);

      if (kDebugMode) {
        print('PDF cached successfully: $filename');
      }

      return filePath;
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading PDF: $e');
      }
      return null;
    }
  }

  /// Check if a file is a valid PDF by verifying the magic bytes
  Future<bool> _isValidPdfFile(File file) async {
    try {
      if (!await file.exists()) return false;
      
      final bytes = await file.openRead(0, 5).first;
      if (bytes.length < 5) return false;
      
      // PDF files start with "%PDF-"
      final header = String.fromCharCodes(bytes);
      return header.startsWith('%PDF-');
    } catch (e) {
      if (kDebugMode) {
        print('Error validating PDF file: $e');
      }
      return false;
    }
  }

  /// Save cache metadata
  Future<void> _saveCacheMetadata(String url, String filename) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadata = prefs.getString(_cacheMetadataKey);
      Map<String, dynamic> metadataMap = {};
      if (metadata != null && metadata.isNotEmpty) {
        try {
          metadataMap = Map<String, dynamic>.from(
            (metadata.startsWith('{')) ? (jsonDecode(metadata) as Map) : {},
          );
        } catch (_) {
          metadataMap = {};
        }
      }
      metadataMap[url] = {
        'filename': filename,
        'cachedAt': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_cacheMetadataKey, jsonEncode(metadataMap));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving metadata: $e');
      }
    }
  }

  /// Clear all cached PDFs
  Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create(recursive: true);
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheMetadataKey);
      
      if (kDebugMode) {
        print('Cache cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cache: $e');
      }
    }
  }

  /// Clear cache for a specific URL
  Future<void> clearCacheForUrl(String url) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final filename = _generateFileName(url);
      final file = File('${cacheDir.path}/$filename');
      
      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) {
          print('Deleted cached PDF: ${file.path}');
        }
      }
      
      // Update metadata
      final prefs = await SharedPreferences.getInstance();
      final metadataJson = prefs.getString(_cacheMetadataKey);
      if (metadataJson != null) {
        final metadata = Map<String, dynamic>.from(jsonDecode(metadataJson));
        metadata.remove(url);
        await prefs.setString(_cacheMetadataKey, jsonEncode(metadata));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cache for URL: $e');
      }
    }
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (var entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating cache size: $e');
      }
      return 0;
    }
  }

  /// Format bytes to human readable string
  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Get number of cached files
  Future<int> getCachedFileCount() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) {
        return 0;
      }

      int count = 0;
      await for (var entity in cacheDir.list()) {
        if (entity is File && entity.path.endsWith('.pdf')) {
          count++;
        }
      }
      return count;
    } catch (e) {
      if (kDebugMode) {
        print('Error counting cached files: $e');
      }
      return 0;
    }
  }
}

