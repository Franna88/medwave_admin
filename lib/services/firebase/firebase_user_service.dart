import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/firebase_user_model.dart';
import '../../models/practitioner_application_model.dart';
import 'firebase_config.dart';

/// Firebase User Service for MedWave Admin Panel
/// 
/// Handles CRUD operations for practitioners and practitioner applications.
/// This service provides the data layer for:
/// - Provider Approvals Screen
/// - Provider Management Screen  
/// - User analytics and reporting
class FirebaseUserService {
  static final FirebaseUserService _instance = FirebaseUserService._internal();
  factory FirebaseUserService() => _instance;
  FirebaseUserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => 
      _firestore.collection(FirebaseConfig.usersCollection);
  
  CollectionReference get _applicationsCollection => 
      _firestore.collection(FirebaseConfig.practitionerApplicationsCollection);

  /// Get all practitioner applications with optional filters
  Stream<List<PractitionerApplication>> getPractitionerApplications({
    String? status,
    String? country,
    int? limit,
  }) {
    try {
      Query query = _applicationsCollection;

      // Apply filters
      if (status != null && status != 'all') {
        query = query.where('status', isEqualTo: status);
      }

      if (country != null) {
        query = query.where('country', isEqualTo: country);
      }

      // TODO: Re-enable ordering once composite index is created
      // Order by submission date (newest first) - requires composite index with status/country
      // query = query.orderBy('submittedAt', descending: true);

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => PractitionerApplication.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting practitioner applications: $e');
      }
      return Stream.value([]);
    }
  }

  /// Get pending applications count by country
  Future<Map<String, int>> getPendingApplicationsCount() async {
    try {
      final snapshot = await _applicationsCollection
          .where('status', isEqualTo: 'pending')
          .get();

      final countByCountry = <String, int>{};
      
      for (final doc in snapshot.docs) {
        final app = PractitionerApplication.fromFirestore(doc);
        countByCountry[app.country] = (countByCountry[app.country] ?? 0) + 1;
      }

      return countByCountry;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting pending applications count: $e');
      }
      return {};
    }
  }

  /// Approve a practitioner application
  /// 
  /// This method:
  /// 1. Updates the application status to 'approved'
  /// 2. Creates a user account in the users collection
  /// 3. Sets the account status to 'approved'
  Future<bool> approvePractitionerApplication({
    required String applicationId,
    required String reviewedBy,
    String? reviewNotes,
  }) async {
    try {
      if (kDebugMode) {
        print('Approving application: $applicationId');
      }

      // Get the application
      final appDoc = await _applicationsCollection.doc(applicationId).get();
      if (!appDoc.exists) {
        throw Exception('Application not found');
      }

      final application = PractitionerApplication.fromFirestore(appDoc);

      // Start a batch operation
      final batch = _firestore.batch();

      // Update application status
      batch.update(_applicationsCollection.doc(applicationId), {
        'status': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': reviewedBy,
        'reviewNotes': reviewNotes,
      });

      // Create user account
      final newUser = FirebaseUser(
        id: application.userId,
        firstName: application.firstName,
        lastName: application.lastName,
        email: application.email,
        phoneNumber: '', // Will be updated from application if available
        licenseNumber: application.licenseNumber,
        specialization: application.specialization,
        yearsOfExperience: application.yearsOfExperience,
        practiceLocation: application.practiceLocation,
        country: application.country,
        countryName: application.countryName,
        province: application.province,
        city: application.city,
        address: '', // Will be updated if available
        postalCode: '', // Will be updated if available
        accountStatus: FirebaseConfig.approvedStatus,
        applicationDate: application.submittedAt,
        approvalDate: DateTime.now(),
        approvedBy: reviewedBy,
        settings: UserSettings.defaultSettings(),
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
        role: FirebaseConfig.practitionerRole,
      );

      batch.set(_usersCollection.doc(application.userId), newUser.toFirestore());

      // Commit the batch
      await batch.commit();

      if (kDebugMode) {
        print('Application approved successfully: ${application.fullName}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error approving application: $e');
      }
      return false;
    }
  }

  /// Reject a practitioner application
  Future<bool> rejectPractitionerApplication({
    required String applicationId,
    required String reviewedBy,
    required String rejectionReason,
    String? reviewNotes,
  }) async {
    try {
      if (kDebugMode) {
        print('Rejecting application: $applicationId');
      }

      await _applicationsCollection.doc(applicationId).update({
        'status': 'rejected',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': reviewedBy,
        'rejectionReason': rejectionReason,
        'reviewNotes': reviewNotes,
      });

      if (kDebugMode) {
        print('Application rejected successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error rejecting application: $e');
      }
      return false;
    }
  }

  /// Get all approved practitioners with optional filters
  Stream<List<FirebaseUser>> getApprovedPractitioners({
    String? country,
    String? province,
    int? limit,
  }) {
    try {
      Query query = _usersCollection
          .where('accountStatus', isEqualTo: FirebaseConfig.approvedStatus)
          .where('role', isEqualTo: FirebaseConfig.practitionerRole);

      // Apply filters
      if (country != null) {
        query = query.where('country', isEqualTo: country);
      }

      if (province != null) {
        query = query.where('province', isEqualTo: province);
      }

      // Order by creation date (newest first)
      query = query.orderBy('createdAt', descending: true);

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => FirebaseUser.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting approved practitioners: $e');
      }
      return Stream.value([]);
    }
  }

  /// Get practitioner by ID
  Future<FirebaseUser?> getPractitionerById(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) return null;

      return FirebaseUser.fromFirestore(doc);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting practitioner by ID: $e');
      }
      return null;
    }
  }

  /// Update practitioner account status
  Future<bool> updatePractitionerStatus({
    required String userId,
    required String newStatus,
    required String updatedBy,
    String? reason,
  }) async {
    try {
      await _usersCollection.doc(userId).update({
        'accountStatus': newStatus,
        'lastUpdated': FieldValue.serverTimestamp(),
        'suspensionReason': reason, // For suspended accounts
      });

      if (kDebugMode) {
        print('Practitioner status updated: $userId -> $newStatus');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating practitioner status: $e');
      }
      return false;
    }
  }

  /// Search practitioners by name, email, or license number
  Future<List<FirebaseUser>> searchPractitioners({
    required String query,
    String? country,
    int limit = 20,
  }) async {
    try {
      if (query.isEmpty) return [];

      // Firebase doesn't support full-text search natively
      // We'll implement a basic search by getting all practitioners and filtering
      Query firestoreQuery = _usersCollection
          .where('role', isEqualTo: FirebaseConfig.practitionerRole);

      if (country != null) {
        firestoreQuery = firestoreQuery.where('country', isEqualTo: country);
      }

      final snapshot = await firestoreQuery.limit(100).get(); // Limit for performance

      final practitioners = snapshot.docs
          .map((doc) => FirebaseUser.fromFirestore(doc))
          .toList();

      // Filter by search query
      final searchLower = query.toLowerCase();
      final filtered = practitioners.where((practitioner) {
        return practitioner.fullName.toLowerCase().contains(searchLower) ||
               practitioner.email.toLowerCase().contains(searchLower) ||
               practitioner.licenseNumber.toLowerCase().contains(searchLower) ||
               practitioner.specialization.toLowerCase().contains(searchLower);
      }).toList();

      return filtered.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching practitioners: $e');
      }
      return [];
    }
  }

  /// Get practitioner statistics by country
  Future<Map<String, dynamic>> getPractitionerStatistics(String? countryFilter) async {
    try {
      Query query = _usersCollection.where('role', isEqualTo: FirebaseConfig.practitionerRole);

      if (countryFilter != null) {
        query = query.where('country', isEqualTo: countryFilter);
      }

      final snapshot = await query.get();
      final practitioners = snapshot.docs
          .map((doc) => FirebaseUser.fromFirestore(doc))
          .toList();

      // Calculate statistics
      final stats = <String, dynamic>{
        'total': practitioners.length,
        'approved': practitioners.where((p) => p.isApproved).length,
        'pending': practitioners.where((p) => p.isPending).length,
        'rejected': practitioners.where((p) => p.isRejected).length,
        'suspended': practitioners.where((p) => p.isSuspended).length,
        'active_this_month': practitioners.where((p) {
          if (p.lastActivityDate == null) return false;
          final now = DateTime.now();
          final thirtyDaysAgo = now.subtract(const Duration(days: 30));
          return p.lastActivityDate!.isAfter(thirtyDaysAgo);
        }).length,
        'by_country': <String, int>{},
        'by_specialization': <String, int>{},
      };

      // Group by country
      for (final practitioner in practitioners) {
        final country = practitioner.country;
        stats['by_country'][country] = (stats['by_country'][country] ?? 0) + 1;
      }

      // Group by specialization
      for (final practitioner in practitioners) {
        final specialization = practitioner.specialization;
        stats['by_specialization'][specialization] = 
            (stats['by_specialization'][specialization] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting practitioner statistics: $e');
      }
      return {};
    }
  }

  /// Update practitioner's last activity
  Future<void> updateLastActivity(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'lastActivityDate': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating last activity: $e');
      }
      // Don't throw - this is not critical
    }
  }

  /// Get recently registered practitioners
  Future<List<FirebaseUser>> getRecentPractitioners({
    String? country,
    int days = 30,
    int limit = 10,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      Query query = _usersCollection
          .where('role', isEqualTo: FirebaseConfig.practitionerRole)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoffDate));

      if (country != null) {
        query = query.where('country', isEqualTo: country);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => FirebaseUser.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting recent practitioners: $e');
      }
      return [];
    }
  }

  /// Bulk approve applications
  Future<Map<String, bool>> bulkApproveApplications({
    required List<String> applicationIds,
    required String reviewedBy,
    String? reviewNotes,
  }) async {
    final results = <String, bool>{};

    for (final appId in applicationIds) {
      final success = await approvePractitionerApplication(
        applicationId: appId,
        reviewedBy: reviewedBy,
        reviewNotes: reviewNotes,
      );
      results[appId] = success;
    }

    return results;
  }

  /// Delete practitioner application (admin only)
  Future<bool> deletePractitionerApplication(String applicationId) async {
    try {
      await _applicationsCollection.doc(applicationId).delete();
      if (kDebugMode) {
        print('Application deleted: $applicationId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting application: $e');
      }
      return false;
    }
  }

}
