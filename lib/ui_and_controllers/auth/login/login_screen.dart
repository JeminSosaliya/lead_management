import 'package:flutter/material.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/generated/locale_keys.g.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: WantText(
          text: LocaleKeys.welcome_back.translateText,
          fontSize: width * 0.041,
          fontWeight: FontWeight.w600,
          textColor: colorBlack,
        ),
      ),
    );
  }
}
