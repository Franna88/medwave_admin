import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/country_analytics_model.dart';
import 'firebase_config.dart';
import 'firebase_user_service.dart';
import 'firebase_patient_service.dart';

/// Firebase Analytics Service for MedWave Admin Panel
/// 
/// Provides aggregated analytics and dashboard data.
/// This service powers:
/// - Dashboard Overview
/// - Analytics Screen
/// - Real-time statistics and KPIs
class FirebaseAnalyticsService {
  static final FirebaseAnalyticsService _instance = FirebaseAnalyticsService._internal();
  factory FirebaseAnalyticsService() => _instance;
  FirebaseAnalyticsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseUserService _userService = FirebaseUserService();
  final FirebasePatientService _patientService = FirebasePatientService();

  // Collection references
  CollectionReference get _analyticsCollection => 
      _firestore.collection(FirebaseConfig.countryAnalyticsCollection);

  /// Get country analytics from the pre-calculated collection
  Stream<List<CountryAnalytics>> getCountryAnalytics({String? countryFilter}) {
    try {
      Query query = _analyticsCollection;

      if (countryFilter != null) {
        query = query.where(FieldPath.documentId, isEqualTo: countryFilter);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => CountryAnalytics.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting country analytics: $e');
      }
      return Stream.value([]);
    }
  }

