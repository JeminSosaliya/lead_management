import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/core/utils/extension.dart';

class MemberController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool get isAdmin => ListConst.currentUserProfileData.type == 'admin';
  final _selectedType = 'employee'.obs;
  final _employees = <Map<String, dynamic>>[].obs;
  final _admins = <Map<String, dynamic>>[].obs;
  final _isLoading = false.obs;

  String get selectedType => _selectedType.value;

  List<Map<String, dynamic>> get employees => _employees;

  List<Map<String, dynamic>> get admins => _admins;

  bool get isLoading => _isLoading.value;

  List<Map<String, dynamic>> get currentList {
    return _selectedType.value == 'employee' ? _employees : _admins;
  }

  @override
  void onInit() {
    super.onInit();
    loadEmployees();
    loadAdmins();
  }
  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.context?.showAppSnackBar(
      message: 'Phone number copied to clipboard',
      backgroundColor: colorGreen,
      textColor: colorWhite,
    );
  }
  void setSelectedType(String type) {
    _selectedType.value = type;
  }

  Future<void> loadMembers() async {
    if (_selectedType.value == 'employee') {
      await loadEmployees();
    } else {
      await loadAdmins();
    }
  }

  Future<void> loadEmployees() async {
    try {
      _isLoading.value = true;
      final snapshot = await _firestore
          .collection('users')
          .where('type', isEqualTo: 'employee')
          .get();

      _employees.value = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error loading employees: $e');
      _employees.value = [];
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadAdmins() async {
    try {
      _isLoading.value = true;
      final snapshot = await _firestore
          .collection('users')
          .where('type', isEqualTo: 'admin')
          .get();

      _admins.value = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error loading admins: $e');
      _admins.value = [];
    } finally {
      _isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> toggleUserStatus(
    String userId,
    bool currentStatus,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': !currentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await loadMembers();

      return {'success': true, 'message': 'User status updated successfully'};
    } catch (e) {
      print('Error toggling user status: $e');
      return {'success': false, 'message': 'Failed to update user status: $e'};
    }
  }
}
