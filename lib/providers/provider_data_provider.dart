import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/provider_model.dart';

class ProviderDataProvider extends ChangeNotifier {
  List<Provider> _providers = [];
  List<Provider> _pendingApprovals = [];
  bool _isLoading = false;
  String? _countryFilter; // Add country filter

  List<Provider> get providers => [..._providers, ..._pendingApprovals];
  List<Provider> get pendingApprovals => _pendingApprovals;
  bool get isLoading => _isLoading;
  
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
    _loadMockData();
  }

  void _loadMockData() {
    // Mock data for demonstration
    _providers = [
      Provider(
        id: const Uuid().v4(),
        firstName: 'Sarah',
        lastName: 'Johnson',
        directPhoneNumber: '+1-555-0123',
        email: 'sarah.johnson@healthclinic.com',
        fullCompanyName: 'Johnson Health Clinic',
        businessAddress: '123 Health Street, Los Angeles, CA 90210',
        salesPerson: 'John Smith',
        purchasePlan: 'Monthly subscription',
        shippingAddress: '123 Health Street, Los Angeles, CA 90210',
        package: 'Neuro-100S Panel + Contour-100S Panel',
        additionalNotes: 'Interested in advanced features',
        isApproved: true,
        registrationDate: DateTime.now().subtract(const Duration(days: 30)),
        approvalDate: DateTime.now().subtract(const Duration(days: 25)),
        country: 'USA',
      ),
      Provider(
        id: const Uuid().v4(),
        firstName: 'Michael',
        lastName: 'Chen',
        directPhoneNumber: '+1-555-0456',
        email: 'michael.chen@wellnesscenter.com',
        fullCompanyName: 'Chen Wellness Center',
        businessAddress: '456 Wellness Ave, New York City, NY 10001',
        salesPerson: 'Jane Doe',
        purchasePlan: 'Annual contract',
        shippingAddress: '456 Wellness Ave, New York City, NY 10001',
        package: 'SoftWave + Endo-100S Panel',
        additionalNotes: null,
        isApproved: true,
        registrationDate: DateTime.now().subtract(const Duration(days: 45)),
        approvalDate: DateTime.now().subtract(const Duration(days: 40)),
        country: 'USA',
      ),
      Provider(
        id: const Uuid().v4(),
        firstName: 'Emily',
        lastName: 'Rodriguez',
        directPhoneNumber: '+1-555-0789',
        email: 'emily.rodriguez@spa.com',
        fullCompanyName: 'Rodriguez Spa & Wellness',
        businessAddress: '789 Spa Blvd, Miami, FL 33101',
        salesPerson: 'Mike Johnson',
        purchasePlan: 'Quarterly payment',
        shippingAddress: '789 Spa Blvd, Miami, FL 33101',
        package: 'Contour-100S Panel',
        additionalNotes: 'Looking for spa-specific features',
        isApproved: true,
        registrationDate: DateTime.now().subtract(const Duration(days: 60)),
        approvalDate: DateTime.now().subtract(const Duration(days: 55)),
        country: 'USA',
      ),
      Provider(
        id: const Uuid().v4(),
        firstName: 'David',
        lastName: 'Mbeki',
        directPhoneNumber: '+27-11-123-4567',
        email: 'david.mbeki@johannesburgclinic.co.za',
        fullCompanyName: 'Mbeki Medical Clinic',
        businessAddress: '123 Nelson Mandela Drive, Johannesburg, Gauteng 2000',
        salesPerson: 'Sarah Wilson',
        purchasePlan: 'Annual contract',
        shippingAddress: '123 Nelson Mandela Drive, Johannesburg, Gauteng 2000',
        package: 'Neuro-100S Panel + SoftWave',
        additionalNotes: 'Leading clinic in Johannesburg',
        isApproved: true,
        registrationDate: DateTime.now().subtract(const Duration(days: 40)),
        approvalDate: DateTime.now().subtract(const Duration(days: 35)),
        country: 'RSA',
      ),
      Provider(
        id: const Uuid().v4(),
        firstName: 'Thandi',
        lastName: 'Nkosi',
        directPhoneNumber: '+27-21-987-6543',
        email: 'thandi.nkosi@capetownwellness.co.za',
        fullCompanyName: 'Nkosi Wellness Center',
        businessAddress: '456 Long Street, Cape Town, Western Cape 8001',
        salesPerson: 'David Brown',
        purchasePlan: 'Monthly subscription',
        shippingAddress: '456 Long Street, Cape Town, Western Cape 8001',
        package: 'SoftWave + Endo-100S Panel',
        additionalNotes: 'Premium wellness center in Cape Town',
        isApproved: true,
        registrationDate: DateTime.now().subtract(const Duration(days: 25)),
        approvalDate: DateTime.now().subtract(const Duration(days: 20)),
        country: 'RSA',
      ),
    ];

    _pendingApprovals = [
      Provider(
        id: const Uuid().v4(),
        firstName: 'James',
        lastName: 'Wilson',
        directPhoneNumber: '+1-555-0321',
        email: 'james.wilson@newclinic.com',
        fullCompanyName: 'Wilson Medical Clinic',
        businessAddress: '321 Medical Dr, Houston, TX 77001',
        salesPerson: 'Sarah Wilson',
        purchasePlan: 'Monthly subscription',
        shippingAddress: '321 Medical Dr, Houston, TX 77001',
        package: 'Neuro-100S Panel + SoftWave',
        additionalNotes: 'New clinic opening next month',
        isApproved: false,
        registrationDate: DateTime.now().subtract(const Duration(days: 5)),
        country: 'USA',
      ),
      Provider(
        id: const Uuid().v4(),
        firstName: 'Lisa',
        lastName: 'Thompson',
        directPhoneNumber: '+1-555-0654',
        email: 'lisa.thompson@therapy.com',
        fullCompanyName: 'Thompson Therapy Center',
        businessAddress: '654 Therapy St, Chicago, IL 60601',
        salesPerson: 'David Brown',
        purchasePlan: 'Annual contract',
        shippingAddress: '654 Therapy St, Chicago, IL 60601',
        package: 'SoftWave + Endo-100S Panel',
        additionalNotes: 'Expanding practice, need additional licenses',
        isApproved: false,
        registrationDate: DateTime.now().subtract(const Duration(days: 3)),
        country: 'USA',
      ),
      Provider(
        id: const Uuid().v4(),
        firstName: 'Sipho',
        lastName: 'Dlamini',
        directPhoneNumber: '+27-31-456-7890',
        email: 'sipho.dlamini@durbanhealth.co.za',
        fullCompanyName: 'Dlamini Health Solutions',
        businessAddress: '789 Victoria Street, Durban, KwaZulu-Natal 4001',
        salesPerson: 'Mike Johnson',
        purchasePlan: 'Quarterly payment',
        shippingAddress: '789 Victoria Street, Durban, KwaZulu-Natal 4001',
        package: 'Contour-100S Panel',
        additionalNotes: 'New health solutions provider in Durban',
        isApproved: false,
        registrationDate: DateTime.now().subtract(const Duration(days: 2)),
        country: 'RSA',
      ),
    ];

    notifyListeners();
  }

  Future<void> loadProviders() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would fetch from API
    // For now, we'll just reload the mock data
    _loadMockData();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> approveProvider(String providerId) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    final pendingIndex = _pendingApprovals.indexWhere((p) => p.id == providerId);
    if (pendingIndex != -1) {
      final provider = _pendingApprovals[pendingIndex];
      final approvedProvider = provider.copyWith(
        isApproved: true,
        approvalDate: DateTime.now(),
      );
      
      _pendingApprovals.removeAt(pendingIndex);
      _providers.add(approvedProvider);
      
      notifyListeners();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> rejectProvider(String providerId) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    final pendingIndex = _pendingApprovals.indexWhere((p) => p.id == providerId);
    if (pendingIndex != -1) {
      final provider = _pendingApprovals[pendingIndex];
      final rejectedProvider = provider.copyWith(
        isApproved: false,
        approvalDate: DateTime.now(),
      );
      
      _pendingApprovals.removeAt(pendingIndex);
      _providers.add(rejectedProvider);
      
      notifyListeners();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProvider(Provider provider) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    if (provider.isApproved) {
      _providers.add(provider);
    } else {
      _pendingApprovals.add(provider);
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProvider(Provider provider) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    final index = _providers.indexWhere((p) => p.id == provider.id);
    if (index != -1) {
      _providers[index] = provider;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteProvider(String providerId) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    _providers.removeWhere((p) => p.id == providerId);
    _pendingApprovals.removeWhere((p) => p.id == providerId);
    
    _isLoading = false;
    notifyListeners();
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

  List<Provider> searchProviders(String query) {
    final lowercaseQuery = query.toLowerCase();
    return providers.where((provider) {
      return provider.fullName.toLowerCase().contains(lowercaseQuery) ||
             provider.fullCompanyName.toLowerCase().contains(lowercaseQuery) ||
             provider.email.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Add country filter method
  void setCountryFilter(String? country) {
    _countryFilter = country;
    notifyListeners();
  }

  // Analytics methods - update to use filtered data
  int get totalProviders => filteredApprovedProviders.length;
  int get totalPendingApprovals => filteredPendingApprovals.length;
  double get averageMonthlyRevenue => 35000.0; // Default value since we removed monthlyRevenue from model
}
