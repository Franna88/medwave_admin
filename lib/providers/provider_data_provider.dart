import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/provider_model.dart';
import '../models/firebase_user_model.dart';
import '../models/practitioner_application_model.dart';
import '../services/firebase/firebase_user_service.dart';

class ProviderDataProvider extends ChangeNotifier {
  // Firebase service instance
  final FirebaseUserService _firebaseUserService = FirebaseUserService();
  
  // Local state
  List<Provider> _providers = [];
  List<Provider> _pendingApprovals = [];
  bool _isLoading = false;
  String? _error;
  String? _countryFilter;

  // Stream subscriptions for real-time updates
  StreamSubscription<List<FirebaseUser>>? _approvedProvidersSubscription;
  StreamSubscription<List<PractitionerApplication>>? _pendingApplicationsSubscription;

  // Getters
  List<Provider> get providers => [..._providers, ..._pendingApprovals];
  List<Provider> get pendingApprovals => _pendingApprovals;
  List<Provider> get approvedProviders => _providers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get filtered providers based on country
  List<Provider> get filteredProviders {
    if (_countryFilter == null) return providers;
    return providers.where((provider) => provider.country == _countryFilter).toList();
  }
  
  // Get filtered approved providers
  List<Provider> get filteredApprovedProviders {
    if (_countryFilter == null) return _providers;
    return _providers.where((provider) => provider.country == _countryFilter).toList();
  }
  
  // Get filtered pending approvals
  List<Provider> get filteredPendingApprovals {
    if (_countryFilter == null) return _pendingApprovals;
    return _pendingApprovals.where((provider) => provider.country == _countryFilter).toList();
  }

  ProviderDataProvider() {
    if (kDebugMode) {
      print('🔥 ProviderDataProvider: Constructor called');
    }
    // Don't initialize Firebase streams immediately
    // They will be initialized when user logs in
  }

  /// Initialize Firebase streams for real-time data - call after authentication
  void initializeAfterAuth() {
    if (kDebugMode) {
      print('🔥 ProviderDataProvider: initializeAfterAuth() called');
    }
    _initializeFirebaseStreams();
  }

  /// Initialize Firebase streams for real-time data
  void _initializeFirebaseStreams() {
    if (kDebugMode) {
      print('🔥 ProviderDataProvider: _initializeFirebaseStreams() called');
    }
    // Small delay to ensure authentication is properly propagated
    Future.delayed(const Duration(milliseconds: 500), () {
      if (kDebugMode) {
        print('🔥 ProviderDataProvider: Calling _loadFirebaseData() after delay');
      }
      _loadFirebaseData();
    });
  }

