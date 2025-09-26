import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/generated/locale_keys.g.dart';
import 'package:lead_management/ui_and_controllers/start_up/splash/splash_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());
    return Scaffold(
      body: GetBuilder<SplashController>(
        builder: (SplashController splashController) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              WantText(
                text: "Lead Management",
                fontSize: width * 0.041,
                fontWeight: FontWeight.w600,
                textColor: colorBlack,
              ),
            ],
          );
        },
      ),
    );
  }
}
