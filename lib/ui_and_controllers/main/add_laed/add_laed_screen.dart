import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/ui_and_controllers/main/add_laed/add_lead_controller.dart';
import 'package:lead_management/ui_and_controllers/main/member_list_screen/member_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_appbar.dart';

import 'package:lead_management/ui_and_controllers/widgets/custom_textformfield.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_button.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';
import 'package:lead_management/ui_and_controllers/widgets/dropdown.dart';
import 'package:intl/intl.dart';

class AddLeadScreen extends StatelessWidget {
  const AddLeadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final memberController = Get.put(MemberController());
    Get.put(AddLeadController());
    String currentUserRole =
        ListConst.currentUserProfileData.type ?? 'employee';
    bool isOwner = currentUserRole == 'admin';

    return Scaffold(
      backgroundColor: colorWhite,
      appBar: CustomAppBar(
        title: isOwner ? 'Add New Lead' : 'Add My Lead',
        showBackButton: true,
      ),
      body: GetBuilder<AddLeadController>(
        builder: (AddLeadController controller) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: colorMainTheme),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(width * 0.041),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFormField(
                      labelText: "Client Name",
                      hintText: 'Enter client Name',
                      controller: controller.nameController,
                      prefixIcon: Icon(Icons.person, color: colorGrey),

                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter the client name';
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.023),

                    CustomTextFormField(
                      labelText: "Client Contact Number",
                      hintText: 'Enter client contact number',
                      controller: controller.clientPhoneController,
                      prefixIcon: Icon(Icons.phone, color: colorGrey),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter phone number';
                        }
                        if (value.length != 10) {
                          return 'Phone number must be exactly 10 digits';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                          return 'Invalid phone number format';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.023),

                    CustomTextFormField(
                      labelText: "Email",
                      hintText: 'Enter email',
                      controller: controller.emailController,
                      prefixIcon: Icon(Icons.email, color: colorGrey),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                        }
                        return null;
                      },
                      //      validator: (value) {
                      //   if (value != null && value.isNotEmpty) {
                      //     // Basic email format check
                      //     if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[a-zA-Z]{2,}$').hasMatch(value)) {
                      //       return 'Please enter a valid email address';
                      //     }
                      //
                      //     // Optional: Only allow specific known domains
                      //     final allowedDomains = [
                      //       'gmail.com',
                      //       'yahoo.com',
                      //       'outlook.com',
                      //       'hotmail.com',
                      //       'icloud.com',
                      //     ];
                      //
                      //     final domain = value.split('@').last.toLowerCase();
                      //     if (!allowedDomains.contains(domain)) {
                      //       return 'Please enter a valid domain (e.g. gmail.com)';
                      //     }
                      //   }
                      //   return null;
                      // },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9@._-]'),
                        ),
                        LengthLimitingTextInputFormatter(100),
                      ],
                    ),
                    SizedBox(height: height * 0.023),

                    CustomTextFormField(
                      labelText: "Company Name",
                      hintText: 'Company Name',
                      controller: controller.companyController,
                      prefixIcon: Icon(Icons.business, color: colorGrey),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter the company name';
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.023),
                    CustomTextFormField(
                      labelText: "Address (Optional)",
                      hintText: 'Please enter the address',
                      controller: controller.addressController,
                      maxLines: 2,
                      prefixIcon: Icon(Icons.home, color: colorGrey),
                    ),
                    SizedBox(height: height * 0.023),

                    CustomTextFormField(
                      labelText: "Description/Notes",
                      hintText: 'Enter description/Notes',
                      controller: controller.descriptionController,
                      maxLines: 3,
                      prefixIcon: Icon(Icons.note, color: colorGrey),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter the note';
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.023),
                    CustomTextFormField(
                      labelText: "Referral Name",
                      hintText: 'Enter referral Name',
                      controller: controller.referralNameController,
                      prefixIcon: Icon(Icons.person, color: colorGrey),
                    ),
                    SizedBox(height: height * 0.023),
                    CustomTextFormField(
                      labelText: "Referral Number",
                      hintText: 'Enter referral number',
                      controller: controller.referralNumberController,
                      prefixIcon: Icon(Icons.call, color: colorGrey),
                      keyboardType: TextInputType.phone,

                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                    SizedBox(height: height * 0.023),
                    SearchableCSCDropdown(
                      title: 'Source',
                      items: controller.sources,
                      hintText: controller.selectedSource ?? 'Select Source',
                      iconData1: Icons.arrow_drop_down,
                      iconData2: Icons.arrow_drop_up,
                      onChanged: (value) {
                        controller.setSelectedSource(value);
                      },
                      showError: controller.showSourceError,
                    ),
                    if (controller.selectedSource == null &&
                        controller.showSourceError)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          'Please select a source',
                          style: TextStyle(color: colorRedError, fontSize: 12),
                        ),
                      ),
                    SizedBox(height: height * 0.023),

                    if (isOwner) ...[
                      SearchableCSCDropdown(
                        title: 'Assign To Employee',
                        items: memberController.employees
                            .where((e) => e["isActive"] == true)
                            .map((e) => e["name"].toString())
                            .toList(),
                        hintText:
                            controller.selectedEmployeeName ??
                            'Select Employee',
                        iconData1: Icons.arrow_drop_down,
                        iconData2: Icons.arrow_drop_up,
                        onChanged: (value) {
                          final employee = memberController.employees
                              .where((e) => e["isActive"] == true)
                              .firstWhere(
                                (e) => e["name"].toString() == value,
                                orElse: () => {"uid": "", "name": ""},
                              );
                          if (employee["uid"] != "") {
                            controller.setSelectedEmployee(
                              employee["uid"],
                              employeeName: value,
                            );
                          }
                        },
                        showError: controller.showEmployeeError,
                      ),

                      if (controller.selectedEmployee == null &&
                          controller.showEmployeeError)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            'Please select an employee',
                            style: TextStyle(
                              color: colorRedError,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      SizedBox(height: height * 0.023),
                    ],

                    SearchableCSCDropdown(
                      title: 'Select Technician (Optional)',
                      items: controller.technicianTypes,
                      hintText:
                          controller.selectedTechnician ?? 'Select Technician',
                      iconData1: Icons.arrow_drop_down,
                      iconData2: Icons.arrow_drop_up,
                      onChanged: (value) {
                        controller.setSelectedTechnician(value);
                      },
                    ),
                    SizedBox(height: height * 0.023),

                    WantText(
                      text: 'Location (Optional)',
                      fontSize: width * 0.041,
                      fontWeight: FontWeight.w500,
                      textColor: colorBlack,
                    ),
                    SizedBox(height: height * 0.016),
                    GestureDetector(
                      onTap: () {
                        controller.pickLocation();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: width * 0.035,
                          horizontal: height * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: colorWhite,
                          border: Border.all(color: colorGreyTextFieldBorder),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_pin, color: colorGrey),
                            SizedBox(width: width * 0.03),
                            Expanded(
                              child: Text(
                                controller.locationAddress ??
                                    'Tap to select location from map',
                                style: TextStyle(
                                  color: controller.locationAddress == null
                                      ? colorGreyText
                                      : colorBlack,
                                  fontSize: width * 0.035,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: colorGreyText,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.023),

                    CustomTextFormField(
                      labelText: "Initial Follow-up Date & Time",
                      hintText: 'Initial Follow-up Date & Time',
                      controller: controller.followUpController,
                      readOnly: true,
                      onTap: () async {
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );

                        if (date != null) {
                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (time != null) {
                            // Combine date and time
                            DateTime dateTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );

                            final formattedDateTime = DateFormat(
                              'dd MMM yyyy, hh:mm a',
                            ).format(dateTime);

                            controller.followUpController.text =
                                formattedDateTime;

                            controller.nextFollowUp = dateTime;
                          }
                        }
                      },
                      prefixIcon: Icon(Icons.calendar_today, color: colorGrey),
                    ),

                    SizedBox(height: height * 0.023),

                    CustomButton(
                      Width: width,
                      onTap: controller.isSubmitting
                          ? null
                          : () => controller.submitForm(),
                      label: isOwner ? 'Add Lead' : 'Add My Lead',
                      boarderRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
