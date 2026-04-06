import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/core/global_widegts/custom_background.dart';
import 'package:goatlearning/feature/user/home/components/custom_exercise.dart';
import 'package:goatlearning/feature/user/home/components/custom_theory.dart';
import 'package:goatlearning/feature/user/home/controller/home_controller.dart';
import 'package:goatlearning/feature/user/profile/controller/user_profile_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final HomeController homeController = Get.put(HomeController());
  final UserProfileController profileController = Get.find();

  Future<void> showCreateFolderDialog(BuildContext context) async {
    final TextEditingController folderNameController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'create_folder'.tr,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5EAEB5),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: folderNameController,
                  decoration: InputDecoration(
                    labelText: 'folder_name'.tr,
                    hintText: 'enter_folder_name'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
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
                      child: Text('cancel'.tr),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5EAEB5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final name = folderNameController.text.trim();
                        if (name.isEmpty) return;
                        // Pop before awaiting to avoid using dialog context after dispose
                        Navigator.of(context).pop();
                        await homeController.createFolder(name);
                      },
                      child: Text(
                        'create'.tr,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        topCild: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              onTap: () {
                homeController.showSearchBar();
              },
              child: Container(
                height: 35,
                width: 35,
                margin: const EdgeInsets.only(top: 25),
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image.asset(IconsPath.search),
              ),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 14),
              Obx(
                () =>
                    homeController.isSearchActive.value
                        ? TextField(
                          controller: homeController.searchController,
                          decoration: InputDecoration(
                            hintText: 'search_chapters'.tr,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: homeController.clearSearch,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                          onChanged: homeController.filterList,
                        )
                        : Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDF5F7),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: TabBar(
                            controller: homeController.tabController,
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            labelColor: Colors.white,
                            indicator: BoxDecoration(
                              color: const Color(0xFF5EAEB5),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            tabs: [
                              Tab(text: 'theory'.tr),
                              Tab(text: 'exercise'.tr),
                            ],
                          ),
                        ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: TabBarView(
                  controller: homeController.tabController,
                  children: [CustomTheoryWidget(), CustomExerciseWidget()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
