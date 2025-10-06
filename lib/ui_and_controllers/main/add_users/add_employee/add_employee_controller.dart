import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/core/utils/extension.dart';

class AddEmployeeController extends GetxController {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _designationController = TextEditingController();
  
  final _isLoading = false.obs;
  final _obscurePassword = true.obs;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getters
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get nameController => _nameController;
  TextEditingController get numberController => _numberController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get addressController => _addressController;
  TextEditingController get designationController => _designationController;
  bool get isLoading => _isLoading.value;
  bool get obscurePassword => _obscurePassword.value;

  void togglePasswordVisibility() {
    _obscurePassword.value = !_obscurePassword.value;
  }

  Future<void> addUser() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;

    try {
      // Step 1: Create user account with Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Step 2: Update user display name
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      // Step 3: Save user details to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _numberController.text.trim(),
        'address': _addressController.text.trim(),
        'designation': _designationController.text.trim(),
        'type': 'employee',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'createdBy': ListConst.currentUserProfileData.name, // Admin who created this employee
      });

      await _auth.signOut();
      
      Get.context!.showAppSnackBar(
        message: "Employee created successfully!",
        backgroundColor: colorGreen,
      );
      
      // Clear form
      _clearForm();
      
      // Navigate back to home screen
      Get.back();
      
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Error creating employee account.";
      
      switch (e.code) {
        case 'weak-password':
          errorMessage = "Password is too weak.";
          break;
        case 'email-already-in-use':
          errorMessage = "An account already exists with this email.";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email address.";
          break;
        case 'operation-not-allowed':
          errorMessage = "Email/password accounts are not enabled.";
          break;
        default:
          errorMessage = "Error creating account: ${e.message}";
      }
      
      Get.context!.showAppSnackBar(
        message: errorMessage,
        backgroundColor: colorRedCalendar,
      );
    } catch (e) {
      print("Error: $e");
      Get.context!.showAppSnackBar(
        message: "Error creating employee. Please try again.",
        backgroundColor: colorRedCalendar,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void _clearForm() {
    _nameController.clear();
    _numberController.clear();
    _emailController.clear();
    _passwordController.clear();
    _addressController.clear();
    _designationController.clear();
  }

  @override
  void onClose() {
    _nameController.dispose();
    _numberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _designationController.dispose();
    super.onClose();
  }
}
