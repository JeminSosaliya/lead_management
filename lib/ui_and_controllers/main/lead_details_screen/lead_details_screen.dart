import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_assets.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/ui_and_controllers/main/lead_details_screen/lead_details_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_button.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_textformfield.dart';
import 'package:lead_management/ui_and_controllers/widgets/dropdown.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

class LeadDetailsScreen extends StatelessWidget {
  final String leadId;
  final Map<String, dynamic> initialData;

  const LeadDetailsScreen({
    super.key,
    required this.leadId,
    required this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(LeadDetailsController(leadId: leadId));

    return Scaffold(
      backgroundColor: colorWhite,
      appBar: AppBar(
        title: WantText(
          text: 'Lead Details',
          fontSize: width * 0.061,
          fontWeight: FontWeight.w600,
          textColor: colorWhite,
        ),
        backgroundColor: colorMainTheme,
        iconTheme: IconThemeData(color: colorWhite),
      ),
      body: GetBuilder<LeadDetailsController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: colorMainTheme),
            );
          }

          bool isCompleted = controller.leadData['stage'] == 'completed';

          return SingleChildScrollView(
            padding: EdgeInsets.all(width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(width * 0.041),
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colorBoxShadow,
                        blurRadius: 6,
                        offset: Offset(4, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: colorMainTheme,
                        child: WantText(
                          text:
                              controller.leadData['clientName'] != null &&
                                  controller.leadData['clientName'].isNotEmpty
                              ? controller.leadData['clientName'][0]
                                    .toUpperCase()
                              : '',
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
                              text: controller.leadData['clientName'] ?? 'N/A',
                              fontSize: width * 0.046,
                              fontWeight: FontWeight.w600,
                              textColor: colorBlack,
                            ),
                            SizedBox(height: height * 0.008),
                            Row(
                              children: [
                                _badge(
                                  controller.leadData['stage'] ?? 'N/A',
                                  colorMainTheme,
                                ),
                                SizedBox(width: width * 0.02),
                                _badge(
                                  controller.leadData['callStatus'] ?? 'N/A',
                                  Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.02),
                _infoCard(
                  title: "Phone",
                  value: controller.leadData['clientPhone'] ?? 'N/A',
                  trailing: controller.leadData['clientPhone'] != null
                      ? GestureDetector(
                          onTap: () {
                            log('tap on whatsapp');
                            controller.openWhatsApp(
                              controller.leadData['clientPhone'],
                            );
                          },
                          child: Image.asset(
                            AppAssets.whatsapp,
                            height: 15,
                            width: 15,
                          ),
                        )
                      : null,
                ),
                if (controller.leadData['clientEmail'] != null)
                  _infoCard(
                    title: "Email",
                    value: controller.leadData['clientEmail'],
                  ),
                if (controller.leadData['companyName'] != null)
                  _infoCard(
                    title: "Company",
                    value: controller.leadData['companyName'],
                  ),
                _infoCard(
                  title: "Source",
                  value: controller.leadData['source'] ?? 'N/A',
                ),
                if (controller.leadData['description'] != null)
                  _infoCard(
                    title: "Description",
                    value: controller.leadData['description'],
                  ),
                if (controller.leadData['nextFollowUp'] != null)
                  _infoCard(
                    title: "Next Follow-up",
                    value:
                        (controller.leadData['nextFollowUp'] as Timestamp?)
                            ?.toDate()
                            .toString() ??
                        'N/A',
                  ),
                SizedBox(height: height * 0.03),
                if (!isCompleted)
                  CustomButton(
                    Width: width,
                    onTap: controller.callLead,
                    label: '📞 Call Lead',
                  ),
                if (controller.showUpdateForm && !isCompleted) ...[
                  SizedBox(height: height * 0.03),
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
                              : 'Select Response*',
                          iconData1: Icons.arrow_drop_down,
                          iconData2: Icons.arrow_drop_up,
                          onChanged: (value) {
                            controller.setSelectedResponse(value);
                          },
                          showError: controller.showResponseError,
                        ),

                        if (controller.showResponseError)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              'Please select a response',
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
                                  Get.back();
                                },
                          label: 'Update Lead',
                        ),
                      ],
                    ),
                  ),
                ],
                if (isCompleted)
                  Container(
                    margin: EdgeInsets.only(top: height * 0.03),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.red),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: WantText(
                            text:
                                'This lead is completed and cannot be updated.',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            textColor: Colors.red,
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
        fontSize: width * 0.035,
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
    return Container(
      width: width,
      margin: EdgeInsets.only(bottom: height * 0.015),
      padding: EdgeInsets.all(width * 0.035),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: colorBoxShadow, blurRadius: 5, offset: Offset(1, 1)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$title: ",
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
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
