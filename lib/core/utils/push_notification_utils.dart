// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:get/get.dart';
// import 'package:lead_management/routes/route_manager.dart';
//
// String channelId = "lead_management_app_channel";
// String channelName = "lead_management_app";
// String channelDes = "lead_management_app_channel_des";
//
// class NotificationUtils {
//   late AndroidNotificationChannel channel;
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   void init() async {
//     channel = AndroidNotificationChannel(
//       channelId,
//       channelName,
//       description: channelDes,
//       importance: Importance.high,
//       playSound: true,
//     );
//
//     if (Platform.isAndroid) {
//       await flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//       >()
//           ?.createNotificationChannel(channel)
//           .then((void value) {});
//
//       final notifStatus = await Permission.notification.status;
//       if (!notifStatus.isGranted) {
//         await Permission.notification.request();
//       }
//     } else if (Platform.isIOS) {
//       flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//           IOSFlutterLocalNotificationsPlugin
//       >()
//           ?.requestPermissions(alert: true, sound: true)
//           .then((bool? value) {
//         if (value ?? false) {}
//       });
//     }
//     notificationConfig();
//     onMessageOpenApp();
//   }
//
//   void notificationConfig() async {
//     NotificationSettings settings = await FirebaseMessaging.instance
//         .requestPermission(
//       alert: true,
//       badge: true,
//       provisional: false,
//       sound: true,
//     );
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized ||
//         settings.authorizationStatus == AuthorizationStatus.notDetermined) {
//       FirebaseMessaging.instance.getToken().then((String? token) async {
//         if (kDebugMode) {
//           print("TOKEN ========================================== $token");
//         }
//         final prefs = await SharedPreferences.getInstance();
//         final userId = prefs.getString('current_user_id');
//
//         if (userId != null && token != null) {
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(userId)
//               .update({
//             'fcmToken': token,
//             'updatedAt': FieldValue.serverTimestamp(),
//           });
//         }
//       });
//     } else {
//       if (kDebugMode) {
//         print('User declined or has not accepted permission');
//       }
//     }
//
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: false,
//       sound: true,
//     );
//     onMessage();
//   }
//
//   void onMessage() {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       showNotification(initializeNotification: false, message: message);
//     });
//   }
//
//   showNotification({
//     required RemoteMessage message,
//     required bool initializeNotification,
//   }) {
//     if (initializeNotification) {
//       flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     }
//
//     final DarwinInitializationSettings iosSettings =
//     DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: false,
//       requestSoundPermission: true,
//       defaultPresentAlert: true,
//       defaultPresentSound: true,
//     );
//     const AndroidInitializationSettings androidSettings =
//     AndroidInitializationSettings(
//       "@mipmap/ic_launcher",
//     );
//     InitializationSettings settings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//     flutterLocalNotificationsPlugin.initialize(
//       settings,
//       onDidReceiveNotificationResponse: selectNotification,
//     );
//     AndroidNotificationDetails androidPlatformChannelSpecifics =
//     AndroidNotificationDetails(
//       channel.id,
//       channel.name,
//       importance: Importance.max,
//       icon: '@mipmap/ic_launcher',
//       channelShowBadge: false,
//       color: const Color.fromARGB(0, 120, 120, 120),
//       playSound: true,
//     );
//     DarwinNotificationDetails iOSPlatformChannelSpecifics =
//     const DarwinNotificationDetails(presentAlert: true, presentSound: true);
//     NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iOSPlatformChannelSpecifics,
//     );
//     String? title = "";
//     String? body = "";
//     Object? notification;
//     if (message.notification != null) {
//       notification = message.notification;
//       title = message.notification!.title;
//       body = message.notification!.body;
//     } else {
//       notification = message.data;
//       title = message.data["title"];
//       body = message.data["body"];
//     }
//     if (notification != null) {
//       if (Platform.isAndroid) {
//         flutterLocalNotificationsPlugin.show(
//           notification.hashCode,
//           title,
//           body,
//           platformChannelSpecifics,
//           payload: jsonEncode(message.data),
//         );
//       }
//     }
//     return onMessageOpenApp();
//   }
//
//   void selectNotification(NotificationResponse? notificationResponse) async {
//     if (notificationResponse != null) {
//       if (notificationResponse.payload != null) {
//         if (notificationResponse.payload!.isNotEmpty) {
//           var response = json.decode(notificationResponse.payload!);
//           handlePushTap(response);
//         }
//         if (kDebugMode) {
//           print('notification payload${notificationResponse.payload}');
//         }
//       } else {
//         if (kDebugMode) {
//           print("PAYLOAD IS NULL");
//         }
//         // Even if payload is null, ensure app opens to a safe route
//         _navigateToDefault();
//       }
//     }
//   }
//
//   void onMessageOpenApp() {
//     // Terminated state tap
//     FirebaseMessaging.instance.getInitialMessage().then((
//         RemoteMessage? message,
//         ) {
//       if (message != null) {
//         Map<String, dynamic> notification = {
//           "title": message.notification?.title,
//           "des": message.notification?.body,
//           "data": message.data.toString(),
//         };
//         log("Notification getInitialMessage :- ${notification.toString()}");
//         if (message.data.isNotEmpty) {
//           handlePushTap(message.data);
//         } else {
//           _navigateToDefault();
//         }
//       } else {
//         log("Notification getInitialMessage :- null");
//       }
//     });
//
//     // Background state tap
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       handlePushTap(message.data.isNotEmpty ? message.data : null);
//       Map<String, dynamic> notification = {
//         "title": message.notification?.title,
//         "des": message.notification?.body,
//         "data": message.data.toString(),
//       };
//       log("Notification onMessageOpenedApp :- ${notification.toString()}");
//     });
//   }
//
//   handlePushTapWithPayload(String? payLoadData) {
//     if (payLoadData != null) {
//       log(payLoadData.toString(), name: "myapp call");
//       try {
//         Map<String, dynamic> payLoad = jsonDecode(payLoadData);
//         handlePushTap(payLoad);
//       } catch (e) {
//         if (kDebugMode) {
//           print("Notification Exception :-$e");
//         }
//         _navigateToDefault();
//       }
//     } else {
//       _navigateToDefault();
//     }
//   }
//
//   handlePushTap(Map<String, dynamic>? payLoad) {
//     try {
//       // Decide route by payload if provided; else default to home
//       final String? route = payLoad?['route'] as String?;
//       final String? leadId = payLoad?['leadId'] as String?;
//       final String? navigateTo = route;
//
//       if (navigateTo != null && navigateTo.isNotEmpty) {
//         // Known routes can be extended here
//         switch (navigateTo) {
//           case '/home':
//           case 'home':
//             Get.offAllNamed(AppRoutes.home);
//             return;
//           case '/login':
//           case 'login':
//             Get.offAllNamed(AppRoutes.login);
//             return;
//           case '/adminLogin':
//           case 'adminLogin':
//             Get.offAllNamed(AppRoutes.goggleLogin);
//             return;
//           case '/leadDetailsScreen':
//           case 'leadDetailsScreen':
//           // If your lead details screen expects arguments, pass them here.
//           // Adjust according to your actual screen parameters.
//             Get.offAllNamed(AppRoutes.leadDetailsScreen, arguments: {
//               'leadId': leadId,
//             });
//             return;
//           default:
//           // Unknown route string → fallback
//             _navigateToDefault();
//             return;
//         }
//       }
//
//       // No route provided → open app to Home
//       _navigateToDefault();
//     } catch (e) {
//       if (kDebugMode) {
//         debugPrint("Notification Exception :-$e");
//       }
//       _navigateToDefault();
//     }
//   }
//
//   void _navigateToDefault() {
//     // Always bring user into app at a safe entry route
//     if (Get.currentRoute != AppRoutes.home) {
//       Get.offAllNamed(AppRoutes.home);
//     }
//   }
//
//   void onDidReceiveLocalNotification(
//       int id,
//       String? title,
//       String? body,
//       String? payload,
//       ) async {
//     if (payload != null && payload.isNotEmpty) {
//       log(payload, name: "NOTIFICATION PAYLOAD");
//       handlePushTapWithPayload(payload);
//     } else {
//       _navigateToDefault();
//     }
//   }
// }



import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:lead_management/routes/route_manager.dart';
import 'package:permission_handler/permission_handler.dart';

String channelId = "lead_management_app_channel";
String channelName = "lead_management_app";
String channelDes = "lead_management_app_channel_des";

class NotificationUtils {
  static Map<String, dynamic>? _pendingPayload;
  late AndroidNotificationChannel channel;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void init() async {
    channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDes,
      importance: Importance.high,
      playSound: true,
    );

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
      >()
          ?.createNotificationChannel(channel)
          .then((void value) {});

      final notifStatus = await Permission.notification.status;
      if (!notifStatus.isGranted) {
        await Permission.notification.request();
      }
    } else if (Platform.isIOS) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
      >()
          ?.requestPermissions(alert: true, sound: true)
          .then((bool? value) {
        if (value ?? false) {}
      });
    }
    notificationConfig();
    onMessageOpenApp();
  }

  void notificationConfig() async {
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      FirebaseMessaging.instance.getToken().then((String? token) async {
        if (kDebugMode) {
          print("TOKEN ========================================== $token");
        }
        // if ((preferences.getString(SharedPreference.sessionToken) ?? "")
        //     .isNotEmpty) {
        //   await AuthRepo.updateDeviceToken(token!);
        // }
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('current_user_id');

        if (userId != null && token != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'fcmToken': token,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: false,
      sound: true,
    );
    onMessage();
  }

  void onMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(initializeNotification: false, message: message);
    });
  }

  showNotification({
    required RemoteMessage message,
    required bool initializeNotification,
  }) {
    if (initializeNotification) {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    }

    final DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentSound: true,
      // onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings(
      // "@drawable/ic_notification",
      "@mipmap/ic_launcher",
    );
    InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: selectNotification,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      channel.id,
      channel.name,
      importance: Importance.max,
      // icon: '@drawable/ic_notification',
      icon: '@mipmap/ic_launcher',
      channelShowBadge: false,
      color: const Color.fromARGB(0, 120, 120, 120),
      playSound: true,
    );
    DarwinNotificationDetails iOSPlatformChannelSpecifics =
    const DarwinNotificationDetails(presentAlert: true, presentSound: true);
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    String? title = "";
    String? body = "";
    Object? notification;
    if (message.notification != null) {
      notification = message.notification;
      title = message.notification!.title;
      body = message.notification!.body;
    } else {
      notification = message.data;
      title = message.data["title"];
      body = message.data["body"];
    }
    if (notification != null) {
      if (Platform.isAndroid) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          title,
          body,
          platformChannelSpecifics,
          payload: jsonEncode(message.data),
        );
      }
    }
    return onMessageOpenApp();
  }

  void selectNotification(NotificationResponse? notificationResponse) async {
    if (notificationResponse != null) {
      if (notificationResponse.payload != null) {
        if (notificationResponse.payload!.isNotEmpty) {
          var response = json.decode(notificationResponse.payload!);
          handlePushTap(response);
        }
        if (kDebugMode) {
          print('notification payload${notificationResponse.payload}');
        }
      } else {
        if (kDebugMode) {
          print("PAYLOAD IS NULL");
        }
      }
    }
  }

  void onMessageOpenApp() {
    /// This function Manage push notification tap when app is in terminate state
    FirebaseMessaging.instance.getInitialMessage().then((
        RemoteMessage? message,
        ) {
      if (message != null) {
        try {
          _pendingPayload = Map<String, dynamic>.from(message.data);
        } catch (_) {
          _pendingPayload = message.data;
        }
        log("Notification getInitialMessage (stored) :- ${_pendingPayload.toString()}");
      } else {
        log("Notification getInitialMessage :- null");
      }
    });

    /// This function Manage push notification tap when app is in background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handlePushTap(message.data);
      Map<String, dynamic> notification = {
        "title": message.notification!.title,
        "des": message.notification!.body,
        "data": message.data.toString(),
      };
      log("Notification onMessageOpenedApp :- ${notification.toString()}");
    });
    // FirebaseMessaging.onBackgroundMessage((message) {
    //   return Future(() => null);
    // });
  }

  static bool hasPendingDeepLink() => _pendingPayload != null;

  static bool processPendingDeepLinkIfAny() {
    if (_pendingPayload != null) {
      final Map<String, dynamic> payload = _pendingPayload!;
      _pendingPayload = null;
      NotificationUtils().handlePushTap(payload);
      return true;
    }
    return false;
  }

  handlePushTapWithPayload(String? payLoadData) {
    if (payLoadData != null) {
      log(payLoadData.toString(), name: "myapp call");
      try {
        Map<String, dynamic> payLoad = jsonDecode(payLoadData);
        if (payLoad["type"] != null) {
          switch (payLoad["type"]) {
            case "message":
              break;
            case "newQuestion":
              break;
            default:
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Notification Exception :-$e");
        }
      }
    }
  }

  handlePushTap(Map<String, dynamic>? payLoad) {
    if (payLoad != null) {
      log("---------> 1${payLoad.toString()}", name: "myapp call");
      print("---------> 2${payLoad.toString()}");
      debugPrint("---------> 3${payLoad.toString()}");
      try {
        Map<String, dynamic> messageData = payLoad;
        // Primary deep link: lead details screen
        // Expecting a payload like: { "type": "lead_message", "leadId": "<id>" }
        final dynamic leadIdRaw = messageData['leadId'] ?? messageData['lead_id'] ?? messageData['lead_id_str'];
        log("LEAD_MESSAGE notification received 3 :: ${messageData['type']}");
        print("LEAD_MESSAGE notification received 3 :: ${messageData['type']}");
        debugPrint("LEAD_MESSAGE notification received 3 :: ${messageData['type']}");
        if (leadIdRaw != null) {
          final String leadId = leadIdRaw.toString();
          // Navigate to lead details with [leadId, initialData=null]
          debugPrint("LEAD_MESSAGE notification received 4 :: ${messageData['type']}");
          // Use offAll to ensure Splash/Home don't override navigation during cold start
          Get.offAllNamed(
            AppRoutes.leadDetailsScreen,
            arguments: [leadId, null],
          );
          return;
        }

        // Fallbacks for other legacy types (kept for future extension)
        if (messageData['type'] == 'LEAD_MESSAGE') {
          debugPrint("LEAD_MESSAGE notification received");
          print("LEAD_MESSAGE notification received 1");
          log("LEAD_MESSAGE notification received 2");
          final String leadId = leadIdRaw.toString();
          Get.offAllNamed(
            AppRoutes.leadDetailsScreen,
            arguments: [leadId, null],
          );
          return;
        }
        if (messageData['type'] == 'SEND_CHALLENGE_REQUEST') {
          return;
        }
        if (messageData['type'] == 'ACCEPT_CHALLENGE_REQUEST') {
          return;
        }
        if (messageData['type'] == 'ACCEPT_FRIEND_REQUEST') {
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint("Notification Exception :-$e");
        }
      }
    }
  }

  void onDidReceiveLocalNotification(
      int id,
      String? title,
      String? body,
      String? payload,
      ) async {
    // display a dialog with the notification details, tap ok to go to another page
    if (payload != null) {
      // handlePushTap(payload);
      log(payload, name: "NOTIFICATION PAYLOAD");
    } else {
      if (kDebugMode) {
        print("PAYLOAD IS NULL");
      }
    }
  }
}
