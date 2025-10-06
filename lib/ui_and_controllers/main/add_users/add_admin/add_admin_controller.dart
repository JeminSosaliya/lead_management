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
  final _addressController = TextEditingController();
  
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
  bool get isLoading => _isLoading.value;
  bool get obscurePassword => _obscurePassword.value;

  void togglePasswordVisibility() {
    _obscurePassword.value = !_obscurePassword.value;
  }

  Future<void> addAdmin() async {
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

      // Step 3: Save add_admin details to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _numberController.text.trim(),
        'address': _addressController.text.trim(),
        'type': 'admin', // Manually set as admin
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'createdBy': _auth.currentUser?.uid, // Admin who created this admin
      });

      // Step 4: Sign out the newly created add_admin (since we want current add_admin to stay logged in)
      await _auth.signOut();

      // Step 5: Sign back in as current add_admin
      // Note: You might want to store add_admin credentials temporarily or use a different approach
      // For now, we'll just show success message
      
      Get.context!.showAppSnackBar(
        message: "Admin created successfully!",
        backgroundColor: colorGreen,
      );
      
      // Clear form
      _clearForm();
      
      // Navigate back to home screen
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
    _addressController.clear();
  }

  @override
  void onClose() {
    _nameController.dispose();
    _numberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.onClose();
  }
} 