import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/firebase_user_model.dart';
import 'firebase_config.dart';

/// Firebase Admin Service for MedWave Admin Panel
/// 
/// Handles creation and management of admin users (super_admin and country_admin).
/// This service is separate from practitioner management and provides
/// secure admin user creation functionality.
class FirebaseAdminService {
  static final FirebaseAdminService _instance = FirebaseAdminService._internal();
  factory FirebaseAdminService() => _instance;
  FirebaseAdminService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => 
      _firestore.collection(FirebaseConfig.usersCollection);

  /// Create a new admin user
  /// 
  /// This method:
  /// 1. Creates Firebase Auth account
  /// 2. Creates user profile with admin role
  /// 3. Sets account status to approved
  /// 4. Logs the creation action
  Future<AdminCreationResult> createAdminUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role, // super_admin or country_admin
    required String country,
    required String createdBy,
    String? phoneNumber,
    String? specialization,
    String? practiceLocation,
    String? province,
    String? city,
    String? address,
    String? postalCode,
  }) async {
    try {
      if (kDebugMode) {
        print('Creating admin user: $email with role: $role');
      }

      // Validate role
      if (!_isValidAdminRole(role)) {
        return AdminCreationResult.failure('Invalid admin role: $role');
      }

      // Validate country for country admins
      if (role == FirebaseConfig.countryAdminRole && !_isValidCountry(country)) {
        return AdminCreationResult.failure('Invalid country code: $country');
      }

      // Check if email already exists
      final existingUser = await _checkEmailExists(email);
      if (existingUser) {
        return AdminCreationResult.failure('User with this email already exists');
      }

      // Store current user to restore later
      final currentUser = _auth.currentUser;

      // Create Firebase Auth account
      UserCredential userCredential;
      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        return AdminCreationResult.failure('Failed to create authentication account: $e');
      }

      final newUser = userCredential.user;
      if (newUser == null) {
        return AdminCreationResult.failure('Failed to create user account');
      }

      // Create admin user profile
      final adminUser = FirebaseUser(
        id: newUser.uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber ?? '',
        licenseNumber: '', // Admins don't need license numbers
        specialization: specialization ?? 'Administration',
        yearsOfExperience: 0, // Not applicable for admins
        practiceLocation: practiceLocation ?? 'Administrative Office',
        country: country,
        countryName: _getCountryName(country),
        province: province ?? '',
        city: city ?? '',
        address: address ?? '',
        postalCode: postalCode ?? '',
        accountStatus: FirebaseConfig.approvedStatus, // Admins are auto-approved
        applicationDate: DateTime.now(),
        approvalDate: DateTime.now(),
        approvedBy: createdBy,
        settings: UserSettings.defaultSettings(),
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
        role: role, // super_admin or country_admin
      );

      // Save user profile to Firestore
      await _usersCollection.doc(newUser.uid).set(adminUser.toFirestore());

      // Update display name in Auth
      await newUser.updateDisplayName('${firstName} ${lastName}');

      // Sign out the newly created user and restore previous session
      await _auth.signOut();
      if (currentUser != null) {
        // Note: In a real app, you'd need to handle re-authentication properly
        // For now, we'll just log this
        if (kDebugMode) {
          print('Admin created successfully. Previous session will need re-authentication.');
        }
      }

      // Log admin creation
      await _logAdminCreation(
        adminUserId: newUser.uid,
        createdBy: createdBy,
        role: role,
        country: country,
      );

      if (kDebugMode) {
        print('Admin user created successfully: ${adminUser.fullName} (${adminUser.role})');
      }

      return AdminCreationResult.success(
        adminUser: adminUser,
        message: 'Admin user ${adminUser.fullName} created successfully!',
      );

    } on FirebaseAuthException catch (e) {
      String message = _getAuthErrorMessage(e.code);
      if (kDebugMode) {
        print('Firebase Auth Error during admin creation: ${e.code} - ${e.message}');
      }
      return AdminCreationResult.failure(message);
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error during admin creation: $e');
      }
      return AdminCreationResult.failure('An unexpected error occurred: $e');
    }
  }

  /// Get all admin users
  Future<List<FirebaseUser>> getAllAdmins({String? countryFilter}) async {
    try {
      Query query = _usersCollection.where('role', whereIn: [
        FirebaseConfig.superAdminRole,
        FirebaseConfig.countryAdminRole,
      ]);

      if (countryFilter != null) {
        query = query.where('country', isEqualTo: countryFilter);
      }

      final snapshot = await query.orderBy('createdAt', descending: true).get();
      
      return snapshot.docs
          .map((doc) => FirebaseUser.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting admin users: $e');
      }
      return [];
    }
  }

  /// Update admin user role or permissions
  Future<bool> updateAdminUser({
    required String adminUserId,
    required String updatedBy,
    String? newRole,
    String? newCountry,
    String? newStatus,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (newRole != null && _isValidAdminRole(newRole)) {
        updateData['role'] = newRole;
      }

      if (newCountry != null && _isValidCountry(newCountry)) {
        updateData['country'] = newCountry;
        updateData['countryName'] = _getCountryName(newCountry);
      }

      if (newStatus != null) {
        updateData['accountStatus'] = newStatus;
      }

      await _usersCollection.doc(adminUserId).update(updateData);

      // Log the update
      await _logAdminUpdate(
        adminUserId: adminUserId,
        updatedBy: updatedBy,
        changes: updateData,
      );

      if (kDebugMode) {
        print('Admin user updated: $adminUserId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating admin user: $e');
      }
      return false;
    }
  }

  /// Suspend admin user
  Future<bool> suspendAdminUser({
    required String adminUserId,
    required String suspendedBy,
    required String reason,
  }) async {
    try {
      await _usersCollection.doc(adminUserId).update({
        'accountStatus': FirebaseConfig.suspendedStatus,
        'suspensionReason': reason,
        'suspendedBy': suspendedBy,
        'suspendedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('Admin user suspended: $adminUserId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error suspending admin user: $e');
      }
      return false;
    }
  }

  /// Reactivate suspended admin user
  Future<bool> reactivateAdminUser({
    required String adminUserId,
    required String reactivatedBy,
  }) async {
    try {
      await _usersCollection.doc(adminUserId).update({
        'accountStatus': FirebaseConfig.approvedStatus,
        'suspensionReason': FieldValue.delete(),
        'suspendedBy': FieldValue.delete(),
        'suspendedAt': FieldValue.delete(),
        'reactivatedBy': reactivatedBy,
        'reactivatedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('Admin user reactivated: $adminUserId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error reactivating admin user: $e');
      }
      return false;
    }
  }

  /// Check if email already exists
  Future<bool> _checkEmailExists(String email) async {
    try {
      final snapshot = await _usersCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking email existence: $e');
      }
      return false;
    }
  }

  /// Log admin creation for audit trail
  Future<void> _logAdminCreation({
    required String adminUserId,
    required String createdBy,
    required String role,
    required String country,
  }) async {
    try {
      await _firestore.collection('admin_audit_logs').add({
        'action': 'admin_created',
        'adminUserId': adminUserId,
        'createdBy': createdBy,
        'role': role,
        'country': country,
        'timestamp': FieldValue.serverTimestamp(),
        'details': {
          'action_type': 'create_admin',
          'target_user': adminUserId,
          'assigned_role': role,
          'assigned_country': country,
        },
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error logging admin creation: $e');
      }
      // Don't throw - logging failure shouldn't break the main operation
    }
  }

  /// Log admin updates for audit trail
  Future<void> _logAdminUpdate({
    required String adminUserId,
    required String updatedBy,
    required Map<String, dynamic> changes,
  }) async {
    try {
      await _firestore.collection('admin_audit_logs').add({
        'action': 'admin_updated',
        'adminUserId': adminUserId,
        'updatedBy': updatedBy,
        'changes': changes,
        'timestamp': FieldValue.serverTimestamp(),
        'details': {
          'action_type': 'update_admin',
          'target_user': adminUserId,
          'modified_fields': changes.keys.toList(),
        },
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error logging admin update: $e');
      }
    }
  }

  /// Validate admin role
  bool _isValidAdminRole(String role) {
    return role == FirebaseConfig.superAdminRole || 
           role == FirebaseConfig.countryAdminRole;
  }

  /// Validate country code
  bool _isValidCountry(String country) {
    const validCountries = ['USA', 'RSA']; // Add more as needed
    return validCountries.contains(country);
  }

  /// Get country name from code
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

  /// Convert Firebase Auth error codes to user-friendly messages
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Failed to create admin account. Please try again.';
    }
  }
}

/// Admin creation result wrapper
class AdminCreationResult {
  final bool isSuccess;
  final String message;
  final FirebaseUser? adminUser;

  AdminCreationResult._({
    required this.isSuccess,
    required this.message,
    this.adminUser,
  });

  factory AdminCreationResult.success({
    required FirebaseUser adminUser,
    required String message,
  }) {
    return AdminCreationResult._(
      isSuccess: true,
      message: message,
      adminUser: adminUser,
    );
  }

  factory AdminCreationResult.failure(String message) {
    return AdminCreationResult._(
      isSuccess: false,
      message: message,
    );
  }
}

/// Admin user creation data
class AdminCreationData {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String role;
  final String country;
  final String? phoneNumber;
  final String? specialization;
  final String? practiceLocation;
  final String? province;
  final String? city;
  final String? address;
  final String? postalCode;

  AdminCreationData({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.country,
    this.phoneNumber,
    this.specialization,
    this.practiceLocation,
    this.province,
    this.city,
    this.address,
    this.postalCode,
  });

  bool get isValid {
    return email.isNotEmpty &&
           password.isNotEmpty &&
           firstName.isNotEmpty &&
           lastName.isNotEmpty &&
           role.isNotEmpty &&
           country.isNotEmpty;
  }
}
