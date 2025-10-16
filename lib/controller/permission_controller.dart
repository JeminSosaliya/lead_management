import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PermissionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final _canCreateAdmin = false.obs;
  final _isLoading = true.obs;

  bool get canCreateAdmin => _canCreateAdmin.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _checkCreateAdminPermission();
  }

  Future<void> _checkCreateAdminPermission() async {
    try {
      _isLoading.value = true;
      
      DocumentSnapshot doc = await _firestore
          .collection('admin_setting')
          .doc('permission')
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _canCreateAdmin.value = data['create_admin'] ?? false;
      } else {
        _canCreateAdmin.value = false;
      }
    } catch (e) {
      print('Error checking add_admin permission: $e');
      _canCreateAdmin.value = false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshPermissions() async {
    await _checkCreateAdminPermission();
  }
} 