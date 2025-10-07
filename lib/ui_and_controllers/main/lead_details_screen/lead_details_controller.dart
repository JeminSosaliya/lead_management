import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/model/lead_add_model.dart';
import 'package:lead_management/ui_and_controllers/main/employee_home/employee_home_controller.dart';
import 'package:lead_management/ui_and_controllers/main/owner_home/owner_home_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadDetailsController extends GetxController {
  final String leadId;
  Lead? lead;
  bool isLoading = true;
  bool isUpdating = false;
  bool showUpdateForm = false;
  bool showResponseError = false;
  bool showStageError = false;
  final formKey = GlobalKey<FormState>();
  final noteController = TextEditingController();
  final followUpController = TextEditingController();
  DateTime? nextFollowUpDateTime;
  String selectedResponse = '';
  String selectedStage = '';
  String selectedStageDisplay = '';
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
  final List<String> stageOptions = [
    'In Progress',
    'Completed',
    'Cancelled',
  ];

  LeadDetailsController({required this.leadId});

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

  void setSelectedStage(String value) {
    selectedStageDisplay = value;
    if (value == 'In Progress') {
      selectedStage = 'inProgress';
    } else if (value == 'Completed') {
      selectedStage = 'completed';
    } else if (value == 'Cancelled') {
      selectedStage = 'cancelled';
    }
    showStageError = false;
    update();
  }

  void initializeData(Lead initialData) {
    lead = initialData;
    isLoading = false;
    update();
  }

  Future<void> fetchLead() async {
    isLoading = true;
    update();
    try {
      final doc = await fireStore.collection('leads').doc(leadId).get();
      if (doc.exists) {
        lead = Lead.fromMap(doc.data()!);
      } else {  Get.context?.showAppSnackBar(
        message: 'Lead not found',
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
      }
    } catch (e) {
      log("Error fetching lead: $e");
    }
    isLoading = false;
    update();
  }

  void callLead() async {
    if (lead == null) return;

    if (lead!.stage == 'completed' || lead!.stage == 'cancelled') {
      Get.context?.showAppSnackBar(
        message: 'Cannot call completed leads',
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
      return;
    }

    String? phone = lead!.clientPhone;
    if (phone.isEmpty) {
      Get.context?.showAppSnackBar(
        message: 'Phone number not available',
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
      return;
    }

    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      showUpdateForm = true;
      update();
    } else {
      Get.context?.showAppSnackBar(
        message: 'Could not launch call',
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
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
      } else {Get.context?.showAppSnackBar(
        message: 'Could not open WhatsApp',
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
      }
    } catch (e) { Get.context?.showAppSnackBar(
      message: 'Could not open WhatsApp: $e',
      backgroundColor: colorRedCalendar,
      textColor: colorWhite,
    );
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
        final formattedDateTime = DateFormat('dd MMM yyyy, hh:mm a').format(nextFollowUpDateTime!);
        followUpController.text = formattedDateTime;
        update();
      }
    }
  }

  Future<void> updateLead() async {
    if (lead == null || lead!.stage == 'completed' || lead!.stage == 'cancelled') {
      Get.context?.showAppSnackBar(
        message: 'Cannot update completed leads',
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
      return;
    }

    showResponseError = selectedResponse.isEmpty;
    showStageError = selectedStage.isEmpty;
    update();

    if (formKey.currentState!.validate() && !showResponseError && !showStageError) {
      isUpdating = true;
      update();

      String newCallStatus = selectedResponse.toLowerCase().replaceAll(' ', '');
      String newStage = selectedStage;

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
        Get.context?.showAppSnackBar(
          message: 'Lead updated successfully',
          backgroundColor: colorGreen,
          textColor: colorWhite,
        );
        showUpdateForm = false;
        noteController.clear();
        followUpController.clear();
        nextFollowUpDateTime = null;
        selectedResponse = '';
        selectedStage = '';
        selectedStageDisplay = '';
        await fetchLead();
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
    } else {
      String? errorMessage;
      if (noteController.text.trim().isEmpty) {
        errorMessage = 'Please enter call note';
      } else if (showResponseError) {
        errorMessage = 'Please select a response';
      }
      if (errorMessage != null) {
        Get.context?.showAppSnackBar(
          message: errorMessage,
          backgroundColor: colorRedCalendar,
          textColor: colorWhite,
        );
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