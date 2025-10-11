import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/model/lead_add_model.dart';
import 'package:lead_management/ui_and_controllers/main/home/home_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/location_picker_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadDetailsController extends GetxController {
  final String leadId;
  Lead? lead;
  bool isLoading = true;
  bool isUpdating = false;
  bool showUpdateForm = false;
  bool showResponseError = false;
  bool showStageError = false;
  bool isEditMode = false;
  bool showEmployeeError = false;
  bool showSourceError = false;
  final formKey = GlobalKey<FormState>();
  final editFormKey = GlobalKey<FormState>();
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

  List<Map<String, dynamic>> employees = [];
  List<String> technicianTypes = [];
  List<String> sources = [
    'Website',
    'Phone',
    'Referral',
    'Walk-in',
    'Other',
  ];
  String? selectedEmployee;
  String? selectedEmployeeName;
  String? selectedTechnician;
  String? selectedSource;
  double? selectedLatitude;
  double? selectedLongitude;
  String? locationAddress;
  DateTime? initialFollowUp;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController referralNameController = TextEditingController();
  TextEditingController referralNumberController = TextEditingController();
  TextEditingController initialFollowUpController = TextEditingController();

  LeadDetailsController({required this.leadId});

  @override
  void onInit() {
    super.onInit();
    fetchLead();
    fetchEmployees();
    fetchTechnicianTypes();
  }

  Future<void> fetchEmployees() async {
    try {
      String currentUserId = ListConst.currentUserProfileData.uid.toString();
      String currentUserRole = ListConst.currentUserProfileData.type ?? '';

      QuerySnapshot snap = await fireStore
          .collection('users')
          .where('type', isEqualTo: 'employee')
          .where('isActive', isEqualTo: true)
          .get();
      employees = snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          'name': data['name'] ?? '',
        };
      }).toList();

      if (currentUserRole == 'employee') {
        employees = employees.where((e) => e['uid'] != currentUserId).toList();
      }

      update();
    } catch (e) {
      print("Error fetching employees: $e");
    }
  }
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

  void toggleEditMode() {
    isEditMode = !isEditMode;
    if (isEditMode) {
      // Initialize controllers with current lead data
      nameController.text = lead?.clientName ?? '';
      phoneController.text = lead?.clientPhone ?? '';
      emailController.text = lead?.clientEmail ?? '';
      companyController.text = lead?.companyName ?? '';
      descriptionController.text = lead?.description ?? '';
      addressController.text = lead?.address ?? '';
      referralNameController.text = lead?.referralName ?? '';
      referralNumberController.text = lead?.referralNumber ?? '';
      selectedSource = lead?.source;
      selectedTechnician = lead?.technician;
      selectedLatitude = lead?.latitude;
      selectedLongitude = lead?.longitude;
      locationAddress = lead?.locationAddress;
      if (lead?.initialFollowUp != null) {
        initialFollowUp = lead!.initialFollowUp!.toDate();
        initialFollowUpController.text = DateFormat('dd MMM yyyy, hh:mm a').format(initialFollowUp!);
      }
      // Set selected employee
      selectedEmployee = lead?.assignedTo;
      selectedEmployeeName = lead?.assignedToName;
    }
    update();
  }

  void setSelectedEmployee(String? value) {
    if (value != null) {
      final employee = employees.firstWhere((e) => e['name'] == value);
      selectedEmployee = employee['uid'];
      selectedEmployeeName = value;
      showEmployeeError = false;
    }
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
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.context?.showAppSnackBar(
          message: "Location permission is required",
          backgroundColor: colorRedCalendar,
          textColor: colorWhite,
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Get.context?.showAppSnackBar(
        message: "Location permission denied permanently. Enable in settings.",
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
      return;
    }
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.context?.showAppSnackBar(
        message: "Please turn on location services",
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
      return;
    }

    final result = await Get.to(() => LocationPickerScreen(
      initialLatitude: selectedLatitude,
      initialLongitude: selectedLongitude,
    ));

    if (result != null && result is Map<String, dynamic>) {
      selectedLatitude = result['latitude'];
      selectedLongitude = result['longitude'];
      locationAddress =
      'Lat: ${selectedLatitude!.toStringAsFixed(6)}, Lng: ${selectedLongitude!.toStringAsFixed(6)}';
      update();
    }
  }

  Future<void> pickInitialFollowUp() async {
    DateTime now = DateTime.now();
    DateTime? date = await showDatePicker(
      context: Get.context!,
      initialDate: now,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (date != null) {
      bool isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      TimeOfDay initialTime = isToday
          ? TimeOfDay.fromDateTime(now.add(Duration(minutes: 1)))
          : TimeOfDay(hour: 9, minute: 0);

      TimeOfDay? time = await showTimePicker(
        context: Get.context!,
        initialTime: initialTime,
      );

      if (time != null) {
        initialFollowUp = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        if (initialFollowUp!.isBefore(now)) {
          Get.context?.showAppSnackBar(
            message: 'Please select a future date and time',
            backgroundColor: colorRedCalendar,
            textColor: colorWhite,
          );
          initialFollowUp = null;
          initialFollowUpController.clear();
          return;
        }

        initialFollowUpController.text =
            DateFormat('dd MMM yyyy, hh:mm a').format(initialFollowUp!);
        update();
      }
    }
  }

  Future<void> updateLeadDetails() async {
    String currentUserRole = ListConst.currentUserProfileData.type ?? '';
    showSourceError = selectedSource == null;
    showEmployeeError = selectedEmployee == null;
    update();

    if (editFormKey.currentState!.validate() && !showSourceError && !showEmployeeError) {
      isUpdating = true;
      update();

      try {
        Lead updatedLead = Lead(
          leadId: leadId,
          clientName: nameController.text.trim(),
          clientPhone: phoneController.text.trim(),
          clientEmail: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
          companyName: companyController.text.trim().isEmpty ? null : companyController.text.trim(),
          referralName: referralNameController.text.trim().isEmpty ? null : referralNameController.text.trim(),
          referralNumber: referralNumberController.text.trim().isEmpty ? null : referralNumberController.text.trim(),
          source: selectedSource,
          description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
          assignedTo: selectedEmployee ?? lead!.assignedTo,
          assignedToName: selectedEmployeeName ?? lead!.assignedToName,
          addedByName: lead!.addedByName,
          assignedToRole: 'employee',
          addedBy: lead!.addedBy,
          addedByEmail: lead!.addedByEmail,
          addedByRole: lead!.addedByRole,
          technician: selectedTechnician,
          latitude: selectedLatitude,
          longitude: selectedLongitude,
          locationAddress: locationAddress,
          address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
          createdAt: lead!.createdAt,
          updatedAt: Timestamp.now(),
          initialFollowUp: initialFollowUp != null ? Timestamp.fromDate(initialFollowUp!) : lead!.initialFollowUp,
          stage: lead!.stage,
          callStatus: lead!.callStatus,
        );

        await fireStore.collection('leads').doc(leadId).update(updatedLead.toMap());

        Get.context?.showAppSnackBar(
          message: 'Lead details updated successfully',
          backgroundColor: colorGreen,
          textColor: colorWhite,
        );

        isEditMode = false;
        await fetchLead();

        String role = ListConst.currentUserProfileData.type ?? '';
        if (role == 'employee' || role == 'admin') {
          try {
            Get.find<HomeController>().loadLeads();
          } catch (e) {
            print('HomeController not found: $e');
          }
        }
      } catch (e) {
        print("Error updating lead details: $e");
        Get.context?.showAppSnackBar(
          message: 'Failed to update lead details',
          backgroundColor: colorRedCalendar,
          textColor: colorWhite,
        );
      } finally {
        isUpdating = false;
        update();
      }
    } else {
      String? errorMessage;
      if (nameController.text.trim().isEmpty) {
        errorMessage = 'Client name is required';
      } else if (phoneController.text.trim().isEmpty) {
        errorMessage = 'Client number is required';
      } else if (phoneController.text.length != 10 || !RegExp(r'^\d{10}$').hasMatch(phoneController.text)) {
        errorMessage = 'Client number must be exactly 10 digits';
      } else if (emailController.text.isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text)) {
        errorMessage = 'Invalid email format';
      } else if (companyController.text.trim().isEmpty) {
        errorMessage = 'Company name is required';
      } else if (descriptionController.text.trim().isEmpty) {
        errorMessage = 'Description/Notes is required';
      } else if (referralNumberController.text.isNotEmpty && (referralNumberController.text.length != 10 || !RegExp(r'^\d{10}$').hasMatch(referralNumberController.text))) {
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
      }
    }
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


  Future<void> openDirectionsToLead(double destLat, double destLng) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.context?.showAppSnackBar(
            message: 'Location permission is required to show directions',
            backgroundColor: colorRedCalendar,
            textColor: colorWhite,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.context?.showAppSnackBar(
          message: 'Location permission denied. Please enable it in settings.',
          backgroundColor: colorRedCalendar,
          textColor: colorWhite,
        );
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.context?.showAppSnackBar(
          message: 'Please turn on location services',
          backgroundColor: colorRedCalendar,
          textColor: colorWhite,
        );
        return;
      }

      Get.context?.showAppSnackBar(
        message: 'Getting your location...',
        backgroundColor: colorMainTheme,
        textColor: colorWhite,
      );

      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      final String directionsUrl =
          'https://www.google.com/maps/dir/?api=1&origin=${currentPosition.latitude},${currentPosition.longitude}&destination=$destLat,$destLng&travelmode=driving';

      final Uri uri = Uri.parse(directionsUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.context?.showAppSnackBar(
          message: 'Could not open maps',
          backgroundColor: colorRedCalendar,
          textColor: colorWhite,
        );
      }
    } on TimeoutException catch (_) {
      Get.context?.showAppSnackBar(
        message: 'Location request timed out. Please try again.',
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
    } catch (e) {
      log("Error opening directions: $e");

    }
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

    try {
      // Clean phone number (remove spaces, dashes, etc.)
      String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

      final Uri url = Uri(scheme: 'tel', path: cleanPhone);

      // Check if the URL can be launched
      bool canLaunch = await canLaunchUrl(url);

      if (canLaunch) {
        // ✅ Add LaunchMode.externalApplication for better compatibility
        bool launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          showUpdateForm = true;
          update();
        } else {
          throw Exception('Failed to launch dialer');
        }
      } else {
        throw Exception('Cannot launch phone dialer');
      }
    } catch (e) {
      log("Error launching call: $e");
      Get.context?.showAppSnackBar(
        message: 'Could not launch call. Please check if you have a dialer app installed.',
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
    }
  }
  // void callLead() async {
  //   if (lead == null) return;
  //
  //   if (lead!.stage == 'completed' || lead!.stage == 'cancelled') {
  //     Get.context?.showAppSnackBar(
  //       message: 'Cannot call completed leads',
  //       backgroundColor: colorRedCalendar,
  //       textColor: colorWhite,
  //     );
  //     return;
  //   }
  //
  //   String? phone = lead!.clientPhone;
  //   if (phone.isEmpty) {
  //     Get.context?.showAppSnackBar(
  //       message: 'Phone number not available',
  //       backgroundColor: colorRedCalendar,
  //       textColor: colorWhite,
  //     );
  //     return;
  //   }
  //
  //   final Uri url = Uri(scheme: 'tel', path: phone);
  //   if (await canLaunchUrl(url)) {
  //     await launchUrl(url);
  //     showUpdateForm = true;
  //     update();
  //   } else {
  //     Get.context?.showAppSnackBar(
  //       message: 'Could not launch call',
  //       backgroundColor: colorRedCalendar,
  //       textColor: colorWhite,
  //     );
  //   }
  // }

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
    DateTime now = DateTime.now();
    DateTime? date = await showDatePicker(
      context: Get.context!,
      initialDate: now,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (date != null) {
      bool isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      TimeOfDay initialTime = isToday
          ? TimeOfDay.fromDateTime(now.add(Duration(minutes: 1)))
          : TimeOfDay(hour: 9, minute: 0);

      TimeOfDay? time = await showTimePicker(
        context: Get.context!,
        initialTime: initialTime,
      );

      if (time != null) {
        nextFollowUpDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        if (nextFollowUpDateTime!.isBefore(now)) {
          Get.context?.showAppSnackBar(
            message: 'Please select a future date and time',
            backgroundColor: colorRedCalendar,
            textColor: colorWhite,
          );
          nextFollowUpDateTime = null;
          return;
        }

        final formattedDateTime = DateFormat('dd MMM yyyy, hh:mm a').format(
            nextFollowUpDateTime!);
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
        if (role == 'employee' || role == 'admin') {
          try {
            Get.find<HomeController>().loadLeads();
          } catch (e) {
            print('HomeController not found: $e');
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
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    companyController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    referralNameController.dispose();
    referralNumberController.dispose();
    initialFollowUpController.dispose();
    super.onClose();
  }
}

