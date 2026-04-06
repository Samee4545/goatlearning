import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_linear_progress_indicator/custom_linear_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/core/const/image_path.dart';
import 'package:goatlearning/core/global_widegts/app_base_widget.dart';
import 'package:goatlearning/core/global_widegts/custom_error_text.dart';
import 'package:goatlearning/core/global_widegts/custom_shimmer_image.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/route/routes.dart';
import 'package:goatlearning/feature/user/profile/controller/user_profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final UserProfileController userProfileController = Get.put(
    UserProfileController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await userProfileController.fetchProfile();
          await userProfileController.completePercentage();
        },
        child: AppBaseWidget(
          needBackButton: false,
          needChapterTitle: true,
          title: 'welcome_message'.trParams({
            'username':
                userProfileController.profile.value?.username ?? 'user'.tr,
          }),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.5),
                child: CustomText(
                  text: 'profile'.tr,
                  color: AppColors.textPrimaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Obx(() {
                if (userProfileController.profile.value == null) {
                  return CustomErrorText(text: 'loading'.tr);
                }
                if (userProfileController.profile.value!.username!.isEmpty) {
                  return CustomErrorText(text: 'not_available'.tr);
                }
                final profile = userProfileController.profile.value!;
                return Center(
                  child: Column(
                    children: [
                      CustomShimmerImage(
                        height: 60,
                        width: 60,
                        borderWidth: 1,
                        color: Color(0xff173156),
                        image: profile.profileImage ?? 'not_available'.tr,
                        errorImage: Image.asset(ImagePath.profile),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomText(
                            text: profile.username ?? 'not_available'.tr,
                            color: Color(0xff173156),
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(width: 4),
                          GestureDetector(
                            onTap: () async {
                              Get.toNamed(AppRoutes.completeProfile);
                            },
                            child: Image.asset(
                              IconsPath.editBg,
                              height: 20,
                              width: 20,
                              color: AppColors.appColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      CustomText(
                        text: 'profession_label'.trParams({
                          'profession':
                              profile.profession ?? 'not_available'.tr,
                        }),
                        color: Color(0xffA3B0C2),
                        fontSize: 12,
                      ),
                      CustomText(
                        text: 'class_label'.trParams({
                          'class': profile.sector ?? 'not_available'.tr,
                        }),
                        color: Color(0xffA3B0C2),
                        fontSize: 12,
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomText(
                  text: 'continue_learning'.tr,
                  color: AppColors.textPrimaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 18),

              Obx(
                () => Expanded(
                  child:
                      userProfileController.percentage.value?.data.isEmpty ??
                              true
                          ? ListView(
                            physics: AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                              ),
                              Center(
                                child: CustomText(
                                  text: 'no_data_found'.tr,
                                  color: AppColors.textPrimaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                          : ListView.separated(
                            physics: AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount:
                                userProfileController
                                    .percentage
                                    .value
                                    ?.data
                                    .length ??
                                0,
                            separatorBuilder: (_, __) => SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              var chapter =
                                  userProfileController
                                      .percentage
                                      .value!
                                      .data[index]
                                      .chapter;
                              return SizedBox(
                                height: 56,
                                child: Row(
                                  children: [
                                    Container(
                                      height: 56,
                                      width: 63,
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Color(
                                          0xff1DB4DA,
                                        ).withValues(alpha: 0.11),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: CachedNetworkImage(
                                          imageUrl: chapter.coverImage,
                                          fit: BoxFit.cover,
                                          placeholder:
                                              (context, url) => Center(
                                                child: SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              ),
                                          errorWidget:
                                              (context, url, error) => Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                                size: 24,
                                              ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            text: chapter.chapterName,
                                            color: AppColors.appColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          SizedBox(height: 4),
                                          CustomText(
                                            text: 'completed_percentage'
                                                .trParams({
                                                  'percent':
                                                      userProfileController
                                                          .percentage
                                                          .value!
                                                          .data[index]
                                                          .completePercent
                                                          .toString(),
                                                }),
                                            color: Color(0xffA3B0C2),
                                            fontSize: 12,
                                          ),
                                          SizedBox(height: 6),
                                          SizedBox(
                                            height: 2,
                                            child:
                                                CustomLinearProgressIndicator(
                                                  value:
                                                      userProfileController
                                                          .percentage
                                                          .value!
                                                          .data[index]
                                                          .completePercent
                                                          .toDouble() /
                                                      100,
                                                  minHeight: 2,
                                                  backgroundColor: const Color(
                                                    0xffBBDFE8,
                                                  ),
                                                  gradientColors: const [
                                                    Color(0xff7FBECD),
                                                    Color(0xff7FBECD),
                                                  ],
                                                  borderColor:
                                                      Colors.transparent,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
