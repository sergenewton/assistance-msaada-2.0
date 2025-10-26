import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/report.dart';
import '../repositories/report_repository.dart';

class GetReportStatus {
  final ReportRepository repository;

  GetReportStatus(this.repository);

  Future<Either<Failure, ReportStatusResult>> call(String reportId) async {
    if (reportId.isEmpty) {
      return const Left(ValidationFailure('Report ID is required'));
    }

    final result = await repository.getReportById(reportId);
    
    return result.fold(
      (failure) => Left(failure),
      (report) {
        final statusResult = ReportStatusResult(
          report: report,
          statusHistory: _generateStatusHistory(report),
          estimatedResolutionTime: _estimateResolutionTime(report),
          nextActions: _getNextActions(report),
        );
        return Right(statusResult);
      },
    );
  }

  List<StatusHistoryItem> _generateStatusHistory(Report report) {
    final history = <StatusHistoryItem>[];
    
    // Add creation entry
    history.add(StatusHistoryItem(
      status: ReportStatus.pending,
      timestamp: report.createdAt,
      description: 'Signalement créé',
    ));

    // Add current status if different from pending
    if (report.status != ReportStatus.pending) {
      history.add(StatusHistoryItem(
        status: report.status,
        timestamp: report.updatedAt ?? report.createdAt,
        description: _getStatusDescription(report.status),
      ));
    }

    return history;
  }

  String _getStatusDescription(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'En attente de traitement';
      case ReportStatus.inProgress:
        return 'Pris en charge par notre équipe';
      case ReportStatus.resolved:
        return 'Signalement résolu';
      case ReportStatus.closed:
        return 'Dossier fermé';
      case ReportStatus.cancelled:
        return 'Signalement annulé';
    }
  }

  Duration? _estimateResolutionTime(Report report) {
    if (report.isCompleted) return null;

    switch (report.urgency) {
      case UrgencyLevel.critical:
        return const Duration(hours: 24);
      case UrgencyLevel.high:
        return const Duration(days: 3);
      case UrgencyLevel.medium:
        return const Duration(days: 7);
      case UrgencyLevel.low:
        return const Duration(days: 14);
    }
  }

  List<String> _getNextActions(Report report) {
    switch (report.status) {
      case ReportStatus.pending:
        return [
          'Votre signalement est en cours d\'analyse',
          'Vous recevrez une notification dès qu\'il sera pris en charge',
        ];
      case ReportStatus.inProgress:
        return [
          'Notre équipe travaille sur votre signalement',
          'Vous pouvez ajouter des informations si nécessaire',
          'Nous vous tiendrons informé des développements',
        ];
      case ReportStatus.resolved:
        return [
          'Votre signalement a été résolu',
          'Vous pouvez consulter la réponse de notre équipe',
          'N\'hésitez pas à nous contacter si vous avez des questions',
        ];
      case ReportStatus.closed:
        return [
          'Ce dossier est maintenant clos',
          'Vous pouvez créer un nouveau signalement si nécessaire',
        ];
      case ReportStatus.cancelled:
        return [
          'Ce signalement a été annulé',
          'Vous pouvez créer un nouveau signalement si nécessaire',
        ];
    }
  }
}

class ReportStatusResult {
  final Report report;
  final List<StatusHistoryItem> statusHistory;
  final Duration? estimatedResolutionTime;
  final List<String> nextActions;

  ReportStatusResult({
    required this.report,
    required this.statusHistory,
    this.estimatedResolutionTime,
    required this.nextActions,
  });
}

class StatusHistoryItem {
  final ReportStatus status;
  final DateTime timestamp;
  final String description;

  StatusHistoryItem({
    required this.status,
    required this.timestamp,
    required this.description,
  });
}