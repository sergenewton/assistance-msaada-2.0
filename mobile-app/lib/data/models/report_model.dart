import '../../domain/entities/report.dart';

class ReportModel extends Report {
  const ReportModel({
    required String id,
    required String userId,
    required String title,
    required String description,
    required ReportType type,
    required ReportStatus status,
    required UrgencyLevel urgency,
    required DateTime createdAt,
    DateTime? updatedAt,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    String? assignedTo,
    String? response,
  }) : super(
    id: id,
    userId: userId,
    title: title,
    description: description,
    type: type,
    status: status,
    urgency: urgency,
    createdAt: createdAt,
    updatedAt: updatedAt,
    attachments: attachments,
    metadata: metadata,
    assignedTo: assignedTo,
    response: response,
  );

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ReportType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ReportType.other,
      ),
      status: ReportStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ReportStatus.pending,
      ),
      urgency: UrgencyLevel.values.firstWhere(
        (e) => e.toString().split('.').last == json['urgency'],
        orElse: () => UrgencyLevel.medium,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'] as List)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      assignedTo: json['assigned_to'] as String?,
      response: json['response'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'urgency': urgency.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'attachments': attachments,
      'metadata': metadata,
      'assigned_to': assignedTo,
      'response': response,
    };
  }

  ReportModel copyWith({
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
    return ReportModel(
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