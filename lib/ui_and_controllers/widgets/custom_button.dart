import 'package:flutter/material.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    required this.Width,
    required this.onTap,
    this.isSelected = false,
    this.buttonClick = false,
    this.boarderRadius,
    this.backgroundColor,
    this.borderColor,
    this.labelWidget,
    this.paddingVertical,
    this.fontSize,
    this.textColor,
    this.label,
  }) : super(key: key);

  final double Width;
  final Function()? onTap;
  final String? label;
  final bool isSelected;
  final bool buttonClick;
  final double? boarderRadius;
  final Widget? labelWidget;
  final double? paddingVertical;
  final double? fontSize;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Width,
        padding: EdgeInsets.symmetric(
          vertical: paddingVertical ?? height * 0.011,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? colorMainTheme,
          border: Border.all(color: borderColor ?? colorMainTheme),
          borderRadius: BorderRadius.circular(boarderRadius ?? width * 0.03),
        ),
        child: Center(
          child:
              labelWidget ??
              WantText(
                text: label ?? "",
                fontSize: fontSize ?? Width * 0.041,
                fontWeight: FontWeight.w500,
                textColor: textColor ?? colorWhite,
              ),
        ),
      ),
    );
  }
}
