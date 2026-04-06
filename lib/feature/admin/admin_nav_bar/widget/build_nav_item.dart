import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/feature/admin/admin_nav_bar/controller/admin_nav_bar_controller.dart';

Widget adminBuildNavItem(
  int index,
  String assetPath,
  String label,
  AdminNavBarController adminController,
) {
  return Obx(() {
    bool isSelected = adminController.selectedIndex.value == index;
    return GestureDetector(
      onTap: () => adminController.changeIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 0,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Image.asset(
              assetPath,
              width: 24,
              height: 24,
              color: isSelected ? Colors.black : Colors.white,
            ),
            if (isSelected) const SizedBox(width: 8),
            if (isSelected) CustomText(text: label, color: Color(0xff203141)),
          ],
        ),
      ),
    );
  });
}
