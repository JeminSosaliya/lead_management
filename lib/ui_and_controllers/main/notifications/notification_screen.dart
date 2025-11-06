import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/routes/route_manager.dart';
import 'package:lead_management/ui_and_controllers/main/notifications/notification_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_appbar.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_card.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_shimmer.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller =
        Get.put(NotificationController());

    return Scaffold(
      backgroundColor: colorWhite,
      appBar: CustomAppBar(
        title: 'Notifications',
        showBackButton: true,
        onBackPressed: () => Get.back(),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ListView.builder(
            itemCount: 4,
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.041,
              vertical: height * 0.02,
            ),
            itemBuilder: (_, __) => Padding(
              padding: EdgeInsets.only(bottom: height * 0.015),
              child: CustomShimmer(height: height * 0.11),
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: width * 0.18, color: colorGreyText),
                  SizedBox(height: height * 0.02),
                  WantText(
                    text: 'No notifications yet',
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.w600,
                    textColor: colorDarkGreyText,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.01),
                  WantText(
                    text:
                        'Stay tuned! You will see assignment and status updates here.',
                    fontSize: width * 0.036,
                    textColor: colorGreyText,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshNotifications,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.041,
              vertical: height * 0.02,
            ),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final doc = controller.notifications[index];
              final data = doc.data();
              final String title = (data['title'] ?? 'Notification').toString();
              final String message = (data['message'] ?? '').toString();
              final String notificationType =
                  (data['notificationType'] ?? '').toString();
              final String leadId = (data['leadId'] ?? '').toString();
              final DateTime timestamp = _parseTimestamp(data['timestamp']);

              return Padding(
                padding: EdgeInsets.only(bottom: height * 0.015),
                child: GestureDetector(
                  onTap: () {
                    if (leadId.isNotEmpty) {
                      Get.toNamed(
                        AppRoutes.leadDetailsScreen,
                        arguments: [leadId, null],
                      );
                    } else {
                      Get.context?.showAppSnackBar(
                        message: 'Lead details not available',
                        backgroundColor: colorRedCalendar,
                        textColor: colorWhite,
                      );
                    }
                  },
                  child: CustomCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WantText(
                                text: title,
                                fontSize: width * 0.041,
                                fontWeight: FontWeight.w600,
                                textColor: colorBlack,
                              ),
                              SizedBox(height: height * 0.006),
                              WantText(
                                text: message.isEmpty
                                    ? notificationType
                                    : message,
                                fontSize: width * 0.035,
                                textColor: colorDarkGreyText,
                                textOverflow: TextOverflow.visible,
                              ),
                              SizedBox(height: height * 0.008),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (notificationType.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorMainTheme.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: WantText(
                                        text: notificationType,
                                        fontSize: width * 0.031,
                                        fontWeight: FontWeight.w500,
                                        textColor: colorMainTheme,
                                      ),
                                    ),
                                  WantText(
                                    text: DateFormat('dd MMM yyyy, hh:mm a')
                                        .format(timestamp),
                                    fontSize: width * 0.031,
                                    textColor: colorGreyText,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  DateTime _parseTimestamp(dynamic raw) {
    if (raw is Timestamp) {
      return raw.toDate();
    }
    if (raw is DateTime) {
      return raw;
    }
    if (raw is int) {
      return DateTime.fromMillisecondsSinceEpoch(raw);
    }
    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }
}

