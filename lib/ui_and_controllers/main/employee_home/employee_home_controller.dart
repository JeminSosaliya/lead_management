
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/model/lead_add_model.dart';

class EmployeeHomeController extends GetxController {
  List<Lead> myLeads = [];
  bool isLoading = false;
  String currentTab = 'all';
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    // loadMyLeads();
    setupRealTimeListener();
  }

  void setupRealTimeListener() {
    log('Setting up real-time listener for leads assigned to current user');
    String currentUserId = ListConst.currentUserProfileData.uid.toString();
    print("🔵 Setting up listener for user: $currentUserId");

    fireStore
        .collection('leads')
        .where('assignedTo', isEqualTo: currentUserId)
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      myLeads = snapshot.docs.map((doc) => Lead.fromMap(doc.data() as Map<String, dynamic>)).toList();
      isLoading = false;
      update();
    },);
  }

  Future<void> loadMyLeads() async {
    log('Loading leads assigned to current user');
    isLoading = true;
    update();

    try {
      String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      QuerySnapshot querySnapshot = await fireStore
          .collection('leads')
          .where('assignedTo', isEqualTo: currentUserId)
          .get();

      myLeads = querySnapshot.docs.map((doc) {
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

  List<Lead> get filteredLeads {
    if (currentTab == 'all') {
      return myLeads;
    }
    return myLeads.where((lead) => lead.stage == currentTab).toList();
  }

  Future<bool> updateLeadStatus(String leadId, String stage, String callStatus) async {
    try {
      await fireStore.collection('leads').doc(leadId).update({
        'stage': stage,
        'callStatus': callStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("Error updating lead: $e");
      return false;
    }
  }
}