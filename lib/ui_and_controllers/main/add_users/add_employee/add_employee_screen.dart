import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/ui_and_controllers/main/add_users/add_employee/add_employee_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_button.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_textformfield.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

import '../../../widgets/custom_appbar.dart';

class AddEmployeeScreen extends StatelessWidget {
  const AddEmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddEmployeeController());

    return Scaffold(
      backgroundColor: colorWhite,
      appBar: CustomAppBar(title: 'Add Employee', showBackButton: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(width * 0.041),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: height * 0.02),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: width * 0.2,
                      height: width * 0.2,
                      decoration: BoxDecoration(
                        color: colorMainTheme,
                        borderRadius: BorderRadius.circular(width * 0.1),
                      ),
                      child: Icon(
                        Icons.person_add,
                        size: width * 0.1,
                        color: colorWhite,
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    WantText(
                      text: "Add New Employee",
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.bold,
                      textColor: colorBlack,
                    ),
                    SizedBox(height: height * 0.005),
                    WantText(
                      text:
                          "Fill in the details to create a new employee account",
                      fontSize: width * 0.035,
                      textColor: colorGreyText,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.03),

              CustomTextFormField(
                controller: controller.nameController,
                labelText: "Full Name",
                hintText: "Enter employee full name",
                keyboardType: TextInputType.name,
                prefixIcon: Icon(
                  Icons.person,
                  color: colorGreyText,
                  size: width * 0.05,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the employee's name";
                  }
                  if (value.length < 2) {
                    return "Name must be at least 2 characters";
                  }
                  return null;
                },
              ),

              SizedBox(height: height * 0.02),

              CustomTextFormField(
                controller: controller.numberController,
                labelText: "Phone Number",
                hintText: "Enter employee phone number",
                keyboardType: TextInputType.phone,
                prefixIcon: Icon(
                  Icons.phone,
                  color: colorGreyText,
                  size: width * 0.05,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the phone number';
                  }
                  if (value.length < 10) {
                    return 'Phone number must be exactly 10 digits';
                  }

                  return null;
                },
              ),

              SizedBox(height: height * 0.02),

              CustomTextFormField(
                controller: controller.emailController,
                labelText: "Email Address",
                hintText: "Enter employee email address",
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(
                  Icons.email,
                  color: colorGreyText,
                  size: width * 0.05,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
                  LengthLimitingTextInputFormatter(100),
                ],
              ),

              SizedBox(height: height * 0.02),

              Obx(
                () => CustomTextFormField(
                  controller: controller.passwordController,
                  labelText: "Password",
                  hintText: "Enter employee password",
                  obscureText: controller.obscurePassword,
                  prefixIcon: Icon(
                    Icons.lock,
                    color: colorGreyText,
                    size: width * 0.05,
                  ),
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
                      return "Please enter the password";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: height * 0.02),

              Obx(
                () => CustomTextFormField(
                  controller: controller.confirmPasswordController,
                  labelText: "Confirm Password",
                  hintText: "Confirm employee password",
                  obscureText: controller.obscureConfirmPassword,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: colorGreyText,
                    size: width * 0.05,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: colorGreyText,
                      size: width * 0.05,
                    ),
                    onPressed: controller.toggleConfirmPasswordVisibility,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please confirm the password";
                    }
                    if (value != controller.passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: height * 0.02),

              CustomTextFormField(
                controller: controller.addressController,
                labelText: "Address",
                hintText: "Enter employee address",
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                prefixIcon: Icon(
                  Icons.location_on,
                  color: colorGreyText,
                  size: width * 0.05,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the address";
                  }
                  return null;
                },
              ),

              SizedBox(height: height * 0.02),

              CustomTextFormField(
                controller: controller.designationController,
                labelText: "Designation",
                hintText: "Enter employee designation/position",
                keyboardType: TextInputType.text,
                prefixIcon: Icon(
                  Icons.work,
                  color: colorGreyText,
                  size: width * 0.05,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the designation";
                  }
                  if (value.length < 2) {
                    return "Please enter a valid designation";
                  }
                  return null;
                },
              ),

              SizedBox(height: height * 0.02),

              CustomTextFormField(
                controller: controller.referenceController,
                labelText: "Reference Person",
                hintText: "Enter reference person name",
                keyboardType: TextInputType.text,
                prefixIcon: Icon(
                  Icons.person_pin,
                  color: colorGreyText,
                  size: width * 0.05,
                ),
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: height * 0.04),
              Obx(
                () => CustomButton(
                  Width: width,
                  onTap: controller.isLoading ? null : (){
                    FocusScope.of(context).unfocus();
                    controller.addUser();
                  },
                  label: controller.isLoading
                      ? "Adding Employee..."
                      : "Add Employee",
                  backgroundColor: controller.isLoading
                      ? colorGreyText
                      : colorMainTheme,
                ),
              ),

              SizedBox(height: height * 0.02),

              // Cancel Button
              CustomButton(
                Width: width,
                onTap: () => Get.back(),
                label: "Cancel",
                backgroundColor: colorTransparent,
                borderColor: colorMainTheme,
                textColor: colorMainTheme,
              ),
              SizedBox(height: height * 0.048),
            ],
          ),
        ),
      ),
    );
  }
}
