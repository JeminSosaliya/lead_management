import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/Get.dart';
import 'package:lead_management/core/constant/app_assets.dart';
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
import 'package:lead_management/ui_and_controllers/widgets/custom_shimmer.dart';
import 'package:lead_management/ui_and_controllers/widgets/rich_text.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';
import 'package:intl/intl.dart';

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
            length: 6,
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
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
      padding: EdgeInsets.only(bottom: width * 0.15),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        Lead lead = leads[index];
        bool isUpdated = _isLeadUpdated(lead);

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

                    Container(
                      alignment: Alignment.center,
                      width: width * 0.25,
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

    // return ListView.builder(
    //   padding: EdgeInsets.only(bottom: height * 0.019),
    //   itemCount: leads.length,
    //   itemBuilder: (context, index) {
    //     Lead lead = leads[index];
    //     bool isUpdated = _isLeadUpdated(lead);
    //
    //     return GestureDetector(
    //       onTap: () {
    //         Get.toNamed(
    //           AppRoutes.leadDetailsScreen,
    //           arguments: [lead.leadId, lead],
    //         );
    //       },
    //       child: Container(
    //         margin: EdgeInsets.symmetric(
    //           horizontal: width * 0.041,
    //           vertical: height * 0.008,
    //         ),
    //         decoration: BoxDecoration(
    //           color: Colors.white,
    //           borderRadius: BorderRadius.circular(16),
    //           border: Border.all(
    //             color: Colors.grey.shade200,
    //             width: 1,
    //           ),
    //           boxShadow: [
    //             BoxShadow(
    //               color: Colors.black.withOpacity(0.06),
    //               blurRadius: 8,
    //               offset: Offset(0, 3),
    //             ),
    //           ],
    //         ),
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             // Header Section with Avatar, Name, and Status Badge
    //             Container(
    //               padding: EdgeInsets.all(width * 0.035),
    //               decoration: BoxDecoration(
    //                 color: colorMainTheme.withOpacity(0.05),
    //                 borderRadius: BorderRadius.only(
    //                   topLeft: Radius.circular(16),
    //                   topRight: Radius.circular(16),
    //                 ),
    //               ),
    //               child: Row(
    //                 children: [
    //                   // Avatar
    //                   CircleAvatar(
    //                     backgroundColor: colorMainTheme,
    //                     radius: width * 0.065,
    //                     child: WantText(
    //                       text: lead.clientName[0].toUpperCase(),
    //                       fontSize: width * 0.05,
    //                       fontWeight: FontWeight.bold,
    //                       textColor: colorWhite,
    //                     ),
    //                   ),
    //                   SizedBox(width: width * 0.035),
    //
    //                   // Name and Phone
    //                   Expanded(
    //                     child: Column(
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         WantText(
    //                           text: lead.clientName,
    //                           fontSize: width * 0.043,
    //                           fontWeight: FontWeight.w700,
    //                           textColor: colorBlack,
    //                         ),
    //                         SizedBox(height: height * 0.004),
    //                         Row(
    //                           children: [
    //                             Icon(
    //                               Icons.phone,
    //                               size: width * 0.035,
    //                               color: colorMainTheme,
    //                             ),
    //                             SizedBox(width: width * 0.015),
    //                             WantText(
    //                               text: lead.clientPhone,
    //                               fontSize: width * 0.033,
    //                               fontWeight: FontWeight.w500,
    //                               textColor: colorDarkGreyText,
    //                             ),
    //                           ],
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //
    //                   // Status Badge
    //                   Container(
    //                     padding: EdgeInsets.symmetric(
    //                       horizontal: width * 0.025,
    //                       vertical: height * 0.008,
    //                     ),
    //                     decoration: BoxDecoration(
    //                       color: _getStatusColor(lead.callStatus),
    //                       borderRadius: BorderRadius.circular(20),
    //                     ),
    //                     child: WantText(
    //                       text: _formatStatus(lead.callStatus),
    //                       fontSize: width * 0.028,
    //                       fontWeight: FontWeight.w600,
    //                       textColor: colorWhite,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //
    //             // Divider
    //             Divider(height: 1, color: Colors.grey.shade200),
    //
    //             // Assignment Info Section
    //             Padding(
    //               padding: EdgeInsets.symmetric(
    //                 horizontal: width * 0.035,
    //                 vertical: height * 0.012,
    //               ),
    //               child: Column(
    //                 children: [
    //                   // Assigned To
    //                   Row(
    //                     children: [
    //                       Container(
    //                         padding: EdgeInsets.all(6),
    //                         decoration: BoxDecoration(
    //                           color: Colors.blue.shade50,
    //                           borderRadius: BorderRadius.circular(8),
    //                         ),
    //                         child: Icon(
    //                           Icons.person_outline,
    //                           size: width * 0.04,
    //                           color: Colors.blue.shade700,
    //                         ),
    //                       ),
    //                       SizedBox(width: width * 0.025),
    //                       Expanded(
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             WantText(
    //                               text: 'Assigned To',
    //                               fontSize: width * 0.028,
    //                               fontWeight: FontWeight.w500,
    //                               textColor: colorGreyText,
    //                             ),
    //                             WantText(
    //                               text: lead.assignedToName,
    //                               fontSize: width * 0.035,
    //                               fontWeight: FontWeight.w600,
    //                               textColor: colorBlack,
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //
    //                   SizedBox(height: height * 0.012),
    //
    //                   // Added By
    //                   Row(
    //                     children: [
    //                       Container(
    //                         padding: EdgeInsets.all(6),
    //                         decoration: BoxDecoration(
    //                           color: Colors.green.shade50,
    //                           borderRadius: BorderRadius.circular(8),
    //                         ),
    //                         child: Icon(
    //                           Icons.person_add_outlined,
    //                           size: width * 0.04,
    //                           color: Colors.green.shade700,
    //                         ),
    //                       ),
    //                       SizedBox(width: width * 0.025),
    //                       Expanded(
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             WantText(
    //                               text: 'Added By',
    //                               fontSize: width * 0.028,
    //                               fontWeight: FontWeight.w500,
    //                               textColor: colorGreyText,
    //                             ),
    //                             WantText(
    //                               text: lead.addedByName,
    //                               fontSize: width * 0.035,
    //                               fontWeight: FontWeight.w600,
    //                               textColor: colorBlack,
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //             ),
    //
    //             // Footer with timestamps
    //             Container(
    //               padding: EdgeInsets.symmetric(
    //                 horizontal: width * 0.035,
    //                 vertical: height * 0.01,
    //               ),
    //               decoration: BoxDecoration(
    //                 color: Colors.grey.shade50,
    //                 borderRadius: BorderRadius.only(
    //                   bottomLeft: Radius.circular(16),
    //                   bottomRight: Radius.circular(16),
    //                 ),
    //               ),
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   // Created timestamp
    //                   Row(
    //                     children: [
    //                       Icon(
    //                         Icons.calendar_today,
    //                         size: width * 0.032,
    //                         color: colorMainTheme,
    //                       ),
    //                       SizedBox(width: width * 0.015),
    //                       WantText(
    //                         text: _formatDateTime(lead.createdAt),
    //                         fontSize: width * 0.029,
    //                         fontWeight: FontWeight.w500,
    //                         textColor: colorDarkGreyText,
    //                       ),
    //                     ],
    //                   ),
    //
    //                   // Updated timestamp (if updated)
    //                   if (isUpdated)
    //                     Container(
    //                       padding: EdgeInsets.symmetric(
    //                         horizontal: width * 0.02,
    //                         vertical: height * 0.004,
    //                       ),
    //                       decoration: BoxDecoration(
    //                         color: Colors.orange.shade100,
    //                         borderRadius: BorderRadius.circular(12),
    //                       ),
    //                       child: Row(
    //                         children: [
    //                           Icon(
    //                             Icons.update,
    //                             size: width * 0.032,
    //                             color: Colors.orange.shade700,
    //                           ),
    //                           SizedBox(width: width * 0.012),
    //                           WantText(
    //                             text: _formatDateTime(lead.updatedAt),
    //                             fontSize: width * 0.029,
    //                             fontWeight: FontWeight.w600,
    //                             textColor: Colors.orange.shade700,
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     );
    //   },
    // );
  }

  String _formatDateTime(Timestamp timestamp) {
    try {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  bool _isLeadUpdated(Lead lead) {
    // Check if updatedAt is different from createdAt
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
