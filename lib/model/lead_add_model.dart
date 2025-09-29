// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class Lead {
//   String? leadId;
//   String clientName;
//   String clientPhone;
//   String? clientEmail;
//   String? companyName;
//   String? source;
//   String? description;
//   String stage;
//   String callStatus;
//   String assignedTo; // Employee UID
//   String assignedToEmail; // Employee Email
//   String assignedToRole; // 'employee'
//
//   String addedBy; // Owner/Employee UID
//   String addedByEmail; // Owner/Employee Email
//   String addedByRole;
//   Timestamp createdAt;
//   Timestamp updatedAt;
//
//   Lead({
//     this.leadId,
//     required this.clientName,
//     required this.clientPhone,
//     this.clientEmail,
//     this.companyName,
//     this.source,
//     this.description,
//     this.stage = 'new',
//     this.callStatus = 'notContacted',
//     required this.assignedTo,
//     required this.assignedToEmail,
//     required this.assignedToRole,
//     required this.addedBy,
//     required this.addedByEmail,
//     required this.addedByRole,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       'leadId': leadId,
//       'clientName': clientName,
//       'clientPhone': clientPhone,
//       'clientEmail': clientEmail,
//       'companyName': companyName,
//       'source': source,
//       'description': description,
//       'stage': stage,
//       'callStatus': callStatus,
//       'assignedTo': assignedTo,
//       'assignedToEmail': assignedToEmail,
//       'assignedToRole': assignedToRole,
//       'addedBy': addedBy,
//       'addedByEmail': addedByEmail,
//       'addedByRole': addedByRole,
//       'createdAt': createdAt,
//       'updatedAt': updatedAt,
//     };
//   }
//
//   factory Lead.fromMap(Map<String, dynamic> map) {
//     return Lead(
//       leadId: map['leadId'],
//       clientName: map['clientName'],
//       clientPhone: map['clientPhone'],
//       clientEmail: map['clientEmail'],
//       companyName: map['companyName'],
//       source: map['source'],
//       description: map['description'],
//       stage: map['stage'],
//       callStatus: map['callStatus'],
//       assignedTo: map['assignedTo'],
//       assignedToEmail: map['assignedToEmail'],
//       assignedToRole: map['assignedToRole'],
//       addedBy: map['addedBy'],
//       addedByEmail: map['addedByEmail'],
//       addedByRole: map['addedByRole'],
//       createdAt: map['createdAt'],
//       updatedAt: map['updatedAt'],
//     );
//   }
// }
//
//


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
  final String assignedToEmail;
  final String assignedToRole;
  final String addedBy;
  final String addedByEmail;
  final String addedByRole;
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
    required this.assignedToEmail,
    required this.assignedToRole,
    required this.addedBy,
    required this.addedByEmail,
    required this.addedByRole,
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
      assignedToEmail: map['assignedToEmail'] as String,
      assignedToRole: map['assignedToRole'] as String,
      addedBy: map['addedBy'] as String,
      addedByEmail: map['addedByEmail'] as String,
      addedByRole: map['addedByRole'] as String,
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
      'assignedToEmail': assignedToEmail,
      'assignedToRole': assignedToRole,
      'addedBy': addedBy,
      'addedByEmail': addedByEmail,
      'addedByRole': addedByRole,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'stage': stage,
      'callStatus': callStatus,
      'callNote': callNote,
      'nextFollowUp': nextFollowUp,
    };
  }
}