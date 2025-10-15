import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/model/lead_add_model.dart';
import 'package:lead_management/ui_and_controllers/main/home/home_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/location_picker_screen.dart';

import '../../auth/goggle_login/google_calendar_controller.dart';

class AddLeadController extends GetxController {
  bool isLoading = false;
  bool isSubmitting = false;

  String? selectedEmployee;
  String? selectedEmployeeName;
  String? selectedEmployeeType;
  String? selectedTechnician;
  String? selectedSource;
  String? selectedEmployeeEmail;
  DateTime? nextFollowUp;
  bool showEmployeeError = false;
  bool showSourceError = false;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  List<String> technicianTypes = [];

  double? selectedLatitude;
  double? selectedLongitude;
  String? locationAddress;

  TextEditingController addressController = TextEditingController();
  final calendarController = Get.put(GoogleCalendarController());

  @override
  void onInit() {
    super.onInit();
    fetchTechnicianTypes();
  }

  final formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController clientPhoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController followUpController = TextEditingController();
  TextEditingController referralNameController = TextEditingController();
  TextEditingController referralNumberController = TextEditingController();

  final List<String> sources = [
    'Website',
    'Phone',
    'Referral',
    'Walk-in',
    'Other',
  ];

  Future<void> fetchTechnicianTypes() async {
    try {
      DocumentSnapshot doc = await fireStore
          .collection('technicians')
          .doc('technician_list')
          .get();

      if (doc.exists) {
        List<dynamic> types = doc.get('technicianList') ?? [];
        technicianTypes = types.map((e) => e.toString()).toList();
        update();
      }
    } catch (e) {
      print("Error fetching technician types: $e");
    }
  }

  void setSelectedEmployee(
    String? value, {
    String? employeeName,
    String? userType,
    String? email,
  }) {
    selectedEmployee = value;
    selectedEmployeeName = employeeName;
    selectedEmployeeType = userType;
    selectedEmployeeEmail = email;

    showEmployeeError = false;
    update();
  }

  void setSelectedSource(String? value) {
    selectedSource = value;
    showSourceError = false;
    update();
  }

  void setSelectedTechnician(String? value) {
    selectedTechnician = value;
    update();
  }

