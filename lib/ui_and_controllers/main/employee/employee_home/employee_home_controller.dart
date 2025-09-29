// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:get/get.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:lead_management/core/utils/firebase_service.dart';
// // import 'package:lead_management/core/utils/shred_pref.dart';
// //
// // class EmployeeHomeController extends GetxController {
// //   List<QueryDocumentSnapshot> myLeads = [];
// //   bool isLoading = true; // Start with true
// //   String currentTab = 'all';
// //
// //   @override
// //   void onInit() {
// //     super.onInit();
// //     print("🟢 EmployeeHomeController initialized");
// //     loadMyLeads(); // Pehle load karein
// //     setupRealTimeListener(); // Fir real-time listener
// //   }
// //
// //   void setupRealTimeListener() {
// //     String currentUserId = FirebaseService.getCurrentUserId();
// //     print("🔵 Setting up listener for user: $currentUserId");
// //
// //     try {
// //       FirebaseService.fireStore
// //           .collection('leads')
// //           .where('assignedTo', isEqualTo: currentUserId)
// //           .orderBy('createdAt', descending: true)
// //           .snapshots()
// //           .listen((QuerySnapshot snapshot) {
// //         print("🟡 Real-time update: ${snapshot.docs.length} leads");
// //
// //         myLeads = snapshot.docs;
// //         isLoading = false;
// //         update();
// //       }, onError: (error) {
// //         print("🔴 Listener error: $error");
// //         isLoading = false;
// //         update();
// //       });
// //     } catch (e) {
// //       print("🔴 Error setting up listener: $e");
// //       isLoading = false;
// //       update();
// //     }
// //   }
// //
// //   Future<void> loadMyLeads() async {
// //     isLoading = true;
// //     update();
// //
// //     try {
// //       // Method 1: Firestore se users collection check karein
// //       QuerySnapshot employees = await FirebaseFirestore.instance
// //           .collection('users')
// //           .where('role', isEqualTo: 'employee')
// //           .get();
// //
// //       print("👥 All Employees:");
// //       for (var doc in employees.docs) {
// //         Map<String, dynamic> emp = doc.data() as Map<String, dynamic>;
// //         print("Employee: ${emp['email']} - UID: ${emp['uid']}");
// //       }
// //
// //       // Method 2: Saari leads dikhao for debugging
// //       QuerySnapshot allLeads = await FirebaseFirestore.instance
// //           .collection('leads')
// //           .get();
// //
// //       print("📋 All Leads in Database:");
// //       for (var doc in allLeads.docs) {
// //         Map<String, dynamic> lead = doc.data() as Map<String, dynamic>;
// //         print("Lead: ${lead['clientName']} - AssignedTo: ${lead['assignedTo']}");
// //       }
// //
// //       // Method 3: Current user se query
// //       String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
// //       print("🔍 Querying for user: $currentUserId");
// //
// //       QuerySnapshot myLeadsQuery = await FirebaseFirestore.instance
// //           .collection('leads')
// //           .where('assignedTo', isEqualTo: currentUserId)
// //           .get();
// //
// //       print("✅ My Leads Found: ${myLeadsQuery.docs.length}");
// //       myLeads = myLeadsQuery.docs;
// //
// //     } catch (e) {
// //       print("❌ Error: $e");
// //     }
// //
// //     isLoading = false;
// //     update();
// //   }
// //   void changeTab(String tab) {
// //     currentTab = tab;
// //     update();
// //   }
// //
// //   List<QueryDocumentSnapshot> get filteredLeads {
// //     if (currentTab == 'all') {
// //       return myLeads;
// //     }
// //     return myLeads.where((lead) {
// //       Map<String, dynamic> data = lead.data() as Map<String, dynamic>;
// //       return data['stage'] == currentTab;
// //     }).toList();
// //   }
// //
// //   Future<bool> updateLeadStatus(String leadId, String stage, String callStatus) async {
// //     try {
// //       await FirebaseService.fireStore.collection('leads').doc(leadId).update({
// //         'stage': stage,
// //         'callStatus': callStatus,
// //         'updatedAt': FieldValue.serverTimestamp(),
// //       });
// //
// //       // Real-time listener automatically update kar dega
// //       return true;
// //     } catch (e) {
// //       print("Error updating lead: $e");
// //       Get.snackbar('Error', 'Failed to update lead status');
// //       return false;
// //     }
// //   }
// // }
//
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lead_management/core/utils/firebase_service.dart';
// import 'package:lead_management/core/utils/shred_pref.dart';
// import 'package:lead_management/model/lead_add_model.dart';
//
// class EmployeeHomeController extends GetxController {
//   List<Lead> myLeads = []; // Changed to List<Lead>
//   bool isLoading = true;
//   String currentTab = 'all';
//
//   @override
//   void onInit() {
//     super.onInit();
//     print("🟢 EmployeeHomeController initialized");
//     loadMyLeads();
//     setupRealTimeListener();
//   }
//
//   void setupRealTimeListener() {
//     String currentUserId = FirebaseService.getCurrentUserId();
//     print("🔵 Setting up listener for user: $currentUserId");
//
//     try {
//       FirebaseService.fireStore
//           .collection('leads')
//           .where('assignedTo', isEqualTo: currentUserId)
//           .orderBy('createdAt', descending: true)
//           .snapshots()
//           .listen((QuerySnapshot snapshot) {
//         print("🟡 Real-time update: ${snapshot.docs.length} leads");
//
//         myLeads = snapshot.docs.map((doc) => Lead.fromMap(doc.data() as Map<String, dynamic>)).toList();
//         isLoading = false;
//         update();
//       }, onError: (error) {
//         print("🔴 Listener error: $error");
//         isLoading = false;
//         update();
//       });
//     } catch (e) {
//       print("🔴 Error setting up listener: $e");
//       isLoading = false;
//       update();
//     }
//   }
//
//   Future<void> loadMyLeads() async {
//     isLoading = true;
//     update();
//
//     try {
//       QuerySnapshot employees = await FirebaseFirestore.instance
//           .collection('users')
//           .where('role', isEqualTo: 'employee')
//           .get();
//
//       print("👥 All Employees:");
//       for (var doc in employees.docs) {
//         Map<String, dynamic> emp = doc.data() as Map<String, dynamic>;
//         print("Employee: ${emp['email']} - UID: ${emp['uid']}");
//       }
//
//       QuerySnapshot allLeads = await FirebaseFirestore.instance
//           .collection('leads')
//           .get();
//
//       print("📋 All Leads in Database:");
//       for (var doc in allLeads.docs) {
//         Map<String, dynamic> lead = doc.data() as Map<String, dynamic>;
//         print("Lead: ${lead['clientName']} - AssignedTo: ${lead['assignedTo']}");
//       }
//
//       String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
//       print("🔍 Querying for user: $currentUserId");
//
//       QuerySnapshot myLeadsQuery = await FirebaseFirestore.instance
//           .collection('leads')
//           .where('assignedTo', isEqualTo: currentUserId)
//           .get();
//
//       print("✅ My Leads Found: ${myLeadsQuery.docs.length}");
//       myLeads = myLeadsQuery.docs.map((doc) => Lead.fromMap(doc.data() as Map<String, dynamic>)).toList();
//
//     } catch (e) {
//       print("❌ Error: $e");
//     }
//
//     isLoading = false;
//     update();
//   }
//
//   void changeTab(String tab) {
//     currentTab = tab;
//     update();
//   }
//
//   List<Lead> get filteredLeads {
//     if (currentTab == 'all') {
//       return myLeads;
//     }
//     return myLeads.where((lead) => lead.stage == currentTab).toList();
//   }
//
//   Future<bool> updateLeadStatus(String leadId, String stage, String callStatus) async {
//     try {
//       await FirebaseService.fireStore.collection('leads').doc(leadId).update({
//         'stage': stage,
//         'callStatus': callStatus,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//       return true;
//     } catch (e) {
//       print("Error updating lead: $e");
//       Get.snackbar('Error', 'Failed to update lead status');
//       return false;
//     }
//   }
// }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lead_management/core/utils/firebase_service.dart';
import 'package:lead_management/core/utils/shred_pref.dart';
import 'package:lead_management/model/lead_add_model.dart';

