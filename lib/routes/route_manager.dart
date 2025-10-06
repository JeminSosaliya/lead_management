import 'package:get/get.dart';
import 'package:lead_management/ui_and_controllers/auth/login/login_screen.dart';
import 'package:lead_management/ui_and_controllers/main/add_laed/add_laed_screen.dart';
import 'package:lead_management/ui_and_controllers/main/add_users/add_admin/add_admin_screen.dart';
import 'package:lead_management/ui_and_controllers/main/add_users/add_employee/add_employee_screen.dart';
import 'package:lead_management/ui_and_controllers/main/add_users/add_technician/add_technician_screen.dart';
import 'package:lead_management/ui_and_controllers/main/employee_home/employee_home_screen.dart';
import 'package:lead_management/ui_and_controllers/main/member_details_screen/member_detail_screen.dart';
import 'package:lead_management/ui_and_controllers/main/member_list_screen/member_list_screen.dart';
import 'package:lead_management/ui_and_controllers/main/owner_home/owner_home_screen.dart';
import 'package:lead_management/ui_and_controllers/main/profile/profile_screen.dart';
import 'package:lead_management/ui_and_controllers/splash/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = "/splash";
  static const String login = "/login";
  static const String ownerHomeScreen = '/ownerHomeScreen';
  static const String employeeHomeScreen = '/employeeHomeScreen';
  static const String addLeadScreen = '/addLeadScreen';
  static const String addEmployee = "/add-employee";
  static const String addAdmin = "/add-admin";
  static const String addTechnician = "/add-technician";
  static const String profile = "/profile";
  static const String members = "/members";
  static const String memberDetailScreen = "/memberDetailScreen";


  static List<GetPage> pages = [
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: ownerHomeScreen, page: () => OwnerHomeScreen()),
    GetPage(name: employeeHomeScreen, page: () => EmployeeHomeScreen()),
    GetPage(name: addLeadScreen, page: () => AddLeadScreen()),
    GetPage(name: addEmployee, page: () => const AddEmployeeScreen()),
    GetPage(name: addAdmin, page: () => const AddAdminScreen()),
    GetPage(name: addTechnician, page: () => const AddTechnicianScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: members, page: () => const MemberListScreen()),
    GetPage(name: memberDetailScreen, page: () => MemberDetailScreen()),


  ];
}
