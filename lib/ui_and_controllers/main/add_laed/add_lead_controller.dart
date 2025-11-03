import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/model/lead_add_model.dart';
import 'package:lead_management/ui_and_controllers/main/home/home_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/location_picker_screen.dart';
import '../../../core/utils/push_notification_utils.dart';
import '../../auth/goggle_login/google_calendar_controller.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    String? goggleEventId,
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
        eventId: goggleEventId
      );

      await fireStore.collection('leads').doc(leadId).set(newLead.toMap());
      await _sendLeadAssignmentNotification(
        assignedToUserId: assignedToEmployee,
        assignedToName: assignedToName,
        leadClientName: clientName,
        addedByName: addedByName,
        leadId: leadId,
      );

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

  Future<void> _sendLeadAssignmentNotification({
    required String assignedToUserId,
    required String assignedToName,
    required String leadClientName,
    required String addedByName,
    required String leadId,
  }) async {
    try {
      DocumentSnapshot userDoc = await fireStore
          .collection('users')
          .doc(assignedToUserId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String? deviceToken = userData['fcmToken'];

        if (deviceToken != null && deviceToken.isNotEmpty) {
          String title = "New Lead Assigned";
          String body = "New lead assigned to you";

          bool notificationSent = await sendPushNotification(
            deviceToken: deviceToken,
            title: title,
            body: body,
            leadId: leadId,
          );
          if (notificationSent) {
            print('Notification sent successfully to $assignedToName');
          }
        }
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> submitForm() async {
    String currentUserRole = ListConst.currentUserProfileData.type ?? 'employee';

    showSourceError = selectedSource == null;
    showEmployeeError = currentUserRole == 'admin' ? selectedEmployee == null : false;
    update();

    log(
      'Form valid: ${formKey.currentState!.validate()}, Show Employee Error: $showEmployeeError, Show Source Error: $showSourceError',
    );

    formKey.currentState!.validate();

    String? errorMessage;

    if (nameController.text.trim().isEmpty) {
      errorMessage = 'Client name is required';
    } else if (clientPhoneController.text.trim().isEmpty) {
      errorMessage = 'Client number is required';
    } else if (clientPhoneController.text.length < 10) {
      errorMessage = 'Client number must be more than 9 digits';
    } else if (emailController.text.isNotEmpty &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(emailController.text)) {
      errorMessage = 'Invalid email format';
    } else if (descriptionController.text.trim().isEmpty) {
      errorMessage = 'Description/Notes is required';
    } else if (referralNumberController.text.isNotEmpty &&
        (referralNumberController.text.length < 10)) {
      errorMessage = 'Referral number must be more than 9 digits';
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

    String? googleEventId;

    try {
      final calendarController = Get.find<GoogleCalendarController>();

      if (calendarController.isLoggedIn) {
        Get.dialog(
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorWhite,
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

        googleEventId = await calendarController.addEvent(
          title: nameController.text.trim(),
          description: descriptionController.text.trim(),
          startTime: nextFollowUp ??DateTime.now().add(const Duration(minutes: 5)),
          endTime: nextFollowUp?.add(Duration(minutes: 5)) ?? DateTime.now().add(const Duration(days: 1)),
          employeeEmails: [selectedEmployeeEmail ?? ''],
        );

        Get.back();

        if (googleEventId == null) {
          Get.context?.showAppSnackBar(
            message: 'Event could not be added to Google Calendar',
            backgroundColor: colorRedCalendar,
            textColor: colorWhite,
          );
          return;
        }

        log('✅ Google Calendar event added successfully. Event ID: $googleEventId');
      } else {
        log('⚠️ Skipping Google Calendar (Not logged in)');
      }
    } catch (e) {
      log('💥 Failed to add Google Calendar event: $e');
      Get.context?.showAppSnackBar(
        message: 'Event could not be added to Google Calendar',
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
      return;
    }

    // Step 3️⃣ — Add lead to Firebase now
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: colorMainTheme),
              const SizedBox(height: 15),
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
      referralNumber: referralNumberController.text
          .trim()
          .isEmpty
          ? null
          : referralNumberController.text.trim(),
      nextFollowUp: nextFollowUp,
      goggleEventId: googleEventId
    );

    Get.back();

    if (success) {
      _clearForm();
      Get.back();
      Get.context?.showAppSnackBar(
        message: "Lead added successfully",
        backgroundColor: colorGreen,
        textColor: colorWhite,
      );

      log('🎯 Lead added successfully to Firebase with event ID: $googleEventId and mail is $selectedEmployeeEmail');

      // reload leads
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
      log('❌ Failed to add lead to Firebase.');
    }
  }

  void _clearForm() {
    nameController.clear();
    clientPhoneController.clear();
    emailController.clear();
    companyController.clear();
    descriptionController.clear();
    followUpController.clear();
    referralNameController.clear();
    referralNumberController.clear();
    addressController.clear();
    selectedSource = null;
    selectedEmployee = null;
    selectedEmployeeName = null;
    nextFollowUp = null;
    showEmployeeError = false;
    showSourceError = false;
    update();
  }

  Future<AccessCredentials> _getAccessToken() async {
    final serviceAccountPath = dotenv.env['PATH_TO_SECRET'];

    String serviceAccountJson = await rootBundle.loadString(
      serviceAccountPath!,
    );
    final serviceAccount = ServiceAccountCredentials.fromJson(
      jsonDecode(serviceAccountJson),
    );

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await clientViaServiceAccount(serviceAccount, scopes);
    return client.credentials;
  }
  Future<bool> sendPushNotification({
    required String deviceToken,
    required String title,
    required String body,
    String? leadId,
  }) async {
    if (deviceToken.isEmpty) return false;
    final credentials = await _getAccessToken();
    final accessToken = credentials.accessToken.data;
    final serviceAccountPath = dotenv.env['PATH_TO_SECRET'];
    final serviceAccountJson = await rootBundle.loadString(serviceAccountPath!);
    final projectId = jsonDecode(serviceAccountJson)['project_id'];

    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
    );

    final collapseId = 'lead_assign_${leadId ?? projectId}';
    final data = {
      'message': {
        'token': deviceToken,
        'notification': {'title': title, 'body': body},
        'data': {
          'type': 'LEAD_ASSIGNED',
          if (leadId != null) 'leadId': leadId,
        },
        'android': {
          'priority': 'HIGH',
          'collapse_key': collapseId,
          'notification': {
            'channel_id': channelId,
            'sound': 'default',
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'tag': collapseId,
          },
        },
        'apns': {
          'headers': {'apns-priority': '10', 'apns-collapse-id': collapseId},
          'payload': {
            'aps': {
              'alert': {'title': title, 'body': body},
              'sound': 'default',
              'category': 'FLUTTER_NOTIFICATION_CLICK'
            }
          }
        }
      }
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(data),
    );

    return response.statusCode == 200;
  }

  @override
  void onClose() {
    nameController.dispose();
    clientPhoneController.dispose();
    emailController.dispose();
    companyController.dispose();
    descriptionController.dispose();
    followUpController.dispose();
    referralNameController.dispose();
    referralNumberController.dispose();
    addressController.dispose();
    super.onClose();
  }
}