  /// Get specific country analytics
  Future<CountryAnalytics?> getCountryAnalyticsById(String countryCode) async {
    try {
      final doc = await _analyticsCollection.doc(countryCode).get();
      if (!doc.exists) return null;

      return CountryAnalytics.fromFirestore(doc);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting country analytics by ID: $e');
      }
      return null;
    }
  }

  /// Calculate and update country analytics (admin function)
  /// This would typically be run by a scheduled function or manually by super admins
  Future<bool> calculateCountryAnalytics({
    required String countryCode,
    required String calculatedBy,
  }) async {
    try {
      if (kDebugMode) {
        print('Calculating analytics for country: $countryCode');
      }

      // Get practitioner statistics
      final practitionerStats = await _userService.getPractitionerStatistics(countryCode);
      
      // Get patient statistics
      final patientStats = await _patientService.getPatientStatistics(countryCode);
      
      // Get wound healing statistics
      final woundStats = await _patientService.getWoundHealingStatistics(countryCode);

      // Get pending applications count
      final pendingApps = await _userService.getPendingApplicationsCount();

      // Calculate this month's approvals and rejections
      final approvedThisMonth = await _getApprovalCountThisMonth(countryCode, true);
      final rejectedThisMonth = await _getApprovalCountThisMonth(countryCode, false);

      // Get country name
      final countryName = _getCountryName(countryCode);

      // Create analytics object
      final analytics = CountryAnalytics(
        id: countryCode,
        countryName: countryName,
        totalPractitioners: practitionerStats['approved'] ?? 0,
        activePractitioners: practitionerStats['active_this_month'] ?? 0,
        pendingApplications: pendingApps[countryCode] ?? 0,
        approvedThisMonth: approvedThisMonth,
        rejectedThisMonth: rejectedThisMonth,
        totalPatients: patientStats['total'] ?? 0,
        newPatientsThisMonth: patientStats['new_this_month'] ?? 0,
        totalSessions: woundStats['total_sessions'] ?? 0,
        sessionsThisMonth: await _getSessionsThisMonth(countryCode),
        averageSessionsPerPractitioner: _calculateAverageSessionsPerPractitioner(
          practitionerStats['total'] ?? 0,
          woundStats['total_sessions'] ?? 0,
        ),
        averagePatientsPerPractitioner: _calculateAveragePatientsPerPractitioner(
          practitionerStats['total'] ?? 0,
          patientStats['total'] ?? 0,
        ),
        averageWoundHealingRate: (woundStats['average_healing_rate'] ?? 0.0).toDouble(),
        provinces: await _calculateProvinceStats(countryCode),
        lastCalculated: DateTime.now(),
        calculatedBy: calculatedBy,
      );

      // Save to Firestore
      await _analyticsCollection.doc(countryCode).set(analytics.toFirestore());

      if (kDebugMode) {
        print('Analytics calculated and saved for $countryCode');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating country analytics: $e');
      }
      return false;
    }
  }

  /// Get real-time dashboard metrics (calculated on-demand)
  Future<Map<String, dynamic>> getDashboardMetrics({String? countryFilter}) async {
    try {
      // Get basic counts
      final practitionerStats = await _userService.getPractitionerStatistics(countryFilter);
      final patientStats = await _patientService.getPatientStatistics(countryFilter);
      final pendingApps = await _userService.getPendingApplicationsCount();

      // Calculate growth rates
      final practitionerGrowth = await _calculateGrowthRate(
        'practitioners',
        countryFilter,
        30, // last 30 days
      );
      
      final patientGrowth = await _calculateGrowthRate(
        'patients',
        countryFilter,
        30, // last 30 days
      );

      return {
        'practitioners': {
          'total': practitionerStats['total'] ?? 0,
          'active': practitionerStats['active_this_month'] ?? 0,
          'pending': countryFilter != null 
              ? (pendingApps[countryFilter] ?? 0)
              : pendingApps.values.fold(0, (sum, count) => sum + count),
          'growth_rate': practitionerGrowth,
        },
        'patients': {
          'total': patientStats['total'] ?? 0,
          'new_this_month': patientStats['new_this_month'] ?? 0,
          'active_treatments': patientStats['active_treatments'] ?? 0,
          'completed_treatments': patientStats['completed_treatments'] ?? 0,
          'growth_rate': patientGrowth,
        },
        'sessions': {
          'total_this_month': await _getSessionsThisMonth(countryFilter),
          'average_per_patient': await _getAverageSessionsPerPatient(countryFilter),
        },
        'performance': {
          'average_progress': patientStats['average_progress'] ?? 0.0,
          'healing_rate': 75.0, // This would come from wound statistics
        },
        'geographic': {
          'countries': countryFilter != null 
              ? {countryFilter: practitionerStats['total']}
              : practitionerStats['by_country'] ?? {},
        },
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting dashboard metrics: $e');
      }
      return {};
    }
  }

  /// Get trending data for charts
  Future<Map<String, List<Map<String, dynamic>>>> getTrendingData({
    String? countryFilter,
    int days = 30,
  }) async {
    try {
      final trends = <String, List<Map<String, dynamic>>>{
        'practitioners': [],
        'patients': [],
        'sessions': [],
      };

      // Generate daily data points for the chart
      for (int i = days - 1; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i));
        final dateKey = '${date.day}/${date.month}';

        // For demo purposes, we'll generate sample trend data
        // In a real implementation, you'd query historical data
        trends['practitioners']!.add({
          'date': dateKey,
          'value': 50 + (i * 2), // Sample upward trend
        });

        trends['patients']!.add({
          'date': dateKey,
          'value': 150 + (i * 5), // Sample upward trend
        });

        trends['sessions']!.add({
          'date': dateKey,
          'value': 25 + (i * 1.5), // Sample upward trend
        });
      }

      return trends;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting trending data: $e');
      }
      return {};
    }
  }

  /// Get top performing metrics
  Future<Map<String, dynamic>> getTopPerformingMetrics({String? countryFilter}) async {
    try {
      // Get top performing patients
      final topPatients = await _patientService.getTopPerformingPatients(
        country: countryFilter,
        limit: 5,
      );

      // Get recent activity
      final recentPatients = await _patientService.getPatientsWithRecentActivity(
        country: countryFilter,
        days: 7,
        limit: 10,
      );

      // Get practitioner performance
      final patientCountsByPractitioner = await _patientService.getPatientCountByPractitioner(
        country: countryFilter,
      );

      return {
        'top_patients': topPatients.map((patient) => {
          'id': patient.id,
          'name': patient.fullName,
          'progress': patient.overallProgress,
          'practitioner_id': patient.practitionerId,
        }).toList(),
        'recent_activity': recentPatients.map((patient) => {
          'id': patient.id,
          'name': patient.fullName,
          'last_updated': patient.lastUpdated.toIso8601String(),
          'progress': patient.overallProgress,
        }).toList(),
        'practitioner_performance': patientCountsByPractitioner.entries
            .map((entry) => {
              'practitioner_id': entry.key,
              'patient_count': entry.value,
            })
            .toList(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting top performing metrics: $e');
      }
      return {};
    }
  }

  /// Calculate monthly growth rate
  Future<double> _calculateGrowthRate(String type, String? country, int days) async {
    try {
      // This is a simplified calculation
      // In a real implementation, you'd compare current count vs previous period

      if (type == 'practitioners') {
        final recentPractitioners = await _userService.getRecentPractitioners(
          country: country,
          days: days,
        );
        final practitionerStats = await _userService.getPractitionerStatistics(country);
        final total = practitionerStats['total'] ?? 0;
        
        if (total == 0) return 0.0;
        return (recentPractitioners.length / total) * 100;
      } else if (type == 'patients') {
        // Similar calculation for patients
        return 15.0; // Placeholder
      }

      return 0.0;
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating growth rate: $e');
      }
      return 0.0;
    }
  }

  /// Get approval count for this month
  Future<int> _getApprovalCountThisMonth(String countryCode, bool approved) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final snapshot = await _firestore
          .collection(FirebaseConfig.practitionerApplicationsCollection)
          .where('country', isEqualTo: countryCode)
          .where('status', isEqualTo: approved ? 'approved' : 'rejected')
          .where('reviewedAt', isGreaterThan: Timestamp.fromDate(startOfMonth))
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting approval count: $e');
      }
      return 0;
    }
  }

  /// Get sessions count for this month
  Future<int> _getSessionsThisMonth(String? countryFilter) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Use collection group query for sessions
      Query query = _firestore
          .collectionGroup(FirebaseConfig.sessionsSubcollection)
          .where('date', isGreaterThan: Timestamp.fromDate(startOfMonth));

      final snapshot = await query.count().get();
      
      // Note: If country filtering is needed, we'd need to do it client-side
      // or restructure the data to include country in session documents
      
      return snapshot.count ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting sessions this month: $e');
      }
      return 0;
    }
  }

  /// Calculate average sessions per patient
  Future<double> _getAverageSessionsPerPatient(String? countryFilter) async {
    try {
      final patientStats = await _patientService.getPatientStatistics(countryFilter);
      final woundStats = await _patientService.getWoundHealingStatistics(countryFilter);

      final totalPatients = patientStats['total'] ?? 0;
      final totalSessions = woundStats['total_sessions'] ?? 0;

      if (totalPatients == 0) return 0.0;
      return totalSessions / totalPatients;
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating average sessions per patient: $e');
      }
      return 0.0;
    }
  }

  /// Calculate province statistics
  Future<Map<String, ProvinceStats>> _calculateProvinceStats(String countryCode) async {
    try {
      // For now, return empty map - would need actual province data
      // In a real implementation, you would:
      // 1. Get all practitioners for the country grouped by province
      // 2. Get all patients for the country grouped by province  
      // 3. Calculate session counts by province
      // final practitionerStats = await _userService.getPractitionerStatistics(countryCode);
      // final patientStats = await _patientService.getPatientStatistics(countryCode);
      
      return <String, ProvinceStats>{};
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating province stats: $e');
      }
      return {};
    }
  }

  /// Helper methods
  double _calculateAverageSessionsPerPractitioner(int totalPractitioners, int totalSessions) {
    if (totalPractitioners == 0) return 0.0;
    return totalSessions / totalPractitioners;
  }

  double _calculateAveragePatientsPerPractitioner(int totalPractitioners, int totalPatients) {
    if (totalPractitioners == 0) return 0.0;
    return totalPatients / totalPractitioners;
  }

  String _getCountryName(String countryCode) {
    switch (countryCode) {
      case 'USA':
        return 'United States';
      case 'RSA':
        return 'South Africa';
      default:
        return countryCode;
    }
  }

  /// Refresh all country analytics (super admin function)
  Future<Map<String, bool>> refreshAllCountryAnalytics(String calculatedBy) async {
    final results = <String, bool>{};
    final countries = ['USA', 'RSA']; // Add more as needed

    for (final country in countries) {
      final success = await calculateCountryAnalytics(
        countryCode: country,
        calculatedBy: calculatedBy,
      );
      results[country] = success;
    }

    return results;
  }

  /// Check if analytics data is stale
  Future<List<String>> getStaleAnalytics({int hoursThreshold = 24}) async {
    try {
      final staleCountries = <String>[];
      final snapshot = await _analyticsCollection.get();

      final threshold = DateTime.now().subtract(Duration(hours: hoursThreshold));

      for (final doc in snapshot.docs) {
        final analytics = CountryAnalytics.fromFirestore(doc);
        if (analytics.lastCalculated.isBefore(threshold)) {
          staleCountries.add(analytics.id);
        }
      }

      return staleCountries;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking stale analytics: $e');
      }
      return [];
    }
  }
}
