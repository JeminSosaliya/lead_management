import 'dart:async';

// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:lead_management/controller/permission_controller.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/core/utils/firebase_options.dart';
import 'package:lead_management/core/utils/notification_cleanup_service.dart';
import 'package:lead_management/core/utils/push_notification_utils.dart';
import 'package:lead_management/routes/route_manager.dart';
import 'package:lead_management/ui_and_controllers/auth/goggle_login/google_calendar_controller.dart';

import 'core/utils/shred_pref.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print("Handling a background message: ${message.messageId}");
  print("Background notification title: ${message.notification?.title}");
  print("Background notification body: ${message.notification?.body}");
  print("Background notification data: ${message.data}");

}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await preferences.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  NotificationUtils().init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  Get.put(GoogleCalendarController(), permanent: true);
  Get.put(PermissionController(), permanent: true);
  await dotenv.load(fileName: '.env');
  // Attempt silent login for admin
  final calendarController = Get.find<GoogleCalendarController>();
  await calendarController.autoLogin();
  unawaited(NotificationCleanupService.instance.run());
  // addIsSeenAllFieldToAllNotifications();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('hi')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    // Deep link processing is centralized in Splash after auth init
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Lead Management',
      getPages: AppRoutes.pages,
      initialRoute: AppRoutes.splash,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}

// Future<void> addIsSeenAllFieldToAllNotifications() async {
//   final notificationCollection = FirebaseFirestore.instance.collection('notificationList');
//
//   // Get all documents from the collection
//   final snapshot = await notificationCollection.get();
//
//   for (final doc in snapshot.docs) {
//     final data = doc.data();
//
//     // Check if 'is_seen_all' field already exists
//     if (!data.containsKey('is_seen_all')) {
//       await doc.reference.set({
//         'is_seen_all': false,
//       }, SetOptions(merge: true));
//
//       print("🟢 Added 'is_seen_all': false to document ${doc.id}");
//     } else {
//       print("⚪ Skipped ${doc.id} (already has 'is_seen_all')");
//     }
//   }
//
//   print("✅ Completed adding 'is_seen_all' field to all notifications.");
// }
