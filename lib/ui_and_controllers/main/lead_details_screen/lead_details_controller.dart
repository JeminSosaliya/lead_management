
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/ui_and_controllers/main/employee_home/employee_home_controller.dart';
import 'package:lead_management/ui_and_controllers/main/owner_home/owner_home_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadDetailsController extends GetxController {
  final String leadId;

  LeadDetailsController({required this.leadId});

  late Map<String, dynamic> leadData = {};
  bool isLoading = true;
  bool isUpdating = false;
  bool showUpdateForm = false;
  bool showResponseError = false;
  final formKey = GlobalKey<FormState>();
  final noteController = TextEditingController();
  final followUpController = TextEditingController();
  DateTime? nextFollowUpDateTime;
  String selectedResponse = '';
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final List<String> responseOptions = [
    'Interested',
    'Not Interested',
    'Will visit office',
    'Number does not exist',
    'Number busy',
    'Out of range',
    'Switch off',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchLead();
  }

  void setSelectedResponse(String value) {
    selectedResponse = value;
    showResponseError = false;
    update();
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
      final doc = await fireStore.collection('leads').doc(leadId).get();
      if (doc.exists) {
        leadData = doc.data() ?? {};
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch lead: $e', backgroundColor: colorRedCalendar, snackPosition: SnackPosition.TOP);
    }
    isLoading = false;
    update();
  }

  void callLead() async {
    if (leadData['stage'] == 'completed') {
      Get.snackbar('Info', 'Cannot call completed leads', backgroundColor: colorRedCalendar, snackPosition: SnackPosition.TOP);
      return;
    }
    String? phone = leadData['clientPhone'];
    if (phone == null) {
      Get.snackbar('Error', 'Phone number not available', backgroundColor: colorRedCalendar, snackPosition: SnackPosition.TOP);
      return;
    }
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      showUpdateForm = true;
      update();
    } else {
      Get.snackbar('Error', 'Could not launch call', backgroundColor: colorRedCalendar, snackPosition: SnackPosition.TOP);
    }
  }

  void openWhatsApp(String phone) async {
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleanPhone.startsWith('+')) {
      cleanPhone = '+91$cleanPhone';
    }
    final Uri url = Uri.parse('https://wa.me/$cleanPhone');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Could not open WhatsApp', backgroundColor: colorRedCalendar, snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not open WhatsApp: $e', backgroundColor: colorRedCalendar, snackPosition: SnackPosition.TOP);
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
        nextFollowUpDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        followUpController.text = nextFollowUpDateTime.toString();
        update();
      }
    }
  }

  Future<void> updateLead() async {
    if (leadData['stage'] == 'completed') {
      Get.snackbar('Info', 'Cannot update completed leads', backgroundColor: colorRedCalendar, snackPosition: SnackPosition.TOP);
      return;
    }

    showResponseError = selectedResponse.isEmpty;
    update();

    if (formKey.currentState!.validate() && !showResponseError) {
      isUpdating = true;
      update();

      String newCallStatus = selectedResponse.toLowerCase().replaceAll(' ', '');
      String newStage = ['willvisitoffice', 'numberbusy', 'outofrange', 'switchoff'].contains(newCallStatus)
          ? 'inProgress'
          : 'completed';

      Map<String, dynamic> updates = {
        'stage': newStage,
        'callStatus': newCallStatus,
        'callNote': noteController.text.trim(),
        'nextFollowUp': nextFollowUpDateTime != null
            ? Timestamp.fromDate(nextFollowUpDateTime!)
            : null,
        'updatedAt': Timestamp.now(),
      };

      try {
        await fireStore.collection('leads').doc(leadId).update(updates);
        Get.snackbar('Success', 'Lead updated successfully', backgroundColor: colorGreen, snackPosition: SnackPosition.TOP);
        showUpdateForm = false;
        noteController.clear();
        followUpController.clear();
        nextFollowUpDateTime = null;
        selectedResponse = '';
        update();
        Get.back();
        String role = ListConst.currentUserProfileData.type ?? '';
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
        log("Error updating lead: $e");
      } finally {
        isUpdating = false;
        update();
      }
    }
  }

  @override
  void onClose() {
    noteController.dispose();
    followUpController.dispose();
    super.onClose();
  }
}