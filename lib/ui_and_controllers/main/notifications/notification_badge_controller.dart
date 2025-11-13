import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationBadgeController extends GetxController {
  final hasUnseen = false.obs;
  String? _currentUserId;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('current_user_id');
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      hasUnseen.value = false;
      return;
    }

    try {
      _subscription = FirebaseFirestore.instance
          .collection('notificationList')
          .where('userId', isEqualTo: _currentUserId)
          .where('is_seen_all', isEqualTo: false)
          .snapshots()
          .listen(_handleSnapshot, onError: (_) async {
        await _fallbackListen();
      });
    } catch (_) {
      await _fallbackListen();
    }
  }

  Future<void> _fallbackListen() async {
    await _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('notificationList')
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .listen(
      (snapshot) {
        final bool hasUnseenDocs = snapshot.docs.any(
          (doc) => (doc.data()['is_seen_all'] ?? false) != true,
        );
        hasUnseen.value = hasUnseenDocs;
      },
    );
  }

  void _handleSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    hasUnseen.value = snapshot.docs.isNotEmpty;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

