import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase/firebase_auth_service.dart';
import '../models/firebase_user_model.dart';

class AuthProvider extends ChangeNotifier {
  // Firebase services
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  
  // Authentication state
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  FirebaseUser? _adminUser;
  User? _firebaseUser;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  FirebaseUser? get adminUser => _adminUser;
  User? get firebaseUser => _firebaseUser;
  String? get currentUser => _adminUser?.fullName;
  String? get userRole => _adminUser?.role;
  String? get userEmail => _adminUser?.email;

  AuthProvider() {
    _initializeAuthState();
  }

  /// Initialize authentication state and listen to Firebase auth changes
  void _initializeAuthState() {
    // Listen to Firebase auth state changes
    _firebaseAuthService.authStateChanges.listen(_handleAuthStateChange);
  }

  /// Handle Firebase authentication state changes
  Future<void> _handleAuthStateChange(User? user) async {
    if (kDebugMode) {
      print('🔐 AuthProvider: _handleAuthStateChange called with user: ${user?.email ?? 'null'}');
    }
    if (user == null) {
      // User signed out
      if (kDebugMode) {
        print('🔐 AuthProvider: User signed out');
      }
      _isAuthenticated = false;
      _adminUser = null;
      _firebaseUser = null;
      _error = null;
    } else {
      // User signed in - verify admin privileges
      if (kDebugMode) {
        print('🔐 AuthProvider: User signed in: ${user.email}, verifying admin privileges...');
      }
      try {
        final adminUser = await _firebaseAuthService.getCurrentAdminUser();
        if (adminUser != null) {
          if (kDebugMode) {
            print('🔐 AuthProvider: Admin user verified: ${adminUser.firstName} ${adminUser.lastName} (${adminUser.role})');
          }
          _isAuthenticated = true;
          _adminUser = adminUser;
          _firebaseUser = user;
          _error = null;
        } else {
          // User doesn't have admin privileges
          await _firebaseAuthService.signOut();
          _isAuthenticated = false;
          _adminUser = null;
          _firebaseUser = null;
          _error = 'Admin privileges required';
        }
      } catch (e) {
        _isAuthenticated = false;
        _adminUser = null;
        _firebaseUser = null;
        _error = 'Error verifying admin privileges: $e';
      }
    }
    notifyListeners();
  }

  /// Sign in with email and password
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _firebaseAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.isSuccess) {
        // Authentication state will be updated automatically via _handleAuthStateChange
        return true;
      } else {
        _error = result.message;
        return false;
      }
    } catch (e) {
      _error = 'Unexpected error during login: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out current user
  Future<void> logout() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseAuthService.signOut();
      // Authentication state will be updated automatically via _handleAuthStateChange
    } catch (e) {
      _error = 'Error during logout: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset password for admin user
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      return await _firebaseAuthService.resetPassword(email);
    } catch (e) {
      _error = 'Error sending password reset: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if current user is super admin
  Future<bool> isSuperAdmin() async {
    return await _firebaseAuthService.isSuperAdmin();
  }

  /// Check if current user is country admin for specific country
  Future<bool> isCountryAdmin(String countryCode) async {
    return await _firebaseAuthService.isCountryAdmin(countryCode);
  }

  /// Get accessible countries for current admin
  Future<List<String>> getAccessibleCountries() async {
    return await _firebaseAuthService.getAccessibleCountries();
  }

  /// Clear any authentication errors
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Force refresh current admin user data
  Future<void> refreshAdminUser() async {
    if (_firebaseUser != null) {
      try {
        final adminUser = await _firebaseAuthService.getCurrentAdminUser();
        if (adminUser != null) {
          _adminUser = adminUser;
          notifyListeners();
        }
      } catch (e) {
        _error = 'Error refreshing user data: $e';
        notifyListeners();
      }
    }
  }
}
