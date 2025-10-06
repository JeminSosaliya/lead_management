

import 'package:cloud_firestore/cloud_firestore.dart';

class Lead {
  final String leadId;
  final String clientName;
  final String clientPhone;
  final String? clientEmail;
  final String? companyName;
  final String? source;
  final String? description;
  final String assignedTo;
  final String assignedToName;
  final String addedByName;
  final String assignedToRole;
  final String addedBy;
  final String addedByEmail;
  final String addedByRole;
  final String? technician;
  final double? latitude;
  final double? longitude;
  final String? locationAddress;
  final String? address; // Add this line
  final Timestamp createdAt;
  Timestamp updatedAt;
  String stage;
  String callStatus;
  String? callNote;
  Timestamp? nextFollowUp;

  Lead({
    required this.leadId,
    required this.clientName,
    required this.clientPhone,
    this.clientEmail,
    this.companyName,
    this.source,
    this.description,
    required this.assignedTo,
    required this.assignedToName,
    required this.addedByName,
    required this.assignedToRole,
    required this.addedBy,
    required this.addedByEmail,
    required this.addedByRole,
    this.technician,
    this.latitude,
    this.longitude,
    this.locationAddress,
    this.address, // Add this line
    required this.createdAt,
    required this.updatedAt,
    this.stage = 'new',
    this.callStatus = 'notContacted',
    this.callNote,
    this.nextFollowUp,
  });

  factory Lead.fromMap(Map<String, dynamic> map) {
    return Lead(
      leadId: map['leadId'] as String,
      clientName: map['clientName'] as String,
      clientPhone: map['clientPhone'] as String,
      clientEmail: map['clientEmail'] as String?,
      companyName: map['companyName'] as String?,
      source: map['source'] as String?,
      description: map['description'] as String?,
      assignedTo: map['assignedTo'] as String,
      assignedToName: map['assignedToName'] as String,
      addedByName: map['addedByName'] as String,
      assignedToRole: map['assignedToRole'] as String,
      addedBy: map['addedBy'] as String,
      addedByEmail: map['addedByEmail'] as String,
      addedByRole: map['addedByRole'] as String,
      technician: map['technician'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      locationAddress: map['locationAddress'] as String?,
      address: map['address'] as String?, // Add this line
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp,
      stage: map['stage'] as String? ?? 'new',
      callStatus: map['callStatus'] as String? ?? 'notContacted',
      callNote: map['callNote'] as String?,
      nextFollowUp: map['nextFollowUp'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'leadId': leadId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'clientEmail': clientEmail,
      'companyName': companyName,
      'source': source,
      'description': description,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'addedByName': addedByName,
      'assignedToRole': assignedToRole,
      'addedBy': addedBy,
      'addedByEmail': addedByEmail,
      'addedByRole': addedByRole,
      'technician': technician,
      'latitude': latitude,
      'longitude': longitude,
      'locationAddress': locationAddress,
      'address': address, // Add this line
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'stage': stage,
      'callStatus': callStatus,
      'callNote': callNote,
      'nextFollowUp': nextFollowUp,
    };
  }
}