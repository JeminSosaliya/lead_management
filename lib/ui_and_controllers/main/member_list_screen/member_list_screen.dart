import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/routes/route_manager.dart';
import 'package:lead_management/ui_and_controllers/main/member_details_screen/member_detail_screen.dart';
import 'package:lead_management/ui_and_controllers/main/member_list_screen/member_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_appbar.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_card.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_shimmer.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';
import 'package:shimmer/shimmer.dart';

class MemberListScreen extends StatelessWidget {
  const MemberListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MemberController());

    return Scaffold(
      backgroundColor: colorWhite,
      appBar: CustomAppBar(
        title: "Members",
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorWhite),
            onPressed: controller.loadMembers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Dropdown for selecting type
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(width * 0.041),
            padding: EdgeInsets.symmetric(horizontal: width * 0.041),
            decoration: BoxDecoration(
              border: Border.all(color: colorGreyTextFieldBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: Obx(
                () => DropdownButton<String>(
                  value: controller.selectedType,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: 'employee',
                      child: WantText(
                        text: "Employees",
                        fontSize: width * 0.04,
                        textColor: colorBlack,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'admin',
                      child: WantText(
                        text: "Admins",
                        fontSize: width * 0.04,
                        textColor: colorBlack,
                      ),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.setSelectedType(newValue);
                      controller.loadMembers();
                    }
                  },
                ),
              ),
            ),
          ),

          // Member list
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return Padding(
                  padding: EdgeInsets.all(width * 0.04),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: height * 0.015),
                              child: CustomShimmer(height: height * 0.145,),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.currentList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: width * 0.2,
                        color: colorGreyText,
                      ),
                      SizedBox(height: height * 0.02),
                      WantText(
                        text: "No ${controller.selectedType}s found",
                        fontSize: width * 0.04,
                        textColor: colorGreyText,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.only(bottom: width * 0.15),

                itemCount: controller.currentList.length,
                itemBuilder: (context, index) {
                  final member = controller.currentList[index];
                  return _buildMemberCard(member, controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(
    Map<String, dynamic> member,
    MemberController controller,
  ) {
    return CustomCard(
      verticalPadding: height * 0.008,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: width * 0.06,
          backgroundColor: member['isActive'] == true
              ? colorMainTheme
              : colorMainTheme,
          child: Icon(Icons.person, color: colorWhite, size: width * 0.05),
        ),
        title: WantText(
          text: member['name'] ?? 'Unknown',
          fontSize: width * 0.041,
          fontWeight: FontWeight.w600,
          textColor: colorBlack,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.005),
            WantText(
              text: member['email'] ?? 'No email',
              fontSize: width * 0.031,
              textColor: colorDarkGreyText,
            ),
            SizedBox(height: height * 0.002),
            WantText(
              text: member['phone'] ?? 'No phone',
              fontSize: width * 0.031,
              textColor: colorDarkGreyText,
            ),
            SizedBox(height: height * 0.005),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.02,
                    vertical: height * 0.002,
                  ),
                  decoration: BoxDecoration(
                    color: member['isActive'] == true
                        ? colorGreen
                        : colorRedCalendar,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: WantText(
                    text: member['isActive'] == true ? 'Active' : 'Inactive',
                    fontSize: width * 0.03,
                    fontWeight: FontWeight.w500,
                    textColor: colorWhite,
                  ),
                ),
                SizedBox(width: width * 0.02),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.02,
                    vertical: height * 0.002,
                  ),
                  decoration: BoxDecoration(
                    color: member['type'] == 'admin'
                        ? colorMainTheme
                        : colorMainTheme,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: WantText(
                    text: (member['type'] ?? 'unknown').toUpperCase(),
                    fontSize: width * 0.03,
                    fontWeight: FontWeight.w500,
                    textColor: colorWhite,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: width * 0.04,
          color: colorGreyText,
        ),
        onTap: () {
          if (member != null)
            Get.toNamed(AppRoutes.memberDetailScreen, arguments: member);
        },
      ),
    );
  }
}
