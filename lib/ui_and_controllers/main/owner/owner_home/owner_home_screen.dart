// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:lead_management/config/routes/route_manager.dart';
// import 'package:lead_management/core/utils/firebase_service.dart';
// import 'package:lead_management/ui_and_controllers/main/owner/owner_home/owner_home_controller.dart';
//
// class OwnerHomeScreen extends StatelessWidget {
//   OwnerHomeScreen({super.key});
//
//   final OwnerHomeController controller = Get.put(OwnerHomeController());
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 4,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Lead Management - Owner'),
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'New'),
//               Tab(text: 'All'),
//               Tab(text: 'In Progress'),
//               Tab(text: 'Completed'),
//             ],
//           ),
//         ),
//         body: GetBuilder<OwnerHomeController>(
//           builder: (controller) {
//             if (controller.isLoading && controller.allLeads.isEmpty) {
//               return const Center(child: CircularProgressIndicator());
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
//     return GetBuilder<OwnerHomeController>(
//       builder: (controller) {
//         List<QueryDocumentSnapshot> leads = stage == 'all'
//             ? controller.allLeads
//             : controller.allLeads.where((lead) {
//           Map<String, dynamic> data = lead.data() as Map<String, dynamic>;
//           return data['stage'] == stage;
//         }).toList();
//
//         if (leads.isEmpty) {
//           return const Center(
//             child: Text(
//               'No leads found',
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//           );
//         }
//
//         return ListView.builder(
//           itemCount: leads.length,
//           itemBuilder: (context, index) {
//             Map<String, dynamic> data = leads[index].data() as Map<String, dynamic>;
//             return _buildLeadCard(data, leads[index].id);
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildLeadCard(Map<String, dynamic> data, String leadId) {
//     return Card(
//       margin: const EdgeInsets.all(8.0),
//       child: ListTile(
//         title: Text(data['clientName'] ?? 'No Name'),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Phone: ${data['clientPhone'] ?? 'N/A'}'),
//             Text('Stage: ${data['stage'] ?? 'new'}'),
//             Text('Status: ${data['callStatus'] ?? 'notContacted'}'),
//             FutureBuilder<DocumentSnapshot>(
//               future: FirebaseService.fireStore.collection('users').doc(data['assignedTo']).get(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   Map<String, dynamic>? userData = snapshot.data?.data() as Map<String, dynamic>?;
//                   return Text('Assigned To: ${userData?['email']?.split('@')[0] ?? 'Unknown'}');
//                 }
//                 return const Text('Assigned To: Loading...');
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/config/routes/route_manager.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/utils/firebase_service.dart';
import 'package:lead_management/model/lead_add_model.dart';
import 'package:lead_management/ui_and_controllers/main/lead_deatails/lead_details_screen.dart';
import 'package:lead_management/ui_and_controllers/main/owner/owner_home/owner_home_controller.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

// class OwnerHomeScreen extends StatelessWidget {
//   OwnerHomeScreen({super.key});
//
//   final OwnerHomeController controller = Get.put(OwnerHomeController());
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 4,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Lead Management - Owner'),
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'New'),
//               Tab(text: 'All'),
//               Tab(text: 'In Progress'),
//               Tab(text: 'Completed'),
//             ],
//           ),
//         ),
//         body: GetBuilder<OwnerHomeController>(
//           builder: (controller) {
//             if (controller.isLoading && controller.allLeads.isEmpty) {
//               return const Center(child: CircularProgressIndicator());
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
//     return GetBuilder<OwnerHomeController>(
//       builder: (controller) {
//         List<Lead> leads = stage == 'all'
//             ? controller.allLeads
//             : controller.allLeads.where((lead) => lead.stage == stage).toList();
//
//         if (leads.isEmpty) {
//           return const Center(
//             child: Text(
//               'No leads found',
//               style: TextStyle(fontSize: 16, color: Colors.grey),
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
//         title: Text(lead.clientName),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Phone: ${lead.clientPhone}'),
//             Text('Stage: ${lead.stage}'),
//             Text('Status: ${lead.callStatus}'),
//             FutureBuilder<DocumentSnapshot>(
//               future: FirebaseService.fireStore.collection('users').doc(lead.assignedTo).get(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   Map<String, dynamic>? userData = snapshot.data?.data() as Map<String, dynamic>?;
//                   return Text('Assigned To: ${userData?['email']?.split('@')[0] ?? 'Unknown'}');
//                 }
//                 return const Text('Assigned To: Loading...');
//               },
//             ),
//           ],
//         ),
//         onTap: () => Get.to(() => LeadDetailsScreen(leadId: leadId, initialData: data)),
//       ),
//     );
//   }
// }

class OwnerHomeScreen extends StatelessWidget {
  OwnerHomeScreen({super.key});

  final OwnerHomeController controller = Get.put(OwnerHomeController());

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
            text: 'Lead Management - Owner',
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
        body: GetBuilder<OwnerHomeController>(
          builder: (controller) {
            if (controller.isLoading && controller.allLeads.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: colorMainTheme),
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
    return GetBuilder<OwnerHomeController>(
      builder: (controller) {
        List<Lead> leads = stage == 'all'
            ? controller.allLeads
            : controller.allLeads.where((lead) => lead.stage == stage).toList();

        if (leads.isEmpty) {
          return const Center(
            child: WantText(
              text: 'No leads found',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              textColor: Colors.grey,
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(width * 0.0205),
          itemCount: leads.length,
          itemBuilder: (context, index) {
            Lead lead = leads[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.only(bottom: height * 0.019),
              child: ListTile(
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
                      text: 'Phone: ${lead.clientPhone}',
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      textColor: Colors.grey.shade700,
                    ),
                    WantText(
                      text: 'Stage: ${lead.stage.capitalize}',
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      textColor: Colors.grey.shade700,
                    ),
                    WantText(
                      text:
                          'Status: ${lead.callStatus.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}').trim().capitalize}',
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      textColor: Colors.grey.shade700,
                    ),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseService.fireStore
                          .collection('users')
                          .doc(lead.assignedTo)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          Map<String, dynamic>? userData =
                              snapshot.data?.data() as Map<String, dynamic>?;
                          return WantText(
                            text:
                                'Assigned To: ${userData?['email']?.split('@')[0] ?? 'Unknown'}',
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            textColor: Colors.grey.shade700,
                          );
                        }
                        return const WantText(
                          text: 'Assigned To: Loading...',
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          textColor: Colors.grey,
                        );
                      },
                    ),
                  ],
                ),
                onTap: () => Get.to(
                  () => LeadDetailsScreen(
                    leadId: lead.leadId,
                    initialData: lead.toMap(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
