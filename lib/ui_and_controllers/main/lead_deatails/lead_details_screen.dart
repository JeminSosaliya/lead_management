// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:lead_management/ui_and_controllers/main/lead_deatails/lead_details_controller.dart';
//
// class LeadDetailsScreen extends StatelessWidget {
//   final String leadId;
//   final Map<String, dynamic> initialData;
//
//   const LeadDetailsScreen({super.key, required this.leadId, required this.initialData});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(LeadDetailsController(leadId: leadId));
//     controller.leadData.value = initialData; // Set initial data for immediate display
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Lead Details')),
//       body: Obx(() {
//         var data = controller.leadData.value;
//         if (data.isEmpty) return const Center(child: CircularProgressIndicator());
//
//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Name: ${data['clientName']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Text('Phone: ${data['clientPhone']}'),
//               if (data['clientEmail'] != null) Text('Email: ${data['clientEmail']}'),
//               if (data['companyName'] != null) Text('Company: ${data['companyName']}'),
//               Text('Source: ${data['source'] ?? 'N/A'}'),
//               if (data['description'] != null) Text('Description: ${data['description']}'),
//               Text('Stage: ${data['stage']}'),
//               Text('Status: ${data['callStatus']}'),
//               if (data['callNote'] != null) Text('Note: ${data['callNote']}'),
//               if (data['nextFollowUp'] != null) Text('Next Follow-up: ${(data['nextFollowUp'] as Timestamp).toDate()}'),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: controller.callLead,
//                 child: const Text('Call Lead'),
//               ),
//               if (controller.showUpdateForm.value) ...[
//                 const SizedBox(height: 20),
//                 const Text('Update After Call', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                 DropdownButtonFormField<String>(
//                   decoration: const InputDecoration(labelText: 'Select Response'),
//                   value: controller.selectedResponse.value,
//                   items: [
//                     'Interested',
//                     'Not Interested',
//                     'Will visit office',
//                     'Number does not exist',
//                     'Number busy',
//                     'Out of range',
//                     'Switch off',
//                   ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
//                   onChanged: (v) => controller.selectedResponse.value = v!,
//                 ),
//                 TextFormField(
//                   controller: controller.noteController,
//                   decoration: const InputDecoration(labelText: 'Note'),
//                   maxLines: 3,
//                 ),
//                 TextFormField(
//                   controller: controller.followUpController,
//                   decoration: const InputDecoration(labelText: 'Next Follow-up Date & Time'),
//                   readOnly: true,
//                   onTap: controller.pickFollowUp,
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: controller.updateLead,
//                   child: const Text('Update'),
//                 ),
//               ]
//             ],
//           ),
//         );
//       }),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/ui_and_controllers/main/lead_deatails/lead_details_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_button.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_textformfield.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';


// class LeadDetailsScreen extends StatelessWidget {
//   final String leadId;
//   final Map<String, dynamic> initialData;
//
//   const LeadDetailsScreen({super.key, required this.leadId, required this.initialData});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(LeadDetailsController(leadId: leadId));
//     controller.initializeData(initialData);
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Lead Details')),
//       body: GetBuilder<LeadDetailsController>(
//         init: controller,
//         builder: (controller) {
//           if (controller.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Name: ${controller.leadData['clientName']}',
//                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 Text('Phone: ${controller.leadData['clientPhone']}'),
//                 if (controller.leadData['clientEmail'] != null)
//                   Text('Email: ${controller.leadData['clientEmail']}'),
//                 if (controller.leadData['companyName'] != null)
//                   Text('Company: ${controller.leadData['companyName']}'),
//                 Text('Source: ${controller.leadData['source'] ?? 'N/A'}'),
//                 if (controller.leadData['description'] != null)
//                   Text('Description: ${controller.leadData['description']}'),
//                 Text('Stage: ${controller.leadData['stage']}'),
//                 Text('Status: ${controller.leadData['callStatus']}'),
//                 if (controller.leadData['callNote'] != null)
//                   Text('Note: ${controller.leadData['callNote']}'),
//                 if (controller.leadData['nextFollowUp'] != null)
//                   Text('Next Follow-up: ${(controller.leadData['nextFollowUp'] as Timestamp).toDate()}'),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: controller.callLead,
//                   child: const Text('Call Lead'),
//                 ),
//                 if (controller.showUpdateForm) ...[
//                   const SizedBox(height: 20),
//                   const Text('Update After Call',
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                   DropdownButtonFormField<String>(
//                     decoration: const InputDecoration(labelText: 'Select Response'),
//                     value: controller.selectedResponse,
//                     items: [
//                       'Interested',
//                       'Not Interested',
//                       'Will visit office',
//                       'Number does not exist',
//                       'Number busy',
//                       'Out of range',
//                       'Switch off',
//                     ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
//                     onChanged: (v) => controller.updateSelectedResponse(v!),
//                   ),
//                   TextFormField(
//                     controller: controller.noteController,
//                     decoration: const InputDecoration(labelText: 'Note'),
//                     maxLines: 3,
//                   ),
//                   TextFormField(
//                     controller: controller.followUpController,
//                     decoration: const InputDecoration(labelText: 'Next Follow-up Date & Time'),
//                     readOnly: true,
//                     onTap: controller.pickFollowUp,
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: controller.updateLead,
//                     child: const Text('Update'),
//                   ),
//                 ],
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }



