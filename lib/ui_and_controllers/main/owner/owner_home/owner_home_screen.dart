import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/config/routes/route_manager.dart';
import 'package:lead_management/core/utils/firebase_service.dart';
import 'package:lead_management/ui_and_controllers/main/owner/owner_home/owner_home_controller.dart';

class OwnerHomeScreen extends StatelessWidget {
  OwnerHomeScreen({super.key});

  final OwnerHomeController controller = Get.put(OwnerHomeController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lead Management - Owner'),
          bottom: const TabBar(
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
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              children: [
                _buildLeadList('new'),
                _buildLeadList('all'),
                _buildLeadList('inProgress'),
                _buildLeadList('completed'),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.toNamed(AppRoutes.addLeadScreen);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildLeadList(String stage) {
    return GetBuilder<OwnerHomeController>(
      builder: (controller) {
        List<QueryDocumentSnapshot> leads = stage == 'all'
            ? controller.allLeads
            : controller.allLeads.where((lead) {
          Map<String, dynamic> data = lead.data() as Map<String, dynamic>;
          return data['stage'] == stage;
        }).toList();

        if (leads.isEmpty) {
          return const Center(
            child: Text(
              'No leads found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: leads.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> data = leads[index].data() as Map<String, dynamic>;
            return _buildLeadCard(data, leads[index].id);
          },
        );
      },
    );
  }

  Widget _buildLeadCard(Map<String, dynamic> data, String leadId) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(data['clientName'] ?? 'No Name'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${data['clientPhone'] ?? 'N/A'}'),
            Text('Stage: ${data['stage'] ?? 'new'}'),
            Text('Status: ${data['callStatus'] ?? 'notContacted'}'),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseService.fireStore.collection('users').doc(data['assignedTo']).get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Map<String, dynamic>? userData = snapshot.data?.data() as Map<String, dynamic>?;
                  return Text('Assigned To: ${userData?['email']?.split('@')[0] ?? 'Unknown'}');
                }
                return const Text('Assigned To: Loading...');
              },
            ),
          ],
        ),
      ),
    );
  }
}