    /// Load data from Firebase and set up real-time streams
  Future<void> _loadFirebaseData() async {
    if (kDebugMode) {
      print('🔥 ProviderDataProvider: _loadFirebaseData() started');
    }
    try {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (kDebugMode) {
      print('🔥 ProviderDataProvider: Setting up Firebase streams...');
    }

      // Load approved practitioners
      _approvedProvidersSubscription = _firebaseUserService
          .getApprovedPractitioners(country: _countryFilter)
          .listen(
        (approvedUsers) {
          _providers = approvedUsers.map(_convertFirebaseUserToProvider).toList();
          notifyListeners();
        },
        onError: (error) {
          if (error.toString().contains('permission-denied')) {
            _error = 'Authentication required to load providers';
            if (kDebugMode) {
              print('Permission denied - authentication required');
            }
          } else {
            _error = 'Error loading approved providers: $error';
            if (kDebugMode) {
              print('Error loading approved providers: $error');
            }
          }
          notifyListeners();
        },
      );

      // Load pending applications
      _pendingApplicationsSubscription = _firebaseUserService
          .getPractitionerApplications(status: 'pending', country: _countryFilter)
          .listen(
        (pendingApplications) {
          _pendingApprovals = pendingApplications.map(_convertApplicationToProvider).toList();
          notifyListeners();
        },
        onError: (error) {
          if (error.toString().contains('permission-denied')) {
            _error = 'Authentication required to load applications';
            if (kDebugMode) {
              print('Permission denied - authentication required');
            }
          } else {
            _error = 'Error loading pending applications: $error';
            if (kDebugMode) {
              print('Error loading pending applications: $error');
            }
          }
          notifyListeners();
        },
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to initialize Firebase data: $e';
      if (kDebugMode) {
        print('Error initializing Firebase data: $e');
    }
    notifyListeners();
    }
  }

  /// Convert FirebaseUser to Provider model for UI compatibility
  Provider _convertFirebaseUserToProvider(FirebaseUser user) {
    return Provider(
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      directPhoneNumber: user.phoneNumber,
      email: user.email,
      fullCompanyName: user.practiceLocation,
      businessAddress: user.address,
      salesPerson: 'N/A', // This info isn't in FirebaseUser model
      purchasePlan: 'N/A', // This info isn't in FirebaseUser model
      shippingAddress: user.address,
      package: 'Standard Package', // Default since not in FirebaseUser model
      additionalNotes: 'Specialization: ${user.specialization}',
      isApproved: user.isApproved,
      registrationDate: user.applicationDate,
      approvalDate: user.approvalDate,
      country: user.country,
    );
  }

  /// Convert PractitionerApplication to Provider model for UI compatibility
  Provider _convertApplicationToProvider(PractitionerApplication application) {
    return Provider(
      id: application.id,
      firstName: application.firstName,
      lastName: application.lastName,
      directPhoneNumber: 'N/A', // Not in application model
      email: application.email,
      fullCompanyName: application.practiceLocation,
      businessAddress: '${application.city}, ${application.province}',
      salesPerson: 'N/A', // Not in application model
      purchasePlan: 'N/A', // Not in application model
      shippingAddress: '${application.city}, ${application.province}',
      package: 'Pending Approval', // Default for applications
      additionalNotes: 'License: ${application.licenseNumber} | Specialization: ${application.specialization}',
      isApproved: application.isApproved,
      registrationDate: application.submittedAt,
      approvalDate: application.reviewedAt,
      country: application.country,
    );
  }

  /// Dispose method to clean up streams
  @override
  void dispose() {
    _approvedProvidersSubscription?.cancel();
    _pendingApplicationsSubscription?.cancel();
    super.dispose();
  }

  /// Reload providers from Firebase
  Future<void> loadProviders() async {
    // Cancel existing subscriptions
    await _approvedProvidersSubscription?.cancel();
    await _pendingApplicationsSubscription?.cancel();
    
    // Reload Firebase data
    await _loadFirebaseData();
  }

  /// Approve a practitioner application using Firebase
  Future<bool> approveProvider(String providerId, {String? reviewNotes}) async {
    try {
    _isLoading = true;
      _error = null;
    notifyListeners();

      // Use Firebase service to approve the application
      final success = await _firebaseUserService.approvePractitionerApplication(
        applicationId: providerId,
        reviewedBy: 'admin', // TODO: Get actual admin user ID
        reviewNotes: reviewNotes,
      );

      if (success) {
        if (kDebugMode) {
          print('Provider approved successfully: $providerId');
        }
      } else {
        _error = 'Failed to approve provider';
    }

    _isLoading = false;
    notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = 'Error approving provider: $e';
      if (kDebugMode) {
        print('Error approving provider: $e');
      }
      notifyListeners();
      return false;
    }
  }

  /// Reject a practitioner application using Firebase
  Future<bool> rejectProvider(String providerId, String rejectionReason, {String? reviewNotes}) async {
    try {
    _isLoading = true;
      _error = null;
    notifyListeners();

      // Use Firebase service to reject the application
      final success = await _firebaseUserService.rejectPractitionerApplication(
        applicationId: providerId,
        reviewedBy: 'admin', // TODO: Get actual admin user ID
        rejectionReason: rejectionReason,
        reviewNotes: reviewNotes,
      );

      if (success) {
        if (kDebugMode) {
          print('Provider rejected successfully: $providerId');
        }
    } else {
        _error = 'Failed to reject provider';
    }
    
    _isLoading = false;
    notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = 'Error rejecting provider: $e';
      if (kDebugMode) {
        print('Error rejecting provider: $e');
      }
      notifyListeners();
      return false;
    }
  }

  /// Delete a practitioner application using Firebase
  Future<bool> deleteProvider(String providerId) async {
    try {
    _isLoading = true;
      _error = null;
    notifyListeners();

      // Use Firebase service to delete the application
      final success = await _firebaseUserService.deletePractitionerApplication(providerId);

      if (success) {
        if (kDebugMode) {
          print('Provider deleted successfully: $providerId');
        }
      } else {
        _error = 'Failed to delete provider';
    }
    
    _isLoading = false;
    notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = 'Error deleting provider: $e';
      if (kDebugMode) {
        print('Error deleting provider: $e');
      }
    notifyListeners();
      return false;
    }
  }

  Provider? getProviderById(String id) {
    try {
      return _providers.firstWhere((p) => p.id == id);
    } catch (e) {
      try {
        return _pendingApprovals.firstWhere((p) => p.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  /// Search providers using Firebase search functionality
  Future<List<Provider>> searchProviders(String query) async {
    try {
      if (query.isEmpty) return [];

      // Use Firebase service to search practitioners
      final searchResults = await _firebaseUserService.searchPractitioners(
        query: query,
        country: _countryFilter,
      );

      // Convert search results to Provider models
      return searchResults.map(_convertFirebaseUserToProvider).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching providers: $e');
      }
      return [];
    }
  }

  /// Local search in already loaded providers (for immediate UI feedback)
  List<Provider> searchLoadedProviders(String query) {
    final lowercaseQuery = query.toLowerCase();
    return providers.where((provider) {
      return provider.fullName.toLowerCase().contains(lowercaseQuery) ||
             provider.fullCompanyName.toLowerCase().contains(lowercaseQuery) ||
             provider.email.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Set country filter and reload data
  Future<void> setCountryFilter(String? country) async {
    if (_countryFilter != country) {
    _countryFilter = country;
      // Reload data with new filter
      await loadProviders();
    }
  }

  /// Get real-time provider statistics from Firebase
  Future<Map<String, dynamic>> getProviderStatistics() async {
    try {
      return await _firebaseUserService.getPractitionerStatistics(_countryFilter);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting provider statistics: $e');
      }
      return {};
    }
  }

  /// Get pending applications count by country
  Future<Map<String, int>> getPendingApplicationsCount() async {
    try {
      return await _firebaseUserService.getPendingApplicationsCount();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting pending applications count: $e');
      }
      return {};
    }
  }

  // Analytics getters - use filtered data for immediate UI response
  int get totalProviders => filteredApprovedProviders.length;
  int get totalPendingApprovals => filteredPendingApprovals.length;
  
  /// Calculate average monthly revenue (simplified calculation)
  double get averageMonthlyRevenue {
    // TODO: Implement real revenue calculation based on patient data
    // For now, return a calculated estimate based on provider count
    return totalProviders * 5000.0; // Estimate $5000 per provider per month
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh data manually
  Future<void> refresh() async {
    await loadProviders();
  }
}
