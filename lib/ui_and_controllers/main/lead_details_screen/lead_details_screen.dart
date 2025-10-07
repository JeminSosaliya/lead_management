// import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:get/get.dart';
// import 'package:lead_management/core/constant/app_assets.dart';
// import 'package:lead_management/core/constant/app_color.dart';
// import 'package:lead_management/core/constant/app_const.dart';
// import 'package:lead_management/ui_and_controllers/main/lead_details_screen/lead_details_controller.dart';
// import 'package:lead_management/ui_and_controllers/widgets/custom_button.dart';
// import 'package:lead_management/ui_and_controllers/widgets/custom_textformfield.dart';
// import 'package:lead_management/ui_and_controllers/widgets/dropdown.dart';
// import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';
//
// class LeadDetailsScreen extends StatelessWidget {
//   final String leadId;
//   final Map<String, dynamic> initialData;
//
//   const LeadDetailsScreen({
//     super.key,
//     required this.leadId,
//     required this.initialData,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     Get.put(LeadDetailsController(leadId: leadId));
//
//     return Scaffold(
//       backgroundColor: colorWhite,
//       appBar: AppBar(
//         title: WantText(
//           text: 'Lead Details',
//           fontSize: width * 0.061,
//           fontWeight: FontWeight.w600,
//           textColor: colorWhite,
//         ),
//         backgroundColor: colorMainTheme,
//         iconTheme: IconThemeData(color: colorWhite),
//       ),
//       body: GetBuilder<LeadDetailsController>(
//         builder: (controller) {
//           if (controller.isLoading) {
//             return const Center(
//               child: CircularProgressIndicator(color: colorMainTheme),
//             );
//           }
//
//           final lead = controller.lead!;
//           bool isCompleted = lead.stage == 'completed';
//
//           String formatTimestamp(dynamic timestamp) {
//             if (timestamp == null) return 'N/A';
//             try {
//               if (timestamp is Timestamp) {
//                 DateTime date = timestamp.toDate();
//                 return DateFormat('dd MMM yyyy, hh:mm a').format(date);
//               } else if (timestamp is String) {
//                 // Try to parse if it's a string
//                 DateTime? date = DateTime.tryParse(timestamp);
//                 if (date != null) {
//                   return DateFormat('dd MMM yyyy, hh:mm a').format(date);
//                 }
//               }
//               return timestamp.toString();
//             } catch (e) {
//               return timestamp.toString();
//             }
//           }
//
//           String formatNextFollowUp() {
//             final nextFollowUp = lead.nextFollowUp;
//             if (nextFollowUp == null) return 'N/A';
//             return formatTimestamp(nextFollowUp);
//           }
//
//           String formatCreatedAt() {
//             final createdAt = lead.createdAt;
//             return formatTimestamp(createdAt);
//           }
//
//           return SingleChildScrollView(
//             padding: EdgeInsets.all(width * 0.04),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(width * 0.041),
//                   decoration: BoxDecoration(
//                     color: colorWhite,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: colorBoxShadow,
//                         blurRadius: 6,
//                         offset: Offset(4, 3),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 28,
//                         backgroundColor: colorMainTheme,
//                         child: WantText(
//                           text:
//                           lead.clientName.isNotEmpty
//                               ? lead.clientName[0]
//                                     .toUpperCase()
//                               : '',
//                           fontSize: width * 0.051,
//                           fontWeight: FontWeight.w600,
//                           textColor: colorWhite,
//                         ),
//                       ),
//                       SizedBox(width: width * 0.035),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             WantText(
//                               text: lead.clientName,
//                               fontSize: width * 0.046,
//                               fontWeight: FontWeight.w600,
//                               textColor: colorBlack,
//                             ),
//                             SizedBox(height: height * 0.008),
//                             Row(
//                               children: [
//                                 _badge(
//                                   lead.stage ,
//                                   colorMainTheme,
//                                 ),
//                                 SizedBox(width: width * 0.02),
//                                 _badge(
//                                   lead.callStatus,
//                                   Colors.orange,
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: height * 0.02),
//                 WantText(
//                   text: 'Basic Information',
//                   fontSize: width * 0.045,
//                   fontWeight: FontWeight.w600,
//                   textColor: colorBlack,
//                 ),
//                 SizedBox(height: height * 0.015),
//
//                 _infoCard(
//                   title: "Phone",
//                   value: lead.clientPhone,
//                   trailing: lead.clientPhone != null
//                       ? GestureDetector(
//                     onTap: () {
//                       log('tap on whatsapp');
//                       controller.openWhatsApp(
//                           lead.clientPhone,
//                       );
//                     },
//                     child: Image.asset(
//                       AppAssets.whatsapp,
//                       height: 15,
//                       width: 15,
//                     ),
//                   )
//                       : null,
//                 ),
//
//                 if (lead.clientEmail != null)
//                   _infoCard(
//                     title: "Email",
//                     value: lead.clientEmail!,
//                   ),
//
//                 if (lead.companyName != null)
//                   _infoCard(
//                     title: "Company",
//                     value: lead.companyName!,
//                   ),
//
//                 _infoCard(
//                   title: "Source",
//                   value: lead.source!,
//                 ),
//
//                 if (lead.description != null)
//                   _infoCard(
//                     title: "Description",
//                     value: lead.description!,
//                   ),
//
//                 if (lead.address != null &&
//                 lead.address.toString().isNotEmpty)
//                   _infoCard(
//                     title: "Address",
//                     value: lead.address!,
//                   ),
//
//                 if (lead.locationAddress != null)
//                   _infoCard(
//                     title: "Location",
//                     value: lead.locationAddress!,
//                   ),
//
//                 SizedBox(height: height * 0.02),
//
//                 WantText(
//                   text: 'Assignment Information',
//                   fontSize: width * 0.045,
//                   fontWeight: FontWeight.w600,
//                   textColor: colorBlack,
//                 ),
//                 SizedBox(height: height * 0.02),
//
//                 _infoCard(
//                   title: "Added By",
//                   value: lead.addedByName,
//                 ),
//
//                 _infoCard(
//                   title: "Assigned To",
//                   value: lead.assignedToName,
//                 ),
//
//                 if (lead.technician != null)
//                   _infoCard(
//                     title: "Technician",
//                     value: lead.technician!,
//                   ),
//
//                 SizedBox(height: height * 0.02),
//
//                 WantText(
//                   text: 'Timeline',
//                   fontSize: width * 0.045,
//                   fontWeight: FontWeight.w600,
//                   textColor: colorBlack,
//                 ),
//                 SizedBox(height: height * 0.015),
//
//                 _infoCard(
//                   title: "Created At",
//                   value: formatCreatedAt(),
//                 ),
//
//                 _infoCard(
//                   title: "Next Follow-up",
//                   value: formatNextFollowUp(),
//                 ),
//
//                 if (lead.referralName != null ||
//                 lead.referralNumber != null)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: height * 0.02),
//                       WantText(
//                         text: 'Referral Information',
//                         fontSize: width * 0.045,
//                         fontWeight: FontWeight.w600,
//                         textColor: colorBlack,
//                       ),
//                       SizedBox(height: height * 0.015),
//
//                       if (lead.referralName != null)
//                         _infoCard(
//                           title: "Referral Name",
//                           value: lead.referralName!,
//                         ),
//
//                       if (lead.referralNumber != null)
//                         _infoCard(
//                           title: "Referral Number",
//                           value: lead.referralNumber!,
//                         ),
//                     ],
//                   ),
//
//                 SizedBox(height: height * 0.03),
//                 if (!isCompleted)
//                   CustomButton(
//                     Width: width,
//                     onTap: controller.callLead,
//                     label: '📞 Call Lead',
//                   ),
//                 if (controller.showUpdateForm && !isCompleted) ...[
//                   SizedBox(height: height * 0.03),
//                   WantText(
//                     text: 'Update Lead',
//                     fontSize: width * 0.045,
//                     fontWeight: FontWeight.w600,
//                     textColor: colorBlack,
//                   ),
//                   SizedBox(height: height * 0.015),
//                   Form(
//                     key: controller.formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SearchableCSCDropdown(
//                           title: 'Select response',
//                           items: controller.responseOptions,
//                           hintText: controller.selectedResponse.isNotEmpty
//                               ? controller.selectedResponse
//                               : 'Select Response*',
//                           iconData1: Icons.arrow_drop_down,
//                           iconData2: Icons.arrow_drop_up,
//                           onChanged: (value) {
//                             controller.setSelectedResponse(value);
//                           },
//                           showError: controller.showResponseError,
//                         ),
//
//                         if (controller.showResponseError)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 4, left: 4),
//                             child: Text(
//                               'Please select a response',
//                               style: TextStyle(
//                                 color: colorRedError,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                         SizedBox(height: height * 0.02),
//                         CustomTextFormField(
//                           labelText: "Call Note",
//                           hintText: 'Enter call notes...',
//                           controller: controller.noteController,
//                           maxLines: 3,
//                           validator: (value) {
//                             if (value == null || value.isEmpty)
//                               return 'Please enter call note';
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: height * 0.02),
//                         CustomTextFormField(
//                           labelText: "Next Follow-up Date & Time",
//                           hintText: 'Select follow-up date and time',
//                           controller: controller.followUpController,
//                           readOnly: true,
//                           onTap: controller.pickFollowUp,
//                         ),
//                         SizedBox(height: height * 0.03),
//                         CustomButton(
//                           Width: width,
//                           onTap: controller.isUpdating
//                               ? null
//                               : () {
//                                   controller.updateLead();
//                                   Get.back();
//                                 },
//                           label: 'Update Lead',
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//                 if (isCompleted)
//                   Container(
//                     margin: EdgeInsets.only(top: height * 0.03),
//                     padding: EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.red.shade200),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.info, color: Colors.red),
//                         SizedBox(width: width * 0.03),
//                         Expanded(
//                           child: WantText(
//                             text:
//                                 'This lead is completed and cannot be updated.',
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             textOverflow: TextOverflow.visible,
//                             textColor: Colors.red,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _badge(String text, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: WantText(
//         text: text,
//         fontSize: width * 0.035,
//         fontWeight: FontWeight.w500,
//         textColor: colorWhite,
//       ),
//     );
//   }
//
//   Widget _infoCard({
//     required String title,
//     required String value,
//     Widget? trailing,
//   }) {
//     return Container(
//       width: width,
//       margin: EdgeInsets.only(bottom: height * 0.015),
//       padding: EdgeInsets.all(width * 0.035),
//       decoration: BoxDecoration(
//         color: colorWhite,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(color: colorBoxShadow, blurRadius: 5, offset: Offset(1, 1)),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: RichText(
//               text: TextSpan(
//                 children: [
//                   TextSpan(
//                     text: "$title: ",
//                     style: TextStyle(
//                       color: Colors.black54,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                     ),
//                   ),
//                   TextSpan(
//                     text: value,
//                     style: const TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.normal,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (trailing != null) trailing,
//         ],
//       ),
//     );
//   }
// }



