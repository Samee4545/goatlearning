import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:goatlearning/core/const/app_colors.dart';
import 'package:goatlearning/core/const/image_path.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmerImage extends StatelessWidget {
  final String? image;
  final double? height;
  final double? width;
  final Widget? errorImage;
  final double? borderWidth;
  final Color? color;

  const CustomShimmerImage({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.errorImage,
    this.borderWidth,
    this.color,
  });

  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final trimmed = url.trim();
    return trimmed.startsWith('http://') || trimmed.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 124,
      height: height ?? 124,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color ?? AppColors.white,
          width: borderWidth ?? 3,
        ),
      ),
      child: ClipOval(
        child:
            _isValidUrl(image)
                ? CachedNetworkImage(
                  imageUrl: image!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder:
                      (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.white,
                        ),
                      ),
                  errorWidget: (context, url, error) {
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey[200],
                      child:
                          errorImage ??
                          Image.asset(ImagePath.profile, fit: BoxFit.cover),
                    );
                  },
                )
                : Image.asset(
                  ImagePath.profile,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
      ),
    );
  }
}
