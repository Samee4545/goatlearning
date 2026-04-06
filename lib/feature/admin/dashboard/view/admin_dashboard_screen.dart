import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/core/global_widegts/custom_background.dart';
import 'package:goatlearning/feature/admin/dashboard/components/admin_exercise_wiget.dart';
import 'package:goatlearning/feature/admin/dashboard/components/admin_theory_widget.dart';
import 'package:goatlearning/feature/admin/edit/controller/admin_edit_controller.dart';
import 'package:goatlearning/feature/admin/profile/controller/admin_profile_controller.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final AdminProfileController adminProfileController = Get.find();
  final AdminEditController adminEditController = Get.put(
    AdminEditController(),
  );

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load all data once on initialization - both theory and exercise tabs will use cached data
    adminEditController.loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                        // Pop the dialog BEFORE awaiting async work to avoid using a
                        // deactivated context after the refresh updates the tree.
                        Navigator.of(context).pop();
                        await adminEditController.createFolder(name);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCreateFolderDialog(context);
        },
        backgroundColor: Color(0xFF5EAEB5),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: CustomBackground(
        topCild: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              onTap: () {
                adminEditController.showSearchBar();
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
              SizedBox(height: 14),
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF5F7),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  indicator: BoxDecoration(
                    color: const Color(0xFF5EAEB5),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  tabs: [Tab(text: 'theory'.tr), Tab(text: 'exercise'.tr)],
                ),
              ),
              SizedBox(height: 14),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [AdminTheoryWidget(), AdminExerciseWidget()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
