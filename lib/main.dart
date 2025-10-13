import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/core/utils/firebase_options.dart';
import 'package:lead_management/core/utils/push_notification_utils.dart';
import 'package:lead_management/routes/route_manager.dart';

import 'core/utils/shred_pref.dart';

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
    return GetMaterialApp(
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
