import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/core/utils/user_status_service.dart';
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
    Get.put(EmployeeHomeController());
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
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: colorMainTheme),
                      title: WantText(
                        text: "Profile",
                        textColor: colorBlack,
                        fontWeight: FontWeight.w500,
                      ),
                      onTap: () {
                        Get.back();
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
          title: GetBuilder<EmployeeHomeController>(
            builder: (controller) => controller.isSearching
                ? TextField(
                    controller: controller.searchController,
                    autofocus: true,
                    style: TextStyle(
                      color: colorWhite,
                      fontSize: width * 0.041,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by client name or phone...',
                      hintStyle: TextStyle(color: colorWhite70),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close, color: colorWhite),
                        onPressed: controller.stopSearch,
                      ),
                    ),
                    onChanged: controller.onSearchChanged,
                  )
                : WantText(
                    text: 'My Leads',
                    fontSize: width * 0.061,
                    fontWeight: FontWeight.w600,
                    textColor: colorWhite,
                  ),
          ),
          backgroundColor: colorMainTheme,
          iconTheme: IconThemeData(color: colorWhite),
          actions: [
            GetBuilder<EmployeeHomeController>(
              builder: (controller) => controller.isSearching
                  ? const SizedBox.shrink()
                  : Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.search, color: colorWhite),
                          onPressed: controller.startSearch,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.filter_list,
                            color: controller.filtersApplied
                                ? colorAmber
                                : colorWhite,
                          ),
                          onPressed: () =>
                              _showFilterBottomSheet(context, controller),
                        ),
                      ],
                    ),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: colorWhite,
            unselectedLabelColor: colorWhite70,
            indicatorColor: colorWhite,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Today'),
              Tab(text: 'New'),
              Tab(text: 'In Progress'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: GetBuilder<EmployeeHomeController>(
          builder: (controller) {
            if (controller.isLoading) {
              return Center(
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
                _buildLeadList('all', controller),
                _buildLeadList('today', controller),
                _buildLeadList('new', controller),
                _buildLeadList('inProgress', controller),
                _buildLeadList('completed', controller),
                _buildLeadList('cancelled', controller),
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

  void _showFilterBottomSheet(
    BuildContext context,
    EmployeeHomeController controller,
  ) {
    String? tempTechnician = controller.selectedTechnician;

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
                  GetBuilder<EmployeeHomeController>(
                    builder: (controller) {
                      if (controller.isTechnicianListLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: colorMainTheme,
                          ),
                        );
                      }
                      if (controller.technicianListError != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WantText(
                              text: 'Technician',
                              fontSize: width * 0.041,
                              fontWeight: FontWeight.w500,
                              textColor: colorBlack,
                            ),
                            SizedBox(height: height * 0.01),
                            WantText(
                              text: controller.technicianListError!,
                              fontSize: width * 0.035,
                              textColor: colorRedCalendar,
                            ),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WantText(
                            text: 'Technician',
                            fontSize: width * 0.041,
                            fontWeight: FontWeight.w500,
                            textColor: colorBlack,
                          ),
                          SizedBox(height: height * 0.01),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: controller.technicianTypes.isEmpty
                                    ? colorGrey
                                    : colorGreyTextFieldBorder,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: tempTechnician,
                              hint: WantText(
                                text: controller.technicianTypes.isEmpty
                                    ? 'No technicians available'
                                    : 'Select Technician',
                                fontSize: width * 0.035,
                                textColor: colorGreyText,
                              ),
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: controller.technicianTypes.isEmpty
                                  ? []
                                  : controller.technicianTypes
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
                              onChanged: controller.technicianTypes.isEmpty
                                  ? null
                                  : (value) {
                                      setState(() {
                                        tempTechnician = value;
                                      });
                                    },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: height * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CustomButton(
                          Width: width * 0.4,
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
                          Width: width * 0.4,
                          onTap: () {
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

  Widget _buildLeadList(String stage, EmployeeHomeController controller) {
    List<Lead> leads = controller.getFilteredLeads(stage);

    if (leads.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(width * 0.041),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.filter_list, size:width*0.1, color: colorGrey),
              SizedBox(height: height * 0.019),
              WantText(
                text:
                    controller.isSearching && controller.searchQuery.isNotEmpty
                    ? 'No leads found for "${controller.searchQuery}"'
                    : controller.filtersApplied
                    ? 'No leads for selected technician'
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
      padding: EdgeInsets.only(top: width * 0.041),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        Lead lead = leads[index];
        return GestureDetector(
          onTap: () {
            Get.to(
              () => LeadDetailsScreen(leadId: lead.leadId, initialData: lead),
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
                        text: 'Assigned To: ${lead.assignedToName}',
                        fontSize: width * 0.038,
                        fontWeight: FontWeight.w600,
                        textColor: colorDarkGreyText,
                      ),
                      SizedBox(height: height * 0.005),
                      WantText(
                        text: 'Added By: ${lead.addedByName}',
                        fontSize: width * 0.038,
                        fontWeight: FontWeight.w600,
                        textColor: colorDarkGreyText,
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
  }

  Color _getStageColor(String stage) {
    switch (stage) {
      case 'new':
        return colorBlue;
      case 'inProgress':
        return colorOrange;
      case 'completed':
        return colorGreenOne;
      case 'cancelled':
        return colorBlue;
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

