import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/model/lead_add_model.dart';
import 'package:lead_management/ui_and_controllers/main/home/home_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/location_picker_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/push_notification_utils.dart';
import '../../auth/goggle_login/google_calendar_controller.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';

class LeadDetailsController extends GetxController {
  final String leadId;
  Lead? lead;
  bool isLoading = true;
  final _isUpdating = false.obs;

  bool get isUpdating => _isUpdating.value;
  bool showUpdateForm = false;
  bool showResponseError = false;
  bool showStageError = false;
  bool isEditMode = false;
  bool showEmployeeError = false;
  bool showSourceError = false;
  bool isDetailsExpanded = false;
  final TextEditingController chatController = TextEditingController();
  final ScrollController chatScrollController = ScrollController();
  bool isSendingMessage = false;
  final formKey = GlobalKey<FormState>();
  final editFormKey = GlobalKey<FormState>();
  final noteController = TextEditingController();
  final followUpController = TextEditingController();
  DateTime? nextFollowUpDateTime;
  String selectedResponse = '';
  String selectedStage = '';
  String selectedStageDisplay = '';
  String selectedEmployeeEmail = '';
  String employeeOldEmail = '';
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
  final List<String> stageOptions = ['In Progress', 'Completed', 'Cancelled'];
  List<Map<String, dynamic>> employees = [];
  List<String> technicianTypes = [];
  List<String> sources = ['Website', 'Phone', 'Referral', 'Walk-in', 'Other'];
  String? selectedEmployee;
  String? selectedEmployeeName;
  String? selectedEmployeeType;
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
  TextEditingController altPhoneController = TextEditingController();

  LeadDetailsController({required this.leadId});

  bool get isAdmin => ListConst.currentUserProfileData.type == 'admin';

  String get currentUserId =>
      ListConst.currentUserProfileData.uid?.toString() ?? '';

  String get currentUserName =>
      ListConst.currentUserProfileData.name?.toString() ?? '';

  bool get canChat {
    if (lead == null) return false;
    return currentUserId == (lead!.addedBy) ||
        currentUserId == (lead!.assignedTo);
  }

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

      QuerySnapshot employeesSnap = await fireStore
          .collection('users')
          .where('type', isEqualTo: 'employee')
          .where('isActive', isEqualTo: true)
          .get();

      QuerySnapshot adminsSnap = await fireStore
          .collection('users')
          .where('type', isEqualTo: 'admin')
          .where('isActive', isEqualTo: true)
          .get();