import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_assets.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/ui_and_controllers/main/lead_details_screen/lead_details_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_button.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_textformfield.dart';
import 'package:lead_management/ui_and_controllers/widgets/dropdown.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

import '../../../model/lead_add_model.dart';

class LeadDetailsScreen extends StatelessWidget {
  final String leadId;
  final Lead? initialData;

  const LeadDetailsScreen({
    super.key,
    required this.leadId,
    this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LeadDetailsController(leadId: leadId));

    if (initialData != null) {
      controller.initializeData(initialData!);
    }

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
          if (controller.isLoading || controller.lead == null) {
            return const Center(
              child: CircularProgressIndicator(color: colorMainTheme),
            );
          }

          final lead = controller.lead!;
          bool isCompleted = lead.stage == 'completed';

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
            return value != null && value.trim().isNotEmpty && value.toLowerCase() != 'null';
          }

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
                              fontSize: width * 0.046,
                              fontWeight: FontWeight.w600,
                              textColor: colorBlack,
                            ),
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
                SizedBox(height: height * 0.03),

                WantText(
                  text: 'Basic Information',
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.w600,
                  textColor: colorBlack,
                ),
                SizedBox(height: height * 0.02),

                _infoCard(
                  title: "Phone",
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

                if (hasValue(lead.clientEmail))
                  _infoCard(
                    title: "Email",
                    value: lead.clientEmail!,
                  ),

                if (hasValue(lead.companyName))
                  _infoCard(
                    title: "Company",
                    value: lead.companyName!,
                  ),

                _infoCard(
                  title: "Source",
                  value: lead.source ?? 'N/A',
                ),

                if (hasValue(lead.description))
                  _infoCard(
                    title: "Description/Notes",
                    value: lead.description!,
                  ),

                if (hasValue(lead.address))
                  _infoCard(
                    title: "Address",
                    value: lead.address!,
                  ),

                if (lead.initialFollowUp != null)
                  _infoCard(
                    title: "Initial Follow-up",
                    value: formatTimestamp(lead.initialFollowUp),
                  ),

                if (lead.nextFollowUp != null)
                  _infoCard(
                    title: "Next Follow-up",
                    value: formatTimestamp(lead.nextFollowUp),
                  ),

                SizedBox(height: height * 0.008),

                WantText(
                  text: 'Assignment Information',
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.w600,
                  textColor: colorBlack,
                ),
                SizedBox(height: height * 0.02),

                _infoCard(
                  title: "Added By",
                  value: lead.addedByName,
                ),

                _infoCard(
                  title: "Assigned To",
                  value: lead.assignedToName,
                ),

                if (hasValue(lead.technician))
                  _infoCard(
                    title: "Technician",
                    value: lead.technician!,
                  ),

                if (hasValue(lead.referralName) || hasValue(lead.referralNumber))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: height * 0.008),
                      WantText(
                        text: 'Referral Information',
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.w600,
                        textColor: colorBlack,
                      ),
                      SizedBox(height: height * 0.02),

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

                        SearchableCSCDropdown(
                          title: 'Select stage',
                          items: controller.stageOptions,
                          hintText: controller.selectedStageDisplay.isNotEmpty
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
                            padding: const EdgeInsets.only(top: 4, left: 4),
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
                         Icon(Icons.info, color: colorRedCalendar),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: WantText(
                            text: 'This lead is completed and cannot be updated.',
                            fontSize: width*0.038,
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
                      color: colorBlack,
                      fontWeight: FontWeight.w500,
                      fontSize: width*0.040,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style:  TextStyle(
                      color: colorDarkGreyText,
                      fontWeight: FontWeight.w500,
                      fontSize: width*0.040,
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