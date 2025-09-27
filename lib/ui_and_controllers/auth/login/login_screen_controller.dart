import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lead_management/config/routes/route_manager.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/core/utils/firebase_service.dart';

class LoginController extends GetxController {
  final FirebaseService firebaseService = FirebaseService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login(BuildContext context) async {
    if (emailController.text.isEmpty) {
      Get.context?.showAppSnackBar(
        message: "Please Enter Your Email",
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
      return;
    } else if (!emailController.text.isEmailValid) {
      Get.context?.showAppSnackBar(
        message: "Invalid email format",
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
      return;
    }
    if (passwordController.text.isEmpty) {
      Get.context?.showAppSnackBar(
        message: "Please enter the password",
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
      return;
    }

    isLoading = true;
    update();

    final userData = await FirebaseService.loginWithEmail(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    isLoading = false;
    update();

    if (userData == null) {

      Get.context?.showAppSnackBar(
        message: 'Login failed. Invalid credentials.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    print("🔐 Logged in User UID: ${userData['uid']}");
    print("🎭 Logged in User Role: ${userData['role']}");

    final role = userData['role'];
    if (role == 'admin') {
      Get.offAllNamed(AppRoutes.ownerHomeScreen);
    } else {
      Get.offAllNamed(AppRoutes.employeeHomeScreen);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
