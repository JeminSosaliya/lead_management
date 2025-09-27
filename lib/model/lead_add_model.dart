import 'package:cloud_firestore/cloud_firestore.dart';

class Lead {
  String? leadId;
  String clientName;
  String clientPhone;
  String? clientEmail;
  String? companyName;
  String? source;
  String? description;
  String stage;
  String callStatus;
  String assignedTo;
  String addedBy;
  Timestamp createdAt;
  Timestamp updatedAt;

  Lead({
    this.leadId,
    required this.clientName,
    required this.clientPhone,
    this.clientEmail,
    this.companyName,
    this.source,
    this.description,
    this.stage = 'new',
    this.callStatus = 'notContacted',
    required this.assignedTo,
    required this.addedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'leadId': leadId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'clientEmail': clientEmail,
      'companyName': companyName,
      'source': source,
      'description': description,
      'stage': stage,
      'callStatus': callStatus,
      'assignedTo': assignedTo,
      'addedBy': addedBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Lead.fromMap(Map<String, dynamic> map) {
    return Lead(
      leadId: map['leadId'],
      clientName: map['clientName'],
      clientPhone: map['clientPhone'],
      clientEmail: map['clientEmail'],
      companyName: map['companyName'],
      source: map['source'],
      description: map['description'],
      stage: map['stage'],
      callStatus: map['callStatus'],
      assignedTo: map['assignedTo'],
      addedBy: map['addedBy'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}