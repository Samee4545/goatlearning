import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/global_widegts/app_base_widget.dart';
import 'package:goatlearning/core/global_widegts/cached_pdf_viewer.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/feature/user/exercise/controller/exercise_controller.dart';
import 'package:goatlearning/feature/user/home/model/user_chapter_model.dart';
import 'package:goatlearning/generated/assets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ExerciseView extends StatefulWidget {
  final String? chapterTitle;
  final String chapterId;

  const ExerciseView({super.key, this.chapterTitle, required this.chapterId});

  @override
  State<ExerciseView> createState() => _ExerciseViewState();
}

class _ExerciseViewState extends State<ExerciseView> {
  late final ExerciseController controller;
  late Future<ChapterDetail?> _chapterDetailFuture;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ExerciseController());
    _chapterDetailFuture = controller.getChapterDetails(widget.chapterId);
  }

  @override
  void dispose() {
    Get.delete<ExerciseController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChapterDetail?>(
      future: _chapterDetailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading(context);
        }
        if (snapshot.hasError) {
          return Center(child: CustomText(text: 'Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.exercises.isEmpty) {
          return const Center(child: CustomText(text: 'No exercises found'));
        }

        if (controller.exercises.isEmpty) {
          controller.initializeExercises(
            snapshot.data!.exercises,
            widget.chapterId,
          );
        }

        return Scaffold(
          body: AppBaseWidget(
            needBackButton: true,
            needCallBackForBackButton: () {
              if (controller.showQuestionView.value) {
                controller.showQuestionView.value = false;
              } else {
                final index = controller.currentQuestionIndex.value;
                final problemPercent =
                    (controller.problemHighestProgress[index]?.value ?? 0.0) *
                    50;
                final solutionPercent =
                    (controller.solutionHighestProgress[index]?.value ?? 0.0) *
                    50;
                final totalPercent =
                    (problemPercent + solutionPercent).toInt().toDouble();
                controller.calculatorPercent(widget.chapterId, totalPercent);
                Get.back();
              }
            },
            needChapterLeadingIcon: true,
            chapterAssetsPath: Assets.imagesChapterIcon,
            needChapterTitle: true,
            needNotificationIcon: true,
            title: widget.chapterTitle,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    child: Obx(() {
                      return controller.showQuestionView.value
                          ? _buildExerciseView(context)
                          : _buildGridView(context);
                    }),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return Scaffold(
      body: AppBaseWidget(
        needBackButton: true,
        needCallBackForBackButton: () {
          Get.back();
        },
        needChapterLeadingIcon: true,
        chapterAssetsPath: Assets.imagesChapterIcon,
        needChapterTitle: true,
        needNotificationIcon: true,
        title: widget.chapterTitle,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: 30,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.textPrimaryColor,
                      width: 2,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridView(BuildContext context) {
    final totalItems = controller.exercises.length;
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
      itemCount: controller.exercises.length,
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
            controller.goToQuestion(index);
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
    final index = controller.currentQuestionIndex.value;
    final exercise = controller.exercises[index];
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
                  controller.previousQuestion();
                },
              ),
              CustomText(
                text: 'Exercise ${index + 1}/${controller.exercises.length}',
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
                  controller.nextQuestion();
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
              pdfUrl: exercise.problemUrl,
              pdfKey: ValueKey('problem_pdf_$index'),
              controller: controller.getProblemPdfController(index),
              canShowScrollHead: true,
              canShowScrollStatus: true,
              scrollDirection: PdfScrollDirection.vertical,
              onDocumentLoaded: (details) {
                controller.updateProblemProgress(
                  index,
                  1,
                  details.document.pages.count,
                );
              },
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
              controller.toggleSolution(index);
            },
            child: Obx(() {
              return CustomText(
                text:
                    controller.solutionVisible[index]!.value
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
              visible: controller.solutionVisible[index]!.value,
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
                        pdfUrl: exercise.solutionUrl,
                        pdfKey: ValueKey('solution_pdf_$index'),
                        controller: controller.getSolutionPdfController(index),
                        canShowScrollHead: true,
                        canShowScrollStatus: true,
                        scrollDirection: PdfScrollDirection.vertical,
                        onDocumentLoaded: (details) {
                          controller.updateSolutionProgress(
                            index,
                            1,
                            details.document.pages.count,
                          );
                        },
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
