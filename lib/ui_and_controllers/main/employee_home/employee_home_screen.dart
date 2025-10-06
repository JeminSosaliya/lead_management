import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/model/lead_add_model.dart';
import 'package:lead_management/routes/route_manager.dart';
import 'package:lead_management/ui_and_controllers/main/employee_home/employee_home_controller.dart';
import 'package:lead_management/ui_and_controllers/main/lead_details_screen/lead_details_screen.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_button.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

class EmployeeHomeScreen extends StatelessWidget {
  const EmployeeHomeScreen({super.key});

  Future<void> _logout() async {
    try {
      log("Logging out user: ${FirebaseAuth.instance.currentUser?.email}");
      await FirebaseAuth.instance.signOut();
      log("Logging out user:: ${FirebaseAuth.instance.currentUser?.email}");
      Get.offAllNamed(AppRoutes.login);
      Get.context?.showAppSnackBar(
        message: "Logged out successfully",
        backgroundColor: colorGreen,
      );
    } catch (e) {
      Get.context?.showAppSnackBar(
        message: "Error logging out. Please try again.",
        backgroundColor: colorRedCalendar,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Get.put(EmployeeHomeController());

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: colorWhite,
        drawer: Drawer(
          backgroundColor: colorWhite,
          child: Column(
            children: [
              Container(
                color: colorMainTheme,
                width: width,
                padding: EdgeInsets.only(
                  bottom: height * 0.05,
                  top: height * 0.08,
                  left: width * 0.05,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WantText(
                      text: "Welcome ${ListConst.currentUserProfileData.name}",
                      fontSize: width * 0.046,
                      fontWeight: FontWeight.bold,
                      textColor: colorWhite,
                    ),
                    WantText(
                      text: ListConst.currentUserProfileData.email.toString(),
                      fontSize: width * 0.035,
                      textColor: colorWhite.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  scrollDirection: Axis.vertical,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: Icon(Icons.person, color: colorMainTheme),
                      title: WantText(
                        text: "Profile",
                        textColor: colorBlack,
                        fontWeight: FontWeight.w500,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed(AppRoutes.profile);
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.041,
                  vertical: height * 0.025,
                ),
                child: CustomButton(
                  Width: width,
                  onTap: () {
                    log("Logout tapped");
                    context.showAppDialog(
                      title: 'Are you sure you want to logout?',
                      buttonOneTitle: 'Cancel',
                      buttonTwoTitle: 'Logout',
                      onTapOneButton: () {
                        log('Cancel logout');
                        Get.back();
                      },
                      onTapTwoButton: () async {
                        log("logout");
                        Get.back();
                        await _logout();
                      },
                    );
                  },
                  /*        onTap: () {
                    context.showAppDialog(
                      barrierDismissible: false,
                      contentWidget: Padding(
                        padding: EdgeInsets.all(width * 0.05),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.logout, color: colorRedCalendar, size: width * 0.12),
                            SizedBox(height: height * 0.02),
                            WantText(
                              text: "Are you sure you want to logout?",
                              fontSize: width * 0.045,
                              fontWeight: FontWeight.w600,
                              maxLines: 2,
                              textColor: colorBlack,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      actionWidget: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: CustomButton(
                                Width: width,
                                label: "Cancel",
                                onTap: () => Navigator.pop(context),
                                backgroundColor: colorWhite,
                                borderColor: colorGrey,
                                textColor: colorGrey,
                              ),
                            ),
                            SizedBox(width: width * 0.04),
                            Expanded(
                              child: CustomButton(
                                Width: width,
                                label: "Logout",
                                onTap: () async {
                                  Navigator.pop(context); // Close dialog
                                  await _logout();
                                },
                                backgroundColor: colorRedCalendar,
                                borderColor: colorRedCalendar,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.03),
                      ],
                    );
                  },*/
                  // onTap: () {
                  //   Get.generalDialog(
                  //     barrierDismissible: false,
                  //     transitionDuration: const Duration(milliseconds: 250),
                  //     pageBuilder: (context, animation, secondaryAnimation) {
                  //       return Center(
                  //         child: ScaleTransition(
                  //           scale: CurvedAnimation(
                  //             parent: animation,
                  //             curve: Curves.easeOutBack,
                  //           ),
                  //           child: Dialog(
                  //             shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(16),
                  //             ),
                  //             backgroundColor: colorWhite,
                  //             child: Padding(
                  //               padding: EdgeInsets.all(width * 0.05),
                  //               child: Column(
                  //                 mainAxisSize: MainAxisSize.min,
                  //                 children: [
                  //                   Icon(Icons.logout, color: colorRedCalendar, size: width * 0.12),
                  //                   SizedBox(height: height * 0.02),
                  //                   WantText(
                  //                     text: "Are you sure you want to logout?",
                  //                     fontSize: width * 0.045,
                  //                     fontWeight: FontWeight.w600,
                  //                     maxLines: 2,
                  //                     textColor: colorBlack,
                  //                     textAlign: TextAlign.center,
                  //                   ),
                  //                   SizedBox(height: height * 0.03),
                  //                   Row(
                  //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //                     children: [
                  //                       // Cancel Button
                  //                       Expanded(
                  //                         child: CustomButton(
                  //                           Width: width,
                  //                           label: "Cancel",
                  //                           onTap: () => Get.back(),
                  //                           backgroundColor: colorWhite,
                  //                           borderColor: colorGrey,
                  //                           textColor: colorGrey,
                  //                         ),
                  //                       ),
                  //                       SizedBox(width: width * 0.04),
                  //                       // Confirm Logout Button
                  //                       Expanded(
                  //                         child: CustomButton(
                  //                           Width: width,
                  //                           label: "Logout",
                  //                           onTap: () async {
                  //                             Get.back(); // Close popup
                  //                             await _logout(); // Call your logout logic
                  //                           },
                  //                           backgroundColor: colorRedCalendar,
                  //                           borderColor: colorRedCalendar,
                  //                         ),
                  //                       ),
                  //                     ],
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //     transitionBuilder: (context, animation, secondaryAnimation, child) {
                  //       return FadeTransition(
                  //         opacity: animation,
                  //         child: child,
                  //       );
                  //     },
                  //   );
                  // },
                  label: "Logout",
                  backgroundColor: colorRedCalendar,
                  borderColor: colorRedCalendar,
                ),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: WantText(
            text: 'My Leads',
            fontSize: width * 0.061,
            fontWeight: FontWeight.w600,
            textColor: colorWhite,
          ),
          backgroundColor: colorMainTheme,
          iconTheme: IconThemeData(color: colorWhite),
          bottom: TabBar(
            labelColor: colorWhite,
            unselectedLabelColor: colorWhite70,
            indicatorColor: colorWhite,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'New'),
              Tab(text: 'In Progress'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: GetBuilder<EmployeeHomeController>(
          builder: (EmployeeHomeController controller) {
            if (controller.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colorMainTheme),
                    SizedBox(height: height * 0.008),
                    WantText(
                      text: 'Loading your leads...',
                      fontSize: width * 0.041,
                      fontWeight: FontWeight.w500,
                      textColor: colorGreyText,
                    ),
                  ],
                ),
              );
            }

            if (controller.myLeads.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment, size: 64, color: colorGrey),
                    SizedBox(height: 16),
                    WantText(
                      text: 'No leads assigned to you yet',
                      fontSize: width * 0.041,
                      fontWeight: FontWeight.w500,
                      textColor: colorGrey,
                    ),
                    SizedBox(height: 8),
                    WantText(
                      text:
                      'Add a new lead or wait for owner to assign you one',
                      fontSize: width * 0.035,
                      fontWeight: FontWeight.w400,
                      textColor: colorGrey,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              children: [
                _buildLeadList('all'),
                _buildLeadList('new'),

                _buildLeadList('inProgress'),
                _buildLeadList('completed'),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: colorMainTheme,
          onPressed: () => Get.toNamed(AppRoutes.addLeadScreen),
          child: Icon(Icons.add, color: colorWhite),
        ),
      ),
    );
  }

  Widget _buildLeadList(String stage) {
    return GetBuilder<EmployeeHomeController>(
      builder: (EmployeeHomeController controller) {
        List<Lead> leads = stage == 'all'
            ? controller.myLeads
            : controller.myLeads.where((lead) => lead.stage == stage).toList();

        if (leads.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(width * 0.041),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.filter_list, size: width * 0.1, color: colorGrey),
                  SizedBox(height: height * 0.019),
                  WantText(
                    text: 'No $stage leads',
                    fontSize: width * 0.041,
                    fontWeight: FontWeight.w500,
                    textColor: colorGrey,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.only(top: width * 0.041),
          itemCount: leads.length,
          itemBuilder: (context, index) {
            Lead lead = leads[index];
            return GestureDetector(
              onTap: () {
                Get.to(
                      () =>
                      LeadDetailsScreen(
                        leadId: lead.leadId,
                        initialData: lead,
                      ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(width * 0.041),
                margin: EdgeInsets.only(
                  bottom: height * 0.019,
                  left: width * 0.041,
                  right: width * 0.041,
                ),
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorBoxShadow,
                      blurRadius: 7,
                      offset: Offset(4, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: colorMainTheme,
                      radius: 22,
                      child: WantText(
                        text: lead.clientName[0].toUpperCase(),
                        fontSize: width * 0.046,
                        fontWeight: FontWeight.w600,
                        textColor: colorWhite,
                      ),
                    ),
                    SizedBox(width: width * 0.04),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WantText(
                            text: lead.clientName,
                            fontSize: width * 0.041,
                            fontWeight: FontWeight.w600,
                            textColor: colorBlack,
                          ),
                          SizedBox(height: height * 0.005),

                          WantText(
                            text: '📞 ${lead.clientPhone}',
                            fontSize: width * 0.035,
                            fontWeight: FontWeight.w400,
                            textColor: colorDarkGreyText,
                          ),
                          SizedBox(height: height * 0.012),

                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStageColor(lead.stage),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: WantText(
                                  text: lead.stage,
                                  fontSize: width * 0.030,
                                  fontWeight: FontWeight.w500,
                                  textColor: colorWhite,
                                ),
                              ),
                              SizedBox(width: width * 0.0205),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(lead.callStatus),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: WantText(
                                  text: lead.callStatus,
                                  fontSize: width * 0.030,
                                  fontWeight: FontWeight.w500,
                                  textColor: colorWhite,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStageColor(String stage) {
    switch (stage) {
      case 'new':
        return colorBlue;
      case 'inProgress':
        return colorOrange;
      case 'completed':
        return colorGreenOne;
      default:
        return colorGrey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'interested':
        return colorGreenOne;
      case 'notinterested':
        return colorRed;
      case 'numberdoesnotexist':
        return colorPurple;
      case 'numberbusy':
        return colorAmber;
      case 'outofrange':
        return colorRedAccent;
      case 'switchoff':
        return colorGrey;
      case 'willvisitoffice':
        return colorBlueAccent;
      default:
        return colorGrey;
    }
  }
}

