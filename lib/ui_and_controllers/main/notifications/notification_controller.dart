import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController extends GetxController {
  final notifications = <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  final isLoading = true.obs;
  String? _currentUserId;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _notificationSubscription;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('current_user_id');
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      isLoading.value = false;
      return;
    }

    _notificationSubscription = FirebaseFirestore.instance
        .collection('notificationList')
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .listen((snapshot) {
      notifications.value = _sortByTimestamp(snapshot.docs);
      isLoading.value = false;
    });
  }

  Future<void> refreshNotifications() async {
    if (_currentUserId == null || _currentUserId!.isEmpty) return;
    isLoading.value = true;
    final snapshot = await FirebaseFirestore.instance
        .collection('notificationList')
        .where('userId', isEqualTo: _currentUserId)
        .get();
    notifications.value = _sortByTimestamp(snapshot.docs);
    isLoading.value = false;
  }

  Future<void> markAsSeen(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notificationList')
          .doc(docId)
          .update({'isSeen': true});
    } catch (_) {}
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortByTimestamp(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final sorted = [...docs];
    sorted.sort(
      (a, b) => _extractTimestamp(b.data())
          .compareTo(_extractTimestamp(a.data())),
    );
    return sorted;
  }

  DateTime _extractTimestamp(Map<String, dynamic> data) {
    final value = data['timestamp'];
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  void onClose() {
    _notificationSubscription?.cancel();
    super.onClose();
  }
}

