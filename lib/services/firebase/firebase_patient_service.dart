import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/firebase_patient_model.dart';
import '../../models/session_model.dart';
import 'firebase_config.dart';

/// Firebase Patient Service for MedWave Admin Panel
/// 
/// Handles CRUD operations for patients and their treatment sessions.
/// This service provides the data layer for:
/// - Patient Management Screen
/// - Patient analytics and progress tracking
/// - Session data and wound healing monitoring
class FirebasePatientService {
  static final FirebasePatientService _instance = FirebasePatientService._internal();
  factory FirebasePatientService() => _instance;
  FirebasePatientService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _patientsCollection => 
      _firestore.collection(FirebaseConfig.patientsCollection);

  /// Get all patients with optional filters
  Stream<List<FirebasePatient>> getPatients({
    String? country,
    String? practitionerId,
    int? limit,
  }) {
    try {
      Query query = _patientsCollection;

      // Apply filters
      if (country != null) {
        query = query.where('country', isEqualTo: country);
      }

      if (practitionerId != null) {
        query = query.where('practitionerId', isEqualTo: practitionerId);
      }

      // Order by creation date (newest first)
      query = query.orderBy('createdAt', descending: true);

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => FirebasePatient.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting patients: $e');
      }
      return Stream.value([]);
    }
  }

  /// Get patient by ID
  Future<FirebasePatient?> getPatientById(String patientId) async {
    try {
      final doc = await _patientsCollection.doc(patientId).get();
      if (!doc.exists) return null;

      return FirebasePatient.fromFirestore(doc);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting patient by ID: $e');
      }
      return null;
    }
  }

  /// Get patients by practitioner
  Stream<List<FirebasePatient>> getPatientsByPractitioner(String practitionerId) {
    try {
      return _patientsCollection
          .where('practitionerId', isEqualTo: practitionerId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => FirebasePatient.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting patients by practitioner: $e');
      }
      return Stream.value([]);
    }
  }

  /// Search patients by name, ID number, or email
  Future<List<FirebasePatient>> searchPatients({
    required String query,
    String? country,
    String? practitionerId,
    int limit = 20,
  }) async {
    try {
      if (query.isEmpty) return [];

      Query firestoreQuery = _patientsCollection;

      if (country != null) {
        firestoreQuery = firestoreQuery.where('country', isEqualTo: country);
      }

      if (practitionerId != null) {
        firestoreQuery = firestoreQuery.where('practitionerId', isEqualTo: practitionerId);
      }

      final snapshot = await firestoreQuery.limit(100).get(); // Limit for performance

      final patients = snapshot.docs
          .map((doc) => FirebasePatient.fromFirestore(doc))
          .toList();

      // Filter by search query
      final searchLower = query.toLowerCase();
      final filtered = patients.where((patient) {
        return patient.fullName.toLowerCase().contains(searchLower) ||
               patient.idNumber.toLowerCase().contains(searchLower) ||
               patient.email.toLowerCase().contains(searchLower) ||
               patient.patientCell.toLowerCase().contains(searchLower);
      }).toList();

      return filtered.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching patients: $e');
      }
      return [];
    }
  }

  /// Get patient sessions
  Stream<List<Session>> getPatientSessions(String patientId) {
    try {
      return _patientsCollection
          .doc(patientId)
          .collection(FirebaseConfig.sessionsSubcollection)
          .orderBy('sessionNumber', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Session.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting patient sessions: $e');
      }
      return Stream.value([]);
    }
  }

  /// Get latest session for a patient
  Future<Session?> getLatestSession(String patientId) async {
    try {
      final snapshot = await _patientsCollection
          .doc(patientId)
          .collection(FirebaseConfig.sessionsSubcollection)
          .orderBy('sessionNumber', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return Session.fromFirestore(snapshot.docs.first);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting latest session: $e');
      }
      return null;
    }
  }

  /// Get session count for a patient
  Future<int> getSessionCount(String patientId) async {
    try {
      final snapshot = await _patientsCollection
          .doc(patientId)
          .collection(FirebaseConfig.sessionsSubcollection)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting session count: $e');
      }
      return 0;
    }
  }

  /// Get recent sessions across all patients (for analytics)
  Future<List<Session>> getRecentSessions({
    String? country,
    String? practitionerId,
    int days = 30,
    int limit = 50,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      // Since this is a collection group query, we need to use collectionGroup
      Query query = _firestore
          .collectionGroup(FirebaseConfig.sessionsSubcollection)
          .where('date', isGreaterThan: Timestamp.fromDate(cutoffDate));

      if (practitionerId != null) {
        query = query.where('practitionerId', isEqualTo: practitionerId);
      }

      query = query.orderBy('date', descending: true).limit(limit);

      final snapshot = await query.get();
      final sessions = snapshot.docs
          .map((doc) => Session.fromFirestore(doc))
          .toList();

      // Filter by country if needed (since we can't do it in the query)
      if (country != null) {
        final filteredSessions = <Session>[];
        for (final session in sessions) {
          final patient = await getPatientById(session.patientId);
          if (patient?.country == country) {
            filteredSessions.add(session);
          }
        }
        return filteredSessions;
      }

      return sessions;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting recent sessions: $e');
      }
      return [];
    }
  }

  /// Get patient statistics by country
  Future<Map<String, dynamic>> getPatientStatistics(String? countryFilter) async {
    try {
      Query query = _patientsCollection;

      if (countryFilter != null) {
        query = query.where('country', isEqualTo: countryFilter);
      }

      final snapshot = await query.get();
      final patients = snapshot.docs
          .map((doc) => FirebasePatient.fromFirestore(doc))
          .toList();

      // Calculate statistics
      final stats = <String, dynamic>{
        'total': patients.length,
        'new_this_month': 0,
        'by_country': <String, int>{},
        'by_age_group': <String, int>{
          '0-18': 0,
          '19-35': 0,
          '36-50': 0,
          '51-65': 0,
          '65+': 0,
        },
        'average_progress': 0.0,
        'active_treatments': 0,
        'completed_treatments': 0,
      };

      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      double totalProgress = 0.0;

      for (final patient in patients) {
        // Count new patients this month
        if (patient.createdAt.isAfter(thirtyDaysAgo)) {
          stats['new_this_month']++;
        }

        // Group by country
        final country = patient.country;
        stats['by_country'][country] = (stats['by_country'][country] ?? 0) + 1;

        // Group by age
        final age = patient.age;
        String ageGroup;
        if (age <= 18) {
          ageGroup = '0-18';
        } else if (age <= 35) {
          ageGroup = '19-35';
        } else if (age <= 50) {
          ageGroup = '36-50';
        } else if (age <= 65) {
          ageGroup = '51-65';
        } else {
          ageGroup = '65+';
        }
        stats['by_age_group'][ageGroup]++;

        // Calculate progress
        totalProgress += patient.overallProgress;

        // Count active/completed treatments
        // This would need to be determined based on your business logic
        // For now, we'll use a simple heuristic
        if (patient.overallProgress >= 90.0) {
          stats['completed_treatments']++;
        } else {
          stats['active_treatments']++;
        }
      }

      // Calculate average progress
      if (patients.isNotEmpty) {
        stats['average_progress'] = totalProgress / patients.length;
      }

      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting patient statistics: $e');
      }
      return {};
    }
  }

  /// Get wound healing statistics
  Future<Map<String, dynamic>> getWoundHealingStatistics(String? countryFilter) async {
    try {
      // Get recent sessions for analysis
      final sessions = await getRecentSessions(
        country: countryFilter,
        days: 90, // Last 3 months
        limit: 200,
      );

      final stats = <String, dynamic>{
        'total_sessions': sessions.length,
        'total_wounds_tracked': 0,
        'average_healing_rate': 0.0,
        'wound_types': <String, int>{},
        'wound_stages': <String, int>{},
        'average_session_duration': 0.0, // Days between sessions
      };

      if (sessions.isEmpty) return stats;

      int totalWounds = 0;
      final woundTypes = <String, int>{};
      final woundStages = <String, int>{};
      final sessionDurations = <double>[];

      // Group sessions by patient to calculate durations
      final sessionsByPatient = <String, List<Session>>{};
      for (final session in sessions) {
        sessionsByPatient.putIfAbsent(session.patientId, () => []).add(session);
      }

      for (final patientSessions in sessionsByPatient.values) {
        // Sort sessions by date
        patientSessions.sort((a, b) => a.date.compareTo(b.date));

        // Calculate session intervals
        for (int i = 1; i < patientSessions.length; i++) {
          final duration = patientSessions[i].date
              .difference(patientSessions[i - 1].date)
              .inDays
              .toDouble();
          sessionDurations.add(duration);
        }
      }

      for (final session in sessions) {
        totalWounds += session.wounds.length;

        for (final wound in session.wounds) {
          // Count wound types
          woundTypes[wound.type] = (woundTypes[wound.type] ?? 0) + 1;

          // Count wound stages
          woundStages[wound.stage] = (woundStages[wound.stage] ?? 0) + 1;
        }
      }

      stats['total_wounds_tracked'] = totalWounds;
      stats['wound_types'] = woundTypes;
      stats['wound_stages'] = woundStages;

      // Calculate average session duration
      if (sessionDurations.isNotEmpty) {
        final avgDuration = sessionDurations.reduce((a, b) => a + b) / sessionDurations.length;
        stats['average_session_duration'] = avgDuration;
      }

      // Calculate healing rate (this would need more sophisticated logic)
      // For now, we'll use a simple metric based on wound progression
      stats['average_healing_rate'] = 75.0; // Placeholder

      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting wound healing statistics: $e');
      }
      return {};
    }
  }

  /// Get top performing patients by progress
  Future<List<FirebasePatient>> getTopPerformingPatients({
    String? country,
    String? practitionerId,
    int limit = 10,
  }) async {
    try {
      Query query = _patientsCollection;

      if (country != null) {
        query = query.where('country', isEqualTo: country);
      }

      if (practitionerId != null) {
        query = query.where('practitionerId', isEqualTo: practitionerId);
      }

      // Note: We can't order by calculated fields like overallProgress in Firestore
      // So we'll get all patients and sort them in memory
      final snapshot = await query.limit(100).get(); // Limit for performance

      final patients = snapshot.docs
          .map((doc) => FirebasePatient.fromFirestore(doc))
          .toList();

      // Sort by progress and take top performers
      patients.sort((a, b) => b.overallProgress.compareTo(a.overallProgress));

      return patients.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting top performing patients: $e');
      }
      return [];
    }
  }

  /// Get patients with recent activity
  Future<List<FirebasePatient>> getPatientsWithRecentActivity({
    String? country,
    int days = 7,
    int limit = 20,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      // Get recent sessions
      Query sessionQuery = _firestore
          .collectionGroup(FirebaseConfig.sessionsSubcollection)
          .where('date', isGreaterThan: Timestamp.fromDate(cutoffDate))
          .orderBy('date', descending: true)
          .limit(limit);

      final sessionSnapshot = await sessionQuery.get();
      final recentSessions = sessionSnapshot.docs
          .map((doc) => Session.fromFirestore(doc))
          .toList();

      // Get unique patient IDs
      final patientIds = recentSessions
          .map((session) => session.patientId)
          .toSet()
          .toList();

      // Get patients
      final patients = <FirebasePatient>[];
      for (final patientId in patientIds) {
        final patient = await getPatientById(patientId);
        if (patient != null) {
          // Filter by country if needed
          if (country == null || patient.country == country) {
            patients.add(patient);
          }
        }
      }

      return patients.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting patients with recent activity: $e');
      }
      return [];
    }
  }

  /// Get patient count by practitioner
  Future<Map<String, int>> getPatientCountByPractitioner({String? country}) async {
    try {
      Query query = _patientsCollection;

      if (country != null) {
        query = query.where('country', isEqualTo: country);
      }

      final snapshot = await query.get();
      final patientCounts = <String, int>{};

      for (final doc in snapshot.docs) {
        final patient = FirebasePatient.fromFirestore(doc);
        patientCounts[patient.practitionerId] = 
            (patientCounts[patient.practitionerId] ?? 0) + 1;
      }

      return patientCounts;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting patient count by practitioner: $e');
      }
      return {};
    }
  }

  /// Create or update patient
  Future<bool> savePatient(FirebasePatient patient) async {
    try {
      if (patient.id.isEmpty) {
        // Create new patient
        await _patientsCollection.add(patient.toFirestore());
      } else {
        // Update existing patient
        await _patientsCollection.doc(patient.id).set(patient.toFirestore());
      }

      if (kDebugMode) {
        print('Patient saved: ${patient.fullName}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving patient: $e');
      }
      return false;
    }
  }

  /// Delete patient and all associated sessions
  Future<bool> deletePatient(String patientId) async {
    try {
      // Delete all sessions first
      final sessionsSnapshot = await _patientsCollection
          .doc(patientId)
          .collection(FirebaseConfig.sessionsSubcollection)
          .get();

      final batch = _firestore.batch();

      // Add session deletions to batch
      for (final sessionDoc in sessionsSnapshot.docs) {
        batch.delete(sessionDoc.reference);
      }

      // Add patient deletion to batch
      batch.delete(_patientsCollection.doc(patientId));

      await batch.commit();

      if (kDebugMode) {
        print('Patient deleted: $patientId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting patient: $e');
      }
      return false;
    }
  }
}
