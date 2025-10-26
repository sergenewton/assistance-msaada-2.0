import 'package:equatable/equatable.dart';

enum ReportType {
  physicalViolence,
  sexualViolence,
  psychologicalViolence,
  economicViolence,
  harassment,
  discrimination,
  other,
}

enum ReportStatus {
  pending,
  inProgress,
  resolved,
  closed,
  cancelled,
}

enum UrgencyLevel {
  low,
  medium,
  high,
  critical,
}

class Report extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final ReportType type;
  final ReportStatus status;
  final UrgencyLevel urgency;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;
  final String? assignedTo;
  final String? response;

  const Report({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.urgency,
    required this.createdAt,
    this.updatedAt,
    this.attachments,
    this.metadata,
    this.assignedTo,
    this.response,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        type,
        status,
        urgency,
        createdAt,
        updatedAt,
        attachments,
        metadata,
        assignedTo,
        response,
      ];

  /// Get display name for report type
  String get typeDisplayName {
    switch (type) {
      case ReportType.physicalViolence:
        return 'Violence physique';
      case ReportType.sexualViolence:
        return 'Violence sexuelle';
      case ReportType.psychologicalViolence:
        return 'Violence psychologique';
      case ReportType.economicViolence:
        return 'Violence économique';
      case ReportType.harassment:
        return 'Harcèlement';
      case ReportType.discrimination:
        return 'Discrimination';
      case ReportType.other:
        return 'Autre';
    }
  }

  /// Get display name for report status
  String get statusDisplayName {
    switch (status) {
      case ReportStatus.pending:
        return 'En attente';
      case ReportStatus.inProgress:
        return 'En cours';
      case ReportStatus.resolved:
        return 'Résolu';
      case ReportStatus.closed:
        return 'Fermé';
      case ReportStatus.cancelled:
        return 'Annulé';
    }
  }

  /// Get display name for urgency level
  String get urgencyDisplayName {
    switch (urgency) {
      case UrgencyLevel.low:
        return 'Faible';
      case UrgencyLevel.medium:
        return 'Moyen';
      case UrgencyLevel.high:
        return 'Élevé';
      case UrgencyLevel.critical:
        return 'Critique';
    }
  }

  /// Check if report is still active
  bool get isActive {
    return status == ReportStatus.pending || status == ReportStatus.inProgress;
  }

  /// Check if report is completed
  bool get isCompleted {
    return status == ReportStatus.resolved || status == ReportStatus.closed;
  }

  /// Check if report is urgent
  bool get isUrgent {
    return urgency == UrgencyLevel.high || urgency == UrgencyLevel.critical;
  }

  /// Get the number of days since creation
  int get daysSinceCreation {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Check if report has attachments
  bool get hasAttachments {
    return attachments != null && attachments!.isNotEmpty;
  }

  Report copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    ReportType? type,
    ReportStatus? status,
    UrgencyLevel? urgency,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    String? assignedTo,
    String? response,
  }) {
    return Report(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      urgency: urgency ?? this.urgency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      assignedTo: assignedTo ?? this.assignedTo,
      response: response ?? this.response,
    );
  }
}