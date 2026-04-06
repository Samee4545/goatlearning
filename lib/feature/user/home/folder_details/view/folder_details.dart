import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/global_widegts/app_base_widget.dart';
import 'package:goatlearning/feature/user/home/folder_details/controller/folder_details_controller.dart';
import 'package:goatlearning/feature/user/home/folder_details/widgets/folder_exercise_widget.dart';
import 'package:goatlearning/feature/user/home/folder_details/widgets/folder_theory_widget.dart';

class FolderDetails extends StatelessWidget {
  const FolderDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final FolderDetailsController controller = Get.put(
      FolderDetailsController(),
    );

    return Scaffold(
      body: AppBaseWidget(
        needBackButton: true,
        needCallBackForBackButton: () {
          Get.back();
        },
        needChapterTitle: true,
        needNotificationIcon: true,
        title: controller.folderName,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child:
                    controller.folderType == 'exercise'
                        ? CustomExerciseWidget(
                          controller: controller,
                          homeController: controller.homeController,
                        )
                        : CustomTheoryWidget(
                          controller: controller,
                          homeController: controller.homeController,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