      employees = [
        ...employeesSnap.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'uid': doc.id,
            'name': data['name'] ?? '',
            'type': 'employee',
            'email': data['email'] ?? '',
          };
        }),
        ...adminsSnap.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'uid': doc.id,
            'name': data['name'] ?? '',
            'type': 'admin',
            'email': data['email'] ?? '',
          };
        }),
      ];

      if (currentUserRole == 'employee') {
        employees = employees.where((e) => e['uid'] != currentUserId).toList();
      }

      update();
    } catch (e) {
      print("Error fetching employees and admins: $e");
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
      nameController.text = lead?.clientName ?? '';
      phoneController.text = lead?.clientPhone ?? '';
      emailController.text = lead?.clientEmail ?? '';
      companyController.text = lead?.companyName ?? '';
      descriptionController.text = lead?.description ?? '';
      addressController.text = lead?.address ?? '';
      referralNameController.text = lead?.referralName ?? '';
      referralNumberController.text = lead?.referralNumber ?? '';
      altPhoneController.text = lead?.clientAltPhone ?? '';
      selectedSource = lead?.source;
      selectedTechnician = lead?.technician;
      selectedEmployeeType = lead?.assignedToRole;
      selectedLatitude = lead?.latitude;
      selectedLongitude = lead?.longitude;
      locationAddress = lead?.locationAddress;

      if (lead?.initialFollowUp != null) {
        initialFollowUp = lead!.initialFollowUp!.toDate();
        initialFollowUpController.text = DateFormat(
          'dd MMM yyyy, hh:mm a',
        ).format(initialFollowUp!);
      }
      selectedEmployee = lead?.assignedTo;
      selectedEmployeeName = lead?.assignedToName;
      final employee = employees.firstWhere(
        (e) => e['name'] == selectedEmployeeName,
        orElse: () => {},
      );
      employeeOldEmail = employee['email']?.toString() ?? '';
      selectedEmployeeEmail = employee['email']?.toString() ?? '';
    }
    update();
  }

  void setSelectedEmployee(String? value) {
    log('Employee list: $employees');

    if (value != null && value.trim().isNotEmpty) {
      final employee = employees.firstWhere(
        (e) => e['name'] == value,
        orElse: () => {},
      );

      selectedEmployee = employee['uid']?.toString() ?? '';
      selectedEmployeeEmail = employee['email']?.toString() ?? '';
      selectedEmployeeName = value;
      selectedEmployeeType = employee['type']?.toString() ?? '';

      log('✅ Selected Employee:');
      log('   Name: $selectedEmployeeName');
      log('   Email: $selectedEmployeeEmail');
      log('   UID: $selectedEmployee');
      log('   Type: $selectedEmployeeType');

      showEmployeeError = false;
    } else {
      selectedEmployee = '';
      selectedEmployeeEmail = '';
      selectedEmployeeName = '';
      selectedEmployeeType = '';
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
      bool isToday =
          date.year == now.year &&
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

        initialFollowUpController.text = DateFormat(
          'dd MMM yyyy, hh:mm a',
        ).format(initialFollowUp!);
        update();
      }
    }
  }

  Future<void> updateLeadDetails() async {
    final calendarController = Get.find<GoogleCalendarController>();

    if (!(editFormKey.currentState?.validate() ?? false) ||
        showSourceError ||
        showEmployeeError) {
      _showValidationError();
      return;
    }

    _isUpdating.value = true;
    update();

    try {
      Lead updatedLead = Lead(
        leadId: leadId,
        followUpLeads: lead!.followUpLeads,
        clientName: nameController.text.trim(),
        clientPhone: phoneController.text.trim(),
        clientEmail: emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
        companyName: companyController.text.trim().isEmpty
            ? null
            : companyController.text.trim(),
        referralName: referralNameController.text.trim().isEmpty
            ? null
            : referralNameController.text.trim(),
        referralNumber: referralNumberController.text.trim().isEmpty
            ? null
            : referralNumberController.text.trim(),
        source: selectedSource,
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        assignedTo: selectedEmployee ?? lead!.assignedTo,
        assignedToName: selectedEmployeeName ?? lead!.assignedToName,
        addedByName: lead!.addedByName,
        assignedToRole: selectedEmployeeType ?? lead!.assignedToRole,
        addedBy: lead!.addedBy,
        addedByEmail: lead!.addedByEmail,
        addedByRole: lead!.addedByRole,
        technician: selectedTechnician,
        latitude: selectedLatitude,
        longitude: selectedLongitude,
        locationAddress: locationAddress,
        address: addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        clientAltPhone: altPhoneController.text.trim().isEmpty
            ? null
            : altPhoneController.text.trim(),
        createdAt: lead!.createdAt,
        updatedAt: Timestamp.now(),
        initialFollowUp: initialFollowUp != null
            ? Timestamp.fromDate(initialFollowUp!)
            : lead!.initialFollowUp,
        stage: lead!.stage,
        callStatus: lead!.callStatus,
        eventId: lead!.eventId,
      );

      if (lead!.eventId != null) {
        try {
          final updatedEventId = await calendarController.updateOrCreateEvent(
            eventId: lead!.eventId!,
            title: "Lead: ${updatedLead.clientName}",
            description: updatedLead.description ?? lead!.description ?? '',
            startTime: initialFollowUp ?? DateTime.now(),
            endTime:
                initialFollowUp?.add(const Duration(minutes: 5)) ??
                DateTime.now().add(const Duration(days: 1)),
            oldEmployeeEmails: [employeeOldEmail],
            newEmployeeEmails: [selectedEmployeeEmail],
          );

          if (updatedEventId != null) {
            updatedLead.eventId = updatedEventId;
            log(
              '✅ Event ID updated: $updatedEventId oldEmployee $employeeOldEmail and newEmployee $selectedEmployeeEmail',
            );
          }
        } catch (e) {
          log(
            "⚠️ Google Calendar update failed: $e, email: $selectedEmployeeEmail",
          );
        }
      }

      await fireStore
          .collection('leads')
          .doc(leadId)
          .update(updatedLead.toMap());

      await _createOrUpdateReminder(
        assignedToUserId: selectedEmployee ?? lead!.assignedTo,
        assignedToName: selectedEmployeeName ?? lead!.assignedToName,
        clientName: updatedLead.clientName,
        description: updatedLead.description ?? '',
        followUpTime: initialFollowUp,
        isUpdate: true,
      );

      Get.context?.showAppSnackBar(
        message: 'Lead details updated successfully',
        backgroundColor: colorGreen,
        textColor: colorWhite,
      );
      await _notifyLeadUpdated(updatedByName: currentUserName);

      isEditMode = false;
      await fetchLead();

      final role = ListConst.currentUserProfileData.type ?? '';
      if (role == 'employee' || role == 'admin') {
        try {
          Get.find<HomeController>().loadLeads();
        } catch (e) {
          log('⚠️ HomeController not found: $e');
        }
      }
    } catch (e) {
      log("💥 Error updating lead details: $e");
    } finally {
      _isUpdating.value = false;
      update();
    }
  }

  Future<void> _createOrUpdateReminder({
    required String assignedToUserId,
    required String assignedToName,
    required String clientName,
    required String description,
    required DateTime? followUpTime,
    String? content, // For call note updates
    bool isUpdate = false,
  }) async {
    try {
      if (followUpTime == null && content == null) {
        log(
          '⚠️ No follow-up time or content provided, skipping reminder update',
        );
        return;
      }

      // Fetch assigned user's FCM token
      DocumentSnapshot userDoc = await fireStore
          .collection('users')
          .doc(assignedToUserId)
          .get();

      if (!userDoc.exists) {
        log('⚠️ User not found for reminder: $assignedToUserId');
        return;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String? fcmToken = userData['fcmToken'] as String?;

      if (fcmToken == null || fcmToken.isEmpty) {
        log('⚠️ No FCM token found for user: $assignedToName');
        fcmToken = '';
      }

      // Query for existing reminder by leadId
      QuerySnapshot reminderQuery = await fireStore
          .collection('reminder')
          .where('leadId', isEqualTo: leadId)
          .limit(1)
          .get();

      Map<String, dynamic> reminderData = {
        'name': assignedToName,
        'id': assignedToUserId,
        'fcmToken': fcmToken,
        'title': clientName,
        'type': 'reminder',
        'isSent': false,
        'leadId': leadId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update time if provided
      if (followUpTime != null) {
        reminderData['time'] = Timestamp.fromDate(followUpTime);
      }

      // Update content (description or call note)
      if (content != null && content.isNotEmpty) {
        reminderData['content'] = content;
      } else if (description.isNotEmpty) {
        reminderData['content'] = description;
      }

      if (reminderQuery.docs.isNotEmpty) {
        // Update existing reminder
        await fireStore
            .collection('reminder')
            .doc(reminderQuery.docs.first.id)
            .update(reminderData);
        log('✅ Reminder updated for lead: $leadId');
      } else {
        // Create new reminder if it doesn't exist
        reminderData['createdAt'] = FieldValue.serverTimestamp();
        if (followUpTime != null) {
          reminderData['time'] = Timestamp.fromDate(followUpTime);
        }
        await fireStore.collection('reminder').add(reminderData);
        log('✅ Reminder created for lead: $leadId');
      }
    } catch (e) {
      log('❌ Error creating/updating reminder: $e');
      // Don't throw - reminder failure shouldn't block lead update
    }
  }

  void _showValidationError() {
    String? errorMessage;

    if (nameController.text.trim().isEmpty) {
      errorMessage = 'Client name is required';
    } else if (phoneController.text.trim().isEmpty) {
      errorMessage = 'Client number is required';
    } else if (emailController.text.isNotEmpty &&
        !RegExp(
          r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(emailController.text)) {
      errorMessage = 'Invalid email format';
    } else if (descriptionController.text.trim().isEmpty) {
      errorMessage = 'Description/Notes is required';
    } else if (referralNumberController.text.isNotEmpty) {
      errorMessage = 'Referral number must be more than 9 digits';
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
      } else {
        Get.context?.showAppSnackBar(
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

  // ===== Chat APIs =====
  Stream<QuerySnapshot<Map<String, dynamic>>> messageStream() {
    return fireStore
        .collection('leads')
        .doc(leadId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<void> sendMessage() async {
    if (_isDisposed) return;
    final text = chatController.text.trim();
    if (text.isEmpty || !canChat) return;
    isSendingMessage = true;
    update();
    try {
      await fireStore
          .collection('leads')
          .doc(leadId)
          .collection('messages')
          .add({
            'text': text,
            'senderId': currentUserId,
            'senderName': currentUserName,
            'createdAt': FieldValue.serverTimestamp(),
          });
      chatController.clear();

      // Notify both participants (addedBy and assignedTo), excluding sender
      await _notifyChatParticipants(text);

      await Future.delayed(const Duration(milliseconds: 50));
      if (chatScrollController.hasClients) {
        chatScrollController.animateTo(
          chatScrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      log('Error sending message: $e');
      Get.context?.showAppSnackBar(
        message: 'Failed to send message',
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
    } finally {
      if (!_isDisposed) {
        isSendingMessage = false;
        update();
      }
    }
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

    log('📞 Raw CALL NUMBER: $phone');

    try {
      // 🔹 Clean phone number (remove spaces, dashes, parentheses, etc.)
      String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

      // 🔹 Remove country code if present
      if (cleanPhone.startsWith('+91') && cleanPhone.length == 13) {
        cleanPhone = cleanPhone.substring(3);
      } else if (cleanPhone.startsWith('91') && cleanPhone.length == 12) {
        cleanPhone = cleanPhone.substring(2);
      }

      log('📞 Cleaned CALL NUMBER: $cleanPhone');

      // 🔹 Validate final number length
      if (cleanPhone.length != 10 ||
          !RegExp(r'^\d{10}$').hasMatch(cleanPhone)) {
        Get.context?.showAppSnackBar(
          message: 'Invalid phone number format',
          backgroundColor: colorRedCalendar,
          textColor: colorWhite,
        );
        return;
      }

      final Uri url = Uri(scheme: 'tel', path: cleanPhone);

      bool canLaunch = await canLaunchUrl(url);

      if (canLaunch) {
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
      log("❌ Error launching call: $e");
      Get.context?.showAppSnackBar(
        message: 'Could not launch call.',
        backgroundColor: colorRedCalendar,
        textColor: colorWhite,
      );
    }
  }

  void openWhatsApp(String phone) async {
    try {
      String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

      cleanPhone = cleanPhone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

      if (!cleanPhone.startsWith('+')) {
        if (cleanPhone.startsWith('0')) {
          cleanPhone = cleanPhone.substring(1);
        }
        cleanPhone = '+91$cleanPhone';
      }

      if (cleanPhone.startsWith('91') && cleanPhone.length == 12) {
        cleanPhone = '+$cleanPhone';
      }

      final phoneRegex = RegExp(r'^\+\d{10,15}$');
      if (!phoneRegex.hasMatch(cleanPhone)) {
        Get.context?.showAppSnackBar(
          message: 'Invalid phone number format',
          backgroundColor: colorRedCalendar,
          textColor: colorWhite,
        );
        log('Invalid phone format: $cleanPhone');
        return;
      }

      String phoneForUrl = cleanPhone.replaceFirst('+', '');
      final Uri url = Uri.parse('https://wa.me/$phoneForUrl');

      log('Opening WhatsApp with phone: $cleanPhone, URL: ${url.toString()}');
      try {
        final launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );

        if (!launched) {
          throw Exception('Failed to launch WhatsApp');
        }
      } catch (e) {
        log('External launch failed, trying platform default: $e');
        try {
          await launchUrl(url, mode: LaunchMode.platformDefault);
        } catch (e2) {
          log('Platform default failed, trying inAppWebView: $e2');
          try {
            await launchUrl(url, mode: LaunchMode.inAppWebView);
          } catch (e3) {
            throw Exception('All launch modes failed: $e3');
          }
        }
      }
    } catch (e) {
      log('Error opening WhatsApp: $e');
      Get.context?.showAppSnackBar(
        message:
            'Could not open WhatsApp. Please make sure WhatsApp is installed.',
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
      bool isToday =
          date.year == now.year &&
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

        final formattedDateTime = DateFormat(
          'dd MMM yyyy, hh:mm a',
        ).format(nextFollowUpDateTime!);
        followUpController.text = formattedDateTime;
        update();
      }
    }
  }

  Future<void> updateLead() async {
    /////
    if (lead == null ||
        lead!.stage == 'completed' ||
        lead!.stage == 'cancelled') {
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

    if (formKey.currentState!.validate() &&
        !showResponseError &&
        !showStageError) {
      _isUpdating.value = true;
      update();

      String newCallStatus = selectedResponse.toLowerCase().replaceAll(' ', '');
      String newStage = selectedStage;
      List<FollowUpLead> updatedList = lead?.followUpLeads ?? [];
      updatedList.add(
        FollowUpLead(
          callNote: noteController.text.trim(),
          nextFollowUp: nextFollowUpDateTime != null
              ? Timestamp.fromDate(nextFollowUpDateTime!)
              : null,
        ),
      );
      Map<String, dynamic> updates = {
        'stage': newStage,
        'callStatus': newCallStatus,
        'followUpLeads': updatedList.map((e) => e.toMap()).toList(),
        // 'callNote': noteController.text.trim(),
        // 'nextFollowUp': nextFollowUpDateTime != null
        //     ? Timestamp.fromDate(nextFollowUpDateTime!)
        //     : null,
        'updatedAt': Timestamp.now(),
        'lastFollowUpDate': nextFollowUpDateTime != null
            ? Timestamp.fromDate(nextFollowUpDateTime!)
            : null,
      };

      try {
        await fireStore.collection('leads').doc(leadId).update(updates);
        await _createOrUpdateReminder(
          assignedToUserId: lead!.assignedTo,
          assignedToName: lead!.assignedToName,
          clientName: lead!.clientName,
          description: lead!.description ?? '',
          followUpTime: nextFollowUpDateTime,
          content: noteController.text.trim(),
          // Call note as content
          isUpdate: true,
        );
        Get.context?.showAppSnackBar(
          message: 'Lead updated successfully',
          backgroundColor: colorGreen,
          textColor: colorWhite,
        );
        await _notifyLeadUpdated(updatedByName: currentUserName); // NEW
        showUpdateForm = false;
        noteController.clear();
        followUpController.clear();
        nextFollowUpDateTime = null;
        selectedResponse = '';
        selectedStage = '';
        selectedStageDisplay = '';
        await fetchLead(); // Fetch updated lead data
        update(); // Update UI to reflect changes

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
        _isUpdating.value = false;
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

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.context?.showAppSnackBar(
      message: 'Phone number copied to clipboard',
      backgroundColor: colorGreen,
      textColor: colorWhite,
    );
  }

  // Expand/Collapse method
  void toggleDetails() {
    isDetailsExpanded = !isDetailsExpanded;
    update();
  }

  @override
  void onClose() {
    // Only dispose if controllers are still attached
    if (noteController.hasListeners) {
      noteController.dispose();
    }
    if (followUpController.hasListeners) {
      followUpController.dispose();
    }
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    companyController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    referralNameController.dispose();
    referralNumberController.dispose();
    initialFollowUpController.dispose();
    altPhoneController.dispose();
    chatController.dispose();
    // Only dispose scroll controller if it's attached
    if (chatScrollController.hasClients) {
      chatScrollController.dispose();
    }
    super.onClose();
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

  Future<bool> _sendPushNotification({
    required String deviceToken,
    required String title,
    required String body,
    String dataType = 'LEAD_MESSAGE', // default keeps chat behavior
    Map<String, String>? extraData, // optional extra key/values
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

    final collapseId = 'lead_$dataType\_$leadId';
    final Map<String, String> data = {
      'type': dataType,
      'leadId': leadId,
      ...?extraData,
    };

    final payload = {
      'message': {
        'token': deviceToken,
        'notification': {'title': title, 'body': body},
        'data': data,
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
              'category': 'FLUTTER_NOTIFICATION_CLICK',
            },
          },
        },
      },
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(payload),
    );

    return response.statusCode == 200;
  }

  Future<void> _notifyChatParticipants(String messageText) async {
    try {
      if (lead == null) return;

      final String senderName = currentUserName;
      final String addedById = lead!.addedBy;
      final String assignedToId = lead!.assignedTo;

      final Set<String> recipients = {addedById, assignedToId};
      recipients.removeWhere(
        (id) => id == currentUserId,
      ); // don't notify sender

      for (final userId in recipients) {
        final doc = await fireStore.collection('users').doc(userId).get();
        if (!doc.exists) continue;

        final data = doc.data() as Map<String, dynamic>;
        final String? deviceToken = data['fcmToken'];
        if (deviceToken == null || deviceToken.isEmpty) continue;

        final title = 'New message on lead ${lead!.clientName}';
        final body = '$senderName: $messageText';

        await _sendPushNotification(
          deviceToken: deviceToken,
          title: title,
          body: body,
          dataType: 'LEAD_MESSAGE',
        );
      }
    } catch (e) {
      log('Error sending chat notifications: $e');
    }
  }

  /*  Future<void> _notifyLeadUpdated({required String updatedByName}) async {
    try {
      if (lead == null) return;

      final recipients = <String>{lead!.addedBy, lead!.assignedTo}
        ..remove(currentUserId);

      for (final userId in recipients) {
        final doc = await fireStore.collection('users').doc(userId).get();
        if (!doc.exists) continue;
        final data = doc.data() as Map<String, dynamic>;
        final token = (data['fcmToken'] as String?) ?? '';
        if (token.isEmpty) continue;

        final title = 'Lead updated';
        final body = '$updatedByName updated lead: ${lead!.clientName}';

        await _sendPushNotification(
          deviceToken: token,
          title: title,
          body: body,
          dataType: 'LEAD_UPDATED',
          extraData: {
            'updatedBy': updatedByName,
          },
        );
      }
    } catch (e) {
      log('Error sending lead update notifications: $e');
    }
  }*/
  Future<void> _notifyLeadUpdated({required String updatedByName}) async {
    try {
      if (lead == null) return;

      final recipients = <String>{lead!.addedBy, lead!.assignedTo}
        ..remove(currentUserId); // don't notify the editor

      for (final userId in recipients) {
        final doc = await fireStore.collection('users').doc(userId).get();
        if (!doc.exists) continue;

        final data = doc.data() as Map<String, dynamic>;
        final String? token = data['fcmToken'];
        if (token == null || token.isEmpty) continue;

        final title = 'Lead updated';
        final body = '$updatedByName updated lead: ${lead!.clientName}';

        // This already includes leadId in the payload, so tapping routes correctly
        await _sendPushNotification(
          deviceToken: token,
          title: title,
          body: body,
        );
      }
    } catch (e) {
      log('Error sending lead update notifications: $e');
    }
  }

  // Add this helper method to check if controller is disposed
  bool get _isDisposed => !Get.isRegistered<LeadDetailsController>(tag: leadId);
}
