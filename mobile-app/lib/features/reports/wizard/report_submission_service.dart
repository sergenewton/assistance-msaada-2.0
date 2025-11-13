
import 'dart:math';
import 'dart:io' show File;
import 'package:http_parser/http_parser.dart' show MediaType;

import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../presentation/screens/report/report_models.dart';

/// Submit the 5-step wizard report to the backend and return a tracking number.
/// Throws [AuthenticationException] if no access token is available.
/// May throw [ServerException] or [NetworkException] for network/server issues.
Future<String> submitWizardReport(ReportFormData data) async {
  // Public submission: no authentication required
  final client = ApiClient();

  // If any binary attachments are present, use multipart upload, else JSON
  final hasPhotos = data.photoPaths.isNotEmpty;
  final hasEvidenceAudio = data.audioPath != null && data.audioPath!.trim().isNotEmpty;
  final hasDescriptionAudio = data.descriptionAudioPath != null && data.descriptionAudioPath!.trim().isNotEmpty;
  final hasFiles = hasPhotos || hasEvidenceAudio || hasDescriptionAudio;

  Future<Map<String, dynamic>> _tryPostJson(String path) async {
    final payload = _buildPayload(data);
    final res = await client.post<Map<String, dynamic>>(
      path,
      data: payload,
      options: Options(contentType: 'application/json'),
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> _tryPostMultipart(String path) async {
    final form = await _buildMultipart(data);
    final res = await client.post<Map<String, dynamic>>(
      path,
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return res.data ?? <String, dynamic>{};
  }

  try {
    Map<String, dynamic> body;
    try {
      body = hasFiles
          ? await _tryPostMultipart(ApiConstants.submitReport)
          : await _tryPostJson(ApiConstants.submitReport);
    } on ServerException catch (se) {
      // Fallback to generic /reports if submit path is not found/method not allowed
      if (se.statusCode == 404 || se.statusCode == 405) {
        body = hasFiles
            ? await _tryPostMultipart(ApiConstants.reports)
            : await _tryPostJson(ApiConstants.reports);
      } else {
        rethrow;
      }
    }

    final tracking = body['report_number'] ??
        body['tracking_number'] ??
        body['tracking'] ??
        body['reference'] ??
        (body['data'] is Map ? (body['data']['report_number'] ?? body['data']['reference']) : null) ??
        body['id'];

    if (tracking is String && tracking.trim().isNotEmpty) return tracking;
    if (tracking is int) return 'ID-$tracking';
    return _fallbackTracking();
  } on Exception catch (e) {
    if (e is AuthorizationException || e is ValidationException || e is ServerException || e is NetworkException) {
      rethrow;
    }
    throw ServerException(e.toString());
  }
}

Map<String, dynamic> _buildPayload(ReportFormData d) {
  String? mapUrgency(Urgency? u) => switch (u) {
        Urgency.critical => 'critical',
        Urgency.high => 'high',
        Urgency.moderate => 'moderate',
        Urgency.low => 'low',
        null => null,
      };

  List<String> mapViolences(Set<ViolenceType> vs) => vs.map((v) {
        return switch (v) {
          // Detailed categories
          ViolenceType.rape => 'rape',
          ViolenceType.sexualAssault => 'sexual_assault',
          ViolenceType.sexualHarassment => 'sexual_harassment',
          ViolenceType.sexualExploitation => 'sexual_exploitation',
          ViolenceType.forcedMarriage => 'forced_marriage',
          ViolenceType.femaleGenitalMutilation => 'female_genital_mutilation',
          ViolenceType.incest => 'incest',
          ViolenceType.sextortion => 'sextortion',
          ViolenceType.physicalAssault => 'physical_assault',
          ViolenceType.denialResources => 'denial_resources',
          ViolenceType.psychologicalViolence => 'psychological_violence',
          ViolenceType.sexualSlavery => 'sexual_slavery',
          ViolenceType.other => 'other',
         
        };

  

      }).toList();

  // Backend expects enumerated ranges
  String? mapAge(AgeGroup? a) => switch (a) {
        AgeGroup.a0_5 => '0-5',
        AgeGroup.a6_12 => '6-12',
        AgeGroup.a13_17 => '13-17',
        AgeGroup.a18_25 => '18-25',
        AgeGroup.a26_35 => '26-35',
        AgeGroup.a36_50 => '36-50',
        AgeGroup.a50plus => '50+',
        null => null,
      };

  // Backend enum: 'female' | 'male' | ...
  String? mapSex(Sex? s) => switch (s) {
        Sex.female => 'female',
        Sex.male => 'male',
        null => null,
      };

  // Backend enum: 'first_time' | 'repeated' | 'chronic'
  String? mapFreq(Frequency? f) => switch (f) {
        Frequency.first => 'first_time',
        Frequency.repeated => 'repeated',
        Frequency.chronic => 'chronic',
        null => null,
      };

  // Map perpetrator relationship to backend enum values
  String? mapRelation(Relation? r) => switch (r) {
        Relation.familyMember => 'family_member',
        Relation.employer => 'employer',
        Relation.colleague => 'colleague',
        Relation.teacher => 'teacher',
        Relation.authority => 'authority',
        Relation.religiousLeader => 'religious_leader',
        Relation.neighbor => 'neighbor',
        Relation.stranger => 'stranger',
        Relation.partner => 'partner',
        Relation.parent => 'parent',
        Relation.unknown => 'unknown',
        Relation.other => 'other',
        null => null,
      };

  // Preferred contact method: choose a single primary based on priority
  String? mapPrimaryContact(Set<ContactPref> prefs) {
    // If more than one method is selected, keep primary null per request
    if (prefs.length != 1) return null;
    final first = prefs.first;
    return switch (first) {
      ContactPref.call => 'call',
      ContactPref.whatsapp => 'whatsapp',
      ContactPref.sms => 'sms',
      ContactPref.inApp => 'in_app',
      ContactPref.none => 'none',
    };
  }

  // Keep all selected contact methods as well for traceability
  List<String>? mapAllContacts(Set<ContactPref> prefs) {
    if (prefs.isEmpty) return null;
    return prefs.map((p) {
      return switch (p) {
        ContactPref.call => 'call',
        ContactPref.whatsapp => 'whatsapp',
        ContactPref.sms => 'sms',
        ContactPref.inApp => 'in_app',
        ContactPref.none => 'none',
      };
    }).toList();
  }

  // Store as single value; backend column is JSON, but a single string is acceptable JSON; if needed, change to list below
  String? mapTimePref(TimePref? t) => switch (t) {
        TimePref.morning => 'morning',
        TimePref.afternoon => 'afternoon',
        TimePref.evening => 'evening',
        null => null,
      };

  // Booleans derived from needs when sensible
  bool? needsUrgentMedical(Set<NeedType> needs) => needs.contains(NeedType.medical) ? true : null;

  Map<String, bool>? mapNeeds(Set<NeedType> needs) {
    if (needs.isEmpty) return null;
    return {
      'psycho': needs.contains(NeedType.psychological),
      'medical': needs.contains(NeedType.medical),
      'legal': needs.contains(NeedType.legal),
      'shelter': needs.contains(NeedType.shelter),
      'economic': needs.contains(NeedType.economic),
      'police': needs.contains(NeedType.policeProtection),
    };
  }

  final incidentDate = d.incidentDate;
  final dateStr = incidentDate != null ? incidentDate.toUtc().toIso8601String() : null;

  String? locationLine() {
    final base = d.addressLine?.trim();
    if (base == null || base.isEmpty) return null;
    if (d.latitude != null && d.longitude != null) {
      return '$base (lat ${d.latitude!.toStringAsFixed(5)}, lng ${d.longitude!.toStringAsFixed(5)})';
    }
    return base;
  }

  String? mapIncidentPlace(IncidentPlace? p) => switch (p) {
        IncidentPlace.domicile => 'domicile',
        IncidentPlace.travail => 'travail',
        IncidentPlace.espacePublic => 'espace_public',
        IncidentPlace.autre => 'autre',
        null => null,
      };

  final payload = <String, dynamic>{
    'is_anonymous': d.anonymous,
    // Use plural key to match backend/mobile schema; backend also accepts legacy 'violence_type'
    'violence_types': mapViolences(d.violenceTypes),
    'urgency_level': mapUrgency(d.urgency),
    'victim_age_range': mapAge(d.victimAgeGroup),
    'victim_gender': mapSex(d.victimSex),
  'incident_date': dateStr,
  'incident_frequency': mapFreq(d.frequency),
    // Prefer the place selector if provided; otherwise keep address string for backward compatibility
    'incident_location': mapIncidentPlace(d.incidentPlace) ?? locationLine(),
    'address_line': d.addressLine?.trim(),
    'latitude': d.latitude,
    'longitude': d.longitude,
    'narrative': d.descriptionText,
    'narrative_encrypted': false,
    'perpetrator_relationship': mapRelation(d.relation),
    'preferred_contact_method': mapPrimaryContact(d.contactPrefs),
    'preferred_contact_methods': mapAllContacts(d.contactPrefs),
  // If backend strictly expects an array, wrap the single value
  'preferred_contact_hours': d.timePref == null ? null : [mapTimePref(d.timePref)],
    'safety_code_word': d.securityCode,
  // Derived risk flags
  'needs_urgent_medical': d.needsUrgentMedical,
  'is_safe_now': d.isSafeNow,
  'children_at_risk': d.childrenAtRisk,
  'death_threats': d.deathThreats,
    'needs': mapNeeds(d.needs),
    'perpetrator_has_home_access': d.perpetratorHasHomeAccess,
    'location_province': d.locationProvince,
    'location_commune': d.locationCommune,
    'location_quartier': d.locationQuartier,
    // Contact number: if method is 'none' we still send number for emergency callback? Keep as provided.
    'contact_number': (d.anonymous == true && (d.contactPrefs.isEmpty || d.contactPrefs.contains(ContactPref.none)))
        ? null
        : d.contactNumber,
    // Attachments not yet sent (requires multipart); send simple names for trace if backend tolerates extras
    'attachments': {
      'photos': d.photoPaths.map(_basename).toList(),
      'audio': d.audioPath != null ? [_basename(d.audioPath!)] : <String>[],
    },
    // Reporter context (optional fields if backend accepts)
    'reporter_name': (d.anonymous == true)
        ? null
        : (d.reporterRole == ReporterRole.victim ? null : d.reporterName),
    'victim_name': (d.anonymous == true) ? null : d.victimName,
  };

  // Remove nulls recursively
  return _removeNulls(payload);
}

Map<String, dynamic> _removeNulls(Map<String, dynamic> input) {
  final out = <String, dynamic>{};
  input.forEach((key, value) {
    if (value == null) return;
    if (value is Map<String, dynamic>) {
      final nested = _removeNulls(value);
      if (nested.isNotEmpty) out[key] = nested;
    } else if (value is List) {
      final list = value.where((e) => e != null).toList();
      if (list.isNotEmpty) out[key] = list;
    } else {
      out[key] = value;
    }
  });
  return out;
}

String _basename(String p) {
  final parts = p.split(RegExp(r'[\\/]'));
  return parts.isNotEmpty ? parts.last : p;
}

String _fallbackTracking() {
  final n1 = (Random().nextInt(9000) + 1000).toString();
  final n2 = (Random().nextInt(9000) + 1000).toString();
  return 'VBG-$n1-$n2';
}

/// Build a multipart form with text fields flattened and files attached.
/// For arrays, this uses the `field[]` convention commonly supported by backends.
Future<FormData> _buildMultipart(ReportFormData d) async {
  final payload = _buildPayload(d);

  // Remove the non-multipart-friendly attachments summary if present
  payload.remove('attachments');

  final form = FormData();

  void addField(String key, dynamic value) {
    if (value == null) return;
    if (value is List) {
      for (final v in value) {
        addField('${key}[]', v);
      }
    } else if (value is Map<String, dynamic>) {
      // Flatten one level using dot-notation
      value.forEach((k, v) => addField('$key.$k', v));
    } else {
      form.fields.add(MapEntry(key, value.toString())) ;
    }
  }

  // Add all text fields
  payload.forEach((k, v) => addField(k, v));

  // Attach photos (max 5 already enforced in UI)
  for (final p in d.photoPaths) {
    try {
      if (p.trim().isEmpty) continue;
      // On mobile, use File; on web, skip (not supported in this implementation)
      final file = File(p);
      if (await file.exists()) {
        form.files.add(MapEntry(
          'photos[]',
          await MultipartFile.fromFile(
            file.path,
            filename: _basename(file.path),
            contentType: MediaType('image', _inferImageSubtype(file.path)),
          ),
        ));
      }
    } catch (_) { /* ignore individual file errors */ }
  }

  // Attach description audio (step 2 recording)
  if (d.descriptionAudioPath != null && d.descriptionAudioPath!.trim().isNotEmpty) {
    try {
      final file = File(d.descriptionAudioPath!);
      if (await file.exists()) {
        form.files.add(MapEntry(
          'description_audio',
          await MultipartFile.fromFile(
            file.path,
            filename: _basename(file.path),
            contentType: MediaType('audio', _inferAudioSubtype(file.path)),
          ),
        ));
      }
    } catch (_) {}
  }

  // Attach evidence audio (step 4 file)
  if (d.audioPath != null && d.audioPath!.trim().isNotEmpty) {
    try {
      final file = File(d.audioPath!);
      if (await file.exists()) {
        form.files.add(MapEntry(
          'audio_evidence',
          await MultipartFile.fromFile(
            file.path,
            filename: _basename(file.path),
            contentType: MediaType('audio', _inferAudioSubtype(file.path)),
          ),
        ));
      }
    } catch (_) {}
  }

  return form;
}

String _inferImageSubtype(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'png';
  if (lower.endsWith('.webp')) return 'webp';
  if (lower.endsWith('.gif')) return 'gif';
  return 'jpeg';
}

String _inferAudioSubtype(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.m4a')) return 'm4a';
  if (lower.endsWith('.aac')) return 'aac';
  if (lower.endsWith('.wav')) return 'wav';
  if (lower.endsWith('.ogg')) return 'ogg';
  if (lower.endsWith('.mp3')) return 'mpeg';
  return 'mpeg';
}
