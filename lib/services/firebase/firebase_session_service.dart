import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/session_model.dart';

/// Firebase Session Service
/// Handles CRUD operations for patient treatment sessions
/// Based on the sessions subcollection structure from DATABASE_README.md
class FirebaseSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all sessions for a specific patient as a stream
  Stream<List<Session>> getPatientSessions(String patientId) {
    try {
      return _firestore
          .collection('patients')
          .doc(patientId)
          .collection('sessions')
          .orderBy('sessionNumber', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Session.fromFirestore(doc)).toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting patient sessions: $e');
      }
      return Stream.value([]);
    }
  }

  /// Get sessions for multiple patients (for practitioner view)
  Stream<List<Session>> getSessionsForPatients(List<String> patientIds) {
    if (patientIds.isEmpty) {
      return Stream.value([]);
    }

    try {
      // Use collection group query to get sessions across all patients
      return _firestore
          .collectionGroup('sessions')
          .where('patientId', whereIn: patientIds)
          .orderBy('date', descending: true)
          .limit(100) // Limit for performance
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Session.fromFirestore(doc)).toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting sessions for patients: $e');
      }
      return Stream.value([]);
    }
  }

  /// Get recent sessions across all patients (for analytics)
  Stream<List<Session>> getRecentSessions({int limitCount = 50}) {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      return _firestore
          .collectionGroup('sessions')
          .where('date', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
          .orderBy('date', descending: true)
          .limit(limitCount)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Session.fromFirestore(doc)).toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting recent sessions: $e');
      }
      return Stream.value([]);
    }
  }

  /// Get sessions by practitioner ID
  Stream<List<Session>> getSessionsByPractitioner(String practitionerId) {
    try {
      return _firestore
          .collectionGroup('sessions')
          .where('practitionerId', isEqualTo: practitionerId)
          .orderBy('date', descending: true)
          .limit(100)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Session.fromFirestore(doc)).toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting sessions by practitioner: $e');
      }
      return Stream.value([]);
    }
  }

  /// Get session statistics for a patient
  Future<Map<String, dynamic>> getPatientSessionStats(String patientId) async {
    try {
      final sessionsSnapshot = await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('sessions')
          .orderBy('sessionNumber')
          .get();

      final sessions = sessionsSnapshot.docs
          .map((doc) => Session.fromFirestore(doc))
          .toList();

      if (sessions.isEmpty) {
        return {
          'totalSessions': 0,
          'lastSessionDate': null,
          'averageVasScore': 0.0,
          'weightProgress': 0.0,
          'painReduction': 0.0,
        };
      }

      final firstSession = sessions.first;
      final lastSession = sessions.last;

      return {
        'totalSessions': sessions.length,
        'lastSessionDate': lastSession.date,
        'averageVasScore': sessions.map((s) => s.vasScore).reduce((a, b) => a + b) / sessions.length,
        'weightProgress': lastSession.weight - firstSession.weight,
        'painReduction': firstSession.vasScore - lastSession.vasScore,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting patient session stats: $e');
      }
      return {
        'totalSessions': 0,
        'lastSessionDate': null,
        'averageVasScore': 0.0,
        'weightProgress': 0.0,
        'painReduction': 0.0,
      };
    }
  }

  /// Create a new session
  Future<String?> createSession(String patientId, Session session) async {
    try {
      final docRef = await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('sessions')
          .add(session.toFirestore());

      if (kDebugMode) {
        print('Session created successfully: ${docRef.id}');
      }
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating session: $e');
      }
      return null;
    }
  }

  /// Update an existing session
  Future<bool> updateSession(String patientId, Session session) async {
    try {
      await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('sessions')
          .doc(session.id)
          .update(session.toFirestore());

      if (kDebugMode) {
        print('Session updated successfully: ${session.id}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating session: $e');
      }
      return false;
    }
  }

  /// Delete a session
  Future<bool> deleteSession(String patientId, String sessionId) async {
    try {
      await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('sessions')
          .doc(sessionId)
          .delete();

      if (kDebugMode) {
        print('Session deleted successfully: $sessionId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting session: $e');
      }
      return false;
    }
  }

  /// Get session count for multiple patients (for analytics)
  Future<Map<String, int>> getSessionCountsByPatient(List<String> patientIds) async {
    try {
      Map<String, int> counts = {};
      
      for (String patientId in patientIds) {
        final snapshot = await _firestore
            .collection('patients')
            .doc(patientId)
            .collection('sessions')
            .count()
            .get();
        
        counts[patientId] = snapshot.count ?? 0;
      }
      
      return counts;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting session counts: $e');
      }
      return {};
    }
  }

  /// Search sessions by notes or other criteria
  Future<List<Session>> searchSessions({
    required String query,
    String? practitionerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query sessionQuery = _firestore.collectionGroup('sessions');

      if (practitionerId != null) {
        sessionQuery = sessionQuery.where('practitionerId', isEqualTo: practitionerId);
      }

      if (startDate != null) {
        sessionQuery = sessionQuery.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        sessionQuery = sessionQuery.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await sessionQuery
          .orderBy('date', descending: true)
          .limit(100)
          .get();

      final sessions = snapshot.docs
          .map((doc) => Session.fromFirestore(doc))
          .toList();

      // Filter by query text (since Firestore doesn't support full-text search)
      if (query.isNotEmpty) {
        return sessions.where((session) {
          return session.notes.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }

      return sessions;
    } catch (e) {
      if (kDebugMode) {
        print('Error searching sessions: $e');
      }
      return [];
    }
  }
}
