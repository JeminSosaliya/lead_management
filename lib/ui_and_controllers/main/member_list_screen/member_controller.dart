import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';

class MemberController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _selectedType = 'employee'.obs;
  final _employees = <Map<String, dynamic>>[].obs;
  final _admins = <Map<String, dynamic>>[].obs;
  final _isLoading = false.obs;

  String get selectedType => _selectedType.value;

  List<Map<String, dynamic>> get employees => _employees.value;

  List<Map<String, dynamic>> get admins => _admins.value;

  bool get isLoading => _isLoading.value;

  // Get current list based on selected type
  List<Map<String, dynamic>> get currentList {
    return _selectedType.value == 'employee' ? _employees.value : _admins.value;
  }

  @override
  void onInit() {
    super.onInit();
    // Automatically load members when controller is initialized
    loadMembers();
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

  Future<void> toggleUserStatus(String userId, bool currentStatus) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': !currentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local lists
      await loadMembers();

      Get.snackbar(
        'Success',
        'User status updated successfully',
        backgroundColor: colorGreen,
        colorText: colorWhite,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update user status: $e',
        backgroundColor: colorRedCalendar,
        colorText: colorWhite,
      );
    }
  }
}
