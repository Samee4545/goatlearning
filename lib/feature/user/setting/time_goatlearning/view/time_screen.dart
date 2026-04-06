import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/app_sizes.dart';
import 'package:goatlearning/core/global_widegts/app_base_widget.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/feature/user/profile/controller/user_profile_controller.dart';
import 'package:goatlearning/feature/user/setting/time_goatlearning/widgets/info_text_section.dart';

class TimeScreen extends StatelessWidget {
  TimeScreen({super.key});

  final UserProfileController userProfileController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBaseWidget(
        needBackButton: false,
        needProfileLeadingIcon: true,
        profileAssetsPath: userProfileController.profile.value?.profileImage,
        needProfileTitle: true,
        title: userProfileController.profile.value?.username,
        needChapterSubtitle: true,
        subtitle: userProfileController.profile.value?.profession,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 16.5, right: 15.5),
              child: CustomText(
                text: 'your_time_on_goatlearning'.tr,
                color: AppColors.textPrimaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: getHeight(24)),
            Padding(
              padding: EdgeInsets.only(left: 16.5, right: 15.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoTextSection(
                    title: 'see_your_time'.tr,
                    description: 'see_time_description'.tr,
                  ),
                  SizedBox(height: 28),
                  InfoTextSection(
                    title: 'time_per_day'.tr,
                    description: 'average_time_description'.tr,
                  ),
                ],
              ),
            ),
            SizedBox(height: getHeight(24)),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                width: double.infinity,
                height: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'avg_this_week'.tr,
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                            ),
                            CustomText(
                              text:
                                  "${userProfileController.percentages.value?.data.avgThisWeek}",
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.appColor,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'avg_last_week'.tr,
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                            ),
                            CustomText(
                              text:
                                  "${userProfileController.percentages.value?.data.avgLastWeek}${'mins'.tr}",
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.appColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          barGroups: [
                            _barGroup(
                              0,
                              userProfileController
                                      .percentages
                                      .value
                                      ?.data
                                      .dailyTotals[0]
                                      .time
                                      .toDouble() ??
                                  0,
                            ),
                            _barGroup(
                              1,
                              userProfileController
                                      .percentages
                                      .value
                                      ?.data
                                      .dailyTotals[1]
                                      .time
                                      .toDouble() ??
                                  0,
                            ),
                            _barGroup(
                              2,
                              userProfileController
                                      .percentages
                                      .value
                                      ?.data
                                      .dailyTotals[2]
                                      .time
                                      .toDouble() ??
                                  0,
                            ),
                            _barGroup(
                              3,
                              userProfileController
                                      .percentages
                                      .value
                                      ?.data
                                      .dailyTotals[3]
                                      .time
                                      .toDouble() ??
                                  0,
                            ),
                            _barGroup(
                              4,
                              userProfileController
                                      .percentages
                                      .value
                                      ?.data
                                      .dailyTotals[4]
                                      .time
                                      .toDouble() ??
                                  0,
                            ),
                            _barGroup(
                              5,
                              userProfileController
                                      .percentages
                                      .value
                                      ?.data
                                      .dailyTotals[5]
                                      .time
                                      .toDouble() ??
                                  0,
                            ),
                            _barGroup(
                              6,
                              userProfileController
                                      .percentages
                                      .value
                                      ?.data
                                      .dailyTotals[6]
                                      .time
                                      .toDouble() ??
                                  0,
                            ),
                          ],
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (
                                  double value,
                                  TitleMeta meta,
                                ) {
                                  // Use translated day abbreviations
                                  final days = [
                                    'sunday_abbr'.tr,
                                    'saturday_abbr'.tr,
                                    'monday_abbr'.tr,
                                    'tuesday_abbr'.tr,
                                    'wednesday_abbr'.tr,
                                    'thursday_abbr'.tr,
                                    'friday_abbr'.tr,
                                  ];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      days[value.toInt()],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          barTouchData: BarTouchData(enabled: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

BarChartGroupData _barGroup(int x, double y) {
  return BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
        toY: y,
        color: Color(0xff5EAEB5),
        width: 6,
        borderRadius: BorderRadius.circular(10),
      ),
    ],
  );
}
