import 'package:get/get.dart';
import 'package:lead_management/ui_and_controllers/auth/login/login_screen.dart';
import 'package:lead_management/ui_and_controllers/start_up/splash/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = "/splash";
  static const String login = "/login";

  static List<GetPage> pages = [
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
  ];
}
