import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/ui_and_controllers/main/add_laed/add_lead_controller.dart';
import 'package:lead_management/ui_and_controllers/main/member_list_screen/member_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_appbar.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_button.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_textformfield.dart';
import 'package:lead_management/ui_and_controllers/widgets/dropdown.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

class AddLeadScreen extends StatelessWidget {
  const AddLeadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final memberController = Get.put(MemberController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      memberController.loadEmployees();
      memberController.loadAdmins();
    });

    Get.put(AddLeadController());
    String currentUserRole =
        ListConst.currentUserProfileData.type ?? 'employee';
    bool isOwner = currentUserRole == 'admin';

    return GetBuilder<AddLeadController>(
      builder: (AddLeadController controller) {
        return Scaffold(
          backgroundColor: colorWhite,
          appBar: CustomAppBar(
            title: isOwner ? 'Add New Lead' : 'Add My Lead',
            showBackButton: true,
            actions: [
              GestureDetector(
                onTap: controller.isSubmitting
                    ? null
                    : () {
                        FocusScope.of(context).unfocus();
                        controller.submitForm();
                      },
                child: Padding(
                  padding: EdgeInsets.only(right: width * 0.046),
                  child: WantText(
                    text: "Save",
                    fontSize: width * 0.041,
                    textColor: colorWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          focusNode: controller.fnName,
                          onFieldSubmitted: (_) {
                            controller.fnPhone.requestFocus();
                          },
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
                            LengthLimitingTextInputFormatter(15),
                          ],
                          textInputAction: TextInputAction.next,
                          focusNode: controller.fnPhone,
                          onFieldSubmitted: (_) {
                            controller.fnAltPhone.requestFocus();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter phone number';
                            }
                            if (value.length < 10) {
                              return 'Phone number must be more than 9 digits';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: height * 0.023),

                        CustomTextFormField(
                          labelText:
                              "Client Alternative Contact Number (optional)",
                          hintText: 'Enter alternative contact number',
                          controller: controller.altPhoneController,
                          prefixIcon: Icon(Icons.phone, color: colorGrey),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(15),
                          ],
                          textInputAction: TextInputAction.next,
                          focusNode: controller.fnAltPhone,
                          onFieldSubmitted: (_) {
                            controller.fnEmail.requestFocus();
                          },
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (value.length < 10) {
                                return 'Alternative number must be more than 9 digits';
                              }
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: height * 0.023),
                        CustomTextFormField(
                          labelText: "Email (optional)",
                          hintText: 'Enter email',
                          controller: controller.emailController,
                          prefixIcon: Icon(Icons.email, color: colorGrey),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          focusNode: controller.fnEmail,
                          onFieldSubmitted: (_) {
                            controller.fnCategory.requestFocus();
                          },
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
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9@._-]'),
                            ),
                            LengthLimitingTextInputFormatter(100),
                          ],
                        ),
                        SizedBox(height: height * 0.023),

                        SearchableCSCDropdown(
                          title: 'Select Category (Optional)',
                          items: controller.technicianTypes,
                          hintText:
                              controller.selectedTechnician ??
                              'Select Technician',
                          iconData1: Icons.arrow_drop_down,
                          iconData2: Icons.arrow_drop_up,
                          onChanged: (value) {
                            controller.setSelectedTechnician(value);
                          },
                          focusNode: controller.fnCategory,
                          textInputAction: TextInputAction.next,
                          nextFocusNode: controller.fnCompany,
                        ),
                        SizedBox(height: height * 0.023),

                        CustomTextFormField(
                          labelText: "Company Name",
                          hintText: 'Company Name',
                          textCapitalization: TextCapitalization.words,
                          controller: controller.companyController,
                          prefixIcon: Icon(Icons.business, color: colorGrey),
                          textInputAction: TextInputAction.next,
                          focusNode: controller.fnCompany,
                          onFieldSubmitted: (_) {
                            controller.fnAddress.requestFocus();
                          },
                        ),
                        SizedBox(height: height * 0.023),
                        CustomTextFormField(
                          labelText: "Address (Optional)",
                          hintText: 'Please enter the address',
                          controller: controller.addressController,
                          textCapitalization: TextCapitalization.words,
                          maxLines: 2,
                          prefixIcon: Icon(Icons.home, color: colorGrey),
                          textInputAction: TextInputAction.next,
                          focusNode: controller.fnAddress,
                          onFieldSubmitted: (_) {
                            controller.fnDescription.requestFocus();
                          },
                        ),
                        SizedBox(height: height * 0.023),

                        CustomTextFormField(
                          labelText: "Description/Notes",
                          hintText: 'Enter description/Notes',
                          controller: controller.descriptionController,
                          maxLines: 3,
                          prefixIcon: Icon(Icons.note, color: colorGrey),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          focusNode: controller.fnDescription,
                          onFieldSubmitted: (_) {
                            controller.fnSource.requestFocus();        // was: fnRefName
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Please enter the note';
                            return null;
                          },
                        ),

                        SizedBox(height: height * 0.023),
                        SearchableCSCDropdown(
                          title: 'Source',
                          items: controller.sources,
                          hintText:
                              controller.selectedSource ?? 'Select Source',
                          iconData1: Icons.arrow_drop_down,
                          iconData2: Icons.arrow_drop_up,
                          onChanged: (value) {
                            controller.setSelectedSource(value);
                          },
                          showError: controller.showSourceError,
                          focusNode: controller.fnSource,
                          textInputAction: TextInputAction.next,
                          nextFocusNode: controller.fnAssignTo,
                        ),
                        if (controller.selectedSource == null &&
                            controller.showSourceError)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              'Please select a source',
                              style: TextStyle(
                                color: colorRedError,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        SizedBox(height: height * 0.023),
                        // Combine employees and admins - visible for BOTH Owner and Employee
                        GetBuilder<MemberController>(
                          builder: (memController) {
                            final assignableUsers = [
                              ...memController.employees.where(
                                (e) =>
                                    e["isActive"] == true &&
                                    e["name"].toString() != "Main Admin",
                              ),
                              ...memController.admins.where(
                                (a) =>
                                    a["isActive"] == true &&
                                    a["name"].toString() != "Main Admin",
                              ),
                            ];
                            // final assignableUsers = [
                            //   ...memController.employees.where(
                            //         (e) => e["isActive"] == true,
                            //   ),
                            //   ...memController.admins.where(
                            //         (a) => a["isActive"] == true,
                            //   ),
                            // ];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SearchableCSCDropdown(
                                  title: 'Assign To',
                                  items: assignableUsers
                                      .map((user) => user["name"].toString())
                                      .toList(),
                                  hintText:
                                      controller.selectedEmployeeName ??
                                      'Select User',
                                  iconData1: Icons.arrow_drop_down,
                                  iconData2: Icons.arrow_drop_up,
                                  onChanged: (value) {
                                    final selectedUser = assignableUsers
                                        .firstWhere(
                                          (user) =>
                                              user["name"].toString() == value,
                                          orElse: () => {
                                            "uid": "",
                                            "name": "",
                                            "type": "",
                                          },
                                        );
                                    if (selectedUser["uid"] != "") {
                                      controller.setSelectedEmployee(
                                        selectedUser["uid"],
                                        employeeName: value,
                                        userType: selectedUser["type"],
                                        email: selectedUser["email"],
                                      );
                                    }
                                  },
                                  showError: controller.showEmployeeError,
                                  focusNode: controller.fnAssignTo,
                                  textInputAction: TextInputAction.next,
                                  nextFocusNode: controller.fnRefName,
                                ),

                                if (controller.selectedEmployee == null &&
                                    controller.showEmployeeError)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 4,
                                      left: 4,
                                    ),
                                    child: Text(
                                      isOwner
                                          ? 'Please select a user to assign'
                                          : 'Please select a user (optional)',
                                      style: TextStyle(
                                        color: colorRedError,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                SizedBox(height: height * 0.023),
                              ],
                            );
                          },
                        ),

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
                              border: Border.all(
                                color: colorGreyTextFieldBorder,
                              ),
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
                          labelText: "Referral Name",
                          hintText: 'Enter referral Name',
                          controller: controller.referralNameController,
                          textCapitalization: TextCapitalization.words,
                          prefixIcon: Icon(Icons.person, color: colorGrey),
                          textInputAction: TextInputAction.next,
                          focusNode: controller.fnRefName,
                          onFieldSubmitted: (_) {
                            controller.fnRefNumber.requestFocus();
                          },
                        ),
                        SizedBox(height: height * 0.023),
                        CustomTextFormField(
                          labelText: "Referral Number",
                          hintText: 'Enter referral number',
                          controller: controller.referralNumberController,
                          prefixIcon: Icon(Icons.call, color: colorGrey),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          focusNode: controller.fnRefNumber,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).unfocus();
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(15),
                          ],
                        ),
                        SizedBox(height: height * 0.023),

                        CustomTextFormField(
                          labelText: "Initial Follow-up Date & Time",
                          hintText: 'Initial Follow-up Date & Time',
                          controller: controller.followUpController,
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Please enter initial follow-up date & time';
                            return null;
                          },
                          onTap: () async {
                            DateTime now = DateTime.now();
                            DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: now,
                              initialEntryMode:
                                  DatePickerEntryMode.calendarOnly,
                              firstDate: now,
                              lastDate: DateTime(2100),
                            );

                            if (date != null) {
                              bool isToday =
                                  date.year == now.year &&
                                  date.month == now.month &&
                                  date.day == now.day;

                              TimeOfDay initialTime = isToday
                                  ? TimeOfDay.fromDateTime(
                                      now.add(Duration(minutes: 1)),
                                    )
                                  : TimeOfDay(hour: 9, minute: 0);

                              TimeOfDay? time = await showTimePicker(
                                context: context,
                                initialTime: initialTime,
                              );

                              if (time != null) {
                                DateTime dateTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );

                                if (dateTime.isBefore(now)) {
                                  Get.context?.showAppSnackBar(
                                    message:
                                        'Please select a future date and time',
                                    backgroundColor: colorRedCalendar,
                                    textColor: colorWhite,
                                  );
                                  return;
                                }

                                final formattedDateTime = DateFormat(
                                  'dd MMM yyyy, hh:mm a',
                                ).format(dateTime);

                                controller.followUpController.text =
                                    formattedDateTime;

                                controller.nextFollowUp = dateTime;
                              }
                            }
                          },
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: colorGrey,
                          ),
                        ),

                        SizedBox(height: height * 0.023),

                        CustomButton(
                          Width: width,
                          onTap: controller.isSubmitting
                              ? null
                              : () {
                                  FocusScope.of(context).unfocus();
                                  controller.submitForm();
                                },
                          label: controller.isSubmitting
                              ? (isOwner
                                    ? 'Adding Lead...'
                                    : 'Adding My Lead...')
                              : (isOwner ? 'Add Lead' : 'Add My Lead'),
                          backgroundColor: controller.isSubmitting
                              ? colorGreyText
                              : colorMainTheme,
                          boarderRadius: 8,
                        ),
                        SizedBox(height: height * 0.045),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
