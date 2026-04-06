import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/app_sizes.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/core/const/image_path.dart';
import 'package:goatlearning/core/global_widegts/custom_background.dart';
import 'package:goatlearning/core/global_widegts/custom_error_text.dart';
import 'package:goatlearning/core/global_widegts/custom_shimmer_image.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/route/routes.dart';
import 'package:goatlearning/feature/admin/profile/controller/admin_profile_controller.dart';
import 'package:goatlearning/feature/admin/setting/manage_admin/controller/add_admin_controller.dart';

class AdminListScreen extends StatelessWidget {
  AdminListScreen({super.key});
  final AdminProfileController adminProfileController = Get.find();
  final AddAdminController addAdminController = Get.put(AddAdminController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        childHeight: screenHeight() * 0.8,
        topCild: SizedBox.shrink(),
        child: Obx(() {
          if (adminProfileController.profile.value == null) {
            return CustomErrorText(text: 'loading'.tr);
          }
          if (adminProfileController.profile.value!.username!.isEmpty) {
            return CustomErrorText(text: 'unknown'.tr);
          }
          final profile = adminProfileController.profile.value!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 16.5, right: 15.5),
                child: CustomText(
                  text: 'manage_admin'.tr,
                  color: AppColors.textPrimaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              // profile.role == "SUPER_ADMIN"
              //                     ?SizedBox.shrink()
              Container(
                margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  // vertical: 8,
                ),
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xffF5F9FA),

                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CustomShimmerImage(
                          height: 30,
                          width: 30,
                          borderWidth: 0,
                          color: Colors.transparent,
                          image: profile.profileImage ?? "N?A",
                          errorImage: Image.asset(ImagePath.profile),
                        ),
                        SizedBox(width: 8),
                        CustomText(
                          text: profile.username ?? "N/A",
                          color: AppColors.textBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          textOverflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    CustomText(
                      text: profile.username ?? "N/A",
                      color: AppColors.textBlack,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Obx(() {
                  if (addAdminController.adminList.value?.data == null) {
                    return CustomErrorText(text: 'loading'.tr);
                  }

                  if (addAdminController.adminList.value!.data!.isEmpty) {
                    return CustomErrorText();
                  }
                  var data =
                      addAdminController.adminList.value!.data!.reversed
                          .toList();
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      var items = data[index];
                      return Container(
                        margin: EdgeInsets.only(
                          bottom: 16,
                          left: 16,
                          right: 16,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xffF5F9FA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(IconsPath.avatar, height: 24),
                                SizedBox(width: 8),
                                CustomText(
                                  text: items.username ?? "N/A",

                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textBlack,
                                ),
                              ],
                            ),
                            profile.role == "SUPER_ADMIN"
                                ? InkWell(
                                  onTap: () {
                                    addAdminController.deleteAdmin(
                                      items.id ?? "no id",
                                    );
                                  },
                                  child: Image.asset(
                                    IconsPath.delete,
                                    height: 16,
                                  ),
                                )
                                : SizedBox.shrink(),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
              SizedBox(height: 24),
            ],
          );
        }),
      ),
      floatingActionButton: Obx(() {
        final profile = adminProfileController.profile.value;
        if (profile == null) return SizedBox.shrink();

        return profile.role == "SUPER_ADMIN"
            ? FloatingActionButton(
              backgroundColor: AppColors.questionBorder,
              onPressed: () {
                Get.toNamed(AppRoutes.addAdmin);
              },
              child: Image.asset(IconsPath.addAdmin, height: 24),
            )
            : SizedBox.shrink();
      }),
    );
  }
}
