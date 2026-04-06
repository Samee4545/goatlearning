import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/services_class/local_service/pdf_cache_service.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// A widget that displays a PDF from cache if available, otherwise from network
/// and automatically caches it for future use
class CachedPdfViewer extends StatefulWidget {
  final String pdfUrl;
  final PdfViewerController? controller;
  final PdfDocumentLoadedCallback? onDocumentLoaded;
  final PdfPageChangedCallback? onPageChanged;
  final PdfDocumentLoadFailedCallback? onDocumentLoadFailed;
  final bool canShowScrollHead;
  final bool canShowScrollStatus;
  final PdfScrollDirection scrollDirection;
  final Key? pdfKey;

  const CachedPdfViewer({
    super.key,
    required this.pdfUrl,
    this.controller,
    this.onDocumentLoaded,
    this.onPageChanged,
    this.onDocumentLoadFailed,
    this.canShowScrollHead = true,
    this.canShowScrollStatus = true,
    this.scrollDirection = PdfScrollDirection.vertical,
    this.pdfKey,
  });

  @override
  State<CachedPdfViewer> createState() => _CachedPdfViewerState();
}

class _CachedPdfViewerState extends State<CachedPdfViewer> {
  final PdfCacheService _cacheService = PdfCacheService();
  String? _cachedFilePath;
  bool _isLoadingCache = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  @override
  void didUpdateWidget(CachedPdfViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload PDF if URL changed
    if (oldWidget.pdfUrl != widget.pdfUrl) {
      _loadPdf();
    }
  }

  /// Validate if URL is valid
  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Clean and encode URL properly
  String _cleanUrl(String url) {
    // Trim whitespace
    url = url.trim();

    // If URL contains spaces, encode them
    if (url.contains(' ')) {
      url = url.replaceAll(' ', '%20');
    }

    return url;
  }

  /// Load PDF from cache or download it
  Future<void> _loadPdf() async {
    final cleanedUrl = _cleanUrl(widget.pdfUrl);

    // Validate URL first
    if (!_isValidUrl(cleanedUrl)) {
      if (kDebugMode) {
        print('Invalid PDF URL: ${widget.pdfUrl}');
      }
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Invalid PDF URL';
          _isLoadingCache = false;
        });
      }
      return;
    }

    try {
      // Check if PDF is already cached
      final cachedPath = await _cacheService.getCachedFilePath(cleanedUrl);

      if (cachedPath != null) {
        // Use cached PDF
        if (kDebugMode) {
          print('Using cached PDF: $cachedPath');
        }
        if (mounted) {
          setState(() {
            _cachedFilePath = cachedPath;
            _isLoadingCache = false;
            _hasError = false;
          });
        }
      } else {
        // Show network PDF immediately
        if (mounted) {
          setState(() {
            _isLoadingCache = false;
            _hasError = false;
          });
        }

        // Download and cache PDF in background (don't wait)
        if (kDebugMode) {
          print('Downloading PDF for caching: $cleanedUrl');
        }
        _cacheService.downloadAndCache(cleanedUrl).then((path) {
          if (path != null && mounted) {
            if (kDebugMode) {
              print('PDF cached successfully: $path');
            }
            setState(() {
              _cachedFilePath = path;
            });
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading PDF: $e');
      }
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load PDF';
          _isLoadingCache = false;
        });
      }
    }
  }

  void _handleLoadError(PdfDocumentLoadFailedDetails details) {
    if (kDebugMode) {
      print('PDF load failed: ${details.error}');
      print('PDF load description: ${details.description}');
    }

    // If we were using cached file and it failed, try network instead
    if (_cachedFilePath != null && mounted) {
      if (kDebugMode) {
        print('Cached PDF failed to load, trying network...');
      }
      // Delete the invalid cached file
      _cacheService.clearCacheForUrl(_cleanUrl(widget.pdfUrl));
      setState(() {
        _cachedFilePath = null; // This will trigger network load
      });
      return;
    }

    // Call the original callback if provided
    widget.onDocumentLoadFailed?.call(details);

    // If network load fails, show error with retry option
    if (mounted) {
      setState(() {
        _hasError = true;
        // Provide a more helpful error message
        if (details.description.toLowerCase().contains('error') ||
            details.description.toLowerCase().contains('failed')) {
          _errorMessage =
              'PDF could not be loaded. The link may have expired. Please go back and try again.';
        } else {
          _errorMessage = 'Failed to load PDF: ${details.description}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCache) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.appColor),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _errorMessage,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoadingCache = true;
                });
                _loadPdf();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.appColor,
              ),
              child: Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final cleanedUrl = _cleanUrl(widget.pdfUrl);

    // Use cached file if available, otherwise use network
    if (_cachedFilePath != null) {
      return SfPdfViewer.file(
        File(_cachedFilePath!),
        key: widget.pdfKey,
        controller: widget.controller,
        onDocumentLoaded: widget.onDocumentLoaded,
        onPageChanged: widget.onPageChanged,
        onDocumentLoadFailed: _handleLoadError,
        canShowScrollHead: widget.canShowScrollHead,
        canShowScrollStatus: widget.canShowScrollStatus,
        scrollDirection: widget.scrollDirection,
        pageSpacing: 0,
      );
    } else {
      return SfPdfViewer.network(
        cleanedUrl,
        key: widget.pdfKey,
        controller: widget.controller,
        onDocumentLoaded: widget.onDocumentLoaded,
        onPageChanged: widget.onPageChanged,
        onDocumentLoadFailed: _handleLoadError,
        canShowScrollHead: widget.canShowScrollHead,
        canShowScrollStatus: widget.canShowScrollStatus,
        scrollDirection: widget.scrollDirection,
        pageSpacing: 0,
      );
    }
  }
}
