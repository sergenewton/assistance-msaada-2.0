import 'package:equatable/equatable.dart';

enum VbgType {
  violence_physique,
  violence_sexuelle,
  violence_psychologique,
  violence_economique,
  harcelement,
  autre
}

enum ReportStatus {
  draft,
  submitted,
  in_progress,
  resolved,
  rejected
}

class VbgReport extends Equatable {
  final String id;
  final String title;
  final String description;
  final VbgType type;
  final ReportStatus status;
  final DateTime incidentDate;
  final String? location;
  final List<String> evidenceFiles;
  final String reporterId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isAnonymous;

  const VbgReport({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.incidentDate,
    this.location,
    required this.evidenceFiles,
    required this.reporterId,
    required this.createdAt,
    required this.updatedAt,
    required this.isAnonymous,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        status,
        incidentDate,
        location,
        evidenceFiles,
        reporterId,
        createdAt,
        updatedAt,
        isAnonymous,
      ];
}