import 'package:flutter/material.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';

class InfoTextSection extends StatelessWidget {
  final String title;
  final String description;

  const InfoTextSection({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: title, color: AppColors.appColor, fontSize: 14),
        const SizedBox(height: 10),
        CustomText(
          text: description,
          color: const Color(0xffA3B0C2),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ],
    );
  }
}
