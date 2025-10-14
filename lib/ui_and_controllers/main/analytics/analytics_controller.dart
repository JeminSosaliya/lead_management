import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/model/lead_add_model.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constant/app_color.dart';

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

  // Stage lists
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

  List<Lead> get filteredLeads {
    var leads = allLeads.toList();


    if (selectedEmployeeId.value != null) {
      leads = leads
          .where((lead) => lead.assignedTo == selectedEmployeeId.value)
          .toList();
      print('After employee filter: ${leads.length} leads');
    }

    if (selectedTechnicianId.value != null) {
      leads = leads
          .where((lead) => lead.technician == selectedTechnicianName.value)
          .toList();
      print('After technician filter: ${leads.length} leads');
    }

    print('Final filtered leads: ${leads.length}');
    // for(var lead in leads){
    //   log('leads is ${lead.stage} and ${lead.clientName}');
    // }
    return leads;
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
          'type': 'employee',
        };
      }).toList();

      employees.sort((a, b) => a['name'].compareTo(b['name']));
      print('Loaded ${employees.length} employees');
    } catch (e) {
      print("Error loading employees: $e");
    }
    isLoadingEmployees.value = false;
  }

  Future<void> loadTechnicians() async {
    isLoadingTechnicians.value = true;
    try {
      DocumentSnapshot docSnapshot = await fireStore
          .collection('technicians')
          .doc('technician_list')
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final technicianList = data['technicianList'] as List<dynamic>?;

        if (technicianList != null) {
          technicians.value = technicianList.asMap().entries.map((entry) {
            int index = entry.key;
            String name = entry.value.toString();
            return {
              'id': 'technician_$index',
              'name': name,
              'email': '',
              'type': 'technician',
            };
          }).toList();

          technicians.sort((a, b) => a['name'].compareTo(b['name']));
          print('Loaded ${technicians.length} technicians');
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
      QuerySnapshot querySnapshot = await fireStore.collection('leads').get();
      allLeads.value = querySnapshot.docs
          .map((doc) => Lead.fromMap(doc.data() as Map<String, dynamic>))
          .toList();



      for (var lead in allLeads) {
        log('Lead: ${lead.clientName}, Stage: ${lead.stage}, AssignedTo: ${lead.assignedTo}, Technician: ${lead.technician}');
      }

      calculateStatistics();
    } catch (e) {
      print("Error loading analytics: $e");
    }
    isLoading.value = false;
  }

  void selectEmployee(String? id, String? name) {
    print('Selecting employee: $id - $name');
    selectedEmployeeId.value = id;
    selectedEmployeeName.value = name;
    calculateStatistics();
  }

  void selectTechnician(String? id, String? name) {
    print('Selecting technician: $id - $name');
    selectedTechnicianId.value = id;
    selectedTechnicianName.value = name;
    calculateStatistics();
  }

  void calculateStatistics() {
    final leads = filteredLeads;

    print('=== CALCULATING STATISTICS ===');
    print('Filtered leads count: ${leads.length}');

    // Reset counts
    newCount.value = 0;
    inProgressCount.value = 0;
    completedCount.value = 0;
    cancelledCount.value = 0;

    // Calculate counts
    for (var lead in leads) {
      switch (lead.stage) {
        case 'notContacted':
          newCount.value++;
          break;
        case 'inProgress':
          inProgressCount.value++;
          break;
        case 'completed':
          completedCount.value++;
          break;
        case 'cancelled':
          cancelledCount.value++;
          break;
      }
    }

    // Update lists
    newList.value = leads.where((l) => l.stage == 'new').toList();
    inProgressList.value = leads.where((l) => l.stage == 'inProgress').toList();
    completedList.value = leads.where((l) => l.stage == 'completed').toList();
    cancelledList.value = leads.where((l) => l.stage == 'cancelled').toList();

    print('=== STATISTICS RESULTS ===');
    print('New: ${newCount.value}');
    print('In Progress: ${inProgressCount.value}');
    print('Completed: ${completedCount.value}');
    print('Cancelled: ${cancelledCount.value}');
    print('Total: ${totalLeads}');

    // Print percentages
    print('=== PERCENTAGES ===');
    print('New: ${getPercentage(newCount.value).toStringAsFixed(1)}%');
    print('In Progress: ${getPercentage(inProgressCount.value).toStringAsFixed(1)}%');
    print('Completed: ${getPercentage(completedCount.value).toStringAsFixed(1)}%');
    print('Cancelled: ${getPercentage(cancelledCount.value).toStringAsFixed(1)}%');
  }

  int get totalLeads => filteredLeads.length;

  double getPercentage(int count) {
    if (totalLeads == 0) return 0.0;
    final percentage = (count / totalLeads) * 100;
    return percentage.isNaN ? 0.0 : percentage;
  }

  void clearFilters() {
    print('Clearing all filters');
    selectedEmployeeId.value = null;
    selectedEmployeeName.value = null;
    selectedTechnicianId.value = null;
    selectedTechnicianName.value = null;
    calculateStatistics();
  }

  String? get selectedStaffName =>
      selectedEmployeeName.value ?? selectedTechnicianName.value;

  String? get selectedStaffType => selectedEmployeeId.value != null
      ? 'employee'
      : selectedTechnicianId.value != null
      ? 'technician'
      : null;

  String get filterDescription {
    final filters = <String>[];
    if (selectedEmployeeName.value != null) {
      filters.add('Employee: ${selectedEmployeeName.value}');
    }
    if (selectedTechnicianName.value != null) {
      filters.add('Technician: ${selectedTechnicianName.value}');
    }
    return filters.isEmpty ? 'All Leads' : filters.join(' + ');
  }

  // Rest of your existing methods (exportFilteredLeadsToExcel, etc.) remain the same...
  Future<void> exportFilteredLeadsToExcel() async {
    try {
      bool granted = await _requestStoragePermission();
      if (!granted) return;

      final excel = Excel.createExcel();
      final sheet = excel['Leads'];

      sheet.appendRow([
        TextCellValue('Index'),
        TextCellValue('Name'),
        TextCellValue('Phone'),
        TextCellValue('Email'),
        TextCellValue('Status'),
      ]);

      for (int i = 0; i < filteredLeads.length; i++) {
        final lead = filteredLeads[i];
        sheet.appendRow([
          IntCellValue(i + 1),
          TextCellValue(lead.clientName),
          TextCellValue(lead.clientPhone),
          TextCellValue(lead.clientEmail ?? ''),
          TextCellValue(lead.stage),
        ]);
      }

      String filePath;

      if (Platform.isAndroid) {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (!downloadsDir.existsSync()) {
          downloadsDir.createSync(recursive: true);
        }
        filePath = p.join(
          downloadsDir.path,
          'Leads_${DateTime.now().millisecondsSinceEpoch}.xlsx',
        );
      } else {
        final dir = await getApplicationDocumentsDirectory();
        filePath = p.join(
          dir.path,
          'Leads_${DateTime.now().millisecondsSinceEpoch}.xlsx',
        );
      }

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);
      Get.context?.showAppSnackBar(
        textColor: Colors.white,
        backgroundColor: Colors.green,
        message: 'Excel exported at: $filePath',
      );

      await _showOpenFileDialog(filePath);
    } catch (e) {
      print("Error exporting Excel: $e");
      Get.context?.showAppSnackBar(
        textColor: Colors.white,
        backgroundColor: Colors.red,
        message: 'Failed to export Excel: $e',
      );
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      Permission permission = sdkInt >= 30
          ? Permission.manageExternalStorage
          : Permission.storage;

      PermissionStatus status = await permission.status;

      while (!status.isGranted) {
        status = await permission.request();

        if (status.isPermanentlyDenied) {
          Get.context?.showAppSnackBar(
            textColor: Colors.white,
            backgroundColor: Colors.red,
            message:
            'Permission Required,Please enable storage permission from settings to export Excel.',
          );
          return false;
        }

        if (status.isGranted) break;
      }

      return status.isGranted;
    } else if (Platform.isIOS) {
      PermissionStatus status = await Permission.storage.status;

      while (!status.isGranted) {
        status = await Permission.storage.request();

        if (status.isPermanentlyDenied) {
          Get.context?.showAppSnackBar(
            textColor: Colors.white,
            backgroundColor: Colors.red,
            message:
            'Permission Required,Please enable storage permission from settings to export Excel.',
          );

          return false;
        }

        if (status.isGranted) break;
      }

      return status.isGranted;
    }

    return true;
  }

  Future<void> _showOpenFileDialog(String filePath) async {
    await Get.dialog(
      Dialog(
        backgroundColor: colorWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.file_present, size: 48, color: colorCustomButton),
              const SizedBox(height: 16),
              Text(
                "Open Excel File?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorMainTheme,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Do you want to open the exported Excel file now?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: colorDarkGreyText),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      "No",
                      style: TextStyle(
                        color: colorRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorCustomButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      Get.back();
                      await OpenFilex.open(filePath);
                    },
                    child: const Text(
                      "Yes",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}