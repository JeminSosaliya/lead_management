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
        log(
          "Notification getInitialMessage (stored) :- ${_pendingPayload.toString()}",
        );
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
      final navigated = NotificationUtils().handlePushTap(payload);
      return navigated;
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

  bool handlePushTap(Map<String, dynamic>? payLoad) {
    if (payLoad != null) {
      log("---------> 1${payLoad.toString()}", name: "myapp call");
      print("---------> 2${payLoad.toString()}");
      debugPrint("---------> 3${payLoad.toString()}");
      try {
        final Map<String, dynamic> messageData = payLoad;

        // Resolve common fields
        final dynamic leadIdRaw =
            messageData['leadId'] ??
            messageData['lead_id'] ??
            messageData['lead_id_str'];
        final String? type =
            (messageData['type'] ??
                    messageData['Type'] ??
                    messageData['event'] ??
                    '')
                .toString()
                .toUpperCase();

        // 1) Primary: open Lead Details if we have a leadId (used by chat)
        if (leadIdRaw != null && leadIdRaw.toString().isNotEmpty) {
          final String leadId = leadIdRaw.toString();
          Get.offAllNamed(
            AppRoutes.leadDetailsScreen,
            arguments: [leadId, null],
          );
          return true;
        }

        // 2) Legacy: explicit LEAD_MESSAGE type (guard for null id)
        if (type == 'LEAD_MESSAGE') {
          final String? leadId =
              (messageData['leadId'] ??
                      messageData['lead_id'] ??
                      messageData['lead_id_str'])
                  ?.toString();
          if (leadId != null && leadId.isNotEmpty) {
            Get.offAllNamed(
              AppRoutes.leadDetailsScreen,
              arguments: [leadId, null],
            );
            return true;
          }
        }

        // 3) Lead assigned/created → open Home
        // Handle common variants
        const assignTypes = {
          'LEAD_ASSIGNED',
          'ASSIGN_LEAD',
          'LEAD_ASSIGN',
          'LEAD_CREATED',
          'NEW_LEAD',
          'LEAD_ADD',
          'LEAD_ADDED',
        };
        final bool looksLikeAssignment =
            assignTypes.contains(type) ||
            messageData.containsKey('assignedTo') ||
            messageData.containsKey('assigned_to');

        if (looksLikeAssignment) {
          // If the assignment notification carries a leadId, prefer opening details
          final dynamic assignLeadIdRaw =
              messageData['leadId'] ?? messageData['lead_id'];
          if (assignLeadIdRaw != null && assignLeadIdRaw.toString().isNotEmpty) {
            Get.offAllNamed(
              AppRoutes.leadDetailsScreen,
              arguments: [assignLeadIdRaw.toString(), null],
            );
            return true;
          }
          Get.offAllNamed(AppRoutes.home);
          return true;
        }

        // 4) Fallback: no actionable deep-link → report not handled
        return false;
      } catch (e) {
        if (kDebugMode) {
          debugPrint("Notification Exception :-$e");
        }
        return false;
      }
    }
    return false;
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
