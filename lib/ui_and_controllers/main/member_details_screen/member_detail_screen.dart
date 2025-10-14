import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/ui_and_controllers/main/member_list_screen/member_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_appbar.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_button.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_card.dart';
import 'package:lead_management/ui_and_controllers/widgets/rich_text.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

class MemberDetailScreen extends StatelessWidget {
  MemberDetailScreen({super.key});

  final member = Get.arguments as Map<String, dynamic>?;

  @override
  Widget build(BuildContext context) {
    if (member == null) {
      return Scaffold(
        backgroundColor: colorWhite,
        appBar: AppBar(
          title: WantText(
            text: 'Member Details',
            fontSize: width * 0.061,
            fontWeight: FontWeight.w600,
            textColor: colorWhite,
          ),
          backgroundColor: colorMainTheme,
          iconTheme: IconThemeData(color: colorWhite),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorGreyText),
              SizedBox(height: 16),
              WantText(
                text: 'No member data found',
                fontSize: width * 0.041,
                fontWeight: FontWeight.w500,
                textColor: colorGreyText,
              ),
              SizedBox(height: 16),
              CustomButton(
                Width: width * 0.5,
                onTap: () => Get.back(),
                label: 'Go Back',
                backgroundColor: colorMainTheme,
                textColor: colorWhite,
              ),
            ],
          ),
        ),
      );
    }

    final controller = Get.find<MemberController>();

    return Scaffold(
      backgroundColor: colorWhite,
      appBar: CustomAppBar(
        title: member!['name'] ?? 'Member Details',
        actions: [
          IconButton(
            icon: Icon(Icons.refresh,color: colorWhite),
            onPressed: () => controller.loadMembers(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          children: [
            SizedBox(height: height * 0.005),

            Center(
              child: Column(
                children: [
                  WantText(
                    text: member!['name'] ?? 'Unknown',
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.w600,
                    textColor: colorBlack,
                  ),

                  SizedBox(height: height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.04,
                          vertical: height * 0.005,
                        ),
                        decoration: BoxDecoration(
                          color: member!['isActive'] == true
                              ? colorGreen
                              : colorRedCalendar,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: WantText(
                          text: member!['isActive'] == true
                              ? 'ACTIVE'
                              : 'INACTIVE',
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.bold,
                          textColor: colorWhite,
                        ),
                      ),
                      SizedBox(width: width * 0.02),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.04,
                          vertical: height * 0.005,
                        ),
                        decoration: BoxDecoration(
                          color: member!['type'] == 'admin'
                              ? colorMainTheme
                              : colorMainTheme,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: WantText(
                          text: (member!['type'] ?? 'unknown').toUpperCase(),
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.bold,
                          textColor: colorWhite,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.035),

            CustomCard(
              leftMargin: 0,
              rightMargin: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WantText(
                    text: "Personal Information",
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.w500,
                    textColor: colorBlack,
                  ),
                  SizedBox(height: height * 0.02),

                  _buildInfoRow(
                    icon: Icons.email,
                    label: "Email",
                    value: member!['email'] ?? 'No email',
                  ),

                  _buildInfoRow(
                    icon: Icons.phone,
                    label: "Phone",
                    value: member!['phone'] ?? 'No phone',
                  ),

                  _buildInfoRow(
                    icon: Icons.location_on,
                    label: "Address",
                    value: member!['address'] ?? 'No address',
                  ),

                  if (member!['designation'] != null)
                    _buildInfoRow(
                      icon: Icons.work,
                      label: "Designation",
                      value: member!['designation'],
                    ),

                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: "Member Since",
                    value: _formatDate(member!['createdAt']),
                  ),

                  _buildInfoRow(
                    icon: Icons.lock,
                    label: "Password",
                    value: member!['password'] ?? 'No password',
                  ),

                  if (member!['reference'] != null)
                    _buildInfoRow(
                      icon: Icons.person_pin,
                      label: "Reference",
                      value: member!['reference'],
                    ),
                ],
              ),
            ),

            SizedBox(height: height * 0.03),

            CustomCard(
              rightMargin: 0,
              leftMargin: 0,
              topMargin: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WantText(
                    text: "Status Management",
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.w500,
                    textColor: colorBlack,
                  ),
                  SizedBox(height: height * 0.02),
                  CustomRichText(
                    title: 'Current Status: ',
                    titleFontSize: width * 0.041,
                    value: member!['isActive'] == true ? 'Active' : 'Inactive',
                    valueFontSize: width * 0.035,
                  ),

                  SizedBox(height: height * 0.02),

                  if (member!['type'] != 'admin')
                    CustomButton(
                      Width: width,
                      onTap: () {
                        _showStatusDialog(context, controller);
                      },
                      label: member!['isActive'] == true
                          ? "Deactivate User"
                          : "Activate User",
                      backgroundColor: member!['isActive'] == true
                          ? colorRedCalendar
                          : colorGreen,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: height * 0.025),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: width * 0.05, color: colorMainTheme),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WantText(
                  text: label,
                  fontSize: width * 0.035,
                  fontWeight: FontWeight.w500,
                  textColor: colorBlack,
                ),
                SizedBox(height: height * 0.001),
                WantText(
                  text: value,
                  fontSize: width * 0.031,
                  fontWeight: FontWeight.w400,
                  textColor: colorDarkGreyText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      if (timestamp is Timestamp) {
        DateTime date = timestamp.toDate();
        return '${date.day}/${date.month}/${date.year}';
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  // Add this method after _showStatusDialog
  void _showStatusDialog(BuildContext context, MemberController controller) {
    final isActive = member!['isActive'] == true;
    final action = isActive ? 'deactivate' : 'activate';

    String title = "Are you sure you want to $action this user?";
    if (isActive) {
      title +=
          "\n\nThis will automatically log out the user from all active devices.";
    }

    context.showAppDialog(
      title: title,
      icon: isActive ? Icons.warning_amber_rounded : Icons.check_circle_outline,
      buttonOneTitle: "Cancel",
      buttonTwoTitle: "Confirm",
      onTapOneButton: () {
        Get.back();
      },
      onTapTwoButton: () async {
        Get.back();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (loadingContext) {
            return WillPopScope(
              onWillPop: () async => false,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(width * 0.05),
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: colorMainTheme),
                      SizedBox(height: height * 0.02),
                      WantText(
                        text: "Updating user status...",
                        fontSize: width * 0.04,
                        textColor: colorBlack,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );

        final result = await controller.toggleUserStatus(
          member!['id'],
          member!['isActive'] == true,
        );

        Get.back();

        Get.context?.showAppSnackBar(
          message: result['message'],
          backgroundColor: result['success'] ? colorGreen : colorRedCalendar,
          textColor: colorWhite,
        );
        if (result['success']) {
          await Future.delayed(const Duration(milliseconds: 500));
          Get.back();
        }
      },
    );
  }
}
