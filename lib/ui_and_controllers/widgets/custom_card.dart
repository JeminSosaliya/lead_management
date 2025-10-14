import 'package:flutter/material.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.child,
    this.horizontalPadding,
    this.verticalPadding,
    this.leftMargin,
    this.rightMargin,
    this.topMargin,
  });

  final Widget? child;
  final double? verticalPadding;
  final double? horizontalPadding;
  final double? rightMargin;
  final double? leftMargin;
  final double? topMargin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding ?? width * 0.041,
        vertical: verticalPadding ?? height * 0.015,
      ),
      margin: EdgeInsets.only(
        top: topMargin ?? height * 0.019,
        left: leftMargin ?? width * 0.041,
        right: rightMargin ?? width * 0.041,
      ),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: colorBoxShadow, blurRadius: 7, offset: Offset(4, 3)),
        ],
      ),
      child: child,
    );
  }
}
