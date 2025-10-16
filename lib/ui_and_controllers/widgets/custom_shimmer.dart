import 'package:flutter/material.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmer extends StatelessWidget {
  const CustomShimmer({super.key,required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: colorGrey.withValues(alpha: .3),
      highlightColor: colorGrey.withValues(alpha: .1),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
