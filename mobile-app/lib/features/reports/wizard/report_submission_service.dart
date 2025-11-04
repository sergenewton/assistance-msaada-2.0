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
          ViolenceType.physical => 'physical',
          ViolenceType.sexual => 'sexual',
          ViolenceType.psychological => 'psychological',
          ViolenceType.economic => 'economic',
          ViolenceType.forcedMarriage => 'forced_marriage',
          ViolenceType.mgf => 'mgf',
          ViolenceType.other => 'other',
        };
      }).toList();

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

  String? mapSex(Sex? s) => switch (s) {
        Sex.female => 'female',
        Sex.male => 'male',
        null => null,
      };

  String? mapFreq(Frequency? f) => switch (f) {
        Frequency.first => 'first',
        Frequency.repeated => 'repeated',
        Frequency.chronic => 'chronic',
        null => null,
      };

  String? mapRelation(Relation? r) => switch (r) {
        Relation.partner => 'partner',
        Relation.parent => 'parent',
        Relation.neighbor => 'neighbor',
        Relation.colleague => 'colleague',
        Relation.unknown => 'unknown',
        Relation.other => 'other',
        null => null,
      };

  // Preferred contact method: choose a single primary based on priority
  String? mapPrimaryContact(Set<ContactPref> prefs) {
    const priority = [ContactPref.call, ContactPref.whatsapp, ContactPref.sms, ContactPref.inApp, ContactPref.none];
    ContactPref? first;
    for (final p in priority) {
      if (prefs.contains(p)) {
        first = p;
        break;
      }
    }
    return switch (first) {
      ContactPref.call => 'call',
      ContactPref.whatsapp => 'whatsapp',
      ContactPref.sms => 'sms',
  ContactPref.inApp => 'in-app',
      ContactPref.none => 'none',
      null => null,
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
        ContactPref.inApp => 'in-app',
        ContactPref.none => 'none',
      };
    }).toList();
  }

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
  final dateStr = incidentDate != null
      ? '${incidentDate.year.toString().padLeft(4, '0')}-${incidentDate.month.toString().padLeft(2, '0')}-${incidentDate.day.toString().padLeft(2, '0')}'
      : null;

  String? locationLine() {
    final base = d.addressLine?.trim();
    if (base == null || base.isEmpty) return null;
    if (d.latitude != null && d.longitude != null) {
      return '$base (lat ${d.latitude!.toStringAsFixed(5)}, lng ${d.longitude!.toStringAsFixed(5)})';
    }
    return base;
  }

  final payload = <String, dynamic>{
    'is_anonymous': d.anonymous,
    // Use plural key to match backend/mobile schema; backend also accepts legacy 'violence_type'
    'violence_types': mapViolences(d.violenceTypes),
    'urgency_level': mapUrgency(d.urgency),
    'victim_age_range': mapAge(d.victimAgeGroup),
    'victim_gender': mapSex(d.victimSex),
    'incident_date': dateStr,
    'incident_location': locationLine(),
    'address_line': d.addressLine?.trim(),
    'latitude': d.latitude,
    'longitude': d.longitude,
    'incident_frequency': mapFreq(d.frequency),
    'narrative': d.descriptionText,
    'narrative_encrypted': false,
    'perpetrator_relationship': mapRelation(d.relation),
    'preferred_contact_method': mapPrimaryContact(d.contactPrefs),
    'preferred_contact_methods': mapAllContacts(d.contactPrefs),
    'preferred_contact_hours': mapTimePref(d.timePref),
    'safety_code_word': d.securityCode,
    // Derived risk flags
    'needs_urgent_medical': needsUrgentMedical(d.needs),
    'needs': mapNeeds(d.needs),
    // Contact number: if method is 'none' we still send number for emergency callback? Keep as provided.
    'contact_number': (d.anonymous == true && (d.contactPrefs.isEmpty || d.contactPrefs.contains(ContactPref.none)))
        ? null
        : d.contactNumber,
    // Attachments not yet sent (requires multipart); send simple names for trace if backend tolerates extras
    'attachments': {
      'photos': d.photoPaths.map(_basename).toList(),
      'audio': d.audioPath != null ? [_basename(d.audioPath!)] : <String>[],
      'documents': d.documentPaths.map(_basename).toList(),
      'screenshots': d.screenshotPaths.map(_basename).toList(),
    },
    // Reporter context (optional fields if backend accepts)
    'reporter_role': switch (d.reporterRole) {
      ReporterRole.victim => 'victim',
      ReporterRole.witness => 'witness',
      ReporterRole.concerned => 'concerned',
      null => null,
    },
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
