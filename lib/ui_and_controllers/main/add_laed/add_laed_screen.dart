// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:lead_management/core/constant/app_color.dart';
// import 'package:lead_management/core/utils/extension.dart';
// import 'package:lead_management/core/utils/shred_pref.dart';
// import 'package:lead_management/ui_and_controllers/main/add_laed/add_lead_controller.dart';
//
// class AddLeadScreen extends StatelessWidget {
//   AddLeadScreen({super.key});
//
//   final AddLeadController controller = Get.put(AddLeadController());
//   final _formKey = GlobalKey<FormState>();
//
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _companyController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     String currentUserRole = preferences.getString(SharedPreference.role) ?? '';
//     bool isOwner = currentUserRole == 'admin';
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(isOwner ? 'Add New Lead' : 'Add My Lead'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: GetBuilder<AddLeadController>(
//         builder: (controller) {
//           if (controller.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: ListView(
//                 children: [
//                   TextFormField(
//                     controller: _nameController,
//                     decoration: const InputDecoration(
//                       labelText: 'Client Name*',
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty)
//                         return 'Please enter client name';
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//
//                   TextFormField(
//                     controller: _phoneController,
//                     decoration: const InputDecoration(
//                       labelText: 'Phone Number*',
//                     ),
//                     keyboardType: TextInputType.phone,
//                     validator: (value) {
//                       if (value == null || value.isEmpty)
//                         return 'Please enter phone number';
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//
//                   TextFormField(
//                     controller: _emailController,
//                     decoration: const InputDecoration(labelText: 'Email'),
//                     keyboardType: TextInputType.emailAddress,
//                   ),
//                   const SizedBox(height: 16),
//
//                   TextFormField(
//                     controller: _companyController,
//                     decoration: const InputDecoration(
//                       labelText: 'Company Name',
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//
//                   DropdownButtonFormField<String>(
//                     decoration: const InputDecoration(labelText: 'Source'),
//                     value: controller.selectedSource,
//                     items: controller.sources.map((source) {
//                       return DropdownMenuItem<String>(
//                         value: source,
//                         child: Text(source),
//                       );
//                     }).toList(),
//                     onChanged: controller.setSelectedSource,
//                   ),
//                   const SizedBox(height: 16),
//
//                   if (isOwner) ...[
//                     DropdownButtonFormField<String>(
//                       decoration: const InputDecoration(
//                         labelText: 'Assign To Employee*',
//                       ),
//                       value: controller.selectedEmployee,
//                       validator: (value) {
//                         if (value == null) {
//                           return 'Please select an employee';
//                         }
//                         return null;
//                       },
//                       items: controller.employees.map<DropdownMenuItem<String>>(
//                         (employee) {
//                           return DropdownMenuItem<String>(
//                             value: employee.uid,
//                             child: Text(employee.name),
//                           );
//                         },
//                       ).toList(),
//                       onChanged: controller.setSelectedEmployee,
//                     ),
//                     const SizedBox(height: 16),
//                   ],
//
//                   TextFormField(
//                     controller: _descriptionController,
//                     decoration: const InputDecoration(
//                       labelText: 'Description/Notes',
//                     ),
//                     maxLines: 3,
//                   ),
//                   const SizedBox(height: 24),
//
//                   ElevatedButton(
//                     onPressed: controller.isSubmitting
//                         ? null
//                         : () => _submitForm(),
//                     child: controller.isSubmitting
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : Text(isOwner ? 'Add Lead' : 'Add My Lead'),
//                   ),
//
//                   if (!isOwner) ...[
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Note: This lead will be automatically assigned to you',
//                       style: TextStyle(
//                         color: Colors.grey,
//                         fontStyle: FontStyle.italic,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       bool success = await controller.addLead(
//         clientName: _nameController.text.trim(),
//         clientPhone: _phoneController.text.trim(),
//         clientEmail: _emailController.text.trim().isEmpty
//             ? null
//             : _emailController.text.trim(),
//         companyName: _companyController.text.trim().isEmpty
//             ? null
//             : _companyController.text.trim(),
//         description: _descriptionController.text.trim().isEmpty
//             ? null
//             : _descriptionController.text.trim(),
//       );
//
//       if (success) {
//         Get.back();
//         Get.context?.showAppSnackBar(
//           message: "Lead added successfully",
//           backgroundColor: colorGreen,
//           textColor: colorWhite,
//         );
//       }
//     }
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/core/utils/shred_pref.dart';
import 'package:lead_management/ui_and_controllers/main/add_laed/add_lead_controller.dart';
//
// class AddLeadScreen extends StatelessWidget {
//   AddLeadScreen({super.key});
//
//   final AddLeadController controller = Get.put(AddLeadController());
//   final _formKey = GlobalKey<FormState>();
//
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _companyController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _followUpController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     String currentUserRole = preferences.getString(SharedPreference.role) ?? '';
//     bool isOwner = currentUserRole == 'admin';
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(isOwner ? 'Add New Lead' : 'Add My Lead'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: GetBuilder<AddLeadController>(
//         builder: (controller) {
//           if (controller.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: ListView(
//                 children: [
//                   TextFormField(
//                     controller: _nameController,
//                     decoration: const InputDecoration(
//                       labelText: 'Client Name*',
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty)
//                         return 'Please enter client name';
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//
//                   TextFormField(
//                     controller: _phoneController,
//                     decoration: const InputDecoration(
//                       labelText: 'Phone Number*',
//                     ),
//                     keyboardType: TextInputType.phone,
//                     validator: (value) {
//                       if (value == null || value.isEmpty)
//                         return 'Please enter phone number';
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//
//                   TextFormField(
//                     controller: _emailController,
//                     decoration: const InputDecoration(labelText: 'Email'),
//                     keyboardType: TextInputType.emailAddress,
//                   ),
//                   const SizedBox(height: 16),
//
//                   TextFormField(
//                     controller: _companyController,
//                     decoration: const InputDecoration(
//                       labelText: 'Company Name',
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//
//                   DropdownButtonFormField<String>(
//                     decoration: const InputDecoration(labelText: 'Source'),
//                     value: controller.selectedSource,
//                     items: controller.sources.map((source) {
//                       return DropdownMenuItem<String>(
//                         value: source,
//                         child: Text(source),
//                       );
//                     }).toList(),
//                     onChanged: controller.setSelectedSource,
//                   ),
//                   const SizedBox(height: 16),
//
//                   if (isOwner) ...[
//                     DropdownButtonFormField<String>(
//                       decoration: const InputDecoration(
//                         labelText: 'Assign To Employee*',
//                       ),
//                       value: controller.selectedEmployee,
//                       validator: (value) {
//                         if (value == null) {
//                           return 'Please select an employee';
//                         }
//                         return null;
//                       },
//                       items: controller.employees.map<DropdownMenuItem<String>>(
//                             (employee) {
//                           return DropdownMenuItem<String>(
//                             value: employee.uid,
//                             child: Text(employee.name),
//                           );
//                         },
//                       ).toList(),
//                       onChanged: controller.setSelectedEmployee,
//                     ),
//                     const SizedBox(height: 16),
//                   ],
//
//                   TextFormField(
//                     controller: _descriptionController,
//                     decoration: const InputDecoration(
//                       labelText: 'Description/Notes',
//                     ),
//                     maxLines: 3,
//                   ),
//                   const SizedBox(height: 16),
//
//                   TextFormField(
//                     controller: _followUpController,
//                     decoration: const InputDecoration(labelText: 'Initial Follow-up Date & Time'),
//                     readOnly: true,
//                     onTap: () async {
//                       DateTime? date = await showDatePicker(
//                         context: context,
//                         initialDate: DateTime.now(),
//                         firstDate: DateTime.now(),
//                         lastDate: DateTime(2100),
//                       );
//                       if (date != null) {
//                         TimeOfDay? time = await showTimePicker(
//                           context: context,
//                           initialTime: TimeOfDay.now(),
//                         );
//                         if (time != null) {
//                           DateTime dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
//                           _followUpController.text = dateTime.toString();
//                           controller.nextFollowUp = dateTime;
//                         }
//                       }
//                     },
//                   ),
//                   const SizedBox(height: 24),
//
//                   ElevatedButton(
//                     onPressed: controller.isSubmitting
//                         ? null
//                         : () => _submitForm(),
//                     child: controller.isSubmitting
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : Text(isOwner ? 'Add Lead' : 'Add My Lead'),
//                   ),
//
//                   if (!isOwner) ...[
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Note: This lead will be automatically assigned to you',
//                       style: TextStyle(
//                         color: Colors.grey,
//                         fontStyle: FontStyle.italic,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       bool success = await controller.addLead(
//         clientName: _nameController.text.trim(),
//         clientPhone: _phoneController.text.trim(),
//         clientEmail: _emailController.text.trim().isEmpty
//             ? null
//             : _emailController.text.trim(),
//         companyName: _companyController.text.trim().isEmpty
//             ? null
//             : _companyController.text.trim(),
//         description: _descriptionController.text.trim().isEmpty
//             ? null
//             : _descriptionController.text.trim(),
//         nextFollowUp: controller.nextFollowUp,
//       );
//
//       if (success) {
//         Get.back();
//         Get.context?.showAppSnackBar(
//           message: "Lead added successfully",
//           backgroundColor: colorGreen,
//           textColor: colorWhite,
//         );
//       }
//     }
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/utils/extension.dart';
import 'package:lead_management/core/utils/shred_pref.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_textformfield.dart';
import 'package:lead_management/ui_and_controllers/widgets/custom_button.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';

class AddLeadScreen extends StatelessWidget {
  AddLeadScreen({super.key});

  final AddLeadController controller = Get.put(AddLeadController());
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _followUpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width; // 390px reference
    double height = MediaQuery.of(context).size.height; // 844px reference
    String currentUserRole = preferences.getString(SharedPreference.role) ?? '';
    bool isOwner = currentUserRole == 'admin';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: WantText(
          text: isOwner ? 'Add New Lead' : 'Add My Lead',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          textColor: Colors.white,
        ),
        backgroundColor: colorMainTheme,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<AddLeadController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(width * 0.041),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFormField(
                      hintText: 'Client Name*',
                      controller: _nameController,
                      prefixIcon: Icon(Icons.person, color: Colors.grey),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter client name';
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.019), // ~16px

                    CustomTextFormField(
                      hintText: 'Phone Number*',
                      controller: _phoneController,
                      prefixIcon: Icon(Icons.phone, color: Colors.grey),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter phone number';
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.019),

                    CustomTextFormField(
                      hintText: 'Email',
                      controller: _emailController,
                      prefixIcon: Icon(Icons.email, color: Colors.grey),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: height * 0.019),

                    CustomTextFormField(
                      hintText: 'Company Name',
                      controller: _companyController,
                      prefixIcon: Icon(Icons.business, color: Colors.grey),
                    ),
                    SizedBox(height: height * 0.019),

                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        label: WantText(text: 'Source', fontSize: 14, fontWeight: FontWeight.w500, textColor: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      value: controller.selectedSource,
                      items: controller.sources.map((source) {
                        return DropdownMenuItem<String>(value: source, child: Text(source));
                      }).toList(),
                      onChanged: controller.setSelectedSource,
                    ),
                    SizedBox(height: height * 0.019),

                    if (isOwner) ...[
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          label: WantText(text: 'Assign To Employee*', fontSize: 14, fontWeight: FontWeight.w500, textColor: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        value: controller.selectedEmployee,
                        validator: (value) {
                          if (value == null) return 'Please select an employee';
                          return null;
                        },
                        items: controller.employees.map<DropdownMenuItem<String>>((employee) {
                          return DropdownMenuItem<String>(value: employee.uid, child: Text(employee.name));
                        }).toList(),
                        onChanged: controller.setSelectedEmployee,
                      ),
                      SizedBox(height: height * 0.019),
                    ],

                    CustomTextFormField(
                      hintText: 'Description/Notes',
                      controller: _descriptionController,
                      maxLines: 3,
                      prefixIcon: Icon(Icons.note, color: Colors.grey),
                    ),
                    SizedBox(height: height * 0.019),

                    CustomTextFormField(
                      hintText: 'Initial Follow-up Date & Time',
                      controller: _followUpController,
                      readOnly: true,
                      onTap: () async {
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            DateTime dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                            _followUpController.text = dateTime.toString();
                            controller.nextFollowUp = dateTime;
                          }
                        }
                      },
                      prefixIcon: Icon(Icons.calendar_today, color: Colors.grey),
                    ),
                    SizedBox(height: height * 0.028), // ~24px

                    CustomButton(
                      Width: width,
                      onTap: controller.isSubmitting ? null : () => _submitForm(),
                      label: isOwner ? 'Add Lead' : 'Add My Lead',
                      backgroundColor: colorMainTheme,
                      textColor: Colors.white,
                      fontSize: 16,
                      boarderRadius: 8,
                    ),

                    // if (!isOwner) ...[
                    //   SizedBox(height: height * 0.019),
                    //   WantText(
                    //     text: 'Note: This lead will be automatically assigned to you',
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.normal,
                    //     textColor: Colors.grey,
                    //     textAlign: TextAlign.center,
                    //   ),
                    // ],
                  ],
                ),
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
        nextFollowUp: controller.nextFollowUp,
      );

      if (success) {
        Get.back();
        Get.context?.showAppSnackBar(
          message: "Lead added successfully",
          backgroundColor: colorGreen,
          textColor: colorWhite,
        );
      }
    }
  }
}