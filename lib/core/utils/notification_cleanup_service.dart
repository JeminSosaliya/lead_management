import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/permission_controller.dart';

class NotificationCleanupService {
  NotificationCleanupService._();

  static final NotificationCleanupService instance =
      NotificationCleanupService._();

  bool _isRunning = false;

  Future<void> run() async {
    if (_isRunning) return;
    _isRunning = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');
      if (userId == null || userId.isEmpty) return;

      final PermissionController permissionController =
          _ensurePermissionController();

      await permissionController.ensureInitialized();
      int retentionDays = permissionController.removeNotificationDays;
      if (retentionDays <= 0) {
        await permissionController.refreshPermissions();
        retentionDays = permissionController.removeNotificationDays;
      }
      if (retentionDays <= 0) return;

      final DateTime cutoffUtc = DateTime.now()
          .toUtc()
          .subtract(Duration(days: retentionDays));
      final collection =
          FirebaseFirestore.instance.collection('notificationList');

      final snapshot =
          await collection.where('userId', isEqualTo: userId).get();
      final oldDocs = snapshot.docs.where((doc) {
        final DateTime timestamp =
            parseTimestamp(doc.data()['timestamp']) ??
                DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
        return timestamp.isBefore(cutoffUtc);
      }).toList();
      if (oldDocs.isNotEmpty) {
        await _deleteInChunks(oldDocs);
      }
    } finally {
      _isRunning = false;
    }
  }

  static DateTime? parseTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate().toUtc();
    }
    if (value is DateTime) {
      return value.toUtc();
    }
    if (value is int) {
      final bool isMilliseconds = value > 100000000000;
      final int millis = isMilliseconds ? value : value * 1000;
      return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
    }
    if (value is String) {
      final DateTime? parsedIso = DateTime.tryParse(value);
      if (parsedIso != null) {
        return parsedIso.toUtc();
      }

      final RegExp rx = RegExp(
        r'^(January|February|March|April|May|June|July|August|September|October|November|December)\s+(\d{1,2}),\s+(\d{4})\s+at\s+(\d{1,2}):(\d{2}):(\d{2})\s+(AM|PM)\s+UTC([+-]\d{1,2})(?::(\d{2}))?$',
      );
      final Match? match = rx.firstMatch(value.trim());
      if (match != null) {
        const monthNames = <String, int>{
          'January': 1,
          'February': 2,
          'March': 3,
          'April': 4,
          'May': 5,
          'June': 6,
          'July': 7,
          'August': 8,
          'September': 9,
          'October': 10,
          'November': 11,
          'December': 12,
        };

        final String monthName = match.group(1)!;
        final int day = int.parse(match.group(2)!);
        final int year = int.parse(match.group(3)!);
        int hour = int.parse(match.group(4)!);
        final int minute = int.parse(match.group(5)!);
        final int second = int.parse(match.group(6)!);
        final String ampm = match.group(7)!;
        final int offsetHour = int.parse(match.group(8)!);
        final int offsetMinute = int.parse(match.group(9) ?? '0');

        if (ampm.toUpperCase() == 'PM' && hour < 12) hour += 12;
        if (ampm.toUpperCase() == 'AM' && hour == 12) hour = 0;

        final int month = monthNames[monthName] ?? 1;
        final DateTime wallClockUtc = DateTime.utc(
          year,
          month,
          day,
          hour,
          minute,
          second,
        );
        final int sign = offsetHour >= 0 ? 1 : -1;
        final Duration offset = Duration(
          hours: offsetHour.abs() * sign,
          minutes: offsetMinute * sign,
        );
        return wallClockUtc.subtract(offset).toUtc();
      }
    }
    return null;
  }

  PermissionController _ensurePermissionController() {
    if (Get.isRegistered<PermissionController>()) {
      return Get.find<PermissionController>();
    }
    return Get.put(PermissionController(), permanent: true);
  }

  Future<void> _deleteInChunks(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    if (docs.isEmpty) return;

    WriteBatch batch = FirebaseFirestore.instance.batch();
    int counter = 0;

    for (final doc in docs) {
      batch.delete(doc.reference);
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
}

