import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/ui_and_controllers/main/profile/profile_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_card.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    return Scaffold(
      backgroundColor: colorWhite,
      appBar: AppBar(
        title: const WantText(text: "Profile"),
        backgroundColor: colorMainTheme,
        foregroundColor: colorWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshProfile,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(colorMainTheme),
                ),
                SizedBox(height: height * 0.02),
                WantText(
                  text: "Loading profile...",
                  fontSize: width * 0.04,
                  textColor: colorGreyText,
                ),
              ],
            ),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: width * 0.2,
                  color: colorRedCalendar,
                ),
                SizedBox(height: height * 0.02),
                WantText(
                  text: controller.errorMessage,
                  fontSize: width * 0.04,
                  textColor: colorRedCalendar,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.02),
                ElevatedButton(
                  onPressed: controller.refreshProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorMainTheme,
                    foregroundColor: colorWhite,
                  ),
                  child: WantText(text: "Retry", textColor: colorWhite),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: height * 0.02),
              Center(
                child: Column(
                  children: [
                    WantText(
                      text: ListConst.currentUserProfileData.name.toString(),
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.w600,
                      textColor: colorBlack,
                    ),
                    SizedBox(height: height * 0.01),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.04,
                        vertical: height * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: ListConst.currentUserProfileData.type == 'admin'
                            ? colorMainTheme
                            : colorGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: WantText(
                        text: ListConst.currentUserProfileData.type
                            .toString()
                            .toUpperCase(),
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.bold,
                        textColor: colorWhite,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.03),

              CustomCard(
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
                      value: ListConst.currentUserProfileData.email.toString(),
                    ),

                    _buildInfoRow(
                      icon: Icons.phone,
                      label: "Phone",
                      value: ListConst.currentUserProfileData.phone.toString(),
                    ),

                    _buildInfoRow(
                      icon: Icons.location_on,
                      label: "Address",
                      value: ListConst.currentUserProfileData.address
                          .toString(),
                    ),
                    if (ListConst.currentUserProfileData.type == 'employee')
                      _buildInfoRow(
                        icon: Icons.work,
                        label: "Designation",
                        value: ListConst.currentUserProfileData.designation
                            .toString(),
                      ),
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: "Member Since",
                      value: ListConst.currentUserProfileData.createdAt != null
                          ? DateFormat('dd/MM/yyyy').format(
                              ListConst.currentUserProfileData.createdAt!,
                            )
                          : 'N/A',
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.03),

              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WantText(
                      text: "Account Information",
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.w500,
                      textColor: colorBlack,
                    ),
                    SizedBox(height: height * 0.02),

                    _buildInfoRow(
                      icon: Icons.person,
                      label: "User Type",
                      value: ListConst.currentUserProfileData.type.toString(),
                    ),

                    _buildInfoRow(
                      icon: Icons.verified,
                      label: "Status",
                      value: ListConst.currentUserProfileData.isActive == true
                          ? "Active"
                          : "Inactive",
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
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
                SizedBox(height: height * 0.005),
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
}
