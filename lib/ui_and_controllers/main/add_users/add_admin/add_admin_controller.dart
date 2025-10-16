import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/utils/extension.dart';

class AddAdminController extends GetxController {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // Add confirm password controller
  final _addressController = TextEditingController();

  final _isLoading = false.obs;
  final _obscurePassword = true.obs;
  final _obscureConfirmPassword = true.obs; // Add confirm password visibility

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getters
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get nameController => _nameController;
  TextEditingController get numberController => _numberController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController => _confirmPasswordController; // Add confirm password getter
  TextEditingController get addressController => _addressController;
  bool get isLoading => _isLoading.value;
  bool get obscurePassword => _obscurePassword.value;
  bool get obscureConfirmPassword => _obscureConfirmPassword.value; // Add confirm password visibility getter

  void togglePasswordVisibility() {
    _obscurePassword.value = !_obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() { // Add confirm password toggle
    _obscureConfirmPassword.value = !_obscureConfirmPassword.value;
  }

  Future<void> addAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _numberController.text.trim(),
        'address': _addressController.text.trim(),
        'password': _passwordController.text.trim(),
        'type': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'createdBy': _auth.currentUser?.uid,
      });

      await _auth.signOut();


      Get.context!.showAppSnackBar(
        message: "Admin created successfully!",
        backgroundColor: colorGreen,
      );

      _clearForm();
      Get.back();

    } on FirebaseAuthException catch (e) {
      String errorMessage = "Error creating add_admin account.";

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
        message: "Error creating add_admin. Please try again.",
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
    _confirmPasswordController.clear();
    _addressController.clear();
  }

  @override
  void onClose() {
    _nameController.dispose();
    _numberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.onClose();
  }
}