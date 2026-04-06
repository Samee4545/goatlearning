import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/global_widegts/cached_pdf_viewer.dart';
import 'package:goatlearning/core/global_widegts/custom_background.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/feature/admin/edit/model/chapter_model.dart';
import 'package:goatlearning/generated/assets.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class AdminExerciseDetailScreen extends StatefulWidget {
  final ChapterModel chapter;

  const AdminExerciseDetailScreen({super.key, required this.chapter});

  @override
  State<AdminExerciseDetailScreen> createState() =>
      _AdminExerciseDetailScreenState();
}

class _AdminExerciseDetailScreenState extends State<AdminExerciseDetailScreen> {
  var showQuestionView = false.obs;
  var currentQuestionIndex = 0.obs;
  var solutionVisible = <int, Rx<bool>>{}.obs;
  final RxMap<int, PdfViewerController?> problemPdfControllers =
      <int, PdfViewerController?>{}.obs;
  final RxMap<int, PdfViewerController?> solutionPdfControllers =
      <int, PdfViewerController?>{}.obs;

  @override
  void initState() {
    super.initState();
    if (widget.chapter.exercises != null) {
      for (int i = 0; i < widget.chapter.exercises!.length; i++) {
        solutionVisible[i] = Rx<bool>(false);
      }
    }
  }

  @override
  void dispose() {
    problemPdfControllers.forEach((key, controller) {
      controller?.dispose();
    });
    solutionPdfControllers.forEach((key, controller) {
      controller?.dispose();
    });
    super.dispose();
  }

  PdfViewerController getProblemPdfController(int index) {
    if (!problemPdfControllers.containsKey(index) ||
        problemPdfControllers[index] == null) {
      problemPdfControllers[index] = PdfViewerController();
    }
    return problemPdfControllers[index]!;
  }

  PdfViewerController getSolutionPdfController(int index) {
    if (!solutionPdfControllers.containsKey(index) ||
        solutionPdfControllers[index] == null) {
      solutionPdfControllers[index] = PdfViewerController();
    }
    return solutionPdfControllers[index]!;
  }

  void clearControllersExcept(int index) {
    problemPdfControllers.keys.where((i) => i != index).toList().forEach((i) {
      problemPdfControllers[i]?.dispose();
      problemPdfControllers.remove(i);
    });
    solutionPdfControllers.keys.where((i) => i != index).toList().forEach((i) {
      solutionPdfControllers[i]?.dispose();
      solutionPdfControllers.remove(i);
    });
  }

  void goToQuestion(int index) {
    currentQuestionIndex.value = index;
    clearControllersExcept(index);
    showQuestionView.value = true;
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < widget.chapter.exercises!.length - 1) {
      currentQuestionIndex.value++;
      clearControllersExcept(currentQuestionIndex.value);
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
      clearControllersExcept(currentQuestionIndex.value);
    }
  }

  void toggleSolution(int index) {
    solutionVisible[index]?.value = !solutionVisible[index]!.value;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.chapter.exercises == null || widget.chapter.exercises!.isEmpty) {
      return Scaffold(
        body: CustomBackground(
          topCild: SizedBox.shrink(),
          child: Column(
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
                    Expanded(
                      child: CustomText(
                        text: widget.chapter.chapterName ?? "Exercises",
                        color: AppColors.textPrimaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(child: CustomText(text: 'No exercises found')),
              ),
            ],
          ),
        ),
      );
    }

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
                    onPressed: () {
                      if (showQuestionView.value) {
                        showQuestionView.value = false;
                      } else {
                        Get.back();
                      }
                    },
                  ),
                  Image.asset(
                    Assets.imagesChapterIcon,
                    color: AppColors.textPrimaryColor,
                    height: 24,
                  ),
                  SizedBox(width: 11),
                  Expanded(
                    child: CustomText(
                      text: widget.chapter.chapterName ?? "Exercises",
                      color: AppColors.textPrimaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.5),
                child: Obx(() {
                  return showQuestionView.value
                      ? _buildExerciseView(context)
                      : _buildGridView(context);
                }),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(BuildContext context) {
    final totalItems = widget.chapter.exercises!.length;
    final firstThird = (totalItems / 3).floor();
    final secondThird = 2 * (totalItems / 3).floor();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: widget.chapter.exercises!.length,
      itemBuilder: (context, index) {
        Color gridColor;
        if (index < firstThird) {
          gridColor = const Color(0xFF35a3e8);
        } else if (index < secondThird) {
          gridColor = const Color(0xFFf87f28);
        } else {
          gridColor = const Color(0xFFfac90e);
        }

        return GestureDetector(
          onTap: () {
            goToQuestion(index);
          },
          child: Container(
            decoration: BoxDecoration(
              color: gridColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.textPrimaryColor, width: 2),
            ),
            child: Center(
              child: CustomText(
                text: '${index + 1}',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExerciseView(BuildContext context) {
    final index = currentQuestionIndex.value;
    final exercise = widget.chapter.exercises![index];
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.textPrimaryColor,
                ),
                onPressed: () {
                  previousQuestion();
                },
              ),
              CustomText(
                text:
                    'Exercise ${index + 1}/${widget.chapter.exercises!.length}',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryColor,
              ),
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textPrimaryColor,
                ),
                onPressed: () {
                  nextQuestion();
                },
              ),
            ],
          ),
          // Problem PDF Viewer
          Container(
            height: screenHeight * 0.4,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.all(8.0),
            child: CachedPdfViewer(
              pdfUrl: exercise.problemUrl ?? '',
              pdfKey: ValueKey('problem_pdf_$index'),
              controller: getProblemPdfController(index),
              canShowScrollHead: true,
              canShowScrollStatus: true,
              scrollDirection: PdfScrollDirection.vertical,
              onDocumentLoaded: (details) {},
              onDocumentLoadFailed:
                  (details) => Get.snackbar(
                    'Error',
                    'Failed to load problem PDF: ${details.description}',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              toggleSolution(index);
            },
            child: Obx(() {
              return CustomText(
                text:
                    solutionVisible[index]!.value
                        ? 'HIDE SOLUTION'
                        : 'SHOW SOLUTION',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryColor,
              );
            }),
          ),
          Obx(() {
            return Visibility(
              visible: solutionVisible[index]!.value,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Solution PDF Viewer
                    Container(
                      height: screenHeight * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: CachedPdfViewer(
                        pdfUrl: exercise.solutionUrl ?? '',
                        pdfKey: ValueKey('solution_pdf_$index'),
                        controller: getSolutionPdfController(index),
                        canShowScrollHead: true,
                        canShowScrollStatus: true,
                        scrollDirection: PdfScrollDirection.vertical,
                        onDocumentLoaded: (details) {},
                        onDocumentLoadFailed:
                            (details) => Get.snackbar(
                              'Error',
                              'Failed to load solution PDF: ${details.description}',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
