import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/utils/shred_pref.dart';
import 'package:lead_management/ui_and_controllers/main/add_laed/add_lead_controller.dart';

class AddLeadScreen extends StatelessWidget {
  AddLeadScreen({super.key});

  final AddLeadController controller = Get.put(AddLeadController());
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String currentUserRole = preferences.getString(SharedPreference.role) ?? '';
    bool isOwner = currentUserRole == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(isOwner ? 'Add New Lead' : 'Add My Lead'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<AddLeadController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Client Name*'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter client name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number*'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter phone number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _companyController,
                    decoration: const InputDecoration(labelText: 'Company Name'),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Source'),
                    value: controller.selectedSource,
                    items: controller.sources.map((source) {
                      return DropdownMenuItem<String>(
                        value: source,
                        child: Text(source),
                      );
                    }).toList(),
                    onChanged: controller.setSelectedSource,
                  ),
                  const SizedBox(height: 16),

                  // SIRF OWNER KE LIYE EMPLOYEE DROPDOWN
                  if (isOwner) ...[
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Assign To Employee*'),
                      value: controller.selectedEmployee,
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an employee';
                        }
                        return null;
                      },
                      items: controller.employees.map<DropdownMenuItem<String>>((employee) {
                        return DropdownMenuItem<String>(
                          value: employee.uid,
                          child: Text(employee.name),
                        );
                      }).toList(),
                      onChanged: controller.setSelectedEmployee,
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description/Notes'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: controller.isSubmitting ? null : () => _submitForm(),
                    child: controller.isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(isOwner ? 'Add Lead' : 'Add My Lead'),
                  ),

                  // EMPLOYEE KE LIYE MESSAGE
                  if (!isOwner) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Note: This lead will be automatically assigned to you',
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      bool success = await controller.addLead(
        clientName: _nameController.text.trim(),
        clientPhone: _phoneController.text.trim(),
        clientEmail: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        companyName: _companyController.text.trim().isEmpty ? null : _companyController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      );

      if (success) {
        Get.back();
        Get.snackbar('Success', 'Lead added successfully!');
      }
    }
  }
}