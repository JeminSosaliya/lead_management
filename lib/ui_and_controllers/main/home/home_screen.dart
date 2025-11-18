import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/Get.dart';
import 'package:lead_management/controller/permission_controller.dart';
import 'package:lead_management/core/constant/app_assets.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/core/utils/user_status_service.dart';
import 'package:lead_management/model/lead_add_model.dart';
import 'package:lead_management/routes/route_manager.dart';
import 'package:lead_management/ui_and_controllers/main/home/home_controller.dart';
import 'package:lead_management/ui_and_controllers/main/notifications/notification_badge_controller.dart';
import 'package:lead_management/ui_and_controllers/main/profile/profile_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_button.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_card.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_shimmer.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Future<void> _logout() async {
  //   try {
  //     log("Logging out user: ${FirebaseAuth.instance.currentUser?.email}");
  //     try {
  //       final userStatusService = Get.find<UserStatusService>();
  //       await userStatusService.stopListening();
  //     } catch (e) {
  //       // Service not found, continue with logout
  //     }
  //
  //     await FirebaseAuth.instance.signOut();
  //     log("Logged out user: ${FirebaseAuth.instance.currentUser?.email}");
  //     Get.offAllNamed(AppRoutes.login);
  //     Get.context?.showAppSnackBar(
  //       message: "Logged out successfully",
  //       backgroundColor: colorGreen,
  //     );
  //   } catch (e) {
  //     Get.context?.showAppSnackBar(
  //       message: "Error logging out. Please try again.",
  //       backgroundColor: colorRedCalendar,
  //     );
  //   }
  // }
  Future<void> _logout() async {
    try {
      log("Logging out user: ${FirebaseAuth.instance.currentUser?.email}");

      // Remove FCM token before logout
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .update({
                'fcmToken': null, // ⬅️ Set to null, don't use arrayRemove
              });
          log("✅ FCM token removed for user: ${currentUser.uid}");
        } catch (e) {
          log("⚠️ Error removing FCM token: $e");
        }
      }

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
    final PermissionController _permissionController = Get.put(
      PermissionController(),
    );
    final NotificationBadgeController _notificationBadgeController =
        Get.put(NotificationBadgeController(), permanent: true);

    return GetBuilder<HomeController>(
      builder: (controller) {
        return PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) async {
            if (didPop) return;

            context.showAppDialog(
              title: 'Are you sure you want to exit the app?',
              buttonOneTitle: 'No',
              buttonTwoTitle: 'Yes',
              onTapOneButton: () {
                Get.back();
              },
              onTapTwoButton: () {
                Get.back();
                if (GetPlatform.isAndroid) {
                  SystemNavigator.pop();
                }
              },
            );
          },
          child: DefaultTabController(
            length: 7,
            initialIndex: 1,
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
                            Obx(() {
                              if (_permissionController.isLoading) {
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
                                    text: "Loading permissions...",
                                    textColor: colorGreyText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              }

                              if (_permissionController.canCreateAdmin) {
                                return ListTile(
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
                                );
                              }

                              return const SizedBox.shrink();
                            }),

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
                    // SizedBox(height: height * 0.048),
                  ],
                ),
              ),
              appBar: AppBar(
                backgroundColor: colorMainTheme,
                automaticallyImplyLeading: false,
                flexibleSpace: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.03,
                      right: width * 0.008,
                      top: height * 0.005,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) => GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: Image.asset(
                              AppAssets.logoTwo,
                              height: height * 0.04,
                            ),
                          ),
                        ),

                        SizedBox(width: width * 0.03),

                        Expanded(
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
                                          hintStyle: TextStyle(
                                            color: colorWhite70,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: colorWhite,
                                      ),
                                      onPressed: controller.stopSearch,
                                    ),
                                  ],
                                )
                              :  Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: WantText(
                                  text: controller.isAdmin
                                      ? 'L M - Owner'
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
                                    child: Icon(
                                      Icons.search,
                                      color: colorWhite,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.filter_list,
                                      color: controller.filtersApplied
                                          ? colorAmber
                                          : colorWhite,
                                    ),
                                    onPressed: () =>
                                        _showFilterBottomSheet(
                                          context,
                                          controller,
                                        ),
                                  ),
                                  Obx(() {
                                    final bool showBadge =
                                        _notificationBadgeController
                                            .hasUnseen.value;
                                    return GestureDetector(
                                      onTap: () {
                                        Get.toNamed(AppRoutes.notifications);
                                      },
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Icon(
                                            Icons.notifications_none,
                                            color: colorWhite,
                                          ),
                                          if (showBadge)
                                            Positioned(
                                              right: -2,
                                              top: -2,
                                              child: Container(
                                                width: width * 0.02,
                                                height: width * 0.02,
                                                decoration: BoxDecoration(
                                                  color: colorRedCalendar,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: colorWhite,
                                                    width: width * 0.005,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  }),
                                  SizedBox(width: width * 0.02,)
                                ],
                              ),
                            ],
                          ),
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
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Today'),
                    Tab(text: 'Expired'),
                    Tab(text: 'Not Contacted'),
                    Tab(text: 'In Progress'),
                    Tab(text: 'Completed'),
                    Tab(text: 'Cancelled'),

                  ],
                ),
              ),

              body: controller.isLoading
                  ? ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            top: height * 0.015,
                            right: width * 0.041,
                            left: width * 0.041,
                          ),
                          child: CustomShimmer(height: height * 0.12),
                        );
                      },
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
                        _buildLeadList('expired', controller),
                        _buildLeadList('notContacted', controller),
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
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context, HomeController controller) {
    String? tempEmployeeId = controller.selectedEmployeeId;
    String? tempEmployeeName = controller.selectedEmployeeName;
    String? tempTechnician = controller.selectedTechnician;

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

                        if (activeEmployees.isEmpty)
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorGreyTextFieldBorder,
                              ),
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

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WantText(
                        text: 'Category',
                        fontSize: width * 0.041,
                        fontWeight: FontWeight.w500,
                        textColor: colorBlack,
                      ),
                      SizedBox(height: height * 0.01),

                      if (controller.isTechnicianListLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: colorMainTheme,
                          ),
                        )
                      else if (controller.technicianListError != null)
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
                                  text: 'No Category available',
                                  fontSize: width * 0.035,
                                  textColor: Colors.orange.shade900,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: colorGreyTextFieldBorder),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<String>(
                            value: tempTechnician,
                            hint: WantText(
                              text: 'Select Category',
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
                  SizedBox(height: height * 0.048),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLeadList(String stage, HomeController controller) {
    final bool showStageBadge = stage == 'all';
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
                        : stage == 'expired'
                        ? 'No expired leads'
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
      padding: EdgeInsets.only(bottom: width * 0.15),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        Lead lead = leads[index];
        bool isUpdated = _isLeadUpdated(lead);
        final BorderRadius statusBorderRadius = showStageBadge
            ? const BorderRadius.only(topRight: Radius.circular(10))
            : const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(12),
        );

        return GestureDetector(
          onTap: () {
            Get.toNamed(
              AppRoutes.leadDetailsScreen,
              arguments: [lead.leadId, lead],
            );
          },
          child: CustomCard(
            // isDelay: _isFollowUpDelayed(
            //   lead.lastFollowUpDate ??
            //       ((lead.followUpLeads != null &&
            //               lead.followUpLeads!.isNotEmpty)
            //           ? lead.followUpLeads!.last.nextFollowUp
            //           : null),
            // ),
            isDelay: _isFollowUpDelayed(lead.lastFollowUpDate),
            horizontalPadding: 0,
            verticalPadding: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.035,
                          vertical: height * 0.014,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: colorMainTheme,
                              radius: width * 0.06,
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
                                  SizedBox(height: height * 0.003),
                                  WantText(
                                    text: '📞 ${lead.clientPhone}',
                                    fontSize: width * 0.031,
                                    fontWeight: FontWeight.w400,
                                    textColor: colorDarkGreyText,
                                  ),
                                  SizedBox(height: height * 0.003),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: IntrinsicWidth(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: WantText(
                                              text: lead.addedByName,
                                              fontSize: width * 0.035,
                                              fontWeight: FontWeight.w500,
                                              textColor: colorDarkGreyText,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          WantText(
                                            text: ' --> ',
                                            fontSize: width * 0.035,
                                            fontWeight: FontWeight.w500,
                                            textColor: colorDarkGreyText,
                                          ),
                                          Flexible(
                                            child: WantText(
                                              text: lead.assignedToName,
                                              fontSize: width * 0.035,
                                              fontWeight: FontWeight.w500,
                                              textColor: colorDarkGreyText,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [

                        Container(
                          alignment: Alignment.center,
                          width: width * 0.25,
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.015,
                            vertical: height * 0.002,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(lead.callStatus),
                            borderRadius: statusBorderRadius,
                          ),
                          child: WantText(
                            text: _formatStatus(lead.callStatus),
                            fontSize: width * 0.030,
                            fontWeight: FontWeight.w500,
                            textColor: colorWhite,
                          ),
                        ),
                        SizedBox(height: height * 0.002),
                        if (showStageBadge) ...[
                          SizedBox(height: height * 0.002),
                          Container(
                            alignment: Alignment.center,
                            width: width * 0.25,
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.015,
                              vertical: height * 0.002,
                            ),
                            decoration: BoxDecoration(
                              color: _getStageColor(controller, lead),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                            child: WantText(
                              text: _formatStage(controller, lead),
                              fontSize: width * 0.030,
                              fontWeight: FontWeight.w500,
                              textColor: colorWhite,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: width * 0.041,
                    bottom: height * 0.014,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: WantText(
                          text: isUpdated
                              ? _formatDateTime(lead.createdAt)
                              : 'Created: ${_formatDateTime(lead.createdAt)}',
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.w500,
                          textColor: colorCustomButton,
                        ),
                      ),

                      if (isUpdated)
                        Expanded(
                          child: WantText(
                            text: _formatDateTime(lead.updatedAt),
                            fontSize: width * 0.035,
                            fontWeight: FontWeight.w500,
                            textColor: colorOrangeDark,
                          ),
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
  }

  String _formatDateTime(Timestamp timestamp) {
    try {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  bool _isFollowUpDelayed(dynamic followUpRaw) {
    try {
      final DateTime? followUp = _parseFollowUpDate(followUpRaw);
      if (followUp == null) return false;

      final DateTime nowUtc = DateTime.now().toUtc();
      final DateTime followUpUtc = followUp.toUtc();
      return followUpUtc.isBefore(nowUtc);
    } catch (_) {
      return false;
    }
  }

  DateTime? _parseFollowUpDate(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      if (value > 100000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
      } else {
        return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
      }
    }

    if (value is String) {
      final DateTime? iso = DateTime.tryParse(value);
      if (iso != null) return iso;
      final RegExp rx = RegExp(
        r'^(January|February|March|April|May|June|July|August|September|October|November|December)\s+(\d{1,2}),\s+(\d{4})\s+at\s+(\d{1,2}):(\d{2}):(\d{2})\s+(AM|PM)\s+UTC([+-]\d{1,2})(?::(\d{2}))?$',
      );
      final Match? m = rx.firstMatch(value.trim());
      if (m != null) {
        final String monthName = m.group(1)!;
        final int day = int.parse(m.group(2)!);
        final int year = int.parse(m.group(3)!);
        int hour = int.parse(m.group(4)!);
        final int minute = int.parse(m.group(5)!);
        final int second = int.parse(m.group(6)!);
        final String ampm = m.group(7)!;
        final int offsetHour = int.parse(m.group(8)!);
        final int offsetMinute = int.parse(m.group(9) ?? '0');

        // Convert 12-hour to 24-hour
        if (ampm.toUpperCase() == 'PM' && hour < 12) hour += 12;
        if (ampm.toUpperCase() == 'AM' && hour == 12) hour = 0;

        final Map<String, int> monthMap = {
          'January': 1,
          'February': 2,
          'March': 3,
          'April': 4,
          'May': 5,
          'June': 6,
          'July': 7,
          'August': 8,
          'September': 9,
          'October': 10,
          'November': 11,
          'December': 12,
        };
        final int month = monthMap[monthName] ?? 1;
        final DateTime wallClockAsUtc = DateTime.utc(
          year,
          month,
          day,
          hour,
          minute,
          second,
        );

        final int sign = offsetHour >= 0 ? 1 : -1;
        final int absHour = offsetHour.abs();
        final Duration offset = Duration(
          hours: absHour * sign,
          minutes: offsetMinute * sign,
        );

        final DateTime utcInstant = wallClockAsUtc.subtract(offset);
        return utcInstant.toLocal();
      }
    }

    return null;
  }

  bool _isLeadUpdated(Lead lead) {
    try {
      return lead.updatedAt
              .toDate()
              .difference(lead.createdAt.toDate())
              .inSeconds >
          5;
    } catch (e) {
      return false;
    }
  }

  String _formatStatus(String status) {
    final Map<String, String> statusMap = {
      'hotlead': 'Hot Lead',
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
        .map(
          (word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '',
        )
        .join(' ');
  }

  String _formatStage(HomeController controller, Lead lead) {
    if (controller.hasFollowUpToday(lead)) return 'Today';

    final stage = lead.stage.toLowerCase();
    switch (stage) {
      case 'all':
        return 'All';
      case 'notcontacted':
        return 'Not Contacted';
      case 'inprogress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return stage.isEmpty ? 'Not Contacted' : stage.capitalizeFirst!;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'hotlead':
        return colorHotLead;
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

  Color _getStageColor(HomeController controller, Lead lead) {
    if (controller.hasFollowUpToday(lead)) return colorBlueAccent;

    switch (lead.stage.toLowerCase()) {
      case 'all':
        return colorCustomButton;
      case 'notcontacted':
        return colorAmber;
      case 'inprogress':
        return colorOrangeDeep;
      case 'completed':
        return colorGreenTwo;
      case 'cancelled':
        return colorRedCalendar;
      default:
        return colorGrey;
    }
  }
}
