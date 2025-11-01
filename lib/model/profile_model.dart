import 'dart:convert';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// To parse this JSON data, do
//
//     final currentUserProfileData = currentUserProfileDataFromJson(jsonString);

CurrentUserProfileData currentUserProfileDataFromJson(String str) => CurrentUserProfileData.fromJson(json.decode(str));

String currentUserProfileDataToJson(CurrentUserProfileData data) => json.encode(data.toJson());

class CurrentUserProfileData {
  String? address;
  DateTime? createdAt;
  String? createdBy;
  String? designation;
  String? email;
  bool? isActive;
  String? name;
  String? phone;
  String? type;
  String? uid;
  DateTime? updatedAt;
  String? password;

  CurrentUserProfileData({
    this.address,
    this.createdAt,
    this.createdBy,
    this.designation,
    this.email,
    this.isActive,
    this.name,
    this.phone,
    this.type,
    this.uid,
    this.updatedAt,
    this.password,
  });

  factory CurrentUserProfileData.fromJson(Map<String, dynamic> json) => CurrentUserProfileData(
    address: json["address"],
    createdAt: _parseDateTime(json["createdAt"]),
    createdBy: json["createdBy"],
    designation: json["designation"],
    email: json["email"],
    isActive: json["isActive"],
    name: json["name"],
    phone: json["phone"],
    type: json["type"],
    uid: json["uid"],
    updatedAt: _parseDateTime(json["updatedAt"]),
    password: json["password"],
  );

  Map<String, dynamic> toJson() => {
  // Map<String, dynamic> toJson() => {
    "address": address,
    "createdAt": createdAt?.toIso8601String(),
    "createdBy": createdBy,
    "designation": designation,
    "email": email,
    "isActive": isActive,
    "name": name,
    "phone": phone,
    "type": type,
    "uid": uid,
    "updatedAt": updatedAt?.toIso8601String(),
    "password": password,
  };

  // Updated to handle both ISO 8601 and custom format
  static DateTime? _parseDateTime(dynamic dateStr) {
    if (dateStr == null) return null;
    try {
      if (dateStr is String) {
        // Try ISO 8601 format first
        try {
          return DateTime.parse(dateStr).toUtc();
        } catch (e) {
          // Fall back to custom format if ISO fails
          final dateFormat = DateFormat("MMMM dd, yyyy 'at' h:mm:ss a 'UTC'Z");
          return dateFormat.parse(dateStr, true);
        }
      } else if (dateStr is Timestamp) {
        return dateStr.toDate(); // Convert Timestamp to DateTime
      }
      return null; // Return null for unsupported types
    } catch (e) {
      developer.log("Error parsing date $dateStr: $e");
      return null; // Return null on parse failure
    }
  }
}