class EmployeeHomeController extends GetxController {
  List<Lead> myLeads = [];
  bool isLoading = true;
  String currentTab = 'all';

  @override
  void onInit() {
    super.onInit();
    print("🟢 EmployeeHomeController initialized");
    loadMyLeads();
    setupRealTimeListener();
  }

  void setupRealTimeListener() {
    String currentUserId = FirebaseService.getCurrentUserId();
    print("🔵 Setting up listener for user: $currentUserId");

    FirebaseService.fireStore
        .collection('leads')
        .where('assignedTo', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      print("🟡 Real-time update: ${snapshot.docs.length} leads");
      myLeads = snapshot.docs.map((doc) => Lead.fromMap(doc.data() as Map<String, dynamic>)).toList();
      isLoading = false;
      update();
    }, onError: (error) {
      print("🔴 Listener error: $error");
      isLoading = false;
      update();
    });
  }

  Future<void> loadMyLeads() async {
    isLoading = true;
    update();

    try {
      String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      QuerySnapshot myLeadsQuery = await FirebaseService.fireStore
          .collection('leads')
          .where('assignedTo', isEqualTo: currentUserId)
          .get();

      myLeads = myLeadsQuery.docs.map((doc) => Lead.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print("❌ Error loading leads: $e");
    }

    isLoading = false;
    update();
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
      await FirebaseService.fireStore.collection('leads').doc(leadId).update({
        'stage': stage,
        'callStatus': callStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("Error updating lead: $e");
      Get.snackbar('Error', 'Failed to update lead status');
      return false;
    }
  }
}