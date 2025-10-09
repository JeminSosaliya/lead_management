import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/model/lead_add_model.dart';

class AnalyticsController extends GetxController {
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  
  final isLoading = true.obs;
  final isLoadingEmployees = true.obs;
  final isLoadingTechnicians = true.obs;
  final allLeads = <Lead>[].obs;
  final employees = <Map<String, dynamic>>[].obs;
  final technicians = <Map<String, dynamic>>[].obs;
  
  final selectedEmployeeId = Rxn<String>();
  final selectedEmployeeName = Rxn<String>();
  final selectedTechnicianId = Rxn<String>();
  final selectedTechnicianName = Rxn<String>();
  
  final newCount = 0.obs;
  final inProgressCount = 0.obs;
  final completedCount = 0.obs;
  final cancelledCount = 0.obs;
  final newList = <Lead>[].obs;
  final inProgressList = <Lead>[].obs;
  final completedList = <Lead>[].obs;
  final cancelledList = <Lead>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadEmployees();
    loadTechnicians();
    loadAnalytics();
  }
  
  Future<void> loadEmployees() async {
    isLoadingEmployees.value = true;
    
    try {
      QuerySnapshot querySnapshot = await fireStore
          .collection('users')
          .where('type', isEqualTo: 'employee')
          .get();
      
      employees.value = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'email': data['email'] ?? '',
          'type': data['type'] ?? 'employee',
        };
      }).toList();
      
      // Sort by name
      employees.sort((a, b) => a['name'].compareTo(b['name']));
      
    } catch (e) {
      print("Error loading employees: $e");
    }
    
    isLoadingEmployees.value = false;
  }
  
  Future<void> loadTechnicians() async {
    isLoadingTechnicians.value = true;
    
    try {
      // Get the technician_list document from technicians collection
      DocumentSnapshot docSnapshot = await fireStore
          .collection('technicians')
          .doc('technician_list')
          .get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final technicianList = data['technicianList'] as List<dynamic>?;
        debugPrint('Technician List:: $technicianList');
        
        if (technicianList != null) {
          technicians.value = technicianList.asMap().entries.map((entry) {
            int index = entry.key;
            String technicianName = entry.value.toString();
            
            return {
              'id': 'technician_$index', // Generate a unique ID
              'name': technicianName,
              'email': '', // No email available in the array
              'type': 'technician',
            };
          }).toList();
          
          // Sort by name
          technicians.sort((a, b) => a['name'].compareTo(b['name']));
        }
      }
      
    } catch (e) {
      print("Error loading technicians: $e");
    }
    
    isLoadingTechnicians.value = false;
  }
  
  Future<void> loadAnalytics() async {
    isLoading.value = true;
    
    try {
      QuerySnapshot querySnapshot = await fireStore
          .collection('leads')
          .get();
      
      allLeads.value = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Lead.fromMap(data);
      }).toList();
      
      calculateStatistics();
      
    } catch (e) {
      print("Error loading analytics: $e");
    }
    
    isLoading.value = false;
  }
  
  void selectEmployee(String? employeeId, String? employeeName) {
    selectedEmployeeId.value = employeeId;
    selectedEmployeeName.value = employeeName;
    // Don't clear technician selection - allow both to be selected
    calculateStatistics();
  }
  
  void selectTechnician(String? technicianId, String? technicianName) {
    selectedTechnicianId.value = technicianId;
    selectedTechnicianName.value = technicianName;
    // Don't clear employee selection - allow both to be selected
    calculateStatistics();
  }
  
  void calculateStatistics() {
    // Filter leads by both employee and technician selections
    List<Lead> filteredLeads = allLeads;
    
    // Apply employee filter if selected
    if (selectedEmployeeId.value != null) {
      filteredLeads = filteredLeads.where((lead) => lead.assignedTo == selectedEmployeeId.value).toList();
    }
    
    // Apply technician filter if selected
    if (selectedTechnicianId.value != null) {
      filteredLeads = filteredLeads.where((lead) => lead.technician == selectedTechnicianName.value).toList();
    }
    
    // Calculate counts for each stage
    newCount.value = filteredLeads.where((lead) => lead.stage == 'new').length;
    newList.value = filteredLeads.where((lead) => lead.stage == 'new').toList();
    inProgressCount.value = filteredLeads.where((lead) => lead.stage == 'inProgress').length;
    inProgressList.value = filteredLeads.where((lead) => lead.stage == 'inProgress').toList();
    completedCount.value = filteredLeads.where((lead) => lead.stage == 'completed').length;
    completedList.value = filteredLeads.where((lead) => lead.stage == 'completed').toList();
    cancelledCount.value = filteredLeads.where((lead) => lead.stage == 'cancelled').length;
    cancelledList.value = filteredLeads.where((lead) => lead.stage == 'cancelled').toList();
  }
  
  int get totalLeads {
    List<Lead> filteredLeads = allLeads;
    
    // Apply employee filter if selected
    if (selectedEmployeeId.value != null) {
      filteredLeads = filteredLeads.where((lead) => lead.assignedTo == selectedEmployeeId.value).toList();
    }
    
    // Apply technician filter if selected
    if (selectedTechnicianId.value != null) {
      filteredLeads = filteredLeads.where((lead) => lead.technician == selectedTechnicianName.value).toList();
    }
    
    return filteredLeads.length;
  }
  
  double getPercentage(int count) {
    if (totalLeads == 0) return 0;
    return (count / totalLeads) * 100;
  }
  
  void clearFilters() {
    selectedEmployeeId.value = null;
    selectedEmployeeName.value = null;
    selectedTechnicianId.value = null;
    selectedTechnicianName.value = null;
    calculateStatistics();
  }
  
  // Helper getters for UI
  String? get selectedStaffName {
    if (selectedEmployeeName.value != null) return selectedEmployeeName.value;
    if (selectedTechnicianName.value != null) return selectedTechnicianName.value;
    return null;
  }
  
  String? get selectedStaffType {
    if (selectedEmployeeId.value != null) return 'employee';
    if (selectedTechnicianId.value != null) return 'technician';
    return null;
  }
  
  // New getter to show combined selection info
  String get filterDescription {
    List<String> filters = [];
    
    if (selectedEmployeeName.value != null) {
      filters.add('Employee: ${selectedEmployeeName.value}');
    }
    
    if (selectedTechnicianName.value != null) {
      filters.add('Technician: ${selectedTechnicianName.value}');
    }
    
    if (filters.isEmpty) {
      return 'All Leads';
    }
    
    return filters.join(' + ');
  }
}
