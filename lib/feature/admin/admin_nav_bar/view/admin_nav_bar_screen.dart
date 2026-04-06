import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/feature/admin/add_new/controller/admin_add_new_controller.dart';
import 'package:goatlearning/feature/admin/add_new/view/admin_add_new_screen.dart';
import 'package:goatlearning/feature/admin/admin_nav_bar/controller/admin_nav_bar_controller.dart';
import 'package:goatlearning/feature/admin/admin_nav_bar/widget/build_nav_item.dart';
import 'package:goatlearning/feature/admin/dashboard/view/admin_dashboard_screen.dart';
import 'package:goatlearning/feature/admin/edit/view/admin_edit_screen.dart';
import 'package:goatlearning/feature/admin/profile/controller/admin_profile_controller.dart';
import 'package:goatlearning/feature/admin/setting/view/admin_setting_screen.dart';

class AdminNavBarScreen extends StatelessWidget {
  AdminNavBarScreen({super.key});

  final AdminNavBarController adminController = Get.put(
    AdminNavBarController(),
  );
  final AdminProfileController adminProfileController = Get.put(
    AdminProfileController(),
  );
  final AdminAddNewController adminAddNewController = Get.put(
    AdminAddNewController(),
  );
  final List<Widget> screens = [
    AdminDashboardScreen(),
    AdminEditScreen(),
    AdminAddNewScreen(),
    AdminSettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => screens[adminController.selectedIndex.value]),
      bottomNavigationBar: Container(
        height: 80,
        padding: EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 20),
        decoration: const BoxDecoration(color: Color(0xFF131D2C)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            adminBuildNavItem(
              0,
              IconsPath.dashboard,
              'dashboard'.tr,
              adminController,
            ),
            adminBuildNavItem(1, IconsPath.edit, 'edit'.tr, adminController),
            adminBuildNavItem(2, IconsPath.add, 'add_new'.tr, adminController),
            adminBuildNavItem(3, IconsPath.setting, 'settings'.tr, adminController),
          ],
        ),
      ),
    );
  }
}
