import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/utils/helpers.dart';
import '../entities/report.dart';
import '../repositories/report_repository.dart';

class SubmitReport {
  final ReportRepository repository;

  SubmitReport(this.repository);

  Future<Either<Failure, Report>> call(SubmitReportParams params) async {
    // Validate report data
    final validationResult = _validateReportData(params);
    if (validationResult != null) {
      return Left(ValidationFailure(validationResult));
    }

    // Create report entity
    final report = Report(
      id: params.id ?? Helpers.generateId(),
      userId: params.userId,
      title: params.title.trim(),
      description: params.description.trim(),
      type: params.type,
      status: ReportStatus.pending,
      urgency: params.urgency,
      createdAt: DateTime.now(),
      attachments: params.attachments,
      metadata: params.metadata,
    );

    return await repository.submitReport(report);
  }

  String? _validateReportData(SubmitReportParams params) {
    if (params.userId.isEmpty) {
      return 'User ID is required';
    }

    if (params.title.trim().isEmpty) {
      return 'Title is required';
    }

    if (params.title.trim().length > 200) {
      return 'Title must not exceed 200 characters';
    }

    if (params.description.trim().isEmpty) {
      return 'Description is required';
    }

    if (params.description.trim().length < 10) {
      return 'Description must be at least 10 characters long';
    }

    if (params.description.trim().length > 2000) {
      return 'Description must not exceed 2000 characters';
    }

    return null;
  }
}

class SubmitReportParams {
  final String? id;
  final String userId;
  final String title;
  final String description;
  final ReportType type;
  final UrgencyLevel urgency;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;

  SubmitReportParams({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.urgency,
    this.attachments,
    this.metadata,
  });
}