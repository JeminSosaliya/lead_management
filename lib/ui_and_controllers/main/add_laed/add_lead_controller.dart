import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lead_management/model/employee_model.dart';
import 'package:lead_management/model/lead_add_model.dart';
import 'package:lead_management/core/utils/firebase_service.dart';
import 'package:lead_management/core/utils/shred_pref.dart';

class AddLeadController extends GetxController {
  List<Employee> employees = [];
  bool isLoading = false;
  bool isSubmitting = false;

  String? selectedEmployee;
  String? selectedSource;

  final List<String> sources = ['Website', 'Phone', 'Referral', 'Walk-in', 'Other'];

  @override
  void onInit() {
    super.onInit();
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    isLoading = true;
    update();

    try {
      employees = await FirebaseService.getEmployees();
    } catch (e) {
      print("Error loading employees: $e");
      Get.snackbar('Error', 'Failed to load employees');
    }

    isLoading = false;
    update();
  }

  void setSelectedEmployee(String? value) {
    selectedEmployee = value;
    update();
  }

  void setSelectedSource(String? value) {
    selectedSource = value;
    update();
  }

  Future<bool> addLead({
    required String clientName,
    required String clientPhone,
    String? clientEmail,
    String? companyName,
    String? description,
  }) async {
    isSubmitting = true;
    update();

    try {
      String leadId = FirebaseService.fireStore.collection('leads').doc().id;
      String currentUserId = FirebaseService.getCurrentUserId();
      String currentUserRole = preferences.getString(SharedPreference.role) ?? '';

      print("👤 Current User ID: $currentUserId");
      print("🎭 Current User Role: $currentUserRole");
      String assignedToEmployee;

      if (currentUserRole == 'admin') {
        // Owner hai - to selected employee ko assign karega
        if (selectedEmployee == null) {
          Get.snackbar('Error', 'Please select an employee');
          isSubmitting = false;
          update();
          return false;
        }
        assignedToEmployee = selectedEmployee!;
      } else {
        // Employee hai - to khud ko assign karega
        assignedToEmployee = currentUserId;
      }

      Lead newLead = Lead(
        leadId: leadId,
        clientName: clientName,
        clientPhone: clientPhone,
        clientEmail: clientEmail,
        companyName: companyName,
        source: selectedSource,
        description: description,
        assignedTo: assignedToEmployee,
        addedBy: currentUserId,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await FirebaseService.fireStore
          .collection('leads')
          .doc(leadId)
          .set(newLead.toMap());

      isSubmitting = false;
      update();
      return true;
    } catch (e) {
      isSubmitting = false;
      update();
      print("Error adding lead: $e");
      Get.snackbar('Error', 'Failed to add lead');
      return false;
    }
  }
}