import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/notification_cleanup_service.dart';

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
    unawaited(NotificationCleanupService.instance.run());
    _notificationSubscription = FirebaseFirestore.instance
        .collection('notificationList')
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .listen((snapshot) {
      notifications.value = _sortByTimestamp(snapshot.docs);
      isLoading.value = false;
      unawaited(_markAllAsSeenAll(snapshot.docs));
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
    unawaited(_markAllAsSeenAll(snapshot.docs));
  }

  Future<void> markAsSeen(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notificationList')
          .doc(docId)
          .update({'isSeen': true, 'is_seen_all': true});
    } catch (_) {}
  }

  Future<void> _markAllAsSeenAll(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    if (_currentUserId == null || _currentUserId!.isEmpty) return;
    if (docs.isEmpty) return;

    final Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> unseenDocs =
        docs.where((doc) => doc.data()['is_seen_all'] != true);
    if (unseenDocs.isEmpty) return;

    WriteBatch batch = FirebaseFirestore.instance.batch();
    int counter = 0;

    for (final doc in unseenDocs) {
      batch.update(doc.reference, {
        'is_seen_all': true,
      });
      counter++;

      if (counter == 450) {
        await batch.commit();
        batch = FirebaseFirestore.instance.batch();
        counter = 0;
      }
    }

    if (counter > 0) {
      await batch.commit();
    }
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
    return NotificationCleanupService.parseTimestamp(data['timestamp']) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  @override
  void onClose() {
    _notificationSubscription?.cancel();
    super.onClose();
  }
}
