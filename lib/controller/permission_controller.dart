import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PermissionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _canCreateAdmin = false.obs;
  final _removeNotificationDays = 0.obs;
  final _isLoading = true.obs;
  final Completer<void> _initializationCompleter = Completer<void>();

  bool get canCreateAdmin => _canCreateAdmin.value;
  int get removeNotificationDays => _removeNotificationDays.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await Future.wait([
        _checkCreateAdminPermission(),
        _getRemoveNotificationDays(),
      ]);
    } finally {
      if (!_initializationCompleter.isCompleted) {
        _initializationCompleter.complete();
      }
    }
  }

  /// 🔹 Fetch permission for creating admin
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
      print('Error checking create_admin permission: $e');
      _canCreateAdmin.value = false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 🔹 Fetch remove_notification_days value
  Future<void> _getRemoveNotificationDays() async {
    try {
      _isLoading.value = true;

      DocumentSnapshot doc = await _firestore
          .collection('remove_notification_days')
          .doc('notification_days')
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _removeNotificationDays.value = data['remove_days'] ?? 0;
        print('Remove notification days: ${_removeNotificationDays.value}');
      } else {
        print('Document not found: remove_notification_days/notification_days');
        _removeNotificationDays.value = 0;
      }
    } catch (e) {
      print('Error fetching remove_notification_days: $e');
      _removeNotificationDays.value = 0;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 🔄 Refresh all permissions and settings
  Future<void> refreshPermissions() async {
    await Future.wait([
      _checkCreateAdminPermission(),
      _getRemoveNotificationDays(),
    ]);
  }

  Future<void> ensureInitialized() async {
    await _initializationCompleter.future;
  }

  Future<int> waitForRemoveNotificationDays() async {
    await ensureInitialized();
    return _removeNotificationDays.value;
  }
}
