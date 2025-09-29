// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:lead_management/core/utils/firebase_service.dart';
// // import 'package:url_launcher/url_launcher.dart';
// //
// // class LeadDetailsController extends GetxController {
// //   final String leadId;
// //   LeadDetailsController({required this.leadId});
// //
// //   var leadData = <String, dynamic>{}.obs;
// //   var showUpdateForm = false.obs;
// //   var selectedResponse = 'Interested'.obs;
// //   final noteController = TextEditingController();
// //   final followUpController = TextEditingController();
// //   DateTime? nextFollowUpDateTime;
// //
// //   @override
// //   void onInit() {
// //     super.onInit();
// //     fetchLead();
// //   }
// //
// //   void fetchLead() async {
// //     var doc = await FirebaseService.fireStore.collection('leads').doc(leadId).get();
// //     if (doc.exists) {
// //       leadData.value = doc.data()!;
// //     }
// //   }
// //
// //   void callLead() async {
// //     String phone = leadData['clientPhone'];
// //     final Uri url = Uri(scheme: 'tel', path: phone);
// //     if (await canLaunchUrl(url)) {
// //       await launchUrl(url);
// //       showUpdateForm.value = true; // Show form after initiating call
// //     } else {
// //       Get.snackbar('Error', 'Could not launch call');
// //     }
// //   }
// //
// //   void pickFollowUp() async {
// //     DateTime? date = await showDatePicker(
// //       context: Get.context!,
// //       initialDate: DateTime.now(),
// //       firstDate: DateTime.now(),
// //       lastDate: DateTime(2100),
// //     );
// //     if (date != null) {
// //       TimeOfDay? time = await showTimePicker(
// //         context: Get.context!,
// //         initialTime: TimeOfDay.now(),
// //       );
// //       if (time != null) {
// //         nextFollowUpDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
// //         followUpController.text = nextFollowUpDateTime.toString();
// //       }
// //     }
// //   }
// //
// //   void updateLead() async {
// //     String response = selectedResponse.value;
// //     String note = noteController.text.trim();
// //     String newCallStatus = response.toLowerCase().replaceAll(' ', '');
// //     String newStage = ['interested', 'willvisitoffice'].contains(newCallStatus) ? 'inProgress' : 'completed';
// //
// //     Map<String, dynamic> updates = {
// //       'stage': newStage,
// //       'callStatus': newCallStatus,
// //       'callNote': note.isNotEmpty ? note : null,
// //       'nextFollowUp': nextFollowUpDateTime != null ? Timestamp.fromDate(nextFollowUpDateTime!) : null,
// //       'updatedAt': Timestamp.now(),
// //     };
// //
// //     await FirebaseService.fireStore.collection('leads').doc(leadId).update(updates);
// //     Get.snackbar('Success', 'Lead updated successfully');
// //     showUpdateForm.value = false;
// //     noteController.clear();
// //     followUpController.clear();
// //     nextFollowUpDateTime = null;
// //     fetchLead(); // Refresh data
// //   }
// // }
//
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:lead_management/core/utils/firebase_service.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class LeadDetailsController extends GetxController {
//   final String leadId;
//   LeadDetailsController({required this.leadId});
//
//   late Map<String, dynamic> leadData = {};
//   bool isLoading = true;
//   bool showUpdateForm = false;
//   String selectedResponse = 'Interested';
//   final noteController = TextEditingController();
//   final followUpController = TextEditingController();
//   DateTime? nextFollowUpDateTime;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchLead();
//   }
//
//   void initializeData(Map<String, dynamic> initialData) {
//     leadData = initialData;
//     isLoading = false;
//     update();
//   }
//
//   Future<void> fetchLead() async {
//     isLoading = true;
//     update();
//     try {
//       final doc = await FirebaseService.fireStore.collection('leads').doc(leadId).get();
//       if (doc.exists) {
//         leadData = doc.data()!;
//       }
//     } catch (e) {
//       print("Error fetching lead: $e");
//       Get.snackbar('Error', 'Failed to load lead details');
//     }
//     isLoading = false;
//     update();
//   }
//
//   void callLead() async {
//     String phone = leadData['clientPhone'];
//     final Uri url = Uri(scheme: 'tel', path: phone);
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//       showUpdateForm = true;
//       update();
//     } else {
//       Get.snackbar('Error', 'Could not launch call');
//     }
//   }
//
//   void pickFollowUp() async {
//     DateTime? date = await showDatePicker(
//       context: Get.context!,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2100),
//     );
//     if (date != null) {
//       TimeOfDay? time = await showTimePicker(
//         context: Get.context!,
//         initialTime: TimeOfDay.now(),
//       );
//       if (time != null) {
//         nextFollowUpDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
//         followUpController.text = nextFollowUpDateTime.toString();
//         update();
//       }
//     }
//   }
//
//   void updateSelectedResponse(String value) {
//     selectedResponse = value;
//     update();
//   }
//
//   Future<void> updateLead() async {
//     String newCallStatus = selectedResponse.toLowerCase().replaceAll(' ', '');
//     String newStage = ['interested', 'willvisitoffice'].contains(newCallStatus) ? 'inProgress' : 'completed';
//
//     Map<String, dynamic> updates = {
//       'stage': newStage,
//       'callStatus': newCallStatus,
//       'callNote': noteController.text.trim().isNotEmpty ? noteController.text.trim() : null,
//       'nextFollowUp': nextFollowUpDateTime != null ? Timestamp.fromDate(nextFollowUpDateTime!) : null,
//       'updatedAt': Timestamp.now(),
//     };
//
//     try {
//       await FirebaseService.fireStore.collection('leads').doc(leadId).update(updates);
//       Get.snackbar('Success', 'Lead updated successfully');
//       // Reset form
//       showUpdateForm = false;
//       noteController.clear();
//       followUpController.clear();
//       nextFollowUpDateTime = null;
//       selectedResponse = 'Interested';
//       // Refresh lead data
//       await fetchLead();
//       // Navigate back to refresh home screen
//       Get.back();
//     } catch (e) {
//       print("Error updating lead: $e");
//       Get.snackbar('Error', 'Failed to update lead');
//     }
//     update();
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:lead_management/core/utils/firebase_service.dart';
import 'package:lead_management/core/utils/shred_pref.dart';
import 'package:lead_management/ui_and_controllers/main/employee/employee_home/employee_home_controller.dart';
import 'package:lead_management/ui_and_controllers/main/owner/owner_home/owner_home_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadDetailsController extends GetxController {
  final String leadId;
  LeadDetailsController({required this.leadId});

  late Map<String, dynamic> leadData = {};
  bool isLoading = true;
  bool showUpdateForm = false;
  String selectedResponse = 'Interested';
  final noteController = TextEditingController();
  final followUpController = TextEditingController();
  DateTime? nextFollowUpDateTime;

  @override
  void onInit() {
    super.onInit();
    fetchLead();
  }

  void initializeData(Map<String, dynamic> initialData) {
    leadData = initialData;
    isLoading = false;
    update();
  }

  Future<void> fetchLead() async {
    isLoading = true;
    update();
    try {
      final doc = await FirebaseService.fireStore.collection('leads').doc(leadId).get();
      if (doc.exists) {
        leadData = doc.data()!;
      }
    } catch (e) {
      print("Error fetching lead: $e");
      Get.snackbar('Error', 'Failed to load lead details');
    }
    isLoading = false;
    update();
  }

  void callLead() async {
    String phone = leadData['clientPhone'];
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      showUpdateForm = true;
      update();
    } else {
      Get.snackbar('Error', 'Could not launch call');
    }
  }

  void pickFollowUp() async {
    DateTime? date = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      TimeOfDay? time = await showTimePicker(
        context: Get.context!,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        nextFollowUpDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        followUpController.text = nextFollowUpDateTime.toString();
        update();
      }
    }
  }

  void updateSelectedResponse(String value) {
    selectedResponse = value;
    update();
  }

  Future<void> updateLead() async {
    String newCallStatus = selectedResponse.toLowerCase().replaceAll(' ', '');
    String newStage = ['interested', 'willvisitoffice'].contains(newCallStatus) ? 'inProgress' : 'completed';

    Map<String, dynamic> updates = {
      'stage': newStage,
      'callStatus': newCallStatus,
      'callNote': noteController.text.trim().isNotEmpty ? noteController.text.trim() : null,
      'nextFollowUp': nextFollowUpDateTime != null ? Timestamp.fromDate(nextFollowUpDateTime!) : null,
      'updatedAt': Timestamp.now(),
    };

    try {
      await FirebaseService.fireStore.collection('leads').doc(leadId).update(updates);
      Get.snackbar('Success', 'Lead updated successfully');
      // Reset form
      showUpdateForm = false;
      noteController.clear();
      followUpController.clear();
      nextFollowUpDateTime = null;
      selectedResponse = 'Interested';
      update();
      // Navigate back and force refresh on home screen
      Get.back();
      // Force reload based on role
      String role = preferences.getString(SharedPreference.role) ?? '';
      if (role == 'employee') {
        try {
          Get.find<EmployeeHomeController>().loadMyLeads();
        } catch (e) {
          print('EmployeeHomeController not found: $e');
        }
      } else if (role == 'admin') {
        try {
          Get.find<OwnerHomeController>().loadLeads();
        } catch (e) {
          print('OwnerHomeController not found: $e');
        }
      }
    } catch (e) {
      print("Error updating lead: $e");
      Get.snackbar('Error', 'Failed to update lead');
    }
  }
}