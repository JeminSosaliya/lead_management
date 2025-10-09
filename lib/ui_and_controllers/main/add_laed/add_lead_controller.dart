import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/model/lead_add_model.dart';
import 'package:lead_management/model/profile_model.dart';
import 'package:lead_management/ui_and_controllers/main/employee_home/employee_home_controller.dart';
import 'package:lead_management/ui_and_controllers/main/home/home_controller.dart';
import 'package:lead_management/ui_and_controllers/main/owner_home/owner_home_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/location_picker_screen.dart';
import 'package:lead_management/ui_and_controllers/widgets/dropdown.dart';

class AddLeadController extends GetxController {
  List<CurrentUserProfileData> employees = [];
  bool isLoading = false;
  bool isSubmitting = false;

  String? selectedEmployee;
  String?  selectedEmployeeName;
  String? selectedTechnician;
  String? selectedSource;
  DateTime? nextFollowUp;
  bool showEmployeeError = false;
  bool showSourceError = false;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  List<String> technicianTypes = [];

  double? selectedLatitude;
  double? selectedLongitude;
  String? locationAddress;

  TextEditingController addressController =
      TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchTechnicianTypes();
  }

  final formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
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

  void setSelectedEmployee(String? value, {String? employeeName}) {
    selectedEmployee = value;
    selectedEmployeeName = employeeName;
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
            message: 'Please select an employee',
            backgroundColor: colorRedCalendar,
            textColor: colorWhite,
          );
          isSubmitting = false;
          update();
          return false;
        }
        assignedToEmployee = selectedEmployee!;
        assignedToName = selectedEmployeeName ?? '';
        assignedToRole = 'employee';
        addedByName = currentUserName;
      } else {
        assignedToEmployee = currentUserId;
        assignedToName = currentUserName;
        addedByName = currentUserName;
        assignedToRole = 'employee';
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

    log('Form valid: ${formKey.currentState!.validate()}, Show Employee Error: $showEmployeeError, Show Source Error: $showSourceError');

    formKey.currentState!.validate();

    String? errorMessage;

    if (nameController.text.trim().isEmpty) {
      errorMessage = 'Client name is required';
    } else if (phoneController.text.trim().isEmpty) {
      errorMessage = 'Client number is required';
    } else if (phoneController.text.length != 10 ||
        !RegExp(r'^\d{10}$').hasMatch(phoneController.text)) {
      errorMessage = 'Client number must be exactly 10 digits';
    } else if (emailController.text.isNotEmpty &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(emailController.text)) {
      errorMessage = 'Invalid email format';
    } else if (companyController.text.trim().isEmpty) {
      errorMessage = 'Company name is required';
    } else if (descriptionController.text.trim().isEmpty) {
      errorMessage = 'Description/Notes is required';
    }
    else if (referralNumberController.text.isNotEmpty &&
        (referralNumberController.text.length != 10 ||
            !RegExp(r'^\d{10}$').hasMatch(referralNumberController.text))) {
      errorMessage = 'Referral number must be exactly 10 digits';
    } else if (showSourceError) {
      errorMessage = 'Please select a source';
    } else if (showEmployeeError) {
      errorMessage = 'Please select an employee';
    }

    if (errorMessage != null) {
      Get.context?.showAppSnackBar(
        message: errorMessage,
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
      return;
    }

    bool success = await addLead(
      clientName: nameController.text.trim(),
      clientPhone: phoneController.text.trim(),
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

    if (success) {
      Get.back();
      Get.context?.showAppSnackBar(
        message: "Lead added successfully",
        backgroundColor: colorGreen,
        textColor: colorWhite,
      );

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


