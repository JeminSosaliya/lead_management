import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/routes/route_manager.dart';
import 'google_calendar_controller.dart';

class AdminLoginPage extends StatelessWidget {
  final GoogleCalendarController controller =
  Get.put(GoogleCalendarController(), permanent: true);

  AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Login")),
      body: Center(
        child: GetBuilder<GoogleCalendarController>(
          builder: (_) {
            return controller.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: Text(controller.isLoggedIn
                  ? "Signed in as ${controller.adminEmail}"
                  : "Sign in as Admin"),
              onPressed: () async {
                if (!controller.isLoggedIn) {
                  await controller.loginAdmin();
                } else {
                  Get.offAllNamed(AppRoutes.home);
                  Get.snackbar(
                    "Info",
                    "Already signed in as ${controller.adminEmail}",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
