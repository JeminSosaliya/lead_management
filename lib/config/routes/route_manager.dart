import 'package:get/get.dart';
import 'package:lead_management/ui_and_controllers/auth/login/login_screen.dart';
import 'package:lead_management/ui_and_controllers/main/add_laed/add_laed_screen.dart';
import 'package:lead_management/ui_and_controllers/main/employee/employee_home/employee_home_screen.dart';
import 'package:lead_management/ui_and_controllers/main/owner/owner_home/owner_home_screen.dart';
import 'package:lead_management/ui_and_controllers/start_up/splash/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = "/splash";
  static const String login = "/login";
  static const String ownerHomeScreen = '/ownerHomeScreen';
  static const String employeeHomeScreen = '/employeeHomeScreen';
  static const String addLeadScreen = '/addLeadScreen';

  static List<GetPage> pages = [
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: ownerHomeScreen, page: () => OwnerHomeScreen()),
    GetPage(name: employeeHomeScreen, page: () => EmployeeHomeScreen()),
    GetPage(name: addLeadScreen, page: () => AddLeadScreen()),
  ];
}
