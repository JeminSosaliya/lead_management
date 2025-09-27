import 'package:get/get.dart';
import 'package:lead_management/config/routes/route_manager.dart';
import 'package:lead_management/core/utils/shred_pref.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 2), checkLoginStatus);
  }

  void checkLoginStatus() {
    bool isLoggedIn = preferences.getBool(SharedPreference.isLogIn, defValue: false);
    final role = preferences.getString(SharedPreference.role) ?? '';

    if (isLoggedIn) {
      if (role == 'admin') {
        Get.offAllNamed(AppRoutes.ownerHomeScreen);
      } else {
        Get.offAllNamed(AppRoutes.employeeHomeScreen);
      }
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
