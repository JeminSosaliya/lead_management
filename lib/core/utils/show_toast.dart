import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lead_management/core/constant/app_color.dart';

void showToast(String message, Color backgroundColor) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: backgroundColor,
    textColor: colorWhite,
    // Assuming this is defined in `theme_manager.dart`
    fontSize: 16.0,
  );
}
