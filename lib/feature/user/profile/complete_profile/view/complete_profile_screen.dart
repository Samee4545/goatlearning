import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/app_sizes.dart';
import 'package:goatlearning/core/const/icons_path.dart';
import 'package:goatlearning/core/const/image_path.dart';
import 'package:goatlearning/core/global_widegts/app_base_widget.dart';
import 'package:goatlearning/core/global_widegts/custom_submit_button.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';
import 'package:goatlearning/core/global_widegts/custom_textfield.dart';
import 'package:goatlearning/feature/user/profile/controller/user_profile_controller.dart';

class CompleteProfileScreen extends StatelessWidget {
  CompleteProfileScreen({super.key});

  final UserProfileController controller = Get.put(UserProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBaseWidget(
        needBackButton: false,
        needProfileTitle: true,
        title: "Complete Your Profile",
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: getHeight(50),
              left: 16.5,
              right: 15.5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CustomText(
                        text: "Add Profile Photo",
                        color: Color(0xff1C1C1E),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 11),
                      Obx(
                        () => Stack(
                          children: [
                            Container(
                              height: 140,
                              width: 139,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xff173156),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(100),
                                image: DecorationImage(
                                  image:
                                      controller.profileImage.value != null
                                          ? FileImage(
                                            controller.profileImage.value!,
                                          )
                                          : (controller.networkImage.value !=
                                                  null &&
                                              controller
                                                  .networkImage
                                                  .value!
                                                  .isNotEmpty)
                                          ? NetworkImage(
                                            controller.networkImage.value!,
                                          )
                                          : AssetImage(ImagePath.profile)
                                              as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () async {
                                  await controller.pickImage();
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Color(0xff5EAEB5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image.asset(IconsPath.editBg),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                CustomText(
                  text: "Username",
                  color: AppColors.appColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 5),
                CustomTextfield(
                  controller: controller.userNameController,
                  hintext: "Username",
                ),
                SizedBox(height: 15),

                CustomText(
                  text: "Email id",
                  color: AppColors.appColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 5),
                CustomTextfield(
                  controller: controller.emailController,
                  hintext: "Email id",
                ),
                SizedBox(height: 15),

                CustomText(
                  text: "Phone Number",
                  color: AppColors.appColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 5),
                CustomTextfield(
                  controller: controller.phoneNumberController,
                  hintext: "Phone Number",
                ),
                SizedBox(height: 15),

                CustomText(
                  text: "Profession",
                  color: AppColors.appColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 5),
                CustomTextfield(
                  controller: controller.proffessionController,
                  hintext: "Profession",
                ),
                SizedBox(height: 15),

                CustomText(
                  text: "Class",
                  color: AppColors.appColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 5),
                CustomTextfield(
                  controller: controller.classController,
                  hintext: "Class",
                ),

                SizedBox(height: 20),
                CustomSubmitButton(
                  onTap: () {
                    controller.updateProfile();
                  },
                  height: 50,
                  text: "Save",
                  fontSize: 14,
                  textColor: Colors.white,
                  fontWeight: FontWeight.w600,
                  bgColor: AppColors.textPrimaryColor,
                  radius: 12,
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
