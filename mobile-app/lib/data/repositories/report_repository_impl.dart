import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/remote/report_remote_datasource.dart';
import '../datasources/local/cache_datasource.dart';
import '../models/report_model.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;
  final CacheDataSource cacheDataSource;
  final NetworkInfo networkInfo;

  ReportRepositoryImpl({
    required this.remoteDataSource,
    required this.cacheDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Report>> submitReport(Report report) async {
    try {
      if (await networkInfo.isConnected) {
        final reportModel = ReportModel(
          id: report.id,
          userId: report.userId,
          title: report.title,
          description: report.description,
          type: report.type,
          status: report.status,
          urgency: report.urgency,
          createdAt: report.createdAt,
          updatedAt: report.updatedAt,
          attachments: report.attachments,
          metadata: report.metadata,
          assignedTo: report.assignedTo,
          response: report.response,
        );
        
        final result = await remoteDataSource.submitReport(reportModel);
        
        // Cache the submitted report
        await cacheDataSource.cacheReport(result);
        
        return Right(result);
      } else {
        // If no internet, save to local cache for later sync
        final reportModel = ReportModel(
          id: report.id,
          userId: report.userId,
          title: report.title,
          description: report.description,
          type: report.type,
          status: ReportStatus.pending,
          urgency: report.urgency,
          createdAt: report.createdAt,
          updatedAt: report.updatedAt,
          attachments: report.attachments,
          metadata: report.metadata,
          assignedTo: report.assignedTo,
          response: report.response,
        );
        
        await cacheDataSource.cachePendingReport(reportModel);
        return Right(reportModel);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Report>>> getUserReports(String userId) async {
    try {
      if (await networkInfo.isConnected) {
        final reports = await remoteDataSource.getUserReports(userId);
        
        // Cache the reports
        for (final report in reports) {
          await cacheDataSource.cacheReport(report);
        }
        
        return Right(reports);
      } else {
        // If no internet, get from cache
        final cachedReports = await cacheDataSource.getCachedReports(userId);
        return Right(cachedReports);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Report>> getReportById(String reportId) async {
    try {
      if (await networkInfo.isConnected) {
        final report = await remoteDataSource.getReportById(reportId);
        
        // Cache the report
        await cacheDataSource.cacheReport(report);
        
        return Right(report);
      } else {
        // If no internet, get from cache
        final cachedReport = await cacheDataSource.getCachedReportById(reportId);
        if (cachedReport != null) {
          return Right(cachedReport);
        } else {
          return const Left(CacheFailure('Report not found in cache'));
        }
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Report>> updateReport(Report report) async {
    try {
      if (await networkInfo.isConnected) {
        final reportModel = ReportModel(
          id: report.id,
          userId: report.userId,
          title: report.title,
          description: report.description,
          type: report.type,
          status: report.status,
          urgency: report.urgency,
          createdAt: report.createdAt,
          updatedAt: DateTime.now(),
          attachments: report.attachments,
          metadata: report.metadata,
          assignedTo: report.assignedTo,
          response: report.response,
        );
        
        final result = await remoteDataSource.updateReport(reportModel);
        
        // Update cache
        await cacheDataSource.cacheReport(result);
        
        return Right(result);
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteReport(String reportId) async {
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.deleteReport(reportId);
        
        // Remove from cache
        await cacheDataSource.removeCachedReport(reportId);
        
        return Right(result);
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncPendingReports() async {
    try {
      if (await networkInfo.isConnected) {
        final pendingReports = await cacheDataSource.getPendingReports();
        
        for (final report in pendingReports) {
          try {
            await remoteDataSource.submitReport(report);
            await cacheDataSource.removePendingReport(report.id);
          } catch (e) {
            // Continue with other reports even if one fails
            continue;
          }
        }
        
        return const Right(null);
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // -- Minimal placeholder implementations to satisfy interface --

  @override
  Future<Either<Failure, List<Report>>> getReportsByStatus(ReportStatus status) async {
    return const Left(UnknownFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, List<Report>>> getReportsByType(ReportType type) async {
    return const Left(UnknownFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, List<Report>>> getReportsByUrgency(UrgencyLevel urgency) async {
    return const Left(UnknownFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, List<Report>>> getRecentReports(String userId) async {
    return const Left(UnknownFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, List<Report>>> searchReports(String query, String userId) async {
    return const Left(UnknownFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getReportStatistics(String userId) async {
    return const Left(UnknownFailure('Not implemented'));
  }
}