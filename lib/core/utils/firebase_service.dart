
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lead_management/core/utils/shred_pref.dart';
import 'package:lead_management/model/employee_model.dart';

class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static String getCurrentUserId() {
    return auth.currentUser?.uid ?? '';
  }

  static Future<List<Employee>> getEmployees() async {
    try {
      QuerySnapshot querySnapshot = await fireStore
          .collection('users')
          .where('role', isEqualTo: 'employee')
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Employee.fromMap(data);
      }).toList();
    } catch (e) {
      print("Error getting employees: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>?> loginWithEmail(
      String email, String password) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      DocumentSnapshot userDoc = await fireStore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        String role = email == 'owner@gmail.com' ? 'admin' : 'employee';
        await fireStore.collection('users').doc(uid).set({
          'uid': uid,
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });
        userDoc = await fireStore.collection('users').doc(uid).get();
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      await preferences.putString(SharedPreference.uid, uid);
      await preferences.putString(SharedPreference.role, userData['role']);
      await preferences.putString(
          SharedPreference.email, userData['email'] ?? email);
      await preferences.putBool(SharedPreference.isLogIn, true);

      return {
        'uid': uid,
        'role': userData['role'],
        'email': userData['email'] ?? email,
      };
    } on FirebaseAuthException catch (e) {
      print("Auth error: ${e.message}");
      return null;
    } catch (e) {
      print("Unexpected error: $e");
      return null;
    }
  }
}