class LeadDetailsScreen extends StatelessWidget {
  final String leadId;
  final Map<String, dynamic> initialData;

  const LeadDetailsScreen({super.key, required this.leadId, required this.initialData});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final controller = Get.put(LeadDetailsController(leadId: leadId));
    controller.initializeData(initialData);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: WantText(text: 'Lead Details', fontSize: 20, fontWeight: FontWeight.bold, textColor: Colors.white),
        backgroundColor: colorMainTheme,
      ),
      body: GetBuilder<LeadDetailsController>(
        init: controller,
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator(color: colorMainTheme));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(width * 0.041),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(width * 0.041),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WantText(text: 'Name: ${controller.leadData['clientName']}', fontSize: 18, fontWeight: FontWeight.bold, textColor: Colors.black),
                    SizedBox(height: height * 0.0095), // ~8px
                    WantText(text: 'Phone: ${controller.leadData['clientPhone']}', fontSize: 14, fontWeight: FontWeight.normal, textColor: Colors.grey.shade800),
                    if (controller.leadData['clientEmail'] != null)
                      WantText(text: 'Email: ${controller.leadData['clientEmail']}', fontSize: 14, fontWeight: FontWeight.normal, textColor:Colors.grey.shade800),
                    if (controller.leadData['companyName'] != null)
                      WantText(text: 'Company: ${controller.leadData['companyName']}', fontSize: 14, fontWeight: FontWeight.normal, textColor: Colors.grey.shade800),
                    WantText(text: 'Source: ${controller.leadData['source'] ?? 'N/A'}', fontSize: 14, fontWeight: FontWeight.normal, textColor: Colors.grey.shade800),
                    if (controller.leadData['description'] != null)
                      WantText(text: 'Description: ${controller.leadData['description']}', fontSize: 14, fontWeight: FontWeight.normal, textColor: Colors.grey.shade800),
                    WantText(text: 'Stage: ${controller.leadData['stage']}', fontSize: 14, fontWeight: FontWeight.normal, textColor: Colors.grey.shade800),
                    WantText(text: 'Status: ${controller.leadData['callStatus']}', fontSize: 14, fontWeight: FontWeight.normal, textColor: Colors.grey.shade800),
                    if (controller.leadData['callNote'] != null)
                      WantText(text: 'Note: ${controller.leadData['callNote']}', fontSize: 14, fontWeight: FontWeight.normal, textColor: Colors.grey.shade800),
                    if (controller.leadData['nextFollowUp'] != null)
                      WantText(text: 'Next Follow-up: ${(controller.leadData['nextFollowUp'] as Timestamp).toDate()}', fontSize: 14, fontWeight: FontWeight.normal, textColor: Colors.grey.shade800),
                    SizedBox(height: height * 0.0237), // ~20px
                    CustomButton(
                      Width: width,
                      onTap: controller.callLead,
                      label: 'Call Lead',
                      backgroundColor: colorMainTheme,
                      textColor: Colors.white,
                      fontSize: 16,
                      boarderRadius: 8,
                    ),
                    if (controller.showUpdateForm) ...[
                      SizedBox(height: height * 0.0237),
                      WantText(text: 'Update After Call', fontSize: 16, fontWeight: FontWeight.bold, textColor: Colors.black),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          label: WantText(text: 'Select Response', fontSize: 14, fontWeight: FontWeight.w500, textColor: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        value: controller.selectedResponse,
                        items: [
                          'Interested',
                          'Not Interested',
                          'Will visit office',
                          'Number does not exist',
                          'Number busy',
                          'Out of range',
                          'Switch off',
                        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => controller.updateSelectedResponse(v!),
                      ),
                      SizedBox(height: height * 0.019),
                      CustomTextFormField(
                        hintText: 'Note',
                        controller: controller.noteController,
                        maxLines: 3,
                      ),
                      SizedBox(height: height * 0.019),
                      CustomTextFormField(
                        hintText: 'Next Follow-up Date & Time',
                        controller: controller.followUpController,
                        readOnly: true,
                        onTap: controller.pickFollowUp,
                      ),
                      SizedBox(height: height * 0.0237),
                      CustomButton(
                        Width: width,
                        onTap: controller.updateLead,
                        label: 'Update',
                        backgroundColor: colorMainTheme,
                        textColor: Colors.white,
                        fontSize: 16,
                        boarderRadius: 8,
                      ),
                    ]
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