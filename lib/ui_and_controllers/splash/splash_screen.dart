import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lead_management/core/constant/app_assets.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/core/utils/user_status_service.dart';
import 'package:lead_management/routes/route_manager.dart';
import 'package:lead_management/ui_and_controllers/main/profile/profile_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

import '../../core/constant/app_color.dart';
import '../auth/goggle_login/google_calendar_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ProfileController _profileController = Get.put(ProfileController());
  final GoogleCalendarController controller = Get.put(GoogleCalendarController(), permanent: true);

  final User? initialUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    checkLogin()  ;
    getAppData();
    super.initState();
  }

  Future<void> checkLogin() async {
    bool  autoLoginSuccess = await controller.autoLogin();
    log("Auto-login success: $autoLoginSuccess");
    if (!controller.isLoggedIn || !autoLoginSuccess) {
      Get.offAllNamed(AppRoutes.adminLogin);
    } else {
      Get.offAllNamed(AppRoutes.home);
      Get.context?.showAppSnackBar(
        message: "Already signed in as ${controller.adminEmail}",
        backgroundColor: colorGreen,
        textColor: colorWhite,
      );
    }

  }
  void getAppData() async {
    await _profileController.fetchEmployeeData();

    if (initialUser != null &&
        ListConst.currentUserProfileData.isActive == true) {
      await _printFCMTokenForAutoLogin();

      final userStatusService = Get.put(UserStatusService());
      await userStatusService.startListening();
    }

    Timer(const Duration(seconds: 4), () {
      log("intro1");
      log("initialUser :: $initialUser");
      Get.offAllNamed(
        initialUser != null ? AppRoutes.home : AppRoutes.login,
      );
    });
  }

  Future<void> _printFCMTokenForAutoLogin() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        log("========================================");
        log("FCM TOKEN (Auto-Login):");
        log(fcmToken);
        log("User: ${initialUser?.email}");
        log("========================================");
        print("AUTO-LOGIN FCM TOKEN: $fcmToken");
      } else {
        log("FCM Token is null during auto-login");
      }
    } catch (e) {
      log("Error getting FCM token during auto-login: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset(AppAssets.splash, height: height * 0.18)),
    );
  }
}
