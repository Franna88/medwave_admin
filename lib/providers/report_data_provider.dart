import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/report_model.dart';

class ReportDataProvider with ChangeNotifier {
  final List<Report> _reports = [];
  Report? _currentReport;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Report> get reports => List.unmodifiable(_reports);
  Report? get currentReport => _currentReport;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with some sample reports
  ReportDataProvider() {
    _initializeSampleReports();
  }

  void _initializeSampleReports() {
    final sampleReport = Report(
      id: const Uuid().v4(),
      title: 'Monthly Provider Performance',
      description: 'Comprehensive overview of provider performance metrics',
      type: ReportType.providerPerformance,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      createdBy: 'Admin',
      metrics: [
        PredefinedMetrics.availableMetrics[0], // Total Providers
        PredefinedMetrics.availableMetrics[1], // Active Providers
        PredefinedMetrics.availableMetrics[5], // Revenue by Provider
      ],
      template: 'professional',
      isPublished: true,
    );

    _reports.add(sampleReport);
    notifyListeners();
  }

  // Create a new report
  void createNewReport({
    required String title,
    required String description,
    required ReportType type,
    String template = 'default',
  }) {
    final newReport = Report(
      id: const Uuid().v4(),
      title: title,
      description: description,
      type: type,
      createdAt: DateTime.now(),
      createdBy: 'Admin',
      template: template,
    );

    _reports.add(newReport);
    _currentReport = newReport;
    _error = null;
    notifyListeners();
  }

  // Update current report
  void updateCurrentReport({
    String? title,
    String? description,
    ReportType? type,
    List<ReportMetric>? metrics,
    Map<String, dynamic>? filters,
    String? template,
    bool? isPublished,
  }) {
    if (_currentReport == null) return;

    _currentReport = _currentReport!.copyWith(
      title: title,
      description: description,
      type: type,
      metrics: metrics,
      filters: filters,
      template: template,
      isPublished: isPublished,
      lastModified: DateTime.now(),
    );

    // Update in reports list
    final index = _reports.indexWhere((r) => r.id == _currentReport!.id);
    if (index != -1) {
      _reports[index] = _currentReport!;
    }

    _error = null;
    notifyListeners();
  }

  // Add metric to current report
  void addMetricToReport(ReportMetric metric) {
    if (_currentReport == null) return;

    final updatedMetrics = List<ReportMetric>.from(_currentReport!.metrics);
    final metricWithOrder = metric.copyWith(order: updatedMetrics.length);
    updatedMetrics.add(metricWithOrder);

    updateCurrentReport(metrics: updatedMetrics);
  }

  // Remove metric from current report
  void removeMetricFromReport(String metricId) {
    if (_currentReport == null) return;

    final updatedMetrics = _currentReport!.metrics
        .where((metric) => metric.id != metricId)
        .toList();

    // Reorder metrics
    for (int i = 0; i < updatedMetrics.length; i++) {
      updatedMetrics[i] = updatedMetrics[i].copyWith(order: i);
    }

    updateCurrentReport(metrics: updatedMetrics);
  }

  // Reorder metrics in current report
  void reorderMetrics(int oldIndex, int newIndex) {
    if (_currentReport == null) return;

    final updatedMetrics = List<ReportMetric>.from(_currentReport!.metrics);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = updatedMetrics.removeAt(oldIndex);
    updatedMetrics.insert(newIndex, item);

    // Update order for all metrics
    for (int i = 0; i < updatedMetrics.length; i++) {
      updatedMetrics[i] = updatedMetrics[i].copyWith(order: i);
    }

    updateCurrentReport(metrics: updatedMetrics);
  }

  // Load report
  void loadReport(String reportId) {
    _currentReport = _reports.firstWhere(
      (report) => report.id == reportId,
      orElse: () => throw Exception('Report not found'),
    );
    _error = null;
    notifyListeners();
  }

  // Delete report
  void deleteReport(String reportId) {
    _reports.removeWhere((report) => report.id == reportId);
    if (_currentReport?.id == reportId) {
      _currentReport = null;
    }
    _error = null;
    notifyListeners();
  }

  // Duplicate report
  void duplicateReport(String reportId) {
    final originalReport = _reports.firstWhere((report) => report.id == reportId);
    final duplicatedReport = originalReport.copyWith(
      id: const Uuid().v4(),
      title: '${originalReport.title} (Copy)',
      createdAt: DateTime.now(),
      lastModified: null,
      isPublished: false,
    );

    _reports.add(duplicatedReport);
    _currentReport = duplicatedReport;
    _error = null;
    notifyListeners();
  }

  // Publish/unpublish report
  void toggleReportPublish(String reportId) {
    final index = _reports.indexWhere((report) => report.id == reportId);
    if (index != -1) {
      final report = _reports[index];
      _reports[index] = report.copyWith(
        isPublished: !report.isPublished,
        lastModified: DateTime.now(),
      );

      if (_currentReport?.id == reportId) {
        _currentReport = _reports[index];
      }
    }
    notifyListeners();
  }

  // Clear current report
  void clearCurrentReport() {
    _currentReport = null;
    _error = null;
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get reports by type
  List<Report> getReportsByType(ReportType type) {
    return _reports.where((report) => report.type == type).toList();
  }

  // Get published reports
  List<Report> getPublishedReports() {
    return _reports.where((report) => report.isPublished).toList();
  }

  // Get recent reports
  List<Report> getRecentReports({int limit = 5}) {
    final sortedReports = List<Report>.from(_reports)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedReports.take(limit).toList();
  }
}
