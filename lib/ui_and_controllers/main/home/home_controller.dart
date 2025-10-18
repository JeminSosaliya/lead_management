import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/core/utils/push_notification_utils.dart';
import 'package:lead_management/model/lead_add_model.dart';
import 'dart:async';

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

  StreamSubscription<QuerySnapshot>? _employeeSubscription;
  StreamSubscription<DocumentSnapshot>? _technicianSubscription;
  StreamSubscription<QuerySnapshot>? _createdLeadsSubscription;

  bool get isAdmin => ListConst.currentUserProfileData.type == 'admin';

  @override
  void onInit() {
    super.onInit();
    _printFCMToken();
    NotificationUtils().init();
    setupTechnicianTypesListener();
    if (isAdmin) setupEmployeeListener();
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

  void setupEmployeeListener() {
    log('Setting up real-time employee listener');
    _employeeSubscription = fireStore
        .collection('users')
        .where('type', whereIn: ['employee', 'technician'])
        .snapshots()
        .listen(
          (QuerySnapshot snapshot) {
            employees = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'uid': doc.id,
                'name': data['name'] ?? 'Unknown',
                'isActive': data['isActive'] ?? true,
                'type': data['type'] ?? 'employee',
              };
            }).toList();
            log('Employees updated: ${employees.length} users found');
            update();
          },
          onError: (error) {
            log(' Error listening to employees: $error');
          },
          cancelOnError: false,
        );
  }

  void setupTechnicianTypesListener() {
    try {
      isTechnicianListLoading = true;
      technicianListError = null;
      update();
      log('Setting up real-time technician types listener');
      _technicianSubscription = fireStore
          .collection('technicians')
          .doc('technician_list')
          .snapshots()
          .listen(
            (DocumentSnapshot doc) {
              if (doc.exists) {
                List<dynamic> types = doc.get('technicianList') ?? [];
                technicianTypes = types.map((e) => e.toString()).toList();
                log('Technician types updated: $technicianTypes');
                technicianListError = null;
              } else {
                log('Technician list document does not exist');
                technicianTypes = [];
                technicianListError = 'Technician list not found';
              }
              isTechnicianListLoading = false;
              update();
            },
            onError: (error) {
              log('Error listening to technician types: $error');
              technicianTypes = [];
              technicianListError = 'Failed to load technicians: $error';
              isTechnicianListLoading = false;
              update();
            },
            cancelOnError: false,
          );
    } catch (e) {
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

    if (isAdmin) {
      fireStore
          .collection('leads')
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
            leads = snapshot.docs
                .map((doc) => Lead.fromMap(doc.data() as Map<String, dynamic>))
                .toList();

            leads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

            log('✅ Leads updated (Admin): ${leads.length} leads fetched');
            isLoading = false;
            update();
          });
    } else {
      List<Lead> assignedLeads = [];
      List<Lead> createdLeads = [];

      fireStore
          .collection('leads')
          .where('assignedTo', isEqualTo: currentUserId)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
            assignedLeads = snapshot.docs
                .map((doc) => Lead.fromMap(doc.data() as Map<String, dynamic>))
                .toList();

            log('✅ Assigned leads: ${assignedLeads.length}');
            _mergeEmployeeLeads(assignedLeads, createdLeads);
          });

      _createdLeadsSubscription = fireStore
          .collection('leads')
          .where('addedBy', isEqualTo: currentUserId)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
            createdLeads = snapshot.docs
                .map((doc) => Lead.fromMap(doc.data() as Map<String, dynamic>))
                .toList();

            log('✅ Created leads: ${createdLeads.length}');
            _mergeEmployeeLeads(assignedLeads, createdLeads);
          });
    }
  }

  void _mergeEmployeeLeads(List<Lead> assignedLeads, List<Lead> createdLeads) {
    // Use a Map to automatically handle duplicates (same leadId)
    final Map<String, Lead> leadsMap = {};

    // Add assigned leads
    for (var lead in assignedLeads) {
      leadsMap[lead.leadId] = lead;
    }

    // Add created leads (duplicates automatically handled)
    for (var lead in createdLeads) {
      leadsMap[lead.leadId] = lead;
    }

    // Convert back to list and sort
    leads = leadsMap.values.toList();
    leads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    log('✅ Total unique leads (Employee): ${leads.length}');
    isLoading = false;
    update();
  }

  Future<void> loadLeads() async {
    log('Loading leads');
    isLoading = true;
    update();

    try {
      String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

      if (isAdmin) {
        QuerySnapshot querySnapshot = await fireStore.collection('leads').get();
        leads = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Lead.fromMap(data);
        }).toList();
      } else {
        // ✅ Employee sees BOTH assigned AND created leads
        final assignedSnapshot = await fireStore
            .collection('leads')
            .where('assignedTo', isEqualTo: currentUserId)
            .get();

        final createdSnapshot = await fireStore
            .collection('leads')
            .where('addedBy', isEqualTo: currentUserId)
            .get();

        // Merge and deduplicate using Map
        final Map<String, Lead> leadsMap = {};

        for (var doc in assignedSnapshot.docs) {
          final lead = Lead.fromMap(doc.data());
          leadsMap[lead.leadId] = lead;
        }

        for (var doc in createdSnapshot.docs) {
          final lead = Lead.fromMap(doc.data());
          leadsMap[lead.leadId] = lead;
        }

        leads = leadsMap.values.toList();
      }

      leads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

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
    if ((lead.followUpLeads?.isNotEmpty??false) &&lead.followUpLeads?.last.nextFollowUp != null) {
      DateTime next = lead.followUpLeads!.last.nextFollowUp!.toDate();
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
    _employeeSubscription?.cancel();
    _technicianSubscription?.cancel();
    _createdLeadsSubscription?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
