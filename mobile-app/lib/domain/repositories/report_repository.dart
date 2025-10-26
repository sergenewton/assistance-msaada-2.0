import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/report.dart';

abstract class ReportRepository {
  /// Submit a new report
  Future<Either<Failure, Report>> submitReport(Report report);
  
  /// Get all reports for a specific user
  Future<Either<Failure, List<Report>>> getUserReports(String userId);
  
  /// Get a specific report by ID
  Future<Either<Failure, Report>> getReportById(String reportId);
  
  /// Update an existing report
  Future<Either<Failure, Report>> updateReport(Report report);
  
  /// Delete a report
  Future<Either<Failure, bool>> deleteReport(String reportId);
  
  /// Sync pending reports when connection is restored
  Future<Either<Failure, void>> syncPendingReports();
  
  /// Get reports by status
  Future<Either<Failure, List<Report>>> getReportsByStatus(ReportStatus status);
  
  /// Get reports by type
  Future<Either<Failure, List<Report>>> getReportsByType(ReportType type);
  
  /// Get reports by urgency level
  Future<Either<Failure, List<Report>>> getReportsByUrgency(UrgencyLevel urgency);
  
  /// Get recent reports (last 30 days)
  Future<Either<Failure, List<Report>>> getRecentReports(String userId);
  
  /// Search reports by keywords
  Future<Either<Failure, List<Report>>> searchReports(String query, String userId);
  
  /// Get report statistics for a user
  Future<Either<Failure, Map<String, dynamic>>> getReportStatistics(String userId);
}