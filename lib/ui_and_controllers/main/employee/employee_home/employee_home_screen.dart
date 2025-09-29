// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:lead_management/config/routes/route_manager.dart';
// // import 'package:lead_management/ui_and_controllers/main/employee/employee_home/employee_home_controller.dart';
// //
// // class EmployeeHomeScreen extends StatelessWidget {
// //   EmployeeHomeScreen({super.key});
// //
// //   final EmployeeHomeController controller = Get.put(EmployeeHomeController());
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return DefaultTabController(
// //       length: 4,
// //       child: Scaffold(
// //         appBar: AppBar(
// //           title: const Text('My Leads'),
// //           bottom: const TabBar(
// //             tabs: [
// //               Tab(text: 'New'),
// //               Tab(text: 'All'),
// //               Tab(text: 'In Progress'),
// //               Tab(text: 'Completed'),
// //             ],
// //           ),
// //         ),
// //         body: GetBuilder<EmployeeHomeController>(
// //           builder: (controller) {
// //             // Debug information
// //             print("🔄 Employee Screen Rebuilt");
// //             print("📊 Leads count: ${controller.myLeads.length}");
// //             print("⏳ Loading: ${controller.isLoading}");
// //
// //             if (controller.isLoading) {
// //               return const Center(
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     CircularProgressIndicator(),
// //                     SizedBox(height: 16),
// //                     Text('Loading your leads...'),
// //                   ],
// //                 ),
// //               );
// //             }
// //
// //             if (controller.myLeads.isEmpty) {
// //               return const Center(
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     Icon(Icons.assignment, size: 64, color: Colors.grey),
// //                     SizedBox(height: 16),
// //                     Text(
// //                       'No leads assigned to you yet',
// //                       style: TextStyle(fontSize: 16, color: Colors.grey),
// //                     ),
// //                     SizedBox(height: 8),
// //                     Text(
// //                       'Add a new lead or wait for owner to assign you one',
// //                       style: TextStyle(fontSize: 14, color: Colors.grey),
// //                       textAlign: TextAlign.center,
// //                     ),
// //                   ],
// //                 ),
// //               );
// //             }
// //
// //             return TabBarView(
// //               children: [
// //                 _buildLeadList('new'),
// //                 _buildLeadList('all'),
// //                 _buildLeadList('inProgress'),
// //                 _buildLeadList('completed'),
// //               ],
// //             );
// //           },
// //         ),
// //         floatingActionButton: FloatingActionButton(
// //           onPressed: () {
// //             Get.toNamed(AppRoutes.addLeadScreen);
// //           },
// //           child: const Icon(Icons.add),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildLeadList(String stage) {
// //     return GetBuilder<EmployeeHomeController>(
// //       builder: (controller) {
// //         List<QueryDocumentSnapshot> leads = stage == 'all'
// //             ? controller.myLeads
// //             : controller.myLeads.where((lead) {
// //           Map<String, dynamic> data = lead.data() as Map<String, dynamic>;
// //           return data['stage'] == stage;
// //         }).toList();
// //
// //         if (leads.isEmpty) {
// //           return Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(Icons.filter_list, size: 48, color: Colors.grey),
// //                 SizedBox(height: 16),
// //                 Text(
// //                   'No $stage leads',
// //                   style: TextStyle(fontSize: 16, color: Colors.grey),
// //                 ),
// //               ],
// //             ),
// //           );
// //         }
// //
// //         return ListView.builder(
// //           itemCount: leads.length,
// //           itemBuilder: (context, index) {
// //             Map<String, dynamic> data = leads[index].data() as Map<String, dynamic>;
// //             return _buildLeadCard(data, leads[index].id);
// //           },
// //         );
// //       },
// //     );
// //   }
// //
// //   Widget _buildLeadCard(Map<String, dynamic> data, String leadId) {
// //     return Card(
// //       margin: const EdgeInsets.all(8.0),
// //       child: ListTile(
// //         leading: CircleAvatar(
// //           child: Text(data['clientName']?[0] ?? '?'),
// //         ),
// //         title: Text(
// //           data['clientName'] ?? 'No Name',
// //           style: TextStyle(fontWeight: FontWeight.bold),
// //         ),
// //         subtitle: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text('📞 ${data['clientPhone'] ?? 'N/A'}'),
// //             SizedBox(height: 4),
// //             Row(
// //               children: [
// //                 Container(
// //                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// //                   decoration: BoxDecoration(
// //                     color: _getStageColor(data['stage']),
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                   child: Text(
// //                     data['stage'] ?? 'new',
// //                     style: TextStyle(color: Colors.white, fontSize: 12),
// //                   ),
// //                 ),
// //                 SizedBox(width: 8),
// //                 Container(
// //                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// //                   decoration: BoxDecoration(
// //                     color: _getStatusColor(data['callStatus']),
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                   child: Text(
// //                     data['callStatus'] ?? 'notContacted',
// //                     style: TextStyle(color: Colors.white, fontSize: 12),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //         trailing: PopupMenuButton(
// //           itemBuilder: (context) => [
// //             const PopupMenuItem(value: 'inProgress', child: Text('Mark In Progress')),
// //             const PopupMenuItem(value: 'completed', child: Text('Mark Completed')),
// //           ],
// //           onSelected: (value) {
// //             if (value == 'inProgress') {
// //               controller.updateLeadStatus(leadId, 'inProgress', data['callStatus'] ?? 'notContacted');
// //             } else if (value == 'completed') {
// //               controller.updateLeadStatus(leadId, 'completed', data['callStatus'] ?? 'notContacted');
// //             }
// //           },
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Color _getStageColor(String stage) {
// //     switch (stage) {
// //       case 'new': return Colors.blue;
// //       case 'inProgress': return Colors.orange;
// //       case 'completed': return Colors.green;
// //       default: return Colors.grey;
// //     }
// //   }
// //
// //   Color _getStatusColor(String status) {
// //     switch (status) {
// //       case 'interested': return Colors.green;
// //       case 'notInterested': return Colors.red;
// //       case 'fakeNumber': return Colors.purple;
// //       case 'callLater': return Colors.amber;
// //       default: return Colors.grey;
// //     }
// //   }
// // }
//
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:lead_management/config/routes/route_manager.dart';
// import 'package:lead_management/model/lead_add_model.dart';
// import 'package:lead_management/ui_and_controllers/main/employee/employee_home/employee_home_controller.dart';
// import 'package:lead_management/ui_and_controllers/main/lead_deatails/lead_details_screen.dart';
//
// class EmployeeHomeScreen extends StatelessWidget {
//   EmployeeHomeScreen({super.key});
//
//   final EmployeeHomeController controller = Get.put(EmployeeHomeController());
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 4,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('My Leads'),
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'New'),
//               Tab(text: 'All'),
//               Tab(text: 'In Progress'),
//               Tab(text: 'Completed'),
//             ],
//           ),
//         ),
//         body: GetBuilder<EmployeeHomeController>(
//           builder: (controller) {
//             print("🔄 Employee Screen Rebuilt");
//             print("📊 Leads count: ${controller.myLeads.length}");
//             print("⏳ Loading: ${controller.isLoading}");
//
//             if (controller.isLoading) {
//               return const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(height: 16),
//                     Text('Loading your leads...'),
//                   ],
//                 ),
//               );
//             }
//
//             if (controller.myLeads.isEmpty) {
//               return const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.assignment, size: 64, color: Colors.grey),
//                     SizedBox(height: 16),
//                     Text(
//                       'No leads assigned to you yet',
//                       style: TextStyle(fontSize: 16, color: Colors.grey),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'Add a new lead or wait for owner to assign you one',
//                       style: TextStyle(fontSize: 14, color: Colors.grey),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               );
//             }
//
//             return TabBarView(
//               children: [
//                 _buildLeadList('new'),
//                 _buildLeadList('all'),
//                 _buildLeadList('inProgress'),
//                 _buildLeadList('completed'),
//               ],
//             );
//           },
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             Get.toNamed(AppRoutes.addLeadScreen);
//           },
//           child: const Icon(Icons.add),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLeadList(String stage) {
//     return GetBuilder<EmployeeHomeController>(
//       builder: (controller) {
//         List<Lead> leads = stage == 'all'
//             ? controller.myLeads
//             : controller.myLeads.where((lead) => lead.stage == stage).toList();
//
//         if (leads.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.filter_list, size: 48, color: Colors.grey),
//                 SizedBox(height: 16),
//                 Text(
//                   'No $stage leads',
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return ListView.builder(
//           itemCount: leads.length,
//           itemBuilder: (context, index) {
//             Lead lead = leads[index];
//             return _buildLeadCard(lead, lead.leadId);
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildLeadCard(Lead lead, String leadId) {
//     Map<String, dynamic> data = lead.toMap();
//     return Card(
//       margin: const EdgeInsets.all(8.0),
//       child: ListTile(
//         leading: CircleAvatar(
//           child: Text(lead.clientName[0]),
//         ),
//         title: Text(
//           lead.clientName,
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('📞 ${lead.clientPhone}'),
//             SizedBox(height: 4),
//             Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: _getStageColor(lead.stage),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     lead.stage,
//                     style: TextStyle(color: Colors.white, fontSize: 12),
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(lead.callStatus),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     lead.callStatus,
//                     style: TextStyle(color: Colors.white, fontSize: 12),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         onTap: () => Get.to(() => LeadDetailsScreen(leadId: leadId, initialData: data)),
//       ),
//     );
//   }
//
//   Color _getStageColor(String stage) {
//     switch (stage) {
//       case 'new': return Colors.blue;
//       case 'inProgress': return Colors.orange;
//       case 'completed': return Colors.green;
//       default: return Colors.grey;
//     }
//   }
//
//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'interested': return Colors.green;
//       case 'notInterested': return Colors.red;
//       case 'numberdoesnotexist': return Colors.purple;
//       case 'numberbusy': return Colors.amber;
//       case 'outofrange': return Colors.redAccent;
//       case 'switchoff': return Colors.grey;
//       case 'willvisitoffice': return Colors.blueAccent;
//       default: return Colors.grey;
//     }
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/config/routes/route_manager.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/model/lead_add_model.dart';
import 'package:lead_management/ui_and_controllers/main/employee/employee_home/employee_home_controller.dart';
import 'package:lead_management/ui_and_controllers/main/lead_deatails/lead_details_screen.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

// class EmployeeHomeScreen extends StatelessWidget {
//   EmployeeHomeScreen({super.key});
//
//   final EmployeeHomeController controller = Get.put(EmployeeHomeController());
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 4,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('My Leads'),
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'New'),
//               Tab(text: 'All'),
//               Tab(text: 'In Progress'),
//               Tab(text: 'Completed'),
//             ],
//           ),
//         ),
//         body: GetBuilder<EmployeeHomeController>(
//           builder: (controller) {
//             print("🔄 Employee Screen Rebuilt");
//             print("📊 Leads count: ${controller.myLeads.length}");
//             print("⏳ Loading: ${controller.isLoading}");
//
//             if (controller.isLoading) {
//               return const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(height: 16),
//                     Text('Loading your leads...'),
//                   ],
//                 ),
//               );
//             }
//
//             if (controller.myLeads.isEmpty) {
//               return const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.assignment, size: 64, color: Colors.grey),
//                     SizedBox(height: 16),
//                     Text(
//                       'No leads assigned to you yet',
//                       style: TextStyle(fontSize: 16, color: Colors.grey),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'Add a new lead or wait for owner to assign you one',
//                       style: TextStyle(fontSize: 14, color: Colors.grey),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               );
//             }
//
//             return TabBarView(
//               children: [
//                 _buildLeadList('new'),
//                 _buildLeadList('all'),
//                 _buildLeadList('inProgress'),
//                 _buildLeadList('completed'),
//               ],
//             );
//           },
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             Get.toNamed(AppRoutes.addLeadScreen);
//           },
//           child: const Icon(Icons.add),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLeadList(String stage) {
//     return GetBuilder<EmployeeHomeController>(
//       builder: (controller) {
//         List<Lead> leads = stage == 'all'
//             ? controller.myLeads
//             : controller.myLeads.where((lead) => lead.stage == stage).toList();
//
//         if (leads.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.filter_list, size: 48, color: Colors.grey),
//                 SizedBox(height: 16),
//                 Text(
//                   'No $stage leads',
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return ListView.builder(
//           itemCount: leads.length,
//           itemBuilder: (context, index) {
//             Lead lead = leads[index];
//             return _buildLeadCard(lead, lead.leadId);
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildLeadCard(Lead lead, String leadId) {
//     Map<String, dynamic> data = lead.toMap();
//     return Card(
//       margin: const EdgeInsets.all(8.0),
//       child: ListTile(
//         leading: CircleAvatar(
//           child: Text(lead.clientName[0]),
//         ),
//         title: Text(
//           lead.clientName,
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('📞 ${lead.clientPhone}'),
//             SizedBox(height: 4),
//             Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: _getStageColor(lead.stage),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     lead.stage,
//                     style: TextStyle(color: Colors.white, fontSize: 12),
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(lead.callStatus),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     lead.callStatus,
//                     style: TextStyle(color: Colors.white, fontSize: 12),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         onTap: () => Get.to(() => LeadDetailsScreen(leadId: leadId, initialData: data)),
//       ),
//     );
//   }
//
//   Color _getStageColor(String stage) {
//     switch (stage) {
//       case 'new': return Colors.blue;
//       case 'inProgress': return Colors.orange;
//       case 'completed': return Colors.green;
//       default: return Colors.grey;
//     }
//   }
//
//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'interested': return Colors.green;
//       case 'notinterested': return Colors.red;
//       case 'numberdoesnotexist': return Colors.purple;
//       case 'numberbusy': return Colors.amber;
//       case 'outofrange': return Colors.redAccent;
//       case 'switchoff': return Colors.grey;
//       case 'willvisitoffice': return Colors.blueAccent;
//       default: return Colors.grey;
//     }
//   }
// }



class EmployeeHomeScreen extends StatelessWidget {
  EmployeeHomeScreen({super.key});

  final EmployeeHomeController controller = Get.put(EmployeeHomeController());

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: WantText(
            text: 'My Leads',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            textColor: Colors.white,
          ),
          backgroundColor: colorMainTheme,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'New'),
              Tab(text: 'All'),
              Tab(text: 'In Progress'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: GetBuilder<EmployeeHomeController>(
          builder: (controller) {
            if (controller.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colorMainTheme),
                    SizedBox(height: 16),
                    WantText(
                      text: 'Loading your leads...',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      textColor: Colors.grey,
                    ),
                  ],
                ),
              );
            }

            if (controller.myLeads.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    WantText(
                      text: 'No leads assigned to you yet',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      textColor: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    WantText(
                      text: 'Add a new lead or wait for owner to assign you one',
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      textColor: Colors.grey,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              children: [
                _buildLeadList('new', width, height),
                _buildLeadList('all', width, height),
                _buildLeadList('inProgress', width, height),
                _buildLeadList('completed', width, height),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: colorMainTheme,
          onPressed: () => Get.toNamed(AppRoutes.addLeadScreen),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLeadList(String stage, double width, double height) {
    return GetBuilder<EmployeeHomeController>(
      builder: (controller) {
        List<Lead> leads = stage == 'all'
            ? controller.myLeads
            : controller.myLeads.where((lead) => lead.stage == stage).toList();

        if (leads.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.filter_list, size: 48, color: Colors.grey),
                SizedBox(height: height * 0.019),
                WantText(
                  text: 'No $stage leads',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  textColor: Colors.grey,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(width * 0.0205), // ~8px
          itemCount: leads.length,
          itemBuilder: (context, index) {
            Lead lead = leads[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.only(bottom: height * 0.019),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorMainTheme,
                  child: WantText(
                    text: lead.clientName[0].toUpperCase(),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    textColor: Colors.white,
                  ),
                ),
                title: WantText(
                  text: lead.clientName,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  textColor: Colors.black,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WantText(
                      text: '📞 ${lead.clientPhone}',
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      textColor: Colors.grey.shade700,
                    ),
                    SizedBox(height: height * 0.0047), // ~4px
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStageColor(lead.stage),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: WantText(
                            text: lead.stage,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            textColor: Colors.white,
                          ),
                        ),
                        SizedBox(width: width * 0.0205),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(lead.callStatus),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: WantText(
                            text: lead.callStatus,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            textColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () => Get.to(() => LeadDetailsScreen(leadId: lead.leadId, initialData: lead.toMap())),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStageColor(String stage) {
    switch (stage) {
      case 'new': return Colors.blue;
      case 'inProgress': return Colors.orange;
      case 'completed': return Colors.green;
      default: return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'interested': return Colors.green;
      case 'notinterested': return Colors.red;
      case 'numberdoesnotexist': return Colors.purple;
      case 'numberbusy': return Colors.amber;
      case 'outofrange': return Colors.redAccent;
      case 'switchoff': return Colors.grey;
      case 'willvisitoffice': return Colors.blueAccent;
      default: return Colors.grey;
    }
  }
}