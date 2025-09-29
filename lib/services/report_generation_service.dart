import '../models/generated_report_model.dart';
import '../models/patient_model.dart';
import '../models/session_model.dart';
import '../providers/patient_data_provider.dart';
import '../providers/provider_data_provider.dart';

/// Service for generating comprehensive reports from patient and session data
class ReportGenerationService {
  
  /// Generate a complete report based on the provided parameters
  static Future<GeneratedReport> generateReport({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required List<Patient> patients,
    required PatientDataProvider patientProvider,
    required ProviderDataProvider providerProvider,
    required ReportConfiguration configuration,
  }) async {
    
    // Simulate processing time
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Get all sessions for the selected patients within the date range
    final Map<String, List<Session>> patientSessions = {};
    final Map<String, String> patientProviderNames = {};
    
    for (final patient in patients) {
      final sessions = patientProvider.getPatientSessions(patient.id)
          .where((session) => 
              session.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              session.date.isBefore(endDate.add(const Duration(days: 1))))
          .toList();
      
      // Sort sessions by date
      sessions.sort((a, b) => a.date.compareTo(b.date));
      patientSessions[patient.id] = sessions;
      
      // Get provider name
      final provider = providerProvider.filteredApprovedProviders
          .where((p) => p.id == patient.providerId)
          .firstOrNull;
      patientProviderNames[patient.id] = provider != null 
          ? '${provider.firstName} ${provider.lastName}'
          : 'Unknown Provider';
    }
    
    // Calculate summary statistics
    final summary = _calculateSummary(patients, patientSessions, providerProvider);
    
    // Calculate detailed metrics
    final metrics = _calculateMetrics(patients, patientSessions, configuration);
    
    // Prepare patient report data
    final patientData = _preparePatientData(patients, patientSessions, patientProviderNames);
    
    return GeneratedReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      generatedAt: DateTime.now(),
      startDate: startDate,
      endDate: endDate,
      summary: summary,
      patientData: patientData,
      metrics: metrics,
      configuration: configuration,
    );
  }
  
  /// Calculate high-level summary statistics
  static ReportSummary _calculateSummary(
    List<Patient> patients,
    Map<String, List<Session>> patientSessions,
    ProviderDataProvider providerProvider,
  ) {
    final totalSessions = patientSessions.values
        .expand((sessions) => sessions)
        .length;
    
    final providerIds = patients.map((p) => p.providerId).toSet();
    final countries = patients.map((p) => p.country).toSet();
    
    // Calculate average progress
    double totalProgress = 0.0;
    int patientsWithProgress = 0;
    
    for (final patient in patients) {
      final sessions = patientSessions[patient.id] ?? [];
      if (sessions.length >= 2) {
        final progress = _calculatePatientProgress(patient, sessions);
        totalProgress += progress.overallProgress;
        patientsWithProgress++;
      }
    }
    
    final averageProgress = patientsWithProgress > 0 
        ? totalProgress / patientsWithProgress 
        : 0.0;
    
    // Calculate treatment success rate (patients with >50% progress)
    int successfulPatients = 0;
    for (final patient in patients) {
      final sessions = patientSessions[patient.id] ?? [];
      if (sessions.length >= 2) {
        final progress = _calculatePatientProgress(patient, sessions);
        if (progress.overallProgress >= 50.0) {
          successfulPatients++;
        }
      }
    }
    
    final successRate = patientsWithProgress > 0 
        ? (successfulPatients / patientsWithProgress) * 100 
        : 0.0;
    
    // Calculate average treatment duration
    final totalDurationDays = patients
        .map((p) => p.treatmentDuration.inDays)
        .fold(0, (sum, days) => sum + days);
    final averageDuration = patients.isNotEmpty 
        ? Duration(days: totalDurationDays ~/ patients.length)
        : Duration.zero;
    
    return ReportSummary(
      totalPatients: patients.length,
      totalSessions: totalSessions,
      totalProviders: providerIds.length,
      totalCountries: countries.length,
      averageProgress: averageProgress,
      treatmentSuccessRate: successRate,
      averageTreatmentDuration: averageDuration,
    );
  }
  
  /// Calculate detailed metrics for different aspects
  static ReportMetrics _calculateMetrics(
    List<Patient> patients,
    Map<String, List<Session>> patientSessions,
    ReportConfiguration configuration,
  ) {
    PainMetrics? painMetrics;
    WoundMetrics? woundMetrics;
    WeightMetrics? weightMetrics;
    TreatmentMetrics? treatmentMetrics;
    
    if (configuration.includeVasScores) {
      painMetrics = _calculatePainMetrics(patients, patientSessions);
    }
    
    if (configuration.includeWoundHealing) {
      woundMetrics = _calculateWoundMetrics(patients, patientSessions);
    }
    
    if (configuration.includeWeightChanges) {
      weightMetrics = _calculateWeightMetrics(patients, patientSessions);
    }
    
    if (configuration.includeTreatmentProgress) {
      treatmentMetrics = _calculateTreatmentMetrics(patients, patientSessions);
    }
    
    return ReportMetrics(
      painMetrics: painMetrics,
      woundMetrics: woundMetrics,
      weightMetrics: weightMetrics,
      treatmentMetrics: treatmentMetrics,
    );
  }
  
  /// Calculate pain-related metrics
  static PainMetrics _calculatePainMetrics(
    List<Patient> patients,
    Map<String, List<Session>> patientSessions,
  ) {
    final List<PainDataPoint> painTrend = [];
    double totalInitialPain = 0.0;
    double totalCurrentPain = 0.0;
    int patientsWithPainData = 0;
    
    for (final patient in patients) {
      final sessions = patientSessions[patient.id] ?? [];
      if (sessions.isNotEmpty) {
        final firstSession = sessions.first;
        final lastSession = sessions.last;
        
        totalInitialPain += firstSession.vasScore.toDouble();
        totalCurrentPain += lastSession.vasScore.toDouble();
        patientsWithPainData++;
        
        // Add data points for trend
        for (final session in sessions) {
          painTrend.add(PainDataPoint(
            date: session.date,
            painScore: session.vasScore.toDouble(),
            patientId: patient.id,
          ));
        }
      }
    }
    
    final averageInitialPain = patientsWithPainData > 0 
        ? totalInitialPain / patientsWithPainData 
        : 0.0;
    final averageCurrentPain = patientsWithPainData > 0 
        ? totalCurrentPain / patientsWithPainData 
        : 0.0;
    final averagePainReduction = averageInitialPain - averageCurrentPain;
    final painReductionPercentage = averageInitialPain > 0 
        ? (averagePainReduction / averageInitialPain) * 100 
        : 0.0;
    
    // Sort pain trend by date
    painTrend.sort((a, b) => a.date.compareTo(b.date));
    
    return PainMetrics(
      averageInitialPain: averageInitialPain,
      averageCurrentPain: averageCurrentPain,
      averagePainReduction: averagePainReduction,
      painReductionPercentage: painReductionPercentage,
      painTrend: painTrend,
    );
  }
  
  /// Calculate wound healing metrics
  static WoundMetrics _calculateWoundMetrics(
    List<Patient> patients,
    Map<String, List<Session>> patientSessions,
  ) {
    final List<WoundDataPoint> healingTrend = [];
    final Map<String, int> woundTypeDistribution = {};
    double totalInitialArea = 0.0;
    double totalCurrentArea = 0.0;
    
    for (final patient in patients) {
      final sessions = patientSessions[patient.id] ?? [];
      if (sessions.isNotEmpty) {
        final firstSession = sessions.first;
        final lastSession = sessions.last;
        
        final initialArea = firstSession.totalWoundArea;
        final currentArea = lastSession.totalWoundArea;
        
        if (initialArea > 0) {
          totalInitialArea += initialArea;
          totalCurrentArea += currentArea;
          
          // Add data points for trend
          for (final session in sessions) {
            healingTrend.add(WoundDataPoint(
              date: session.date,
              woundArea: session.totalWoundArea,
              patientId: patient.id,
            ));
          }
          
          // Count wound types
          for (final session in sessions) {
            for (final wound in session.wounds) {
              woundTypeDistribution[wound.type] = 
                  (woundTypeDistribution[wound.type] ?? 0) + 1;
            }
          }
        }
      }
    }
    
    final averageWoundHealing = totalInitialArea - totalCurrentArea;
    final woundHealingPercentage = totalInitialArea > 0 
        ? (averageWoundHealing / totalInitialArea) * 100 
        : 0.0;
    
    // Sort healing trend by date
    healingTrend.sort((a, b) => a.date.compareTo(b.date));
    
    return WoundMetrics(
      totalInitialWoundArea: totalInitialArea,
      totalCurrentWoundArea: totalCurrentArea,
      averageWoundHealing: averageWoundHealing,
      woundHealingPercentage: woundHealingPercentage,
      healingTrend: healingTrend,
      woundTypeDistribution: woundTypeDistribution,
    );
  }
  
  /// Calculate weight-related metrics
  static WeightMetrics _calculateWeightMetrics(
    List<Patient> patients,
    Map<String, List<Session>> patientSessions,
  ) {
    final List<WeightDataPoint> weightTrend = [];
    double totalInitialWeight = 0.0;
    double totalCurrentWeight = 0.0;
    int patientsWithWeightData = 0;
    
    for (final patient in patients) {
      final sessions = patientSessions[patient.id] ?? [];
      if (sessions.isNotEmpty) {
        final firstSession = sessions.first;
        final lastSession = sessions.last;
        
        if (firstSession.weight > 0 && lastSession.weight > 0) {
          totalInitialWeight += firstSession.weight;
          totalCurrentWeight += lastSession.weight;
          patientsWithWeightData++;
          
          // Add data points for trend
          for (final session in sessions) {
            if (session.weight > 0) {
              weightTrend.add(WeightDataPoint(
                date: session.date,
                weight: session.weight,
                patientId: patient.id,
              ));
            }
          }
        }
      }
    }
    
    final averageInitialWeight = patientsWithWeightData > 0 
        ? totalInitialWeight / patientsWithWeightData 
        : 0.0;
    final averageCurrentWeight = patientsWithWeightData > 0 
        ? totalCurrentWeight / patientsWithWeightData 
        : 0.0;
    final averageWeightChange = averageCurrentWeight - averageInitialWeight;
    final weightChangePercentage = averageInitialWeight > 0 
        ? (averageWeightChange / averageInitialWeight) * 100 
        : 0.0;
    
    // Sort weight trend by date
    weightTrend.sort((a, b) => a.date.compareTo(b.date));
    
    return WeightMetrics(
      averageInitialWeight: averageInitialWeight,
      averageCurrentWeight: averageCurrentWeight,
      averageWeightChange: averageWeightChange,
      weightChangePercentage: weightChangePercentage,
      weightTrend: weightTrend,
    );
  }
  
  /// Calculate treatment effectiveness metrics
  static TreatmentMetrics _calculateTreatmentMetrics(
    List<Patient> patients,
    Map<String, List<Session>> patientSessions,
  ) {
    int patientsImproved = 0;
    int patientsStable = 0;
    int patientsDeclined = 0;
    
    final Map<String, List<double>> progressByTreatmentType = {};
    final Map<String, List<double>> progressByCountry = {};
    
    for (final patient in patients) {
      final sessions = patientSessions[patient.id] ?? [];
      if (sessions.length >= 2) {
        final progress = _calculatePatientProgress(patient, sessions);
        
        // Categorize patients
        if (progress.overallProgress >= 60.0) {
          patientsImproved++;
        } else if (progress.overallProgress >= 40.0) {
          patientsStable++;
        } else {
          patientsDeclined++;
        }
        
        // Group by treatment type
        final treatmentType = patient.treatmentType.toString().split('.').last;
        progressByTreatmentType[treatmentType] = 
            (progressByTreatmentType[treatmentType] ?? [])..add(progress.overallProgress);
        
        // Group by country
        progressByCountry[patient.country] = 
            (progressByCountry[patient.country] ?? [])..add(progress.overallProgress);
      }
    }
    
    // Calculate averages
    final Map<String, double> avgProgressByTreatmentType = {};
    progressByTreatmentType.forEach((type, progressList) {
      avgProgressByTreatmentType[type] = 
          progressList.fold(0.0, (sum, progress) => sum + progress) / progressList.length;
    });
    
    final Map<String, double> avgProgressByCountry = {};
    progressByCountry.forEach((country, progressList) {
      avgProgressByCountry[country] = 
          progressList.fold(0.0, (sum, progress) => sum + progress) / progressList.length;
    });
    
    final totalPatients = patientsImproved + patientsStable + patientsDeclined;
    final overallSuccessRate = totalPatients > 0 
        ? (patientsImproved / totalPatients) * 100 
        : 0.0;
    
    return TreatmentMetrics(
      overallSuccessRate: overallSuccessRate,
      patientsImproved: patientsImproved,
      patientsStable: patientsStable,
      patientsDeclined: patientsDeclined,
      progressByTreatmentType: avgProgressByTreatmentType,
      progressByCountry: avgProgressByCountry,
    );
  }
  
  /// Prepare individual patient data for the report
  static List<PatientReportData> _preparePatientData(
    List<Patient> patients,
    Map<String, List<Session>> patientSessions,
    Map<String, String> patientProviderNames,
  ) {
    return patients.map((patient) {
      final sessions = patientSessions[patient.id] ?? [];
      final progress = _calculatePatientProgress(patient, sessions);
      final providerName = patientProviderNames[patient.id] ?? 'Unknown Provider';
      
      return PatientReportData(
        patient: patient,
        sessions: sessions,
        progress: progress,
        providerName: providerName,
      );
    }).toList();
  }
  
  /// Calculate progress for individual patient
  static PatientProgress _calculatePatientProgress(Patient patient, List<Session> sessions) {
    if (sessions.isEmpty) {
      return PatientProgress(
        initialPainScore: 0.0,
        currentPainScore: 0.0,
        painReduction: 0.0,
        initialWeight: 0.0,
        currentWeight: 0.0,
        weightChange: 0.0,
        initialWoundArea: 0.0,
        currentWoundArea: 0.0,
        woundHealing: 0.0,
        overallProgress: 0.0,
        progressStatus: 'stable',
      );
    }
    
    final firstSession = sessions.first;
    final lastSession = sessions.last;
    
    final initialPainScore = firstSession.vasScore.toDouble();
    final currentPainScore = lastSession.vasScore.toDouble();
    final painReduction = initialPainScore - currentPainScore;
    
    final initialWeight = firstSession.weight;
    final currentWeight = lastSession.weight;
    final weightChange = currentWeight - initialWeight;
    
    final initialWoundArea = firstSession.totalWoundArea;
    final currentWoundArea = lastSession.totalWoundArea;
    final woundHealing = initialWoundArea - currentWoundArea;
    
    // Calculate overall progress (simplified algorithm)
    double progress = 0.0;
    
    // Pain improvement (25% weight)
    if (initialPainScore > 0) {
      final painImprovement = (painReduction / initialPainScore) * 25.0;
      progress += painImprovement.clamp(-25.0, 25.0);
    }
    
    // Wound healing (50% weight)
    if (initialWoundArea > 0) {
      final woundImprovement = (woundHealing / initialWoundArea) * 50.0;
      progress += woundImprovement.clamp(-50.0, 50.0);
    }
    
    // Weight management (25% weight) - depends on treatment type
    if (initialWeight > 0 && currentWeight > 0) {
      double weightProgress = 0.0;
      if (patient.treatmentType == TreatmentType.weightLoss) {
        // For weight loss, weight reduction is positive
        weightProgress = -(weightChange / initialWeight) * 25.0;
      } else {
        // For wound healing, weight gain might be positive
        weightProgress = (weightChange / initialWeight) * 25.0;
      }
      progress += weightProgress.clamp(-25.0, 25.0);
    }
    
    // Base progress from session consistency
    if (sessions.length >= 4) {
      progress += 10.0; // Bonus for consistency
    }
    
    final overallProgress = progress.clamp(0.0, 100.0);
    
    // Determine progress status
    String progressStatus;
    if (overallProgress >= 60.0) {
      progressStatus = 'improved';
    } else if (overallProgress >= 40.0) {
      progressStatus = 'stable';
    } else {
      progressStatus = 'declined';
    }
    
    return PatientProgress(
      initialPainScore: initialPainScore,
      currentPainScore: currentPainScore,
      painReduction: painReduction,
      initialWeight: initialWeight,
      currentWeight: currentWeight,
      weightChange: weightChange,
      initialWoundArea: initialWoundArea,
      currentWoundArea: currentWoundArea,
      woundHealing: woundHealing,
      overallProgress: overallProgress,
      progressStatus: progressStatus,
    );
  }
}