  Future<void> pickLocation() async {
    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.context?.showAppSnackBar(
          message: "Location permission is required to select location",
          backgroundColor: colorRedCalendar,
          textColor: colorWhite,
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.context?.showAppSnackBar(
        message:
            "Location permission is permanently denied. Please enable it in settings",
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
      return;
    }

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.context?.showAppSnackBar(
        message: "Please turn on location services to select location",
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
      return;
    }

    final result = await Get.to(
      () => LocationPickerScreen(
        initialLatitude: selectedLatitude,
        initialLongitude: selectedLongitude,
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      selectedLatitude = result['latitude'];
      selectedLongitude = result['longitude'];
      locationAddress =
          'Lat: ${selectedLatitude!.toStringAsFixed(6)}, Lng: ${selectedLongitude!.toStringAsFixed(6)}';
      update();
    }
  }

  Future<bool> addLead({
    required String clientName,
    required String clientPhone,
    String? clientEmail,
    String? companyName,
    String? referralNumber,
    String? referralName,
    String? description,
    DateTime? nextFollowUp,
  }) async {
    isSubmitting = true;
    update();

    try {
      String leadId = fireStore.collection('leads').doc().id;
      String currentUserId = ListConst.currentUserProfileData.uid.toString();
      String currentUserRole = ListConst.currentUserProfileData.type ?? '';
      String currentUserEmail = ListConst.currentUserProfileData.email ?? '';
      String currentUserName = ListConst.currentUserProfileData.name ?? '';

      print("👤 Current User ID: $currentUserId");
      print("🎭 Current User Role: $currentUserRole");
      String assignedToEmployee;
      String addedByName;
      String assignedToRole;
      String assignedToName;
      if (currentUserRole == 'admin') {
        if (selectedEmployee == null) {
          Get.context?.showAppSnackBar(
            message: 'Please select a user to assign',
            backgroundColor: colorRedCalendar,
            textColor: colorWhite,
          );
          isSubmitting = false;
          update();
          return false;
        }
        assignedToEmployee = selectedEmployee!;
        assignedToName = selectedEmployeeName ?? '';
        assignedToRole = selectedEmployeeType ?? 'employee';
        addedByName = currentUserName;
      } else {
        if (selectedEmployee != null) {
          assignedToEmployee = selectedEmployee!;
          assignedToName = selectedEmployeeName ?? '';
          assignedToRole = selectedEmployeeType ?? 'employee';
        } else {
          assignedToEmployee = currentUserId;
          assignedToName = currentUserName;
          assignedToRole = 'employee';
        }
        addedByName = currentUserName;
      }

      Lead newLead = Lead(
        leadId: leadId,
        clientName: clientName,
        clientPhone: clientPhone,
        clientEmail: clientEmail,
        companyName: companyName,
        referralName: referralName,
        referralNumber: referralNumber,
        source: selectedSource,
        description: description,
        assignedTo: assignedToEmployee,
        assignedToName: assignedToName,
        addedByName: addedByName,
        assignedToRole: assignedToRole,
        addedBy: currentUserId,
        addedByEmail: currentUserEmail,
        addedByRole: currentUserRole,
        technician: selectedTechnician,
        latitude: selectedLatitude,
        longitude: selectedLongitude,
        locationAddress: locationAddress,
        address: addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        initialFollowUp: nextFollowUp != null
            ? Timestamp.fromDate(nextFollowUp)
            : null,
      );

      await fireStore.collection('leads').doc(leadId).set(newLead.toMap());

      isSubmitting = false;
      update();
      return true;
    } catch (e) {
      isSubmitting = false;
      update();
      print("Error adding lead: $e");

      return false;
    }
  }

  Future<void> submitForm() async {
    String currentUserRole =
        ListConst.currentUserProfileData.type ?? 'employee';

    showSourceError = selectedSource == null;
    if (currentUserRole == 'admin') {
      showEmployeeError = selectedEmployee == null;
    } else {
      showEmployeeError = false;
    }
    update();

    log(
      'Form valid: ${formKey.currentState!.validate()}, Show Employee Error: $showEmployeeError, Show Source Error: $showSourceError',
    );

    formKey.currentState!.validate();

    String? errorMessage;

    // 🔍 Validation
    if (nameController.text.trim().isEmpty) {
      errorMessage = 'Client name is required';
    } else if (clientPhoneController.text.trim().isEmpty) {
      errorMessage = 'Client number is required';
    } else if (clientPhoneController.text.length != 10 ||
        !RegExp(r'^\d{10}$').hasMatch(clientPhoneController.text)) {
      errorMessage = 'Client number must be exactly 10 digits';
    } else if (emailController.text.isNotEmpty &&
        !RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(emailController.text)) {
      errorMessage = 'Invalid email format';
    } else if (descriptionController.text.trim().isEmpty) {
      errorMessage = 'Description/Notes is required';
    } else if (referralNumberController.text.isNotEmpty &&
        (referralNumberController.text.length != 10 ||
            !RegExp(r'^\d{10}$').hasMatch(referralNumberController.text))) {
      errorMessage = 'Referral number must be exactly 10 digits';
    } else if (showSourceError) {
      errorMessage = 'Please select a source';
    } else if (showEmployeeError) {
      errorMessage = 'Please select an employee';
    } else if (followUpController.text.trim().isEmpty || nextFollowUp == null) {
      errorMessage = 'Please select initial follow-up date & time';
    }

    if (errorMessage != null) {
      Get.context?.showAppSnackBar(
        message: errorMessage,
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
      return;
    }

    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: colorMainTheme),
              SizedBox(height: 15),
              Text(
                'Adding Lead...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorMainTheme,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    bool success = await addLead(
      clientName: nameController.text.trim(),
      clientPhone: clientPhoneController.text.trim(),
      clientEmail: emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim(),
      companyName: companyController.text.trim().isEmpty
          ? null
          : companyController.text.trim(),
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      referralName: referralNameController.text.trim().isEmpty
          ? null
          : referralNameController.text.trim(),
      referralNumber: referralNumberController.text.trim().isEmpty
          ? null
          : referralNumberController.text.trim(),
      nextFollowUp: nextFollowUp,
    );

    Get.back();

    if (success) {
      Get.back();
      Get.context?.showAppSnackBar(
        message: "Lead added successfully",
        backgroundColor: colorGreen,
        textColor: colorWhite,
      );

      try {
        final calendarController = Get.find<GoogleCalendarController>();

        if (calendarController.isLoggedIn) {
          Get.dialog(
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 15),
                    Text(
                      'Adding to Google Calendar...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            barrierDismissible: false,
          );

          await calendarController.addEvent(
            title: nameController.text.trim(),
            description: descriptionController.text.trim(),
            startTime: DateTime.now().add(const Duration(minutes: 10)),
            endTime: DateTime.now().add(const Duration(minutes: 12)),
            employeeEmails: [selectedEmployeeEmail ?? ''],
          );
          log('seleceted employee email $selectedEmployeeEmail');
          Get.back(); // close calendar loading
        }
      } catch (e) {
        print('Failed to add Google Calendar event: $e');
        Get.context?.showAppSnackBar(
          message: 'Event could not be added to calendar',
          backgroundColor: colorRedCalendar,
          textColor: colorWhite,
        );
      }

      // 🔄 Reload leads on home
      String role = ListConst.currentUserProfileData.type ?? '';
      if (role == 'employee' || role == 'admin') {
        try {
          Get.find<HomeController>().loadLeads();
        } catch (e) {
          print('HomeController not found: $e');
        }
      }
    } else {
      Get.context?.showAppSnackBar(
        message: "Failed to add lead. Please try again.",
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
    }
  }
}
