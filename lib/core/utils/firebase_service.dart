//
// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:lead_management/core/utils/shred_pref.dart';
// import 'package:lead_management/model/employee_model.dart';
// import 'package:lead_management/ui_and_controllers/profile/profile_model.dart';
//
// class FirebaseService {
//
//
//   static Future<List<CurrentUserProfileData>> getEmployees() async {
//     try {
//       final FirebaseAuth _auth = FirebaseAuth.instance;
//
//           final currentUser = _auth.currentUser;
//
//       QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .where('type', isEqualTo: 'employee')
//           .get();
//       log("QuerySnapshot: ${querySnapshot.docs.length} documents found.");
//       log("QuerySnapshot: ${querySnapshot} documents found.");
//
//       return querySnapshot.docs.map((doc) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//         // return CurrentUserProfileData.fromMap(data);
//         return currentUserProfileDataFromJson(json.encode(doc.data()));
//       }).toList();
//     } catch (e) {
//       print("Error getting employees: $e");
//       return [];
//     }
//   }
//
// }