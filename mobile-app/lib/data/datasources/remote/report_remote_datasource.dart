import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/error/exceptions.dart';
import '../../models/report_model.dart';

abstract class ReportRemoteDataSource {
  Future<ReportModel> submitReport(ReportModel report);
  Future<List<ReportModel>> getUserReports(String userId);
  Future<ReportModel> getReportById(String reportId);
  Future<ReportModel> updateReport(ReportModel report);
  Future<bool> deleteReport(String reportId);
  Future<List<ReportModel>> getReportsByStatus(String status);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final ApiClient apiClient;

  ReportRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ReportModel> submitReport(ReportModel report) async {
    try {
      final response = await apiClient.post(
        ApiConstants.submitReport,
        data: report.toJson(),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return ReportModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to submit report',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to submit report: $e');
    }
  }

  @override
  Future<List<ReportModel>> getUserReports(String userId) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.reports}/$userId',
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> reportsJson = response.data['data'];
        return reportsJson
            .map((json) => ReportModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to get user reports',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get user reports: $e');
    }
  }

  @override
  Future<ReportModel> getReportById(String reportId) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.reports}/detail/$reportId',
      );
      
      if (response.statusCode == 200) {
        return ReportModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to get report',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get report: $e');
    }
  }

  @override
  Future<ReportModel> updateReport(ReportModel report) async {
    try {
      final response = await apiClient.put(
        '${ApiConstants.reports}/${report.id}',
        data: report.toJson(),
      );
      
      if (response.statusCode == 200) {
        return ReportModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to update report',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to update report: $e');
    }
  }

  @override
  Future<bool> deleteReport(String reportId) async {
    try {
      final response = await apiClient.delete(
        '${ApiConstants.reports}/$reportId',
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to delete report',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to delete report: $e');
    }
  }

  @override
  Future<List<ReportModel>> getReportsByStatus(String status) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.reports}/status/$status',
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> reportsJson = response.data['data'];
        return reportsJson
            .map((json) => ReportModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to get reports by status',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get reports by status: $e');
    }
  }
}