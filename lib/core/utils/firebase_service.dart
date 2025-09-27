// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:lead_management/core/utils/shred_pref.dart';
// import 'package:lead_management/model/employee_model.dart';
// import 'package:lead_management/model/lead_add_model.dart';
//
// class FirebaseService {
//   static final FirebaseAuth auth = FirebaseAuth.instance;
//   static final FirebaseFirestore fireStore = FirebaseFirestore.instance;
//
//   static Future<Map<String, dynamic>?> loginWithEmail(
//       String email, String password) async {
//     try {
//       final userCredential = await auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       final uid = userCredential.user!.uid;
//       DocumentSnapshot userDoc = await fireStore.collection('users').doc(uid).get();
//
//       if (!userDoc.exists) {
//         String role = email == 'owner@gmail.com' ? 'admin' : 'employee';
//         await fireStore.collection('users').doc(uid).set({
//           'uid': uid,
//           'email': email,
//           'role': role,
//           'createdAt': FieldValue.serverTimestamp(),
//         });
//         userDoc = await fireStore.collection('users').doc(uid).get();
//       }
//
//       final userData = userDoc.data() as Map<String, dynamic>;
//
//       await preferences.putString(SharedPreference.uid, uid);
//       await preferences.putString(SharedPreference.role, userData['role']);
//       await preferences.putString(
//           SharedPreference.email, userData['email'] ?? email);
//       await preferences.putBool(SharedPreference.isLogIn, true);
//
//       return {
//         'uid': uid,
//         'role': userData['role'],
//         'email': userData['email'] ?? email,
//       };
//     } on FirebaseAuthException catch (e) {
//       print("Auth error: ${e.message}");
//       return null;
//     } catch (e) {
//       print("Unexpected error: $e");
//       return null;
//     }
//   }
//
//   static String getCurrentUserId() {
//     return auth.currentUser?.uid ?? '';
//   }
//
//   static Future<List<Employee>> getEmployees() async {
//     try {
//       QuerySnapshot querySnapshot = await fireStore
//           .collection('users')
//           .where('role', isEqualTo: 'employee')
//           .get();
//
//       return querySnapshot.docs.map((doc) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//         return Employee.fromMap(data);
//       }).toList();
//     } catch (e) {
//       print("Error getting employees: $e");
//       return [];
//     }
//   }
//   // Add new lead
//   Future<bool> addLead(Lead lead) async {
//     try {
//       String leadId = fireStore.collection('leads').doc().id;
//       lead.leadId = leadId;
//
//       await fireStore.collection('leads').doc(leadId).set(lead.toMap());
//       return true;
//     } catch (e) {
//       print("Error adding lead: $e");
//       return false;
//     }
//   }
//
//   // Get leads based on role
//   Stream<QuerySnapshot> getLeadsStream() {
//     String currentUserId = getCurrentUserId();
//     String? userRole = preferences.getString(SharedPreference.role);
//
//     if (userRole == 'admin') {
//       // Owner ko saari leads dikhengi
//       return fireStore
//           .collection('leads')
//           .orderBy('createdAt', descending: true)
//           .snapshots();
//     } else {
//       // Employee ko sirf unki assigned leads dikhengi
//       return fireStore
//           .collection('leads')
//           .where('assignedTo', isEqualTo: currentUserId)
//           .orderBy('createdAt', descending: true)
//           .snapshots();
//     }
//   }
//
//   // Update lead status
//   Future<bool> updateLeadStatus(String leadId, String stage, String callStatus) async {
//     try {
//       await fireStore.collection('leads').doc(leadId).update({
//         'stage': stage,
//         'callStatus': callStatus,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//       return true;
//     } catch (e) {
//       print("Error updating lead: $e");
//       return false;
//     }
//   }
//
//   // Set reminder
//   Future<bool> setReminder(String leadId, Timestamp nextFollowUp, String notes) async {
//     try {
//       await fireStore.collection('leads').doc(leadId).update({
//         'nextFollowUp': nextFollowUp,
//         'followUpNotes': notes,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//       return true;
//     } catch (e) {
//       print("Error setting reminder: $e");
//       return false;
//     }
//   }
//   //
//   // Future<void> logout() async {
//   //   await _auth.signOut();
//   //   await preferences.clearUserItem();
//   // }
// }
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