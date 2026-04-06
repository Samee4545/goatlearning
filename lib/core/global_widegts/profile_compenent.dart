import 'package:flutter/material.dart';
import 'package:goatlearning/core/const/app_sizes.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileComponent extends StatelessWidget {
  final String iconPath;
  final String title;
  final VoidCallback? onPressed;

  const ProfileComponent({
    super.key,
    this.onPressed,
    required this.iconPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 55,
          margin: EdgeInsets.symmetric(vertical: getHeight(10)),
          padding: const EdgeInsets.only(left: 6, right: 6),
          decoration: BoxDecoration(
            color: Color(0xffF5F9FA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 24,
                    width: 24,
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Color(0xffE5FAFF),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(iconPath, height: 14, width: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Color(0xff173156),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}
