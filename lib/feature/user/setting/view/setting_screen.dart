import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/core/const/translation_service.dart';
import 'package:goatlearning/core/global_widegts/custom_background.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/global_widegts/profile_compenent.dart';
import 'package:goatlearning/core/route/routes.dart';
import 'package:goatlearning/core/services_class/billing/billing_manager.dart';
import 'package:goatlearning/feature/user/components/custom_user_appbar.dart';
import 'package:goatlearning/feature/user/profile/controller/user_profile_controller.dart';

class SettingScreen extends StatelessWidget {
  SettingScreen({super.key});
  final UserProfileController userProfileController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        topCild: CustomUserAppbar(profileController: userProfileController),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
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
                    iconPath: IconsPath.cloud,
                    title: 'offline_mode'.tr,
                    onPressed: () => Get.toNamed(AppRoutes.offlineMode),
                  ),
                  ProfileComponent(
                    iconPath: IconsPath.lockIcon2,
                    title: 'restore_purchases'.tr,
                    onPressed:
                        () async => BillingManager.instance.restorePurchases(),
                  ),
                  ProfileComponent(
                    iconPath: IconsPath.helpCenter,
                    title: 'check_billing_status'.tr,
                    onPressed: () async {
                      EasyLoading.show(status: 'Checking billing...');
                      final report =
                          await BillingManager.instance.diagnoseBilling();
                      EasyLoading.dismiss();
                      Get.defaultDialog(
                        title: 'Billing Diagnostics',
                        content: SingleChildScrollView(
                          child: Text(
                            report,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        textConfirm: 'OK',
                        onConfirm: () => Get.back(),
                      );
                    },
                  ),
                  ProfileComponent(
                    iconPath: IconsPath.addAdmin,
                    title: 'admin_login'.tr,
                    onPressed: () => Get.toNamed(AppRoutes.login),
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
