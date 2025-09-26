import 'package:get/get.dart';
import 'package:lead_management/config/routes/route_manager.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration(seconds: 3), () {
      Get.toNamed(AppRoutes.login);
    });
  }
}
