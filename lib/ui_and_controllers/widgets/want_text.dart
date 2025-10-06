import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WantText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? textColor;
  final TextAlign? textAlign;
  final TextOverflow? textOverflow;
  final String fontFamily;
  final int? maxLines;

  const WantText({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.textColor,
    this.textAlign,
    this.textOverflow,
    this.fontFamily = "Roboto",
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign ?? TextAlign.start,
      overflow: textOverflow ?? TextOverflow.ellipsis,
      maxLines: maxLines ?? 5,
      style: _getFontFamilyStyle(),
    );
  }

  TextStyle _getFontFamilyStyle() {
    switch (fontFamily) {
      case "Roboto":
        return GoogleFonts.roboto(
          color: textColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        );
      default:
        return GoogleFonts.poppins(
          color: textColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        );
    }
  }
}
