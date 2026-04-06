import 'package:flutter/material.dart';
import 'package:goatlearning/core/const/image_path.dart';
import '../const/app_colors.dart';
import '../const/icons_path.dart';
import 'custom_text.dart';

class AppBaseWidget extends StatelessWidget {
  final Widget child;
  final bool needChapterLeadingIcon;
  final bool needProfileLeadingIcon;
  final bool needChapterTitle;
  final bool needProfileTitle;
  final bool needChapterSubtitle;
  final bool needProfileSubtitle;
  final String? profileAssetsPath;
  final String? chapterAssetsPath;
  final String? title;
  final String? subtitle;
  final bool needBackButton;
  final bool needLeadingIcon;
  final bool needNotificationIcon;
  final bool needSearchIcon;

  final Function()? needCallBackForSearchIcon;
  final Function()? needCallBackForBackButton;
  final Function()? needCallBackForprofileAssetsPath;

  const AppBaseWidget({
    required this.child,

    this.needChapterLeadingIcon = false,
    this.needProfileLeadingIcon = false,
    this.needChapterTitle = false,
    this.needProfileTitle = false,
    this.needChapterSubtitle = false,
    this.needProfileSubtitle = false,
    this.needNotificationIcon = false,
    this.needSearchIcon = false,
    this.needBackButton = false,
    this.needCallBackForBackButton,
    this.needCallBackForSearchIcon,

    super.key,
    this.needLeadingIcon = false,
    this.chapterAssetsPath,
    this.profileAssetsPath,

    this.title,
    this.subtitle,
    this.needCallBackForprofileAssetsPath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.2,
          //height: 128,
          decoration: BoxDecoration(
            color: AppColors.appColor,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0)),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 65),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 16),
                  if (needBackButton)
                    InkWell(
                      onTap: needCallBackForBackButton,
                      child: Icon(Icons.arrow_back, color: Color(0xFF8AADDE)),
                    ),

                  SizedBox(width: 15),

                  if (needChapterLeadingIcon || needProfileLeadingIcon)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (needChapterLeadingIcon)
                          Image.asset(
                            chapterAssetsPath ?? '',
                            height: 24,
                            color: Color(0xFF8AADDE),
                          ),
                        if (needProfileLeadingIcon)
                          // GestureDetector(
                          //   onTap: needCallBackForprofileAssetsPath,
                          //   child: Container(
                          //     height: 40,
                          //     width: 40,
                          //     decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(100),
                          //       image: DecorationImage(
                          //         image: NetworkImage(profileAssetsPath!),
                          //         fit: BoxFit.cover,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          GestureDetector(
                            onTap: needCallBackForprofileAssetsPath,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                image: DecorationImage(
                                  image:
                                      (profileAssetsPath != null &&
                                              profileAssetsPath!.isNotEmpty)
                                          ? NetworkImage(profileAssetsPath!)
                                              as ImageProvider
                                          : AssetImage(ImagePath.profile),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  SizedBox(width: 10),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (needChapterTitle)
                        CustomText(
                          text: title ?? '',
                          fontSize: 20,
                          color: Color(0xFF8AADDE),
                        ),

                      if (needProfileTitle)
                        CustomText(
                          text: title ?? '',
                          fontSize: 20,
                          color: Colors.white,
                        ),

                      if (needChapterSubtitle || needProfileSubtitle)
                        CustomText(
                          text: subtitle ?? '',
                          color: Color(0xFF8AADDE),
                          fontSize: 15,
                        ),
                    ],
                  ),
                  Spacer(),

                  SizedBox(width: 5),
                  if (needSearchIcon)
                    InkWell(
                      onTap: needCallBackForSearchIcon,
                      child: Container(
                        height: 26,
                        width: 26,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: Image.asset(IconsPath.search),
                      ),
                    ),
                  SizedBox(width: 30),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.appColor),
            child: Container(
              //width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
