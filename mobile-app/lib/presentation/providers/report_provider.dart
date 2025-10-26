import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/report.dart';
import '../../domain/usecases/submit_report.dart';
import '../../domain/usecases/get_report_status.dart';

// State classes
class ReportState {
  final List<Report> reports;
  final bool isLoading;
  final String? error;
  final Report? selectedReport;

  const ReportState({
    this.reports = const [],
    this.isLoading = false,
    this.error,
    this.selectedReport,
  });

  ReportState copyWith({
    List<Report>? reports,
    bool? isLoading,
    String? error,
    Report? selectedReport,
  }) {
    return ReportState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedReport: selectedReport ?? this.selectedReport,
    );
  }
}

// Report provider
class ReportNotifier extends StateNotifier<ReportState> {
  final SubmitReport submitReportUseCase;
  final GetReportStatus getReportStatusUseCase;

  ReportNotifier({
    required this.submitReportUseCase,
    required this.getReportStatusUseCase,
  }) : super(const ReportState());

  Future<void> submitReport(SubmitReportParams params) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await submitReportUseCase(params);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (report) {
        final updatedReports = [...state.reports, report];
        state = state.copyWith(
          isLoading: false,
          reports: updatedReports,
          error: null,
        );
      },
    );
  }

  Future<void> getReportStatus(String reportId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await getReportStatusUseCase(reportId);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (statusResult) => state = state.copyWith(
        isLoading: false,
        selectedReport: statusResult.report,
        error: null,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSelectedReport() {
    state = state.copyWith(selectedReport: null);
  }
}

// Provider instances - these would be properly injected with dependencies
final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  // This would be injected through dependency injection
  throw UnimplementedError('Dependencies need to be injected');
});

// Individual providers for specific data
final reportsListProvider = Provider<List<Report>>((ref) {
  return ref.watch(reportProvider).reports;
});

final reportLoadingProvider = Provider<bool>((ref) {
  return ref.watch(reportProvider).isLoading;
});

final reportErrorProvider = Provider<String?>((ref) {
  return ref.watch(reportProvider).error;
});

final selectedReportProvider = Provider<Report?>((ref) {
  return ref.watch(reportProvider).selectedReport;
});