import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/core/utils/push_notification_utils.dart';
import 'package:lead_management/model/lead_add_model.dart';

class HomeController extends GetxController {
  List<Lead> leads = [];
  bool isLoading = false;
  String currentTab = 'all';
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  bool isSearching = false;
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  List<String> technicianTypes = [];
  String? selectedTechnician;
  bool filtersApplied = false;
  bool isTechnicianListLoading = false;
  String? technicianListError;

  List<Map<String, dynamic>> employees = [];
  String? selectedEmployeeId;
  String? selectedEmployeeName;

  bool get isAdmin => ListConst.currentUserProfileData.type == 'admin';

  @override
  void onInit() {
    super.onInit();
    _printFCMToken();
    NotificationUtils().init();
    fetchTechnicianTypes();
    if (isAdmin) fetchEmployees();
    setupRealTimeListener();
    searchController.addListener(() {
      onSearchChanged(searchController.text);
    });
  }

  Future<void> _printFCMToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        log("========================================");
        log("FCM TOKEN (Home Screen - Auto Login):");
        log(fcmToken);
        log("========================================");
        print("FCM TOKEN: $fcmToken");
      } else {
        log("FCM Token is null");
      }
    } catch (e) {
      log("Error getting FCM token: $e");
    }
  }

  Future<void> fetchEmployees() async {
    try {
      QuerySnapshot snapshot = await fireStore
          .collection('users')
          .where('type', isEqualTo: 'employee')
          .get();

      employees = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          'name': data['name'] ?? 'Unknown',
          'isActive': data['isActive'] ?? true,
        };
      }).toList();
      update();
    } catch (e) {
      log("Error fetching employees: $e");
    }
  }

  Future<void> fetchTechnicianTypes() async {
    try {
      isTechnicianListLoading = true;
      technicianListError = null;
      update();
      log('Fetching technician types from Firestore');
      DocumentSnapshot doc = await fireStore
          .collection('technicians')
          .doc('technician_list')
          .get();

      if (doc.exists) {
        List<dynamic> types = doc.get('technicianList') ?? [];
        technicianTypes = types.map((e) => e.toString()).toList();
        log('Technician types fetched successfully: $technicianTypes');
      } else {
        log('Technician list document does not exist in Firestore');
        technicianTypes = [];
        technicianListError = 'Technician list not found';
      }
    } catch (e) {
      log("Error fetching technician types: $e");
      technicianTypes = [];
      technicianListError = 'Failed to load technicians: $e';
    } finally {
      isTechnicianListLoading = false;
      update();
    }
  }

  void setSelectedTechnician(String? value) {
    selectedTechnician = value;
    log('Selected technician: $value');
    update();
  }

  void setSelectedEmployee(String? uid, String? name) {
    selectedEmployeeId = uid;
    selectedEmployeeName = name;
    update();
  }

  void applyFilters() {
    filtersApplied =
        (isAdmin && selectedEmployeeId != null) || selectedTechnician != null;
    log(
      'Filters applied: $filtersApplied, Selected employee: $selectedEmployeeId, Selected technician: $selectedTechnician',
    );
    update();
  }

  void clearFilters() {
    selectedEmployeeId = null;
    selectedEmployeeName = null;
    selectedTechnician = null;
    filtersApplied = false;
    log('Filters cleared');
    update();
  }

  void setupRealTimeListener() {
    log('Setting up real-time listener for leads');
    String currentUserId = ListConst.currentUserProfileData.uid.toString();
    Query query;

    if (isAdmin) {
      query = fireStore
          .collection('leads')
          .orderBy('updatedAt', descending: true);
    } else {
      query = fireStore
          .collection('leads')
          .where('assignedTo', isEqualTo: currentUserId);
    }

    query.snapshots().listen((QuerySnapshot snapshot) {
      List<Lead> tempLeads = snapshot.docs
          .map((doc) => Lead.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      tempLeads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      leads = tempLeads;
      log('Leads updated: ${leads.length} leads fetched');
      isLoading = false;
      update();
    });
  }

  Future<void> loadLeads() async {
    log('Loading leads');
    isLoading = true;
    update();

    try {
      String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      QuerySnapshot querySnapshot;

      if (isAdmin) {
        querySnapshot = await fireStore.collection('leads').get();
      } else {
        querySnapshot = await fireStore
            .collection('leads')
            .where('assignedTo', isEqualTo: currentUserId)
            .get();
      }

      List<Lead> tempLeads = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Lead.fromMap(data);
      }).toList();

      tempLeads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      leads = tempLeads;
      log('Leads loaded: ${leads.length} leads');
    } catch (e) {
      log("Error loading leads: $e");
    }

    isLoading = false;
    update();
  }

  bool hasFollowUpToday(Lead lead) {
    DateTime today = DateTime.now();
    DateTime todayStart = DateTime(today.year, today.month, today.day);
    DateTime todayEnd = todayStart.add(const Duration(days: 1));

    bool hasFollowUpToday = false;
    if (lead.initialFollowUp != null) {
      DateTime initial = lead.initialFollowUp!.toDate();
      if (initial.isAfter(todayStart) && initial.isBefore(todayEnd)) {
        hasFollowUpToday = true;
      }
    }
    if (lead.nextFollowUp != null) {
      DateTime next = lead.nextFollowUp!.toDate();
      if (next.isAfter(todayStart) && next.isBefore(todayEnd)) {
        hasFollowUpToday = true;
      }
    }
    return hasFollowUpToday;
  }

  void changeTab(String tab) {
    currentTab = tab;
    log('Tab changed to: $tab');
    update();
  }

  void startSearch() {
    isSearching = true;
    log('Search started');
    update();
  }

  void stopSearch() {
    isSearching = false;
    searchQuery = '';
    searchController.clear();
    log('Search stopped');
    update();
  }

  void onSearchChanged(String query) {
    searchQuery = query.trim().toLowerCase();
    log('Search query changed: $searchQuery');
    update();
  }

  List<Lead> getFilteredLeads(String stage) {
    List<Lead> filteredLeads;
    if (stage == 'today') {
      filteredLeads = leads.where((lead) => hasFollowUpToday(lead)).toList();
    } else if (stage == 'all') {
      filteredLeads = leads;
    } else {
      filteredLeads = leads.where((lead) => lead.stage == stage).toList();
    }

    if (isAdmin && selectedEmployeeId != null) {
      filteredLeads = filteredLeads
          .where((lead) => lead.assignedTo == selectedEmployeeId)
          .toList();
    }
    if (selectedTechnician != null) {
      filteredLeads = filteredLeads
          .where((lead) => lead.technician == selectedTechnician)
          .toList();
    }

    if (isSearching && searchQuery.isNotEmpty) {
      filteredLeads = _filterLeadsBySearch(filteredLeads, searchQuery);
    }

    log('Filtered leads for stage $stage: ${filteredLeads.length} leads');
    return filteredLeads;
  }

  List<Lead> _filterLeadsBySearch(List<Lead> leads, String query) {
    if (query.isEmpty) return leads;
    query = query.toLowerCase();
    return leads.where((lead) {
      return lead.clientName.toLowerCase().contains(query) ||
          lead.clientPhone.contains(query) ||
          lead.assignedToName.toLowerCase().contains(query) ||
          lead.addedByName.toLowerCase().contains(query);
    }).toList();
  }

  Future<bool> updateLeadStatus(
    String leadId,
    String stage,
    String callStatus,
  ) async {
    try {
      await fireStore.collection('leads').doc(leadId).update({
        'stage': stage,
        'callStatus': callStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      log(
        'Lead status updated: $leadId, stage: $stage, callStatus: $callStatus',
      );
      return true;
    } catch (e) {
      log("Error updating lead: $e");
      return false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
