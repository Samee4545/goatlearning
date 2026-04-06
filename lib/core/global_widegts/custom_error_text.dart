import 'package:flutter/material.dart';
import 'package:goatlearning/core/global_widegts/custom_text.dart';

class CustomErrorText extends StatelessWidget {
  const CustomErrorText({super.key, this.text, this.color});
  final String? text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomText(
        text: text ?? "No data available",
        fontSize: 16,
        color: color ?? Colors.white,
      ),
    );
  }
}
