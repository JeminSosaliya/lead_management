import 'package:get/get.dart';
import 'package:lead_management/ui_and_controllers/auth/login/login_screen.dart';
import 'package:lead_management/ui_and_controllers/main/add_laed/add_laed_screen.dart';
import 'package:lead_management/ui_and_controllers/main/add_users/add_admin/add_admin_screen.dart';
import 'package:lead_management/ui_and_controllers/main/add_users/add_employee/add_employee_screen.dart';
import 'package:lead_management/ui_and_controllers/main/add_users/add_technician/add_technician_screen.dart';
import 'package:lead_management/ui_and_controllers/main/analytics/analytics_screen.dart';
import 'package:lead_management/ui_and_controllers/main/analytics/lead_list_screen.dart';
import 'package:lead_management/ui_and_controllers/main/home/home_screen.dart';
import 'package:lead_management/ui_and_controllers/main/lead_details_screen/lead_details_screen.dart';
import 'package:lead_management/ui_and_controllers/main/member_details_screen/member_detail_screen.dart';
import 'package:lead_management/ui_and_controllers/main/member_list_screen/member_list_screen.dart';
import 'package:lead_management/ui_and_controllers/main/profile/profile_screen.dart';
import 'package:lead_management/ui_and_controllers/splash/splash_screen.dart';
import 'package:lead_management/ui_and_controllers/main/notifications/notification_screen.dart';

import '../ui_and_controllers/auth/goggle_login/admin_login_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = "/splash";
  static const String login = "/login";
  static const String home = "/home";
  static const String addLeadScreen = '/addLeadScreen';
  static const String addEmployee = "/add-employee";
  static const String addAdmin = "/add-admin";
  static const String addTechnician = "/add-technician";
  static const String profile = "/profile";
  static const String members = "/members";
  static const String memberDetailScreen = "/memberDetailScreen";
  static const String analytics = "/analytics";
  static const String analyticsListScreen = "/analyticsListScreen";
  static const String leadDetailsScreen = "/leadDetailsScreen";
  static const String goggleLogin = "/adminLogin";
  static const String notifications = "/notifications";


  static List<GetPage> pages = [
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: home, page: () => HomeScreen()),
    GetPage(name: goggleLogin, page: () => AdminLoginPage()),

    // GetPage(name: ownerHomeScreen, page: () => OwnerHomeScreen()),
    // GetPage(name: employeeHomeScreen, page: () => EmployeeHomeScreen()),
    GetPage(name: addLeadScreen, page: () => AddLeadScreen()),
    GetPage(name: addEmployee, page: () => const AddEmployeeScreen()),
    GetPage(name: addAdmin, page: () => const AddAdminScreen()),
    GetPage(name: addTechnician, page: () => const AddTechnicianScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: members, page: () => const MemberListScreen()),
    GetPage(name: memberDetailScreen, page: () => MemberDetailScreen()),
    GetPage(name: analytics, page: () => const AnalyticsScreen()),
    GetPage(name: analyticsListScreen, page: () => AnalyticsListScreen()),
    GetPage(name: leadDetailsScreen, page: () => LeadDetailsScreen()),
    GetPage(name: notifications, page: () => const NotificationScreen()),
  ];
}