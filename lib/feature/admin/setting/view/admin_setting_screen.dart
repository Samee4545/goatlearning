import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/core/const/translation_service.dart';
import 'package:goatlearning/core/global_widegts/custom_background.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/global_widegts/profile_compenent.dart';
import 'package:goatlearning/core/route/routes.dart';
import 'package:goatlearning/feature/admin/components/custom_admin_appbar.dart';
import 'package:goatlearning/feature/admin/profile/controller/admin_profile_controller.dart';

class AdminSettingScreen extends StatelessWidget {
  AdminSettingScreen({super.key});
  final AdminProfileController adminProfileController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        topCild: CustomAdminAppbar(
          adminProfileController: adminProfileController,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 35),
            Padding(
              padding: const EdgeInsets.only(left: 16.5, right: 15.5),
              child: CustomText(
                text: 'settings'.tr,
                color: AppColors.textPrimaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  ProfileComponent(
                    iconPath: IconsPath.addUser,
                    title: 'manage_admin'.tr,
                    onPressed: () => Get.toNamed(AppRoutes.adminList),
                  ),
                  ProfileComponent(
                    iconPath: IconsPath.lockIcon,
                    title: 'security'.tr,
                    onPressed: () => Get.toNamed(AppRoutes.adminSecurity),
                  ),
                  ProfileComponent(
                    iconPath: IconsPath.language,
                    title: 'language'.tr,
                    onPressed: () {
                      final currentLang = Get.locale?.languageCode ?? 'en';
                      Get.defaultDialog(
                        title: 'choose_language'.tr,
                        titleStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildLanguageTile(
                              language: 'english'.tr,
                              languageKey: 'English',
                              flag: '🇬🇧',
                              isSelected: currentLang == 'en',
                            ),
                            const SizedBox(height: 8),
                            _buildLanguageTile(
                              language: 'deutsch'.tr,
                              languageKey: 'Deutsch',
                              flag: '🇩🇪',
                              isSelected: currentLang == 'de',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.5),
                    child: InkWell(
                      onTap: () => adminProfileController.logout(),
                      child: Row(
                        children: [
                          Container(
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xffE5FAFF),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Image.asset(IconsPath.logout),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CustomText(
                            text: 'logout'.tr,
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildLanguageTile({
  required String language,
  required String languageKey, // Change from languageCode to languageKey
  required String flag,
  required bool isSelected,
}) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
        width: isSelected ? 2 : 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(language),
      trailing:
          isSelected
              ? const Icon(Icons.check_circle, color: AppColors.primaryColor)
              : null,
      onTap:
          isSelected
              ? null
              : () async {
                await TranslationService.changeLocale(
                  languageKey,
                ); // Pass the key, not the translated name
                Get.back();
              },
    ),
  );
}
