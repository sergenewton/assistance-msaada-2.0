import 'package:flutter/foundation.dart';

// Enums covering choices in the 5-step wizard
enum ReporterRole { victim, witness, concerned }
enum Urgency { critical, high, moderate, low }
enum ViolenceType {
  physical,
  sexual,
  psychological,
  economic,
  forcedMarriage,
  mgf,
  other,
}

enum AgeGroup { a0_5, a6_12, a13_17, a18_25, a26_35, a36_50, a50plus }
enum Sex { female, male }
enum Frequency { first, repeated, chronic }
enum Relation {
  partner,
  parent,
  neighbor,
  colleague,
  unknown,
  other,
}
enum NeedType {
  psychological,
  medical,
  legal,
  shelter,
  economic,
  policeProtection,
  other,
}
enum ContactPref { sms, call, whatsapp, inApp, none }
enum TimePref { morning, afternoon, evening }

@immutable
class ReportFormData {
  final bool? anonymous;
  final ReporterRole? reporterRole;
  final Urgency? urgency;
  final Set<ViolenceType> violenceTypes;

  // Identity
  final String? reporterName;
  final String? victimName;

  // Victim details
  final AgeGroup? victimAgeGroup;
  final Sex? victimSex;
  // Nationalité supprimée sur demande

  // Incident details
  final DateTime? incidentDate;
  final String? addressLine; // Adresse saisie libre
  final double? latitude;
  final double? longitude;
  final Frequency? frequency;
  final Relation? relation;
  final String? descriptionText;
  final String? descriptionAudioPath;

  // Needs
  final Set<NeedType> needs;

  // Evidence (store names/paths only for now)
  final List<String> photoPaths;
  final String? audioPath;
  final List<String> documentPaths;
  final List<String> screenshotPaths;

  // Contact
  final String? contactNumber;
  final Set<ContactPref> contactPrefs; // multi-select
  final TimePref? timePref;
  final String? securityCode;

  const ReportFormData({
    this.anonymous,
    this.reporterRole,
    this.urgency,
    this.violenceTypes = const {},
    this.reporterName,
    this.victimName,
    this.victimAgeGroup,
  this.victimSex,
    this.incidentDate,
  this.addressLine,
    this.latitude,
    this.longitude,
    this.frequency,
    this.relation,
    this.descriptionText,
    this.descriptionAudioPath,
    this.needs = const {},
    this.photoPaths = const [],
    this.audioPath,
    this.documentPaths = const [],
    this.screenshotPaths = const [],
    this.contactNumber,
    this.contactPrefs = const {},
    this.timePref,
    this.securityCode,
  });

  ReportFormData copyWith({
    bool? anonymous,
    ReporterRole? reporterRole,
    Urgency? urgency,
    Set<ViolenceType>? violenceTypes,
    String? reporterName,
    String? victimName,
    AgeGroup? victimAgeGroup,
    Sex? victimSex,
    DateTime? incidentDate,
  String? addressLine,
    double? latitude,
    double? longitude,
    Frequency? frequency,
    Relation? relation,
    String? descriptionText,
    String? descriptionAudioPath,
    Set<NeedType>? needs,
    List<String>? photoPaths,
    String? audioPath,
    List<String>? documentPaths,
    List<String>? screenshotPaths,
    String? contactNumber,
    Set<ContactPref>? contactPrefs,
    TimePref? timePref,
    String? securityCode,
  }) {
    return ReportFormData(
      anonymous: anonymous ?? this.anonymous,
      reporterRole: reporterRole ?? this.reporterRole,
      urgency: urgency ?? this.urgency,
      violenceTypes: violenceTypes ?? this.violenceTypes,
      reporterName: reporterName ?? this.reporterName,
      victimName: victimName ?? this.victimName,
      victimAgeGroup: victimAgeGroup ?? this.victimAgeGroup,
      victimSex: victimSex ?? this.victimSex,
  // nationality removed
      incidentDate: incidentDate ?? this.incidentDate,
  addressLine: addressLine ?? this.addressLine,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      frequency: frequency ?? this.frequency,
      relation: relation ?? this.relation,
      descriptionText: descriptionText ?? this.descriptionText,
      descriptionAudioPath: descriptionAudioPath ?? this.descriptionAudioPath,
      needs: needs ?? this.needs,
      photoPaths: photoPaths ?? this.photoPaths,
      audioPath: audioPath ?? this.audioPath,
      documentPaths: documentPaths ?? this.documentPaths,
      screenshotPaths: screenshotPaths ?? this.screenshotPaths,
      contactNumber: contactNumber ?? this.contactNumber,
      contactPrefs: contactPrefs ?? this.contactPrefs,
      timePref: timePref ?? this.timePref,
      securityCode: securityCode ?? this.securityCode,
    );
  }
}
