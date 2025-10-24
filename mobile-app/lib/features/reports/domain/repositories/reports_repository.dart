import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/vbg_report.dart';

abstract class ReportsRepository {
  Future<Either<Failure, List<VbgReport>>> getReports({
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, VbgReport>> getReportById(String id);

  Future<Either<Failure, VbgReport>> createReport({
    required String title,
    required String description,
    required VbgType type,
    required DateTime incidentDate,
    String? location,
    required List<String> evidenceFiles,
    required bool isAnonymous,
  });

  Future<Either<Failure, VbgReport>> updateReport({
    required String id,
    String? title,
    String? description,
    VbgType? type,
    DateTime? incidentDate,
    String? location,
    List<String>? evidenceFiles,
  });

  Future<Either<Failure, void>> deleteReport(String id);
}