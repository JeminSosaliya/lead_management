// // import 'package:get/get.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:lead_management/core/utils/firebase_service.dart';
// //
// // class OwnerHomeController extends GetxController {
// //   List<QueryDocumentSnapshot> allLeads = [];
// //   bool isLoading = false;
// //   String currentTab = 'all';
// //
// //   @override
// //   void onInit() {
// //     super.onInit();
// //     setupRealTimeListener();
// //   }
// //
// //   void setupRealTimeListener() {
// //     FirebaseService.fireStore
// //         .collection('leads')
// //         .orderBy('createdAt', descending: true)
// //         .snapshots()
// //         .listen((QuerySnapshot snapshot) {
// //       allLeads = snapshot.docs;
// //       update();
// //     });
// //   }
// //
// //   Future<void> loadLeads() async {
// //     isLoading = true;
// //     update();
// //
// //     try {
// //       QuerySnapshot querySnapshot = await FirebaseService.fireStore
// //           .collection('leads')
// //           .orderBy('createdAt', descending: true)
// //           .get();
// //
// //       allLeads = querySnapshot.docs;
// //     } catch (e) {
// //       print("Error loading leads: $e");
// //       Get.snackbar('Error', 'Failed to load leads');
// //     }
// //
// //     isLoading = false;
// //     update();
// //   }
// //
// //   void changeTab(String tab) {
// //     currentTab = tab;
// //     update();
// //   }
// //
// //   List<QueryDocumentSnapshot> get filteredLeads {
// //     if (currentTab == 'all') {
// //       return allLeads;
// //     }
// //     return allLeads.where((lead) {
// //       Map<String, dynamic> data = lead.data() as Map<String, dynamic>;
// //       return data['stage'] == currentTab;
// //     }).toList();
// //   }
// // }
//
//
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lead_management/core/utils/firebase_service.dart';
// import 'package:lead_management/model/lead_add_model.dart';
//
// class OwnerHomeController extends GetxController {
//   List<Lead> allLeads = []; // Changed to List<Lead>
//   bool isLoading = false;
//   String currentTab = 'all';
//
//   @override
//   void onInit() {
//     super.onInit();
//     setupRealTimeListener();
//   }
//
//   void setupRealTimeListener() {
//     FirebaseService.fireStore
//         .collection('leads')
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .listen((QuerySnapshot snapshot) {
//       allLeads = snapshot.docs.map((doc) => Lead.fromMap(doc.data() as Map<String, dynamic>)).toList();
//       update();
//     });
//   }
//
//   Future<void> loadLeads() async {
//     isLoading = true;
//     update();
//
//     try {
//       QuerySnapshot querySnapshot = await FirebaseService.fireStore
//           .collection('leads')
//           .orderBy('createdAt', descending: true)
//           .get();
//
//       allLeads = querySnapshot.docs.map((doc) => Lead.fromMap(doc.data() as Map<String, dynamic>)).toList();
//     } catch (e) {
//       print("Error loading leads: $e");
//       Get.snackbar('Error', 'Failed to load leads');
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
//       return allLeads;
//     }
//     return allLeads.where((lead) => lead.stage == currentTab).toList();
//   }
// }


import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lead_management/core/utils/firebase_service.dart';
import 'package:lead_management/model/lead_add_model.dart';

class OwnerHomeController extends GetxController {
  List<Lead> allLeads = [];
  bool isLoading = false;
  String currentTab = 'all';

  @override
  void onInit() {
    super.onInit();
    setupRealTimeListener();
  }

  void setupRealTimeListener() {
    FirebaseService.fireStore
        .collection('leads')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      allLeads = snapshot.docs.map((doc) => Lead.fromMap(doc.data() as Map<String, dynamic>)).toList();
      update();
    });
  }

  Future<void> loadLeads() async {
    isLoading = true;
    update();

    try {
      QuerySnapshot querySnapshot = await FirebaseService.fireStore
          .collection('leads')
          .orderBy('createdAt', descending: true)
          .get();

      allLeads = querySnapshot.docs.map((doc) => Lead.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print("Error loading leads: $e");
      Get.snackbar('Error', 'Failed to load leads');
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
      return allLeads;
    }
    return allLeads.where((lead) => lead.stage == currentTab).toList();
  }
}