import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/core/utils/user_status_service.dart';
import 'package:lead_management/model/lead_add_model.dart';
import 'package:lead_management/routes/route_manager.dart';
import 'package:lead_management/ui_and_controllers/main/home/home_controller.dart';
import 'package:lead_management/ui_and_controllers/main/lead_details_screen/lead_details_screen.dart';
import 'package:lead_management/ui_and_controllers/main/profile/profile_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_button.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_card.dart';
import 'package:lead_management/ui_and_controllers/widgets/rich_text.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout() async {
    try {
      log("Logging out user: ${FirebaseAuth.instance.currentUser?.email}");
      try {
        final userStatusService = Get.find<UserStatusService>();
        await userStatusService.stopListening();
      } catch (e) {
        // Service not found, continue with logout
      }

      await FirebaseAuth.instance.signOut();
      log("Logged out user: ${FirebaseAuth.instance.currentUser?.email}");
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
    Get.put(HomeController());
    final ProfileController _profileController = Get.put(ProfileController());

    return GetBuilder<HomeController>(
      builder: (controller) {
        return DefaultTabController(
          length: 6,
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
                          text:
                              "Welcome ${ListConst.currentUserProfileData.name}",
                          fontSize: width * 0.046,
                          fontWeight: FontWeight.bold,
                          textColor: colorWhite,
                        ),
                        WantText(
                          text: ListConst.currentUserProfileData.email
                              .toString(),
                          fontSize: width * 0.035,
                          textColor: colorWhite.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: [
                        if (controller.isAdmin)
                          ListTile(
                            leading: const Icon(
                              Icons.admin_panel_settings,
                              color: colorMainTheme,
                            ),
                            title: WantText(
                              text: "Add Admin",
                              textColor: colorBlack,
                              fontWeight: FontWeight.w500,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              Get.toNamed(AppRoutes.addAdmin);
                            },
                          ),
                        if (controller.isAdmin)
                          ListTile(
                            leading: const Icon(
                              Icons.person_add,
                              color: colorMainTheme,
                            ),
                            title: WantText(
                              text: "Add Employee",
                              textColor: colorBlack,
                              fontWeight: FontWeight.w500,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              Get.toNamed(AppRoutes.addEmployee);
                            },
                          ),
                        if (controller.isAdmin)
                          ListTile(
                            leading: const Icon(
                              Icons.engineering,
                              color: colorMainTheme,
                            ),
                            title: WantText(
                              text: "Add Technician",
                              textColor: colorBlack,
                              fontWeight: FontWeight.w500,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              Get.toNamed(AppRoutes.addTechnician);
                            },
                          ),
                        if (controller.isAdmin)
                          Obx(() {
                            if (_profileController.isLoading) {
                              return ListTile(
                                leading: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorMainTheme,
                                    ),
                                  ),
                                ),
                                title: WantText(
                                  text: "Loading...",
                                  textColor: colorGreyText,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }
                            return ListTile(
                              leading: const Icon(
                                Icons.people,
                                color: colorMainTheme,
                              ),
                              title: WantText(
                                text: "Members",
                                textColor: colorBlack,
                                fontWeight: FontWeight.w500,
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                Get.toNamed(AppRoutes.members);
                              },
                            );
                          }),
                        if (controller.isAdmin)
                          ListTile(
                            leading: Icon(
                              Icons.analytics,
                              color: colorMainTheme,
                            ),
                            title: WantText(
                              text: "Analytics",
                              textColor: colorBlack,
                              fontWeight: FontWeight.w500,
                            ),
                            onTap: () {
                              Get.back();
                              Get.toNamed(AppRoutes.analytics);
                            },
                          ),
                        ListTile(
                          leading: const Icon(
                            Icons.person,
                            color: colorMainTheme,
                          ),
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
                      label: "Logout",
                      backgroundColor: colorRedCalendar,
                      borderColor: colorRedCalendar,
                    ),
                  ),
                ],
              ),
            ),
            appBar: AppBar(
              backgroundColor: colorMainTheme,
              iconTheme: IconThemeData(color: colorWhite),

              flexibleSpace: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: width * 0.15,
                    right: width * 0.008,
                    top: height * 0.005,
                  ),
                  child: controller.isSearching
                      ? Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller.searchController,
                                autofocus: true,
                                style: TextStyle(
                                  color: colorWhite,
                                  fontSize: width * 0.041,
                                ),
                                decoration: InputDecoration(
                                  hintText: controller.isAdmin
                                      ? 'Search by employee name...'
                                      : 'Search by client name or phone...',
                                  hintStyle: TextStyle(color: colorWhite70),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: colorWhite),
                              onPressed: controller.stopSearch,
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: WantText(
                                text: controller.isAdmin
                                    ? 'Lead Management - Owner'
                                    : 'My Leads',
                                fontSize: width * 0.048,
                                fontWeight: FontWeight.w600,
                                textColor: colorWhite,
                              ),
                            ),
                            SizedBox(width: width * 0.01),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: controller.startSearch,
                                  child: Icon(Icons.search, color: colorWhite),
                                ),

                                IconButton(
                                  icon: Icon(
                                    Icons.filter_list,
                                    color: controller.filtersApplied
                                        ? colorAmber
                                        : colorWhite,
                                  ),
                                  onPressed: () => _showFilterBottomSheet(
                                    context,
                                    controller,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: colorWhite,
                unselectedLabelColor: colorWhite70,
                indicatorColor: colorWhite,
                tabs: [
                  Tab(text: 'All'),
                  Tab(text: 'Today'),
                  Tab(text: 'New Contacted'),
                  Tab(text: 'In Progress'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Cancelled'),
                ],
              ),
            ),
            body: controller.isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: colorMainTheme),
                        SizedBox(height: height * 0.008),
                        WantText(
                          text: 'Loading your leads...',
                          fontSize: width * 0.041,
                          fontWeight: FontWeight.w500,
                          textColor: colorGreyText,
                        ),
                      ],
                    ),
                  )
                : controller.leads.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment, size: 64, color: colorGrey),
                        SizedBox(height: 16),
                        WantText(
                          text: controller.isAdmin
                              ? 'No leads found'
                              : 'No leads assigned to you yet',
                          fontSize: width * 0.041,
                          fontWeight: FontWeight.w500,
                          textColor: colorGrey,
                        ),
                        SizedBox(height: 8),
                        WantText(
                          text: controller.isAdmin
                              ? 'Add a new lead'
                              : 'Add a new lead or wait for owner to assign you one',
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.w400,
                          textColor: colorGrey,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    children: [
                      _buildLeadList('all', controller),
                      _buildLeadList('today', controller),
                      _buildLeadList('newContacted', controller),
                      _buildLeadList('inProgress', controller),
                      _buildLeadList('completed', controller),
                      _buildLeadList('cancelled', controller),
                    ],
                  ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: colorMainTheme,
              onPressed: () => Get.toNamed(AppRoutes.addLeadScreen),
              shape: const CircleBorder(),
              child: Icon(Icons.add, color: colorWhite),
            ),
          ),
        );
      },
    );
  }

  // void _showFilterBottomSheet(BuildContext context, HomeController controller) {
  //   String? tempEmployeeId = controller.selectedEmployeeId;
  //   String? tempEmployeeName = controller.selectedEmployeeName;
  //   String? tempTechnician = controller.selectedTechnician;
  //
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     backgroundColor: colorWhite,
  //     builder: (BuildContext bottomSheetContext) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           return Padding(
  //             padding: EdgeInsets.symmetric(
  //               horizontal: width * 0.041,
  //               vertical: height * 0.025,
  //             ),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     WantText(
  //                       text: 'Filters',
  //                       fontSize: width * 0.046,
  //                       fontWeight: FontWeight.bold,
  //                       textColor: colorBlack,
  //                     ),
  //                     IconButton(
  //                       icon: Icon(Icons.close, color: colorBlack),
  //                       onPressed: () => Navigator.of(context).pop(),
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(height: height * 0.02),
  //                 if (controller.isAdmin)
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       WantText(
  //                         text: 'Employee',
  //                         fontSize: width * 0.041,
  //                         fontWeight: FontWeight.w500,
  //                         textColor: colorBlack,
  //                       ),
  //                       SizedBox(height: height * 0.01),
  //                       Container(
  //                         padding: const EdgeInsets.symmetric(horizontal: 12),
  //                         decoration: BoxDecoration(
  //                           border: Border.all(color: colorGreyTextFieldBorder),
  //                           borderRadius: BorderRadius.circular(8),
  //                         ),
  //                         child: DropdownButton<String>(
  //                           value: tempEmployeeName,
  //                           hint: WantText(
  //                             text: 'Select Employee',
  //                             fontSize: width * 0.035,
  //                             textColor: colorGreyText,
  //                           ),
  //                           isExpanded: true,
  //                           underline: const SizedBox(),
  //                           items: controller.employees
  //                               .where((e) => e['isActive'] == true)
  //                               .map(
  //                                 (e) => DropdownMenuItem<String>(
  //                                   value: e['name'].toString(),
  //                                   child: WantText(
  //                                     text: e['name'].toString(),
  //                                     fontSize: width * 0.035,
  //                                     textColor: colorBlack,
  //                                   ),
  //                                   onTap: () {
  //                                     tempEmployeeId = e['uid'];
  //                                     tempEmployeeName = e['name'].toString();
  //                                   },
  //                                 ),
  //                               )
  //                               .toList(),
  //                           onChanged: (value) {
  //                             setState(() {
  //                               if (value == null) {
  //                                 tempEmployeeId = null;
  //                                 tempEmployeeName = null;
  //                               } else {
  //                                 final employee = controller.employees
  //                                     .where((e) => e['isActive'] == true)
  //                                     .firstWhere(
  //                                       (e) => e['name'].toString() == value,
  //                                       orElse: () => {'uid': '', 'name': ''},
  //                                     );
  //                                 if (employee['uid'] != '') {
  //                                   tempEmployeeId = employee['uid'];
  //                                   tempEmployeeName = value;
  //                                 }
  //                               }
  //                             });
  //                           },
  //                         ),
  //                       ),
  //                       SizedBox(height: height * 0.023),
  //                     ],
  //                   ),
  //                 Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     WantText(
  //                       text: 'Technician',
  //                       fontSize: width * 0.041,
  //                       fontWeight: FontWeight.w500,
  //                       textColor: colorBlack,
  //                     ),
  //                     SizedBox(height: height * 0.01),
  //                     if (controller.isTechnicianListLoading)
  //                       const Center(
  //                         child: CircularProgressIndicator(
  //                           color: colorMainTheme,
  //                         ),
  //                       )
  //                     else if (controller.technicianListError != null)
  //                       WantText(
  //                         text: controller.technicianListError!,
  //                         fontSize: width * 0.035,
  //                         textColor: colorRedCalendar,
  //                       )
  //                     else
  //                       Container(
  //                         padding: const EdgeInsets.symmetric(horizontal: 12),
  //                         decoration: BoxDecoration(
  //                           border: Border.all(
  //                             color: controller.technicianTypes.isEmpty
  //                                 ? colorGrey
  //                                 : colorGreyTextFieldBorder,
  //                           ),
  //                           borderRadius: BorderRadius.circular(8),
  //                         ),
  //                         child: DropdownButton<String>(
  //                           value: tempTechnician,
  //                           hint: WantText(
  //                             text: controller.technicianTypes.isEmpty
  //                                 ? 'No technicians available'
  //                                 : 'Select Technician',
  //                             fontSize: width * 0.035,
  //                             textColor: colorGreyText,
  //                           ),
  //                           isExpanded: true,
  //                           underline: const SizedBox(),
  //                           items: controller.technicianTypes.isEmpty
  //                               ? []
  //                               : controller.technicianTypes
  //                                     .map(
  //                                       (e) => DropdownMenuItem<String>(
  //                                         value: e,
  //                                         child: WantText(
  //                                           text: e,
  //                                           fontSize: width * 0.035,
  //                                           textColor: colorBlack,
  //                                         ),
  //                                       ),
  //                                     )
  //                                     .toList(),
  //                           onChanged: controller.technicianTypes.isEmpty
  //                               ? null
  //                               : (value) {
  //                                   setState(() {
  //                                     tempTechnician = value;
  //                                   });
  //                                 },
  //                         ),
  //                       ),
  //                   ],
  //                 ),
  //                 SizedBox(height: height * 0.03),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Expanded(
  //                       child: CustomButton(
  //                         Width: width,
  //                         onTap: () {
  //                           controller.clearFilters();
  //                           Navigator.of(context).pop();
  //                         },
  //                         label: "Clear",
  //                         backgroundColor: colorWhite,
  //                         borderColor: colorRedCalendar,
  //                         textColor: colorRedCalendar,
  //                       ),
  //                     ),
  //                     SizedBox(width: width * 0.041),
  //                     Expanded(
  //                       child: CustomButton(
  //                         Width: width,
  //                         onTap: () {
  //                           if (controller.isAdmin) {
  //                             controller.setSelectedEmployee(
  //                               tempEmployeeId,
  //                               tempEmployeeName,
  //                             );
  //                           }
  //                           controller.setSelectedTechnician(tempTechnician);
  //                           controller.applyFilters();
  //                           Navigator.of(context).pop();
  //                         },
  //                         label: "Apply",
  //                         backgroundColor: colorMainTheme,
  //                         borderColor: colorMainTheme,
  //                         textColor: colorWhite,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(height: height * 0.02),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  void _showFilterBottomSheet(BuildContext context, HomeController controller) {
    String? tempEmployeeId = controller.selectedEmployeeId;
    String? tempEmployeeName = controller.selectedEmployeeName;
    String? tempTechnician = controller.selectedTechnician;

    // Get active employees list
    final activeEmployees = controller.employees
        .where((e) => e['isActive'] == true)
        .toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: colorWhite,
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.041,
                vertical: height * 0.025,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WantText(
                        text: 'Filters',
                        fontSize: width * 0.046,
                        fontWeight: FontWeight.bold,
                        textColor: colorBlack,
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: colorBlack),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.02),

                  // Employee Filter (Admin only)
                  if (controller.isAdmin)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WantText(
                          text: 'Employee',
                          fontSize: width * 0.041,
                          fontWeight: FontWeight.w500,
                          textColor: colorBlack,
                        ),
                        SizedBox(height: height * 0.01),

                        // Check if there are active employees
                        if (activeEmployees.isEmpty)
                        // Show message when no employees available
                          Container(
                            padding: EdgeInsets.all(width * 0.041),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.orange.shade700,
                                  size: 20,
                                ),
                                SizedBox(width: width * 0.03),
                                Expanded(
                                  child: WantText(
                                    text: 'No active employees available',
                                    fontSize: width * 0.035,
                                    textColor: Colors.orange.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                        // Show dropdown when employees exist
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: colorGreyTextFieldBorder),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: tempEmployeeName,
                              hint: WantText(
                                text: 'Select Employee',
                                fontSize: width * 0.035,
                                textColor: colorGreyText,
                              ),
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: activeEmployees
                                  .map(
                                    (e) => DropdownMenuItem<String>(
                                  value: e['name'].toString(),
                                  child: WantText(
                                    text: e['name'].toString(),
                                    fontSize: width * 0.035,
                                    textColor: colorBlack,
                                  ),
                                  onTap: () {
                                    tempEmployeeId = e['uid'];
                                    tempEmployeeName = e['name'].toString();
                                  },
                                ),
                              )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  if (value == null) {
                                    tempEmployeeId = null;
                                    tempEmployeeName = null;
                                  } else {
                                    final employee = activeEmployees.firstWhere(
                                          (e) => e['name'].toString() == value,
                                      orElse: () => {'uid': '', 'name': ''},
                                    );
                                    if (employee['uid'] != '') {
                                      tempEmployeeId = employee['uid'];
                                      tempEmployeeName = value;
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                        SizedBox(height: height * 0.023),
                      ],
                    ),

                  // Technician Filter
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WantText(
                        text: 'Technician',
                        fontSize: width * 0.041,
                        fontWeight: FontWeight.w500,
                        textColor: colorBlack,
                      ),
                      SizedBox(height: height * 0.01),

                      if (controller.isTechnicianListLoading)
                      // Show loading
                        const Center(
                          child: CircularProgressIndicator(
                            color: colorMainTheme,
                          ),
                        )
                      else if (controller.technicianListError != null)
                      // Show error
                        Container(
                          padding: EdgeInsets.all(width * 0.041),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: colorRedCalendar,
                                size: 20,
                              ),
                              SizedBox(width: width * 0.03),
                              Expanded(
                                child: WantText(
                                  text: controller.technicianListError!,
                                  fontSize: width * 0.035,
                                  textColor: colorRedCalendar,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (controller.technicianTypes.isEmpty)
                        // Show message when no technicians available
                          Container(
                            padding: EdgeInsets.all(width * 0.041),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.orange.shade700,
                                  size: 20,
                                ),
                                SizedBox(width: width * 0.03),
                                Expanded(
                                  child: WantText(
                                    text: 'No technicians available',
                                    fontSize: width * 0.035,
                                    textColor: Colors.orange.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                        // Show dropdown when technicians exist
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: colorGreyTextFieldBorder),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: tempTechnician,
                              hint: WantText(
                                text: 'Select Technician',
                                fontSize: width * 0.035,
                                textColor: colorGreyText,
                              ),
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: controller.technicianTypes
                                  .map(
                                    (e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: WantText(
                                    text: e,
                                    fontSize: width * 0.035,
                                    textColor: colorBlack,
                                  ),
                                ),
                              )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  tempTechnician = value;
                                });
                              },
                            ),
                          ),
                    ],
                  ),
                  SizedBox(height: height * 0.03),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CustomButton(
                          Width: width,
                          onTap: () {
                            controller.clearFilters();
                            Navigator.of(context).pop();
                          },
                          label: "Clear",
                          backgroundColor: colorWhite,
                          borderColor: colorRedCalendar,
                          textColor: colorRedCalendar,
                        ),
                      ),
                      SizedBox(width: width * 0.041),
                      Expanded(
                        child: CustomButton(
                          Width: width,
                          onTap: () {
                            bool hasValidFilter = false;

                            if (controller.isAdmin && tempEmployeeId != null) {
                              hasValidFilter = true;
                            }
                            if (tempTechnician != null) {
                              hasValidFilter = true;
                            }

                            if (!hasValidFilter &&
                                activeEmployees.isEmpty &&
                                controller.technicianTypes.isEmpty) {
                              Get.context?.showAppSnackBar(
                                message: 'No filter options available',
                                backgroundColor: Colors.orange,
                                textColor: colorWhite,
                              );
                              return;
                            }

                            if (controller.isAdmin) {
                              controller.setSelectedEmployee(
                                tempEmployeeId,
                                tempEmployeeName,
                              );
                            }
                            controller.setSelectedTechnician(tempTechnician);
                            controller.applyFilters();
                            Navigator.of(context).pop();
                          },
                          label: "Apply",
                          backgroundColor: colorMainTheme,
                          borderColor: colorMainTheme,
                          textColor: colorWhite,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.02),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLeadList(String stage, HomeController controller) {
    List<Lead> leads = controller.getFilteredLeads(stage);

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
                text:
                    controller.isSearching && controller.searchQuery.isNotEmpty
                    ? 'No leads found for "${controller.searchQuery}"'
                    : controller.filtersApplied
                    ? 'No leads for selected filters'
                    : stage == 'today'
                    ? 'No leads created today'
                    : 'No $stage leads',
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
      itemCount: leads.length,
      itemBuilder: (context, index) {
        Lead lead = leads[index];
        return GestureDetector(
          onTap: () {
            Get.toNamed(
              AppRoutes.leadDetailsScreen,
              arguments: [lead.leadId, lead],
            );
          },
          child: CustomCard(
            horizontalPadding: 0,
            verticalPadding: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(width: width * 0.03),
                    Center(
                      child: CircleAvatar(
                        backgroundColor: colorMainTheme,
                        radius: width * 0.06,
                        child: WantText(
                          text: lead.clientName[0].toUpperCase(),
                          fontSize: width * 0.046,
                          fontWeight: FontWeight.w600,
                          textColor: colorWhite,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: height * 0.012,
                        horizontal: width * 0.03,
                      ),
                      child: SizedBox(
                        width: width * 0.45,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WantText(
                              text: lead.clientName,
                              fontSize: width * 0.041,
                              fontWeight: FontWeight.w600,
                              textColor: colorBlack,
                            ),
                            CustomRichText(
                              title: 'Assigned To: ',
                              value: lead.assignedToName,
                            ),
                            SizedBox(height: height * 0.005),
                            CustomRichText(
                              title: 'Added By: ',
                              value: lead.addedByName,
                            ),
                            SizedBox(height: height * 0.005),
                            WantText(
                              text: '📞 ${lead.clientPhone}',
                              fontSize: width * 0.031,
                              fontWeight: FontWeight.w400,
                              textColor: colorDarkGreyText,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: width * 0.23,
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.015,
                    vertical: height * 0.002,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(lead.callStatus),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: WantText(
                    text: _formatStatus(lead.callStatus),
                    fontSize: width * 0.030,
                    fontWeight: FontWeight.w500,
                    textColor: colorWhite,
                  ),
                ),
              ],
            ),
          ),
        
        );
      },
    );
  }

  String _formatStatus(String status) {
    final Map<String, String> statusMap = {
      'numberdoesnotexist': 'Number Does Not Exist',
      'notContacted': 'Not Contacted',
      'notinterested': 'Not Interested',
      'numberbusy': 'Number Busy',
      'outofrange': 'Out Of Range',
      'switchoff': 'Switch Off',
      'willvisitoffice': 'Will Visit Office',
      'interested': 'Interested',
    };

    if (statusMap.containsKey(status.toLowerCase())) {
      return statusMap[status.toLowerCase()]!;
    }

    String formatted = status
        .replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
          (Match m) => '${m[1]} ${m[2]}',
    )
        .replaceAll('_', ' ');
    return formatted
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '')
        .join(' ');
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
