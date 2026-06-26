// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/global_widegts/cached_pdf_viewer.dart';
import 'package:goatlearning/core/style/global_text_style.dart';
import 'package:goatlearning/feature/user/home/controller/home_controller.dart';
import 'package:goatlearning/feature/user/exercise/view/exercise_view.dart';
import 'package:goatlearning/generated/assets.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewScreen extends StatefulWidget {
  final String title;
  final String? id;
  final String pdfUrl;
  final String? path;
  const PdfViewScreen({
    super.key,
    required this.title,
    required this.pdfUrl,
    this.path,
    this.id,
  });

  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final HomeController controller = Get.find();
  int _totalPages = 1;
  int _currentPage = 0;
  double _progress = 0.0;
  double _highestProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.titleTextColor),

            onPressed: () {
              int finalPercentage = (_highestProgress * 100).toInt();

              print("Final Percentage: $finalPercentage%");
              controller.calculatorPercent(
                widget.id!,
                finalPercentage.toDouble(),
              );
              Navigator.of(context).pop();
            },
            padding: EdgeInsets.zero,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Image.asset(
                widget.path ?? Assets.imagesChapterIcon,
                height: 25,
                color: AppColors.titleTextColor,
              ),
              SizedBox(width: 10),

              Expanded(
                child: Text(
                  widget.title,
                  style: globalTextStyle(
                    color: AppColors.titleTextColor,
                    fontSize: 20,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 10),
            child: TextButton.icon(
              onPressed: () {
                Get.to(
                  () => ExerciseView(
                    chapterTitle: widget.title,
                    chapterId: widget.id!,
                  ),
                );
              },
              icon: Icon(
                Icons.fitness_center,
                color: AppColors.titleTextColor,
                size: 18,
              ),
              label: Text(
                'exercise'.tr,
                style: globalTextStyle(
                  color: AppColors.titleTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],

        backgroundColor: AppColors.appColor,
        toolbarHeight: MediaQuery.of(context).size.height * 0.1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CachedPdfViewer(
                  pdfUrl: widget.pdfUrl,
                  controller: _pdfViewerController,
                  onDocumentLoaded: (details) {
                    setState(() {
                      _totalPages = details.document.pages.count;
                    });
                  },
                  onPageChanged: (details) {
                    setState(() {
                      _currentPage = details.newPageNumber;
                      _progress = (_currentPage) / _totalPages;

                      if (_progress > _highestProgress) {
                        _highestProgress = _progress;
                        print(
                          "🔥 New Highest Progress: ${(_highestProgress * 100).toStringAsFixed(1)}%",
                        );
                      }
                    });

                    if (kDebugMode) {
                      print(
                        "📖 Reading Progress: ${(_progress * 100).toStringAsFixed(1)}%",
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
