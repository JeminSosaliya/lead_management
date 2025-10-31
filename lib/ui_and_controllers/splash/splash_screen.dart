import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_assets.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/core/utils/push_notification_utils.dart';
import 'package:lead_management/core/utils/user_status_service.dart';
import 'package:lead_management/routes/route_manager.dart';
import 'package:lead_management/ui_and_controllers/main/profile/profile_controller.dart';

import '../../core/constant/app_const.dart';
import '../auth/goggle_login/google_calendar_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ProfileController _profileController = Get.put(ProfileController());
  final GoogleCalendarController controller = Get.put(
    GoogleCalendarController(),
    permanent: true,
  );

  final User? initialUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _handleSplashFlow();
  }

  /// Step 1 → Splash delay + check login state
  Future<void> _handleSplashFlow() async {
    await Future.delayed(const Duration(seconds: 2));
    await _checkLoginFlow();
  }

  /// Step 2 → Check login flow
  Future<void> _checkLoginFlow() async {
    if (initialUser == null) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      try {
        bool autoLoginSuccess = await controller.autoLogin();
        log("Auto-login success: $autoLoginSuccess");
        if (!controller.isLoggedIn || !autoLoginSuccess) {
          log("User not logged in → Going to Login");
          Get.offAllNamed(AppRoutes.goggleLogin);
          return;
        }
        log("Already signed in as Admin: ${controller.adminEmail}");
        await _initializeAppData();
        // If app was launched from a notification (killed state), honor deep link
        if (NotificationUtils.hasPendingDeepLink()) {
          final processed = NotificationUtils.processPendingDeepLinkIfAny();
          if (processed) return; // deep link handled, don't override
        }
        Get.offAllNamed(AppRoutes.home);
        Get.context?.showAppSnackBar(
          message: "Welcome back, ${controller.adminEmail}",
          backgroundColor: colorGreen,
          textColor: colorWhite,
        );
      } catch (e, st) {
        log("Error in splash flow: $e\n$st");
        Get.offAllNamed(AppRoutes.login);
      }
    }
  }

  Future<void> _initializeAppData() async {
    await _profileController.fetchEmployeeData();

    if (initialUser != null) {
      await _printFCMToken();
      final userStatusService = Get.put(UserStatusService());
      await userStatusService.startListening();
    }
  }

  Future<void> _printFCMToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        log("=====================");
        log("FCM TOKEN: $fcmToken");
        log("User: ${initialUser?.email}");
        log("=====================");
      } else {
        log("⚠️ FCM Token is null");
      }
    } catch (e) {
      log("Error fetching FCM Token: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      body: Center(child: Image.asset(AppAssets.splash, height: height * 0.2)),
    );
  }
}

