import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/global_widegts/app_base_widget.dart';
import 'package:goatlearning/core/global_widegts/custom_submit_button.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/feature/user/profile/controller/user_profile_controller.dart';
import 'package:goatlearning/feature/user/setting/help/controller/help_support_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpScreen extends StatelessWidget {
  HelpScreen({super.key});
  final HelpSupportController controller = Get.put(HelpSupportController());
  final UserProfileController userProfileController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBaseWidget(
        needBackButton: false,
        needProfileLeadingIcon: false,
        profileAssetsPath: null,
        needProfileTitle: false,
        title: null,
        needChapterSubtitle: false,
        subtitle: null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.5),
              child: CustomText(
                text: 'help_support'.tr,
                color: AppColors.textPrimaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.only(left: 16.5, right: 15.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'facing_issues_title'.tr,
                    color: AppColors.appColor,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 16),
                  CustomText(
                    text: 'describe_problem_description'.tr,
                    color: Color(0xffA3B0C2),
                    fontWeight: FontWeight.w400,
                  ),
                  SizedBox(height: 18),
                  DottedBorder(
  options: RoundedRectDottedBorderOptions(
    dashPattern: [8, 4],
    strokeWidth: 1,
    radius: Radius.circular(4),
    color: Color(0xff5EAEB5),           // specify color inside options
    padding: EdgeInsets.all(0),         // if needed
    // borderType: (implicitly RoundedRect)
  ),
  child: Container(
    height: 166,
    color: Color(0xFFF5F9FA),
    child: TextField(
      controller: controller.helpController,
      maxLines: null,
      expands: true,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(10),
        hintText: 'type_issue_hint'.tr,
        hintStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xffA3B0C2),
        ),
      ),
    ),
  ),
)
,
                  SizedBox(height: 24),
                  CustomSubmitButton(
                    onTap: () {
                      if (controller.helpController.text.isEmpty) {
                        EasyLoading.showError('type_issue_error'.tr);
                      } else {
                        controller.helpSupport();
                      }
                    },
                    height: 50,
                    text: 'send_button'.tr,
                    fontSize: 14,
                    textColor: Colors.white,
                    fontWeight: FontWeight.w500,
                    bgColor: AppColors.textPrimaryColor,
                    radius: 12,
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
