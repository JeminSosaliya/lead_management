import 'dart:convert';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lead_management/core/constant/constant.dart';
import 'package:lead_management/core/constant/list_const.dart';
import 'package:lead_management/model/profile_model.dart';

class ProfileController extends GetxController {
  final _isLoading = true.obs;
  final _errorMessage = ''.obs;

  bool get isLoading => _isLoading.value;

  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    fetchEmployeeData();
  }

  Future<void> fetchEmployeeData() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final currentUser = _auth.currentUser;
      developer.log(
        "currentUser>>> ${currentUser?.uid ?? 'No user logged in'}",
      ); // Improved log with UID

      if (currentUser == null) {
        _errorMessage.value = 'No user logged in';
        developer.log("No authenticated user found. Skipping fetch.");
        return;
      }

      final DocumentSnapshot value = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      developer.log("Document exists: ${value.exists}");
      developer.log("Document data: ${value.data()}"); // Log raw data for debug

      if (value.exists && value.data() != null) {
        Map<String, dynamic> data = value.data() as Map<String, dynamic>;
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp)
              .toDate()
              .toIso8601String();
        }
        if (data['updatedAt'] is Timestamp) {
          data['updatedAt'] = (data['updatedAt'] as Timestamp)
              .toDate()
              .toIso8601String();
        }
        developer.log("Converted data: $data");

        String jsonString = json.encode(data);
        developer.log("Encoded JSON: $jsonString");

        ListConst.currentUserProfileData = currentUserProfileDataFromJson(
          jsonString,
        );
        developer.log(
          "currentUserProfileData: ${ListConst.currentUserProfileData}",
        );
        developer.log("Parsing successful.");
      } else {
        _errorMessage.value = 'User profile not found';
        developer.log("No document or data found for UID: ${currentUser.uid}");

        return;
      }

      developer.log("currentUser::>>> ${currentUser.uid}");
      final userProfile = ListConst.currentUserProfileData;
      developer.log(
        "userProfile::>>> ${userProfile?.name ?? 'No profile'}",
      ); // Safer log

      if (userProfile != null) {
        if (userProfile.isActive != null) {
          isCurrentUserActive.value = userProfile.isActive!;
          developer.log(
            "isCurrentUserActive >>>>>> ${isCurrentUserActive.value}",
          );
        }
        if (userProfile.name != null) {
          currentUserName.value = userProfile.name!;
          developer.log("currentUserName >>>>>> ${currentUserName.value}");
        }
        if (userProfile.email != null) {
          currentUserEmail.value = userProfile.email!;
          developer.log("currentUserEmail >>>>>> ${currentUserEmail.value}");
        }
        if (userProfile.phone != null) {
          currentUserPhone.value = userProfile.phone!;
          developer.log("currentUserPhone >>>>>> ${currentUserPhone.value}");
        }
        if (userProfile.designation != null) {
          currentUserDesignation.value = userProfile.designation!;
          developer.log(
            "currentUserDesignation >>>>>> ${currentUserDesignation.value}",
          );
        }
        if (userProfile.address != null) {
          currentUserAddress.value = userProfile.address!;
          developer.log(
            "currentUserAddress >>>>>> ${currentUserAddress.value}",
          );
        }
        if (userProfile.type != null) {
          currentUserType.value = userProfile.type!;
          developer.log("currentUserType >>>>>> ${currentUserType.value}");
        }
        if (userProfile.uid != null) {
          currentUserUid.value = userProfile.uid!;
          developer.log("currentUserUid >>>>>> ${currentUserUid.value}");
        }
        if (userProfile.createdBy != null) {
          currentUserCreatedBy.value = userProfile.createdBy!;
          developer.log(
            "currentUserCreatedBy >>>>>> ${currentUserCreatedBy.value}",
          );
        }
        if (userProfile.createdAt != null) {
          currentUserCreatedAt.value = userProfile.createdAt!.toIso8601String();
          developer.log(
            "currentUserCreatedAt >>>>>> ${currentUserCreatedAt.value}",
          );
        }
        if (userProfile.updatedAt != null) {
          currentUserUpdatedAt.value = userProfile.updatedAt!.toIso8601String();
          developer.log(
            "currentUserUpdatedAt >>>>>> ${currentUserUpdatedAt.value}",
          );
        }
        if (userProfile.password != null) {
          currentUserPassword.value = userProfile.password!;
          developer.log(
            "currentUserPassword >>>>>> ${currentUserPassword.value}",
          );
        }
      }
    } catch (e) {
      _errorMessage.value = 'Error loading profile: $e';
      developer.log(
        "Error fetching user profile data: $e",
        stackTrace: StackTrace.current,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await fetchEmployeeData();
  }
}
