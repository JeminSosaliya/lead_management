import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lead_management/core/utils/firebase_service.dart';

class OwnerHomeController extends GetxController {
  List<QueryDocumentSnapshot> allLeads = [];
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
      allLeads = snapshot.docs;
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

      allLeads = querySnapshot.docs;
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

  List<QueryDocumentSnapshot> get filteredLeads {
    if (currentTab == 'all') {
      return allLeads;
    }
    return allLeads.where((lead) {
      Map<String, dynamic> data = lead.data() as Map<String, dynamic>;
      return data['stage'] == currentTab;
    }).toList();
  }
}