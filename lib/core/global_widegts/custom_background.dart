import 'package:flutter/material.dart';
import '../const/app_colors.dart';

class CustomBackground extends StatelessWidget {
  final Widget topCild;
  final Widget child;
  final double? childHeight;
  const CustomBackground({
    super.key,
    required this.topCild,
    required this.child,
    this.childHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (topCild != SizedBox.shrink())
          Container(
            padding: EdgeInsets.only(left: 16, right: 16),
            height: 80, // Reduced from 20% of screen height to fixed 60px
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.appColor,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0)),
            ),
            child: topCild,
          ),

        Expanded(
          child: Container(
            // height: childHeight ?? screenHeight() * 0.7,
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
