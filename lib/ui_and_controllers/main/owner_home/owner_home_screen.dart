import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/controller/permission_controller.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/model/lead_add_model.dart';
import 'package:lead_management/routes/route_manager.dart';
import 'package:lead_management/ui_and_controllers/main/lead_details_screen/lead_details_screen.dart';
import 'package:lead_management/ui_and_controllers/main/owner_home/owner_home_controller.dart';
import 'package:lead_management/ui_and_controllers/main/profile/profile_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_button.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({super.key});

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
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
    Get.put(OwnerHomeController());
    final PermissionController _permissionController = Get.put(
      PermissionController(),
    );

    final ProfileController _profileController = Get.put(ProfileController());
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
                      fontSize: width*0.046,
                      fontWeight: FontWeight.bold,
                      textColor: colorWhite,
                    ),
                    WantText(
                      text: ListConst.currentUserProfileData.email.toString(),
                      fontSize: width*0.035,
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
                            text: "Loading...",
                            textColor: colorGreyText,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }
                      if (ListConst.currentUserProfileData.type == 'admin') {
                        if (_permissionController.canCreateAdmin) {
                          return ListTile(
                            leading: Icon(
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
                      }
                      return SizedBox.shrink();
                    }),
                    if (ListConst.currentUserProfileData.type == 'admin')
                      ListTile(
                        leading: Icon(Icons.person_add, color: colorMainTheme),
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
                    if (ListConst.currentUserProfileData.type == 'admin')
                      ListTile(
                        leading: Icon(Icons.engineering, color: colorMainTheme),
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
                      if (ListConst.currentUserProfileData.type == 'admin') {
                        return ListTile(
                          leading: Icon(Icons.people, color: colorMainTheme),
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
                      }
                      return SizedBox.shrink();
                    }),
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
                padding:  EdgeInsets.symmetric(horizontal: width*0.041,vertical: height*0.025),
                child: CustomButton(Width: width, onTap: () {
                  context.showAppDialog(
                    title: 'Are you sure you want to logout?',
                    buttonOneTitle: 'Cancel',
                    buttonTwoTitle: 'Logout',
                    onTapOneButton: () => Get.back(),
                    onTapTwoButton: () async {
                      Get.back();
                      await _logout();
                    },);
                },label: "Logout", backgroundColor: colorRedCalendar,borderColor: colorRedCalendar,),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: GetBuilder<OwnerHomeController>(
            builder: (controller) => controller.isSearching
                ? TextField(
                    controller: controller.searchController,
                    autofocus: true,
                    style: TextStyle(
                      color: colorWhite,
                      fontSize: width * 0.041,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by employee name...',
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
                    text: 'Lead Management - Owner',
                    fontSize: width * 0.051,
                    fontWeight: FontWeight.w600,
                    textColor: colorWhite,
                  ),
          ),
          backgroundColor: colorMainTheme,
          iconTheme: IconThemeData(color: colorWhite),
          actions: [
            GetBuilder<OwnerHomeController>(
              builder: (controller) => controller.isSearching
                  ? SizedBox.shrink()
                  : IconButton(
                      icon: Icon(Icons.search, color: colorWhite),
                      onPressed: controller.startSearch,
                    ),
            ),
          ],
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
        body: GetBuilder<OwnerHomeController>(
          builder: (controller) {
            if (controller.isLoading && controller.allLeads.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: colorMainTheme),
              );
            }

            return TabBarView(
              children: [
                _buildLeadList('all', controller),
                _buildLeadList('new', controller),
                _buildLeadList('inProgress', controller),
                _buildLeadList('completed', controller),
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

  Widget _buildLeadList(String stage, OwnerHomeController controller) {
    List<Lead> leads = controller.getFilteredLeads(stage);

    if (leads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              controller.isSearching && controller.searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.assignment,
              size: 64,
              color: colorGreyText,
            ),
            SizedBox(height: 16),
            WantText(
              text: controller.isSearching && controller.searchQuery.isNotEmpty
                  ? 'No leads found for "${controller.searchQuery}"'
                  : 'No leads found',
              fontSize: width * 0.041,
              fontWeight: FontWeight.w500,
              textColor: colorGreyText,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: width * 0.041),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        Lead lead = leads[index];
        return GestureDetector(
          onTap: () => Get.to(
            () => LeadDetailsScreen(
              leadId: lead.leadId,
              initialData: lead,
            ),
          ),
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
                  blurRadius: 6,
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
