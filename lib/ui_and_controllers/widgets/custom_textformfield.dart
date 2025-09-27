import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

class CustomTextFormField extends StatelessWidget {
  final Widget? prefixIcon;
  final String? labelText;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool? sizeBox;
  final bool readOnly;
  final Color? titleColor;
  final double? titleFontSize;
  final FontWeight? titleFontWeight;
  final int maxLines;
  final bool showBorder;
  final Color? fillColor;
  final bool extraSpace;
  final Color? hintTextColor;
  final double? customPadding;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextFormField({
    super.key,
    this.prefixIcon,
    this.labelText,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.onTap,
    this.sizeBox = true,
    this.readOnly = false,
    this.titleColor,
    this.titleFontSize,
    this.titleFontWeight,
    this.showBorder = true,
    this.fillColor,
    this.maxLines = 1,
    this.extraSpace = true,
    this.hintTextColor,
    this.customPadding,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null)
          WantText(
            text: labelText ?? "",
            fontSize: width * 0.041,
            fontWeight: FontWeight.w500,
            textColor: colorBlack,
          ),
        if (extraSpace) SizedBox(height: height * 0.016),
        SizedBox(
          width: width,
          child: TextFormField(
            maxLines: maxLines,
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            readOnly: readOnly,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
            style: GoogleFonts.roboto(
              color: colorBlack,
              fontWeight: FontWeight.w500,
            ),
            onTap: onTap,
            decoration: InputDecoration(
              isDense: true,
              filled: fillColor != null,
              fillColor: fillColor ?? colorTransparent,
              contentPadding: EdgeInsets.symmetric(
                vertical: customPadding ?? height * 0.014,
                horizontal: width * 0.030,
              ),
              prefixIcon: prefixIcon,

              hintText: hintText,
              hintStyle: GoogleFonts.roboto(
                color: hintTextColor ?? colorGreyText,
                fontSize: width * 0.035,
                fontWeight: FontWeight.w600,
                height: 1.75,
              ),
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderSide: showBorder
                    ? const BorderSide(color: colorGreyTextFieldBorder)
                    : BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: showBorder
                    ? const BorderSide(color: colorGreyTextFieldBorder)
                    : BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: showBorder
                    ? const BorderSide(color: colorGreyTextFieldBorder)
                    : BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              // constraints: const BoxConstraints(maxHeight: 48),
            ),
          ),
        ),
      ],
    );
  }
}
