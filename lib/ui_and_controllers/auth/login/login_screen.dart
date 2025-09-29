import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/ui_and_controllers/auth/login/login_screen_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_textformfield.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginController());

    return Scaffold(
      body: GetBuilder<LoginController>(
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextFormField(
                    hintText: 'Email',
                    controller: controller.emailController,
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.grey,
                      size: width * 0.041,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z0-9@._\-+]'),
                      ),
                    ],
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    hintText: 'Password',
                    controller: controller.passwordController,
                    // obscureText: true,
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.grey,
                      size: width * 0.041,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: controller.isLoading
                        ? null
                        : () => controller.login(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorMainTheme,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: controller.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const WantText(
                      text: 'Login',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
