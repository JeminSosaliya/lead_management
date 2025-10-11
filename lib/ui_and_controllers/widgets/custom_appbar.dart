import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? iconColor;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final IconData? backIcon;
  final List<Widget>? actions;
  final bool centerTitle;
  final double? elevation;
  final Widget? titleWidget;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final Widget? flexibleSpace;
  final double titleFontSize;
  final FontWeight titleFontWeight;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
    this.showBackButton = true,
    this.onBackPressed,
    this.backIcon,
    this.actions,
    this.centerTitle = false,
    this.elevation,
    this.titleWidget,
    this.bottom,
    this.leading,
    this.flexibleSpace,
    this.titleFontSize = 0.05, // Percentage of width (width * 0.05)
    this.titleFontWeight = FontWeight.w600,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor = backgroundColor ?? colorMainTheme;
    final defaultTitleColor = titleColor ?? colorWhite;
    final defaultIconColor = iconColor ?? colorWhite;

    return AppBar(
      backgroundColor: defaultBackgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      flexibleSpace: flexibleSpace,
      title: titleWidget ??
          WantText(
            text: title,
            fontSize: width * titleFontSize ?? width * 0.05,
            fontWeight: titleFontWeight ?? FontWeight.w600,
            textColor: defaultTitleColor ?? colorWhite,
          ),
      leading: leading ??
          (showBackButton
              ? IconButton(
            icon: Icon(
              backIcon ?? Icons.arrow_back_ios,
              color: defaultIconColor,
              size: width * 0.05,
            ),
            onPressed: onBackPressed ?? () => Get.back(),
          )
              : null),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
  );
}
