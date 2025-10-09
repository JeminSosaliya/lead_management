import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/core/utils/user_status_service.dart';
import 'package:lead_management/routes/route_manager.dart';
import 'package:lead_management/ui_and_controllers/main/profile/profile_controller.dart';

class LoginController extends GetxController {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _isLoading = false.obs;
  final _obscurePassword = true.obs;
  final ProfileController _profileController = Get.put(ProfileController());

  GlobalKey<FormState> get formKey => _formKey;

  TextEditingController get emailController => _emailController;

  TextEditingController get passwordController => _passwordController;

  bool get isLoading => _isLoading.value;

  bool get obscurePassword => _obscurePassword.value;

  void togglePasswordVisibility() {
    _obscurePassword.value = !_obscurePassword.value;
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;

    try {
      print("Attempting login with email: ${_emailController.text.trim()}");

      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      print("Login successful! User: ${userCredential.user?.email}");
      print("User UID: ${userCredential.user?.uid}");

      await _profileController.fetchEmployeeData();

      if (ListConst.currentUserProfileData.isActive == false) {
        await FirebaseAuth.instance.signOut();

        Get.context!.showAppSnackBar(
          message: "Your account has been deactivated.",
          backgroundColor: colorRedCalendar,
        );
        return;
      }

      // ✅ START LISTENING TO USER STATUS CHANGES
      final userStatusService = Get.put(UserStatusService());
      await userStatusService.startListening();

      Get.context!.showAppSnackBar(
        message: "Login successful!",
        backgroundColor: colorGreen,
      );
      Get.offAllNamed(
        ListConst.currentUserProfileData.type == 'admin'
            ? AppRoutes.home
            : AppRoutes.home,
      );
      // Get.offAllNamed(
      //   ListConst.currentUserProfileData.type == 'admin'
      //       ? AppRoutes.ownerHomeScreen
      //       : AppRoutes.employeeHomeScreen,
      // );
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.code} - ${e.message}");
      String errorMessage = "Login failed. Please try again.";
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No user found with this email.";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password.";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email address.";
          break;
        case 'user-disabled':
          errorMessage = "This account has been disabled.";
          break;
        case 'too-many-requests':
          errorMessage = "Too many attempts. Please try again later.";
          break;
        case 'invalid-credential':
          errorMessage =
              "Invalid credentials. Please check your email and password.";
          break;
      }

      Get.context!.showAppSnackBar(
        message: errorMessage,

        backgroundColor: colorRedCalendar,
      );
    } catch (e) {
      print("General Error: $e");
      Get.context?.showAppSnackBar(
        message: "An error occurred. Please try again.",
        backgroundColor: colorRedCalendar,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.onClose();
  }
}
