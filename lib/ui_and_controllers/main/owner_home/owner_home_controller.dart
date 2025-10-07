import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lead_management/model/lead_add_model.dart';

class OwnerHomeController extends GetxController {
  List<Lead> allLeads = [];
  bool isLoading = false;
  String currentTab = 'all';
  bool isSearching = false;
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    setupRealTimeListener();
    searchController.addListener(() {
      onSearchChanged(searchController.text);
    });
  }

  void setupRealTimeListener() {
    log('Setting up real-time listener for all leads');
    fireStore
        .collection('leads')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
          allLeads = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Lead.fromMap(data);
          }).toList();
          update();
        });
  }

  Future<void> loadLeads() async {
    log('Loading all leads from Firestore');
    isLoading = true;
    update();

    try {
      QuerySnapshot querySnapshot = await fireStore
          .collection('leads')
          .orderBy('createdAt', descending: true)
          .get();

      allLeads = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Lead.fromMap(data);
      }).toList();
    } catch (e) {
      print("Error loading leads: $e");
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
    update();
  }

  void startSearch() {
    isSearching = true;
    update();
  }

  void stopSearch() {
    isSearching = false;
    searchQuery = '';
    searchController.clear();
    update();
  }

  void onSearchChanged(String query) {
    searchQuery = query.trim().toLowerCase();
    update();
  }

  List<Lead> getFilteredLeads(String stage) {
    List<Lead> leads;
    if (stage == 'today') {
      leads = allLeads.where((lead) => hasFollowUpToday(lead)).toList();
    } else if (stage == 'all') {
      leads = allLeads;
    } else {
      leads = allLeads.where((lead) => lead.stage == stage).toList();
    }

    if (isSearching && searchQuery.isNotEmpty) {
      leads = _filterLeadsBySearch(leads, searchQuery);
      print("🔍 Search Query: '$searchQuery'");
      print("📊 Total leads before filter: ${allLeads.length}");
      print("📊 Filtered leads count: ${leads.length}");
      allLeads.forEach((lead) {
        print("   - ${lead.assignedToName} (Client: ${lead.clientName})");
      });
      leads.forEach((lead) {
        print("   - ${lead.assignedToName} (Client: ${lead.clientName})");
      });
    }

    return leads;
  }

  List<Lead> _filterLeadsBySearch(List<Lead> leads, String query) {
    return leads.where((lead) {
      if (lead.assignedToName.toLowerCase().contains(query)) {
        return true;
      }
      if (lead.clientName.toLowerCase().contains(query)) {
        return true;
      }
      if (lead.clientPhone.contains(query)) {
        return true;
      }
      return false;
    }).toList();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
