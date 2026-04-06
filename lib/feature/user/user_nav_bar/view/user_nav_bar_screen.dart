import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/feature/user/favorite/view/favourite_screen.dart';
import 'package:goatlearning/feature/user/home/view/home_screen.dart';
import 'package:goatlearning/feature/user/profile/controller/user_profile_controller.dart';
import 'package:goatlearning/feature/user/setting/view/setting_screen.dart';
import 'package:goatlearning/feature/user/user_nav_bar/controller/user_nav_bar_controller.dart';
import 'package:goatlearning/feature/user/user_nav_bar/widget/build_nav_item.dart';

class UserNavBarScreen extends StatelessWidget {
  UserNavBarScreen({super.key});

  final UserNavBarController controller = Get.put(UserNavBarController());
  final UserProfileController userProfileController = Get.put(
    UserProfileController(),
  );

  final List<Widget> screens = [
    HomeScreen(),
    //ProfileScreen(),
    FavouriteScreen(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => screens[controller.selectedIndex.value]),
      bottomNavigationBar: Container(
        height: 80,
        padding: EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 20),
        decoration: const BoxDecoration(color: Color(0xFF152133)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildNavItem(0, IconsPath.home, 'home'.tr, controller),
            SizedBox(width: 15),
            //buildNavItem(1, IconsPath.profile, 'profile'.tr, controller),
            buildNavItem(1, IconsPath.star, 'favorites'.tr, controller),
            SizedBox(width: 15),
            buildNavItem(2, IconsPath.setting, 'settings'.tr, controller),
          ],
        ),
      ),
    );
  }
}
