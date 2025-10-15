import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_assets.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/model/lead_add_model.dart';
import 'package:lead_management/ui_and_controllers/main/lead_details_screen/lead_details_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_appbar.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_button.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_card.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_textformfield.dart';
import 'package:lead_management/ui_and_controllers/widgets/dropdown.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadDetailsScreen extends StatelessWidget {
  const LeadDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leadId = Get.arguments[0];
    final initialData = Get.arguments[1];
    final controller = Get.put(LeadDetailsController(leadId: leadId));

    if (initialData != null) {
      controller.initializeData(initialData!);
      controller.initializeData(initialData!);
    }

    return Scaffold(
      backgroundColor: colorWhite,
      appBar: CustomAppBar(
        title: "Lead Details",
        actions: [
          GetBuilder<LeadDetailsController>(
            builder: (controller) {
              if (controller.lead == null ||
                  controller.lead!.stage == 'completed' ||
                  controller.lead!.stage == 'cancelled' ||
                  controller.isEditMode) {
                return SizedBox.shrink();
              }
              return IconButton(
                icon: Icon(Icons.edit, color: colorWhite),
                onPressed: controller.toggleEditMode,
              );
            },
          ),
        ],
      ),
      body: GetBuilder<LeadDetailsController>(
        builder: (controller) {
          if (controller.isLoading || controller.lead == null) {
            return const Center(
              child: CircularProgressIndicator(color: colorMainTheme),
            );
          }

          final lead = controller.lead!;
          bool isCompleted = lead.stage == 'completed';
          bool isCancelled = lead.stage == 'cancelled';
          bool isEditable = !isCompleted && !isCancelled;

          String formatTimestamp(dynamic timestamp) {
            if (timestamp == null) return 'N/A';
            try {
              if (timestamp is Timestamp) {
                DateTime date = timestamp.toDate();
                return DateFormat('dd MMM yyyy, hh:mm a').format(date);
              } else if (timestamp is String) {
                DateTime? date = DateTime.tryParse(timestamp);
                if (date != null) {
                  return DateFormat('dd MMM yyyy, hh:mm a').format(date);
                }
              }
              return timestamp.toString();
            } catch (e) {
              return timestamp.toString();
            }
          }

          bool hasValue(String? value) {
            return value != null &&
                value.trim().isNotEmpty &&
                value.toLowerCase() != 'null';
          }

          if (controller.isEditMode) {
            // Edit mode form
            return SingleChildScrollView(
              padding: EdgeInsets.all(width * 0.041),
              child: Form(
                key: controller.editFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFormField(
                      labelText: "Client Name",
                      hintText: 'Enter client Name*',
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
                      labelText: "Phone Number",
                      hintText: 'Phone Number*',
                      controller: controller.phoneController,
                      prefixIcon: Icon(Icons.phone, color: colorGrey),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Enter phone number';
                        if (value.length != 10)
                          return 'Phone number must be exactly 10 digits';
                        if (!RegExp(r'^\d{10}$').hasMatch(value))
                          return 'Invalid phone number format';
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
                    if (controller.showSourceError)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          'Please select a source',
                          style: TextStyle(color: colorRedError, fontSize: 12),
                        ),
                      ),
                    SizedBox(height: height * 0.023),
                    SearchableCSCDropdown(
                      title: 'Reassign To',
                      items: controller.employees
                          .map((e) => e['name'] as String)
                          .toList(),
                      hintText: controller.selectedEmployeeName ?? 'Select User',
                      iconData1: Icons.arrow_drop_down,
                      iconData2: Icons.arrow_drop_up,
                      onChanged: (value) {
                        controller.setSelectedEmployee(value);
                      },
                      showError: controller.showEmployeeError,
                    ),
                    if (controller.showEmployeeError)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          'Please select a user',
                          style: TextStyle(color: colorRedError, fontSize: 12),
                        ),
                      ),
                    SizedBox(height: height * 0.023),
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
                      onTap: controller.pickLocation,
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
                    // SizedBox(height: height * 0.023),
                    // CustomTextFormField(
                    //   labelText: "Initial Follow-up Date & Time",
                    //   hintText: 'Initial Follow-up Date & Time',
                    //   controller: controller.initialFollowUpController,
                    //   readOnly: true,
                    //   onTap: controller.pickInitialFollowUp,
                    //   prefixIcon: Icon(Icons.calendar_today, color: colorGrey),
                    // ),
                    SizedBox(height: height * 0.023),
                    CustomButton(
                      Width: width,
                      onTap: controller.isUpdating
                          ? null
                          : controller.updateLeadDetails,
                      label: 'Save Changes',
                      boarderRadius: 8,
                    ),
                    SizedBox(height: height * 0.023),
                    CustomButton(
                      Width: width,
                      onTap: controller.toggleEditMode,
                      label: 'Cancel Edit',
                      backgroundColor: colorGrey,
                      textColor: colorWhite,
                      boarderRadius: 8,
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            // padding: EdgeInsets.all(width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: colorMainTheme,
                        child: WantText(
                          text: hasValue(lead.clientName)
                              ? lead.clientName[0].toUpperCase()
                              : '?',
                          fontSize: width * 0.051,
                          fontWeight: FontWeight.w600,
                          textColor: colorWhite,
                        ),
                      ),
                      SizedBox(width: width * 0.035),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WantText(
                              text: lead.clientName,
                              fontSize: width * 0.041,
                              fontWeight: FontWeight.w600,
                              textColor: colorBlack,
                            ),
                            WantText(
                              text: lead.clientEmail ?? '',
                              fontSize: width * 0.035,
                              fontWeight: FontWeight.w400,
                              textColor: colorDarkGreyText,
                            ),
                            if (hasValue(lead.clientEmail))
                              SizedBox(height: height * 0.008),

                            Row(
                              children: [
                                _badge(lead.stage, colorMainTheme),
                                SizedBox(width: width * 0.02),
                                _badge(lead.callStatus, Colors.orange),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.01),
                if (hasValue(lead.callNote) ||
                    lead.initialFollowUp != null ||
                    lead.nextFollowUp != null) ...[
                  // SizedBox(height: height * 0.01),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(
                      top: height * 0.016,
                      left: width * 0.041,
                      right: width * 0.041,
                    ),
                    padding: EdgeInsets.all(width * 0.03),
                    decoration: BoxDecoration(
                      color: colorWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorMainTheme.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorBoxShadow,
                          blurRadius: 6,
                          offset: Offset(4, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (lead.initialFollowUp != null) ...[
                          WantText(
                            text: "Initial Follow-up",
                            fontSize: width * 0.035,
                            fontWeight: FontWeight.w500,
                            textColor: colorBlack,
                          ),
                          WantText(
                            text: formatTimestamp(lead.initialFollowUp),
                            fontSize: width * 0.031,
                            fontWeight: FontWeight.w500,
                            textColor: colorGreenOne
                          ),
                        ],

                        if (lead.nextFollowUp != null) ...[
                          SizedBox(height: height * 0.01),
                          WantText(
                            text: "Next Follow-up",
                            fontSize: width * 0.035,
                            fontWeight: FontWeight.w500,
                            textColor: colorBlack,
                          ),
                          WantText(
                            text: formatTimestamp(lead.nextFollowUp),
                            fontSize: width * 0.031,
                            fontWeight: FontWeight.w500,
                            textColor: colorGreenOne,
                          ),
                        ],

                        if (hasValue(lead.callNote)) ...[
                          SizedBox(height: height * 0.01),
                          WantText(
                            text: "Reason",
                            fontSize: width * 0.041,
                            fontWeight: FontWeight.w500,
                            textColor: colorBlack,
                          ),
                          WantText(
                            text: lead.callNote!,
                            fontSize: width * 0.035,
                            fontWeight: FontWeight.w500,
                            textColor: colorRed,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WantText(
                        text: "Basic Information",
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.w500,
                        textColor: colorBlack,
                      ),
                      SizedBox(height: height * 0.01),

                      if (hasValue(lead.companyName))
                        _infoCard(title: "Company", value: lead.companyName!),

                      _infoCard(title: "Source", value: lead.source ?? 'N/A'),
                      if (hasValue(lead.description))
                        _infoCard(
                          title: "Description/Notes",
                          value: lead.description!,
                        ),

                      if (hasValue(lead.address))
                        _infoCard(title: "Address", value: lead.address!),

                      _infoCard(
                        title: "Client Contact Number",
                        value: lead.clientPhone,
                        trailing: GestureDetector(
                          onTap: () {
                            log('tap on whatsapp');
                            controller.openWhatsApp(lead.clientPhone);
                          },
                          child: Image.asset(
                            AppAssets.whatsapp,
                            height: 15,
                            width: 15,
                          ),
                        ),
                      ),
                      if (lead.latitude != null && lead.longitude != null)
                        GestureDetector(
                          onTap: () => controller.openDirectionsToLead(
                            lead.latitude!,
                            lead.longitude!,
                          ),
                          child: Container(
                            margin: EdgeInsets.only(top: height * 0.016),
                            padding: EdgeInsets.all(width * 0.03),
                            decoration: BoxDecoration(
                              color: colorWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorMainTheme.withOpacity(0.3),
                                width: .5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(width * 0.015),
                                      decoration: BoxDecoration(
                                        color: colorMainTheme.withValues(
                                          alpha: .1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.location_on,
                                        color: colorMainTheme,
                                        size: width * 0.05,
                                      ),
                                    ),
                                    SizedBox(width: width * 0.03),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          WantText(
                                            text: 'Location',
                                            fontSize: width * 0.035,
                                            fontWeight: FontWeight.w600,
                                            textColor: colorBlack,
                                          ),
                                          SizedBox(height: 4),
                                          WantText(
                                            text:
                                                'Lat: ${lead.latitude!.toStringAsFixed(6)}, Lng: ${lead.longitude!.toStringAsFixed(6)}',
                                            fontSize: width * 0.03,
                                            fontWeight: FontWeight.w400,
                                            textColor: colorDarkGreyText,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.directions,
                                      color: colorMainTheme,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WantText(
                        text: 'Assignment Information',
                        fontSize: width * 0.041,
                        fontWeight: FontWeight.w600,
                        textColor: colorBlack,
                      ),
                      SizedBox(height: height * 0.01),
                      _infoCard(title: "Added By", value: lead.addedByName),

                      _infoCard(
                        title: "Assigned To",
                        value: lead.assignedToName,
                      ),

                      if (hasValue(lead.technician))
                        _infoCard(title: "Technician", value: lead.technician!),
                    ],
                  ),
                ),
                if (hasValue(lead.referralName) ||
                    hasValue(lead.referralNumber))
                  CustomCard(
                    child: Column(
                      children: [
                        if (hasValue(lead.referralName) ||
                            hasValue(lead.referralNumber))
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WantText(
                                text: 'Referral Information',
                                fontSize: width * 0.041,
                                fontWeight: FontWeight.w600,
                                textColor: colorBlack,
                              ),
                              SizedBox(height: height * 0.01),
                              if (hasValue(lead.referralName))
                                _infoCard(
                                  title: "Referral Name",
                                  value: lead.referralName!,
                                ),

                              if (hasValue(lead.referralNumber))
                                _infoCard(
                                  title: "Referral Number",
                                  value: lead.referralNumber!,
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),

                SizedBox(height: height * 0.01),

                if (isEditable)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.041,vertical: height * 0.01),
                    child: CustomButton(
                      Width: width,
                      onTap: controller.callLead,
                      label: '📞 Call Lead',
                    ),
                  ),

                if (controller.showUpdateForm && isEditable) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.041),
                    child: Column(
                      children: [
                        SizedBox(height: height * 0.02),
                        WantText(
                          text: 'Update Lead',
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w600,
                          textColor: colorBlack,
                        ),
                        SizedBox(height: height * 0.015),
                        Form(
                          key: controller.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SearchableCSCDropdown(
                                title: 'Select response',
                                items: controller.responseOptions,
                                hintText: controller.selectedResponse.isNotEmpty
                                    ? controller.selectedResponse
                                    : 'Select Response',
                                iconData1: Icons.arrow_drop_down,
                                iconData2: Icons.arrow_drop_up,
                                onChanged: (value) {
                                  controller.setSelectedResponse(value);
                                },
                                showError: controller.showResponseError,
                              ),

                              if (controller.showResponseError)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 4,
                                  ),
                                  child: Text(
                                    'Please select a response',
                                    style: TextStyle(
                                      color: colorRedError,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              SizedBox(height: height * 0.02),

                              SearchableCSCDropdown(
                                title: 'Select stage',
                                items: controller.stageOptions,
                                hintText:
                                    controller.selectedStageDisplay.isNotEmpty
                                    ? controller.selectedStageDisplay
                                    : 'Select Stage*',
                                iconData1: Icons.arrow_drop_down,
                                iconData2: Icons.arrow_drop_up,
                                onChanged: (value) {
                                  controller.setSelectedStage(value);
                                },
                                showError: controller.showStageError,
                              ),
                              if (controller.showStageError)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 4,
                                  ),
                                  child: Text(
                                    'Please select a stage',
                                    style: TextStyle(
                                      color: colorRedError,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              SizedBox(height: height * 0.02),
                              CustomTextFormField(
                                labelText: "Call Note",
                                hintText: 'Enter call notes...',
                                controller: controller.noteController,
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Please enter call note';
                                  return null;
                                },
                              ),
                              SizedBox(height: height * 0.02),
                              CustomTextFormField(
                                labelText: "Next Follow-up Date & Time",
                                hintText: 'Select follow-up date and time',
                                controller: controller.followUpController,
                                readOnly: true,
                                onTap: controller.pickFollowUp,
                              ),
                              SizedBox(height: height * 0.03),
                              CustomButton(
                                Width: width,
                                onTap: controller.isUpdating
                                    ? null
                                    : () {
                                        controller.updateLead();
                                      },
                                label: 'Update Lead',
                              ),
                              SizedBox(height: height * 0.03),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (!isEditable)
                  Container(
                    margin: EdgeInsets.only(
                      top: height * 0.03,
                      right: width * 0.041,
                      left: width * 0.041,
                    ),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: colorRedCalendar),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: WantText(
                            text:
                                'This lead is ${lead.stage} and cannot be updated.',
                            fontSize: width * 0.038,
                            fontWeight: FontWeight.w500,
                            textOverflow: TextOverflow.visible,
                            textColor: colorRedCalendar,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: WantText(
        text: text,
        fontSize: width * 0.031,
        fontWeight: FontWeight.w500,
        textColor: colorWhite,
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    Widget? trailing,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.002),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$title: ",
                    style: TextStyle(
                      color: colorBlack,
                      fontWeight: FontWeight.w500,
                      fontSize: width * 0.035,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: colorDarkGreyText,
                      fontWeight: FontWeight.w400,
                      fontSize: width * 0.031,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
