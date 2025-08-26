import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/patient_model.dart';

class PatientDataProvider extends ChangeNotifier {
  List<Patient> _patients = [];
  bool _isLoading = false;
  String? _countryFilter; // Add country filter

  List<Patient> get patients => _patients;
  bool get isLoading => _isLoading;
  
  // Get filtered patients based on country
  List<Patient> get filteredPatients {
    if (_countryFilter == null) return _patients;
    return _patients.where((patient) => patient.country == _countryFilter).toList();
  }

  PatientDataProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    // Mock patient data for demonstration
    _patients = [
      Patient(
        id: const Uuid().v4(),
        providerId: 'provider1', // This would match actual provider IDs
        name: 'John Smith',
        email: 'john.smith@email.com',
        phone: '+1-555-0101',
        dateOfBirth: DateTime(1985, 3, 15),
        gender: 'Male',
        treatmentType: TreatmentType.woundHealing,
        treatmentStartDate: DateTime.now().subtract(const Duration(days: 45)),
        progressRecords: [
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 45)),
            woundSize: 25.0,
            woundDepth: 2.5,
            woundDescription: 'Diabetic foot ulcer, right foot',
            painLevel: 8.0,
            mobilityScore: 30.0,
            notes: 'Initial assessment - severe ulceration',
          ),
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 30)),
            woundSize: 18.0,
            woundDepth: 1.8,
            woundDescription: 'Improving granulation tissue',
            painLevel: 6.0,
            mobilityScore: 45.0,
            notes: 'Good response to treatment',
          ),
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 15)),
            woundSize: 12.0,
            woundDepth: 1.2,
            woundDescription: 'Significant improvement',
            painLevel: 4.0,
            mobilityScore: 65.0,
            notes: 'Wound healing well',
          ),
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 7)),
            woundSize: 8.0,
            woundDepth: 0.8,
            woundDescription: 'Nearly healed',
            painLevel: 2.0,
            mobilityScore: 85.0,
            notes: 'Excellent progress',
          ),
        ],
        notes: 'Patient responding well to MedWave treatment',
        country: 'USA',
      ),
      Patient(
        id: const Uuid().v4(),
        providerId: 'provider1',
        name: 'Maria Garcia',
        email: 'maria.garcia@email.com',
        phone: '+1-555-0202',
        dateOfBirth: DateTime(1978, 7, 22),
        gender: 'Female',
        treatmentType: TreatmentType.both,
        treatmentStartDate: DateTime.now().subtract(const Duration(days: 60)),
        progressRecords: [
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 60)),
            weight: 85.0,
            woundSize: 15.0,
            woundDepth: 1.5,
            woundDescription: 'Pressure ulcer, sacral area',
            painLevel: 7.0,
            mobilityScore: 40.0,
            notes: 'Combined weight loss and wound healing treatment',
          ),
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 45)),
            weight: 82.0,
            woundSize: 12.0,
            woundDepth: 1.2,
            woundDescription: 'Wound improving, weight loss progressing',
            painLevel: 5.0,
            mobilityScore: 55.0,
            notes: 'Good progress on both fronts',
          ),
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 30)),
            weight: 79.0,
            woundSize: 8.0,
            woundDepth: 0.8,
            woundDescription: 'Significant improvement',
            painLevel: 3.0,
            mobilityScore: 70.0,
            notes: 'Excellent results',
          ),
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 15)),
            weight: 76.0,
            woundSize: 4.0,
            woundDepth: 0.3,
            woundDescription: 'Nearly healed',
            painLevel: 1.0,
            mobilityScore: 90.0,
            notes: 'Outstanding progress',
          ),
        ],
        notes: 'Excellent response to combined treatment approach',
        country: 'USA',
      ),
      Patient(
        id: const Uuid().v4(),
        providerId: 'provider2',
        name: 'Robert Johnson',
        email: 'robert.johnson@email.com',
        phone: '+1-555-0303',
        dateOfBirth: DateTime(1992, 11, 8),
        gender: 'Male',
        treatmentType: TreatmentType.weightLoss,
        treatmentStartDate: DateTime.now().subtract(const Duration(days: 90)),
        progressRecords: [
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 90)),
            weight: 95.0,
            painLevel: 3.0,
            mobilityScore: 60.0,
            notes: 'Starting weight loss program',
          ),
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 75)),
            weight: 92.0,
            painLevel: 2.0,
            mobilityScore: 65.0,
            notes: 'Good initial progress',
          ),
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 60)),
            weight: 88.0,
            painLevel: 1.0,
            mobilityScore: 75.0,
            notes: 'Steady weight loss',
          ),
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 45)),
            weight: 85.0,
            painLevel: 1.0,
            mobilityScore: 80.0,
            notes: 'Excellent progress',
          ),
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 30)),
            weight: 82.0,
            painLevel: 0.0,
            mobilityScore: 85.0,
            notes: 'Target weight nearly achieved',
          ),
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 15)),
            weight: 80.0,
            painLevel: 0.0,
            mobilityScore: 90.0,
            notes: 'Goal weight achieved',
          ),
        ],
        notes: 'Successful weight loss treatment with MedWave technology',
        country: 'USA',
      ),
      Patient(
        id: const Uuid().v4(),
        providerId: 'provider3',
        name: 'Lisa Chen',
        email: 'lisa.chen@email.com',
        phone: '+1-555-0404',
        dateOfBirth: DateTime(1980, 4, 12),
        gender: 'Female',
        treatmentType: TreatmentType.woundHealing,
        treatmentStartDate: DateTime.now().subtract(const Duration(days: 30)),
        progressRecords: [
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 30)),
            woundSize: 20.0,
            woundDepth: 2.0,
            woundDescription: 'Surgical wound, slow healing',
            painLevel: 6.0,
            mobilityScore: 50.0,
            notes: 'Post-surgical wound care',
          ),
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 20)),
            woundSize: 16.0,
            woundDepth: 1.6,
            woundDescription: 'Improving healing rate',
            painLevel: 4.0,
            mobilityScore: 60.0,
            notes: 'Good response to treatment',
          ),
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 10)),
            woundSize: 10.0,
            woundDepth: 1.0,
            woundDescription: 'Significant improvement',
            painLevel: 2.0,
            mobilityScore: 75.0,
            notes: 'Healing progressing well',
          ),
        ],
        notes: 'Surgical wound responding well to MedWave treatment',
        country: 'USA',
      ),
      // Add RSA patients
      Patient(
        id: const Uuid().v4(),
        providerId: 'provider4',
        name: 'Nomsa Dlamini',
        email: 'nomsa.dlamini@email.co.za',
        phone: '+27-11-123-4567',
        dateOfBirth: DateTime(1982, 9, 15),
        gender: 'Female',
        treatmentType: TreatmentType.woundHealing,
        treatmentStartDate: DateTime.now().subtract(const Duration(days: 40)),
        progressRecords: [
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 40)),
            woundSize: 22.0,
            woundDepth: 2.2,
            woundDescription: 'Diabetic ulcer, left foot',
            painLevel: 7.0,
            mobilityScore: 35.0,
            notes: 'Initial assessment from Johannesburg clinic',
          ),
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 25)),
            woundSize: 16.0,
            woundDepth: 1.6,
            woundDescription: 'Good granulation tissue formation',
            painLevel: 5.0,
            mobilityScore: 50.0,
            notes: 'Responding well to MedWave treatment',
          ),
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 10)),
            woundSize: 10.0,
            woundDepth: 1.0,
            woundDescription: 'Significant improvement',
            painLevel: 3.0,
            mobilityScore: 70.0,
            notes: 'Excellent progress',
          ),
        ],
        notes: 'Patient from Johannesburg showing excellent response',
        country: 'RSA',
      ),
      Patient(
        id: const Uuid().v4(),
        providerId: 'provider5',
        name: 'Themba Nkosi',
        email: 'themba.nkosi@email.co.za',
        phone: '+27-21-987-6543',
        dateOfBirth: DateTime(1975, 12, 3),
        gender: 'Male',
        treatmentType: TreatmentType.weightLoss,
        treatmentStartDate: DateTime.now().subtract(const Duration(days: 70)),
        progressRecords: [
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 70)),
            weight: 92.0,
            painLevel: 2.0,
            mobilityScore: 65.0,
            notes: 'Starting weight loss program in Cape Town',
          ),
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 50)),
            weight: 88.0,
            painLevel: 1.0,
            mobilityScore: 75.0,
            notes: 'Good progress with weight loss',
          ),
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 30)),
            weight: 84.0,
            painLevel: 0.0,
            mobilityScore: 85.0,
            notes: 'Excellent weight loss results',
          ),
          ProgressRecord(
            date: DateTime.now().subtract(const Duration(days: 15)),
            weight: 81.0,
            painLevel: 0.0,
            mobilityScore: 90.0,
            notes: 'Target weight achieved',
          ),
        ],
        notes: 'Successful weight loss treatment from Cape Town clinic',
        country: 'RSA',
      ),
    ];

    notifyListeners();
  }

  // Add country filter method
  void setCountryFilter(String? country) {
    _countryFilter = country;
    notifyListeners();
  }

  Future<void> addPatient(Patient patient) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    _patients.add(patient);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updatePatient(Patient patient) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    final index = _patients.indexWhere((p) => p.id == patient.id);
    if (index != -1) {
      _patients[index] = patient;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deletePatient(String patientId) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    _patients.removeWhere((p) => p.id == patientId);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProgressRecord(String patientId, ProgressRecord record) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    final index = _patients.indexWhere((p) => p.id == patientId);
    if (index != -1) {
      final patient = _patients[index];
      final updatedRecords = List<ProgressRecord>.from(patient.progressRecords)
        ..add(record);
      
      _patients[index] = patient.copyWith(progressRecords: updatedRecords);
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Patient? getPatientById(String id) {
    try {
      return _patients.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Patient> getPatientsByProvider(String providerId) {
    return _patients.where((p) => p.providerId == providerId).toList();
  }

  List<Patient> searchPatients(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _patients.where((patient) {
      return patient.name.toLowerCase().contains(lowercaseQuery) ||
             patient.email.toLowerCase().contains(lowercaseQuery) ||
             patient.treatmentType.toString().toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  List<Patient> getPatientsByTreatmentType(TreatmentType type) {
    return _patients.where((p) => p.treatmentType == type).toList();
  }

  // Analytics methods - update to use filtered data
  int get totalPatients => filteredPatients.length;
  int get activePatients => filteredPatients.where((p) => p.isActive).length;
  double get averageProgress => filteredPatients.isEmpty 
      ? 0.0 
      : filteredPatients.map((p) => p.overallProgress).reduce((a, b) => a + b) / filteredPatients.length;
  
  int getPatientsByTreatmentTypeCount(TreatmentType type) {
    return filteredPatients.where((p) => p.treatmentType == type).length;
  }

  double getAverageProgressByTreatmentType(TreatmentType type) {
    final typePatients = filteredPatients.where((p) => p.treatmentType == type).toList();
    if (typePatients.isEmpty) return 0.0;
    return typePatients.map((p) => p.overallProgress).reduce((a, b) => a + b) / typePatients.length;
  }

  List<Patient> getTopPerformers(int count) {
    final sortedPatients = List<Patient>.from(filteredPatients)
      ..sort((a, b) => b.overallProgress.compareTo(a.overallProgress));
    return sortedPatients.take(count).toList();
  }

  List<Patient> getRecentPatients(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return filteredPatients.where((p) => p.treatmentStartDate.isAfter(cutoffDate)).toList();
  }
}
