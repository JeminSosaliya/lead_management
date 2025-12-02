// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lead_management/core/constant/app_color.dart';
// import 'package:lead_management/core/constant/app_const.dart';
// import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';
//
// class CustomTextFormField extends StatelessWidget {
//   final Widget? prefixIcon;
//   final String? labelText;
//   final String hintText;
//   final TextEditingController controller;
//   final bool obscureText;
//   final TextInputType keyboardType;
//   final Widget? suffixIcon;
//   final VoidCallback? onTap;
//   final bool? sizeBox;
//   final bool readOnly;
//   final Color? titleColor;
//   final double? titleFontSize;
//   final FontWeight? titleFontWeight;
//   final int maxLines;
//   final bool showBorder;
//   final Color? fillColor;
//   final bool extraSpace;
//   final Color? hintTextColor;
//   final double? customPadding;
//   final TextCapitalization textCapitalization;
//   final List<TextInputFormatter>? inputFormatters;
//   final String? Function(String?)? validator;
//   final bool? enabled;
//   final TextInputAction? textInputAction;
//   final FocusNode? focusNode;
//   final ValueChanged<String>? onFieldSubmitted;
//   final int? minLines;
//
//   const CustomTextFormField({
//     super.key,
//     this.prefixIcon,
//     this.labelText,
//     required this.hintText,
//     required this.controller,
//     this.obscureText = false,
//     this.keyboardType = TextInputType.text,
//     this.suffixIcon,
//     this.onTap,
//     this.sizeBox = true,
//     this.readOnly = false,
//     this.titleColor,
//     this.titleFontSize,
//     this.titleFontWeight,
//     this.showBorder = true,
//     this.fillColor,
//     this.maxLines = 1,
//     this.extraSpace = true,
//     this.hintTextColor,
//     this.customPadding,
//     this.textCapitalization = TextCapitalization.none,
//     this.inputFormatters,
//     this.validator,
//     this.enabled,
//     this.textInputAction,
//     this.focusNode,
//     this.onFieldSubmitted,
//     this.minLines,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (labelText != null)
//           WantText(
//             text: labelText ?? "",
//             fontSize: width * 0.041,
//             fontWeight: FontWeight.w500,
//             textColor: colorBlack,
//           ),
//         if (extraSpace) SizedBox(height: height * 0.012),
//         SizedBox(
//           width: width,
//           child: TextFormField(
//             minLines: minLines,
//             enabled: enabled,
//             maxLines: maxLines,
//             controller: controller,
//             obscureText: obscureText,
//             keyboardType: keyboardType,
//             readOnly: readOnly,
//             textCapitalization: textCapitalization,
//             inputFormatters: inputFormatters,
//             validator: validator,
//             focusNode: focusNode,
//             textInputAction: textInputAction,
//             onFieldSubmitted: onFieldSubmitted,
//             style: GoogleFonts.roboto(
//               fontSize: width * 0.035,
//               color: colorBlack,
//               fontWeight: FontWeight.w400,
//             ),
//             onTap: onTap,
//             decoration: InputDecoration(
//               isDense: true,
//               filled: fillColor != null,
//               fillColor: fillColor ?? colorTransparent,
//               contentPadding: EdgeInsets.symmetric(
//                 vertical: customPadding ?? height * 0.014,
//                 horizontal: width * 0.030,
//               ),
//               prefixIcon: prefixIcon,
//
//               hintText: hintText,
//               hintStyle: GoogleFonts.roboto(
//                 color: hintTextColor ?? colorGreyText,
//                 fontSize: width * 0.035,
//                 fontWeight: FontWeight.w400,
//                 height: 1.75,
//               ),
//               suffixIcon: suffixIcon,
//               border: OutlineInputBorder(
//                 borderSide: showBorder
//                     ? const BorderSide(color: colorGreyTextFieldBorder)
//                     : BorderSide(color: Colors.transparent),
//                 borderRadius: BorderRadius.all(Radius.circular(8)),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: showBorder
//                     ? const BorderSide(color: colorMainTheme)
//                     : BorderSide(color: Colors.transparent),
//                 borderRadius: BorderRadius.all(Radius.circular(8)),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderSide: showBorder
//                     ? const BorderSide(color: colorGreyTextFieldBorder)
//                     : BorderSide(color: Colors.transparent),
//                 borderRadius: BorderRadius.all(Radius.circular(8)),
//               ),
//               // constraints: const BoxConstraints(maxHeight: 48),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }





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
  final String? Function(String?)? validator;
  final bool? enabled;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final int? minLines;

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
    this.validator,
    this.enabled,
    this.textInputAction,
    this.focusNode,
    this.onFieldSubmitted,
    this.minLines,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null)
          WantText(
            text: labelText!,
            fontSize: width * 0.041,
            fontWeight: FontWeight.w600,
            textColor: Colors.black87,
          ),
        if (extraSpace) SizedBox(height: height * 0.012),
        TextFormField(
          minLines: minLines,
          maxLines: maxLines ?? (obscureText ? 1 : null),
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          enabled: enabled,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          validator: validator,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          cursorColor: colorMainTheme,
          style: GoogleFonts.roboto(
            fontSize: width * 0.038,
            color: Colors.black87,           // DARK & CLEAR TEXT
            fontWeight: FontWeight.w500,
          ),
          onTap: onTap,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: fillColor ?? Colors.white.withOpacity(0.95), // White background for contrast
            contentPadding: EdgeInsets.symmetric(
              vertical: customPadding ?? height * 0.018,
              horizontal: width * 0.04,
            ),
            prefixIcon: prefixIcon,
            hintText: hintText,
            hintStyle: GoogleFonts.roboto(
              color: Colors.black45,
              fontSize: width * 0.036,
              fontWeight: FontWeight.w400,
            ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black26, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black26, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorMainTheme, width: 1.2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorRedError, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}