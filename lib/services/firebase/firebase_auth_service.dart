import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/firebase_user_model.dart';
import 'firebase_config.dart';

/// Firebase Authentication Service for MedWave Admin Panel
/// 
/// Handles admin authentication with role-based access control.
/// Only users with 'super_admin' or 'country_admin' roles can access the admin panel.
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password for admin access
  /// 
  /// This method:
  /// 1. Authenticates with Firebase Auth
  /// 2. Checks user role in Firestore
  /// 3. Ensures user has admin privileges
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        print('Attempting admin sign in for: $email');
      }

      // Sign in with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return AuthResult.failure('Authentication failed');
      }

      // Get user profile from Firestore
      final userDoc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut(); // Sign out if no profile exists
        return AuthResult.failure('User profile not found');
      }

      final firebaseUser = FirebaseUser.fromFirestore(userDoc);

      // Check if user has admin privileges
      if (!firebaseUser.isAdmin) {
        await _auth.signOut(); // Sign out non-admin users
        return AuthResult.failure(
          'Access denied. Admin privileges required.\n'
          'Current role: ${firebaseUser.role}'
        );
      }

      // Check if account is approved
      if (!firebaseUser.isApproved) {
        await _auth.signOut(); // Sign out unapproved users
        return AuthResult.failure(
          'Account not approved. Status: ${firebaseUser.accountStatus}'
        );
      }

      // Update last login
      await _updateLastLogin(user.uid);

      if (kDebugMode) {
        print('Admin sign in successful: ${firebaseUser.fullName} (${firebaseUser.role})');
      }

      return AuthResult.success(
        user: user,
        firebaseUser: firebaseUser,
        message: 'Welcome back, ${firebaseUser.fullName}!',
      );

    } on FirebaseAuthException catch (e) {
      String message = _getAuthErrorMessage(e.code);
      if (kDebugMode) {
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      }
      return AuthResult.failure(message);
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected auth error: $e');
      }
      return AuthResult.failure('An unexpected error occurred during sign in');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      if (kDebugMode) {
        print('Admin sign out');
      }
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Error during sign out: $e');
      }
      rethrow;
    }
  }

  /// Get current admin user profile
  Future<FirebaseUser?> getCurrentAdminUser() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final userDoc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return null;

      final firebaseUser = FirebaseUser.fromFirestore(userDoc);
      
      // Only return if user has admin privileges
      return firebaseUser.isAdmin ? firebaseUser : null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current admin user: $e');
      }
      return null;
    }
  }

  /// Check if current user has super admin privileges
  Future<bool> isSuperAdmin() async {
    final adminUser = await getCurrentAdminUser();
    return adminUser?.role == FirebaseConfig.superAdminRole;
  }

  /// Check if current user has country admin privileges for specific country
  Future<bool> isCountryAdmin(String countryCode) async {
    final adminUser = await getCurrentAdminUser();
    if (adminUser == null) return false;

    // Super admins have access to all countries
    if (adminUser.role == FirebaseConfig.superAdminRole) return true;

    // Country admins only have access to their assigned country
    return adminUser.role == FirebaseConfig.countryAdminRole && 
           adminUser.country == countryCode;
  }

  /// Get accessible countries for current admin
  Future<List<String>> getAccessibleCountries() async {
    final adminUser = await getCurrentAdminUser();
    if (adminUser == null) return [];

    // Super admins can access all countries
    if (adminUser.role == FirebaseConfig.superAdminRole) {
      return ['USA', 'RSA']; // Add more countries as needed
    }

    // Country admins can only access their assigned country
    if (adminUser.role == FirebaseConfig.countryAdminRole) {
      return [adminUser.country];
    }

    return [];
  }

  /// Reset password for admin user
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Password reset error: ${e.code} - ${e.message}');
      }
      return false;
    }
  }

  /// Update last login timestamp
  Future<void> _updateLastLogin(String userId) async {
    try {
      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .update({
        'lastLogin': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating last login: $e');
      }
      // Don't throw - this is not critical
    }
  }

  /// Convert Firebase Auth error codes to user-friendly messages
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No admin account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This admin account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign in is not enabled.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

/// Authentication result wrapper
class AuthResult {
  final bool isSuccess;
  final String message;
  final User? user;
  final FirebaseUser? firebaseUser;

  AuthResult._({
    required this.isSuccess,
    required this.message,
    this.user,
    this.firebaseUser,
  });

  factory AuthResult.success({
    required User user,
    required FirebaseUser firebaseUser,
    required String message,
  }) {
    return AuthResult._(
      isSuccess: true,
      message: message,
      user: user,
      firebaseUser: firebaseUser,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(
      isSuccess: false,
      message: message,
    );
  }
}

/// Auth state stream wrapper for UI
class AuthStateWrapper {
  final bool isAuthenticated;
  final FirebaseUser? adminUser;
  final String? error;

  AuthStateWrapper({
    required this.isAuthenticated,
    this.adminUser,
    this.error,
  });

  factory AuthStateWrapper.authenticated(FirebaseUser adminUser) {
    return AuthStateWrapper(
      isAuthenticated: true,
      adminUser: adminUser,
    );
  }

  factory AuthStateWrapper.unauthenticated() {
    return AuthStateWrapper(isAuthenticated: false);
  }

  factory AuthStateWrapper.error(String error) {
    return AuthStateWrapper(
      isAuthenticated: false,
      error: error,
    );
  }
}
