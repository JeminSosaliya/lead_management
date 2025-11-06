import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_assets.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/ui_and_controllers/auth/login/login_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_button.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_textformfield.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      height = MediaQuery.of(context).size.height;
      width = MediaQuery.of(context).size.width;
    });

    LoginController controller;
    try {
      controller = Get.find<LoginController>();
    } catch (e) {
      controller = Get.put(LoginController());
    }

    return Scaffold(
      backgroundColor: colorWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: height * 0.08),
                Center(
                  child: Column(
                    children: [
                      // Container(
                      //   width: width * 0.25,
                      //   height: width * 0.25,
                      //   decoration: BoxDecoration(
                      //     color: colorMainTheme,
                      //     borderRadius: BorderRadius.circular(width * 0.125),
                      //   ),
                      //   child: Icon(
                      //     Icons.person,
                      //     size: width * 0.12,
                      //     color: colorWhite,
                      //   ),
                      // ),
                      Image.asset(AppAssets.logoTwo, height: height * 0.12),

                      SizedBox(height: height * 0.02),
                      WantText(
                        text: "Welcome To Rexino",
                        fontSize: width * 0.06,
                        fontWeight: FontWeight.bold,
                        textColor: colorBlack,
                      ),
                      SizedBox(height: height * 0.01),
                      WantText(
                        text: "Sign in to your account",
                        fontSize: width * 0.04,
                        textColor: colorGreyText,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.06),
                CustomTextFormField(
                  controller: controller.emailController,
                  labelText: "Email Address",
                  hintText: "Enter your email",
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: colorGreyText,
                    size: width * 0.05,
                  ),
                  textInputAction: TextInputAction.next,
                  focusNode: controller.fnEmail,
                  onFieldSubmitted: (_) {
                    controller.fnPassword.requestFocus();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    }
                    if (!value.isEmailValid) {
                      return "Please enter a valid email";
                    }
                    return null;
                  },
                ),
                SizedBox(height: height * 0.02),
                Obx(
                  () => CustomTextFormField(
                    controller: controller.passwordController,
                    labelText: "Password",
                    hintText: "Enter your password",
                    obscureText: controller.obscurePassword,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: colorGreyText,
                      size: width * 0.05,
                    ),
                    textInputAction: TextInputAction.done,
                    focusNode: controller.fnPassword,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: colorGreyText,
                        size: width * 0.05,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: height * 0.03),
                Obx(
                  () => CustomButton(
                    onTap: controller.isLoading ? null : (){
                      FocusScope.of(context).unfocus();
                      controller.login();
                    },
                    label: controller.isLoading ? "Signing In..." : "Sign In",
                    backgroundColor: controller.isLoading
                        ? colorGreyText
                        : colorMainTheme,
                    Width: width,
                  ),
                ),
                SizedBox(height: height * 0.03),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
