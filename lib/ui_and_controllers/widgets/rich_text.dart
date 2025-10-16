import 'package:flutter/material.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';

class CustomRichText extends StatelessWidget {
  const CustomRichText({
    super.key,
    required this.title,
    required this.value,
    this.titleFontSize,
    this.valueFontSize,
  });

  final String title;
  final String value;
  final double? titleFontSize;
  final double? valueFontSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: TextStyle(
              fontSize: titleFontSize ?? width * 0.035,
              fontWeight: FontWeight.w500,
              color: colorBlack,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: valueFontSize ?? width * 0.031,
              fontWeight: FontWeight.w400,
              color: colorDarkGreyText,
              overflow: TextOverflow.ellipsis
            ),
          ),
        ],
      ),
    );
  }
}
