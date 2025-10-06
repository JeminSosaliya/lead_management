import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/utils/extension.dart';

class AddTechnicianController extends GetxController {
  final _isLoading = false.obs;
  final _isAdding = false.obs;
  final _technicianTypes = <String>[].obs;
  final _technicianController = TextEditingController();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isAdding => _isAdding.value;
  List<String> get technicianTypes => _technicianTypes;
  TextEditingController get technicianController => _technicianController;

  @override
  void onInit() {
    super.onInit();
    fetchTechnicianTypes();
  }

  Future<void> fetchTechnicianTypes() async {
    _isLoading.value = true;
    try {
      DocumentSnapshot doc = await _firestore
          .collection('technicians')
          .doc('technician_list')
          .get();

      if (doc.exists) {
        List<dynamic> types = doc.get('technicianList') ?? [];
        _technicianTypes.value = types.map((e) => e.toString()).toList();
      }
    } catch (e) {
      Get.context?.showAppSnackBar(
        message: "Error fetching technician types: $e",
        backgroundColor: colorRedCalendar,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> addTechnicianType() async {
    String technicianType = _technicianController.text.trim();
    
    if (technicianType.isEmpty) {
      Get.context?.showAppSnackBar(
        message: "Please enter technician type",
        backgroundColor: colorRedCalendar,
      );
      return;
    }

    if (_technicianTypes.contains(technicianType)) {
      Get.context?.showAppSnackBar(
        message: "This technician type already exists",
        backgroundColor: colorRedCalendar,
      );
      return;
    }

    _isAdding.value = true;
    try {
      // Add to local list first
      List<String> updatedList = [..._technicianTypes, technicianType];
      
      // Update Firebase
      await _firestore
          .collection('technicians')
          .doc('technician_list')
          .set({
        'technicianList': updatedList,
      }, SetOptions(merge: true));

      // Update local state
      _technicianTypes.value = updatedList;
      _technicianController.clear();

      Get.context?.showAppSnackBar(
        message: "Technician type added successfully",
        backgroundColor: colorGreen,
      );
    } catch (e) {
      Get.context?.showAppSnackBar(
        message: "Error adding technician type: $e",
        backgroundColor: colorRedCalendar,
      );
    } finally {
      _isAdding.value = false;
    }
  }

  @override
  void onClose() {
    _technicianController.dispose();
    super.onClose();
  }
}
