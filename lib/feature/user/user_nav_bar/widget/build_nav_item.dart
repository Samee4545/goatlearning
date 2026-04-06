import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/feature/user/user_nav_bar/controller/user_nav_bar_controller.dart';

Widget buildNavItem(
  int index,
  String assetPath,
  String label,
  UserNavBarController controller,
) {
  return Obx(() {
    bool isSelected = controller.selectedIndex.value == index;
    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 0,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xffEDF5F7) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            Image.asset(
              assetPath,
              width: 24,
              height: 24,
              color: isSelected ? AppColors.appColor : Colors.white,
            ),
            if (isSelected) const SizedBox(width: 10),
            if (isSelected) CustomText(text: label, color: Color(0xff203141)),
          ],
        ),
      ),
    );
  });
}
