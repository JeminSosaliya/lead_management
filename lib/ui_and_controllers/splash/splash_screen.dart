import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lead_management/core/constant/app_assets.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/core/utils/user_status_service.dart';
import 'package:lead_management/routes/route_manager.dart';
import 'package:lead_management/ui_and_controllers/main/profile/profile_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ProfileController _profileController = Get.put(ProfileController());
  final User? initialUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    getAppData();
    super.initState();
  }

  void getAppData() async {
    await _profileController.fetchEmployeeData();

    if (initialUser != null &&
        ListConst.currentUserProfileData.isActive == true) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset(AppAssets.splash, height: height * 0.18)),
    );
  }
}
