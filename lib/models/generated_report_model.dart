import 'patient_model.dart';
import 'session_model.dart';

/// Generated Report Model - holds all calculated statistics and data for display
class GeneratedReport {
  final String id;
  final String title;
  final DateTime generatedAt;
  final DateTime startDate;
  final DateTime endDate;
  final ReportSummary summary;
  final List<PatientReportData> patientData;
  final ReportMetrics metrics;
  final ReportConfiguration configuration;

  GeneratedReport({
    required this.id,
    required this.title,
    required this.generatedAt,
    required this.startDate,
    required this.endDate,
    required this.summary,
    required this.patientData,
    required this.metrics,
    required this.configuration,
  });
}

/// High-level summary statistics
class ReportSummary {
  final int totalPatients;
  final int totalSessions;
  final int totalProviders;
  final int totalCountries;
  final double averageProgress;
  final double treatmentSuccessRate;
  final Duration averageTreatmentDuration;

  ReportSummary({
    required this.totalPatients,
    required this.totalSessions,
    required this.totalProviders,
    required this.totalCountries,
    required this.averageProgress,
    required this.treatmentSuccessRate,
    required this.averageTreatmentDuration,
  });
}

/// Detailed metrics for various aspects
class ReportMetrics {
  final PainMetrics? painMetrics;
  final WoundMetrics? woundMetrics;
  final WeightMetrics? weightMetrics;
  final TreatmentMetrics? treatmentMetrics;

  ReportMetrics({
    this.painMetrics,
    this.woundMetrics,
    this.weightMetrics,
    this.treatmentMetrics,
  });
}

/// Pain-related metrics (VAS scores)
class PainMetrics {
  final double averageInitialPain;
  final double averageCurrentPain;
  final double averagePainReduction;
  final double painReductionPercentage;
  final List<PainDataPoint> painTrend;

  PainMetrics({
    required this.averageInitialPain,
    required this.averageCurrentPain,
    required this.averagePainReduction,
    required this.painReductionPercentage,
    required this.painTrend,
  });
}

/// Wound healing metrics
class WoundMetrics {
  final double totalInitialWoundArea;
  final double totalCurrentWoundArea;
  final double averageWoundHealing;
  final double woundHealingPercentage;
  final List<WoundDataPoint> healingTrend;
  final Map<String, int> woundTypeDistribution;

  WoundMetrics({
    required this.totalInitialWoundArea,
    required this.totalCurrentWoundArea,
    required this.averageWoundHealing,
    required this.woundHealingPercentage,
    required this.healingTrend,
    required this.woundTypeDistribution,
  });
}

/// Weight-related metrics
class WeightMetrics {
  final double averageInitialWeight;
  final double averageCurrentWeight;
  final double averageWeightChange;
  final double weightChangePercentage;
  final List<WeightDataPoint> weightTrend;

  WeightMetrics({
    required this.averageInitialWeight,
    required this.averageCurrentWeight,
    required this.averageWeightChange,
    required this.weightChangePercentage,
    required this.weightTrend,
  });
}

/// Treatment effectiveness metrics
class TreatmentMetrics {
  final double overallSuccessRate;
  final int patientsImproved;
  final int patientsStable;
  final int patientsDeclined;
  final Map<String, double> progressByTreatmentType;
  final Map<String, double> progressByCountry;

  TreatmentMetrics({
    required this.overallSuccessRate,
    required this.patientsImproved,
    required this.patientsStable,
    required this.patientsDeclined,
    required this.progressByTreatmentType,
    required this.progressByCountry,
  });
}

/// Individual patient data for the report
class PatientReportData {
  final Patient patient;
  final List<Session> sessions;
  final PatientProgress progress;
  final String providerName;

  PatientReportData({
    required this.patient,
    required this.sessions,
    required this.progress,
    required this.providerName,
  });
}

/// Patient progress summary
class PatientProgress {
  final double initialPainScore;
  final double currentPainScore;
  final double painReduction;
  final double initialWeight;
  final double currentWeight;
  final double weightChange;
  final double initialWoundArea;
  final double currentWoundArea;
  final double woundHealing;
  final double overallProgress;
  final String progressStatus; // 'improved', 'stable', 'declined'

  PatientProgress({
    required this.initialPainScore,
    required this.currentPainScore,
    required this.painReduction,
    required this.initialWeight,
    required this.currentWeight,
    required this.weightChange,
    required this.initialWoundArea,
    required this.currentWoundArea,
    required this.woundHealing,
    required this.overallProgress,
    required this.progressStatus,
  });
}

/// Data point for charts
class PainDataPoint {
  final DateTime date;
  final double painScore;
  final String patientId;

  PainDataPoint({
    required this.date,
    required this.painScore,
    required this.patientId,
  });
}

class WoundDataPoint {
  final DateTime date;
  final double woundArea;
  final String patientId;

  WoundDataPoint({
    required this.date,
    required this.woundArea,
    required this.patientId,
  });
}

class WeightDataPoint {
  final DateTime date;
  final double weight;
  final String patientId;

  WeightDataPoint({
    required this.date,
    required this.weight,
    required this.patientId,
  });
}

/// Report configuration used to generate this report
class ReportConfiguration {
  final String patientFilterType;
  final String sessionFilterType;
  final bool includeVasScores;
  final bool includeWeightChanges;
  final bool includeWoundHealing;
  final bool includeTreatmentProgress;
  final String imageSelection;
  final List<String> selectedWoundTypes;

  ReportConfiguration({
    required this.patientFilterType,
    required this.sessionFilterType,
    required this.includeVasScores,
    required this.includeWeightChanges,
    required this.includeWoundHealing,
    required this.includeTreatmentProgress,
    required this.imageSelection,
    required this.selectedWoundTypes,
  });
}

