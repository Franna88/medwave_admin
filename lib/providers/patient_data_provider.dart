import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../models/patient_model.dart';
import '../models/firebase_patient_model.dart';
import '../models/session_model.dart';
import '../services/firebase/firebase_patient_service.dart';
import '../services/firebase/firebase_session_service.dart';

class PatientDataProvider extends ChangeNotifier {
  // Firebase service instances
  final FirebasePatientService _firebasePatientService = FirebasePatientService();
  final FirebaseSessionService _firebaseSessionService = FirebaseSessionService();
  
  // Local state
  List<Patient> _patients = [];
  Map<String, List<Session>> _patientSessions = {};
  Map<String, Map<String, dynamic>> _patientStats = {};
  bool _isLoading = false;
  String? _error;
  String? _countryFilter;
  
  // Stream subscriptions for real-time updates
  StreamSubscription<List<FirebasePatient>>? _patientsSubscription;
  StreamSubscription<List<Session>>? _sessionsSubscription;

  // Getters
  List<Patient> get patients => _patients;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, List<Session>> get patientSessions => _patientSessions;
  Map<String, Map<String, dynamic>> get patientStats => _patientStats;
  
  // Get filtered patients based on country
  List<Patient> get filteredPatients {
    if (_countryFilter == null) return _patients;
    return _patients.where((patient) => patient.country == _countryFilter).toList();
  }

  // Analytics getters using filtered data with session insights
  int get totalPatients => filteredPatients.length;
  int get activePatients => filteredPatients.where((p) => p.isActive).length;
  
  // Get patients with recent sessions (within 30 days)
  int get patientsWithRecentSessions {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return filteredPatients.where((patient) {
      final sessions = _patientSessions[patient.id] ?? [];
      return sessions.any((session) => session.date.isAfter(thirtyDaysAgo));
    }).length;
  }
  
  // Get total session count across all patients
  int get totalSessions {
    return _patientSessions.values.fold(0, (total, sessions) => total + sessions.length);
  }

  PatientDataProvider() {
    // Connect to existing Firebase patients collection
    _initializeFirebaseStreams();
  }

  /// Initialize Firebase streams for real-time patient data
  void _initializeFirebaseStreams() {
    _loadFirebaseData();
  }

  /// Load patient data from Firebase and set up real-time streams
  Future<void> _loadFirebaseData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load patients with real-time stream
      _patientsSubscription = _firebasePatientService
          .getPatients(country: _countryFilter)
          .listen(
        (firebasePatients) async {
          _patients = firebasePatients.map(_convertFirebasePatientToPatient).toList();
          _isLoading = false;
          notifyListeners();
          
          // Load session data for the patients
          await _loadSessionData();
        },
        onError: (error) {
          _error = 'Error loading patients: $error';
          _isLoading = false;
          if (kDebugMode) {
            print('Error loading patients: $error');
          }
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoading = false;
      _error = 'Error initializing patient data: $e';
      if (kDebugMode) {
        print('Error initializing patient data: $e');
      }
      notifyListeners();
    }
  }

  /// Convert FirebasePatient to simplified Patient model for UI compatibility
  Patient _convertFirebasePatientToPatient(FirebasePatient firebasePatient) {
    return Patient(
      id: firebasePatient.id,
      providerId: firebasePatient.practitionerId,
      name: '${firebasePatient.fullNames} ${firebasePatient.surname}',
      email: firebasePatient.email,
      phone: firebasePatient.patientCell,
      dateOfBirth: firebasePatient.dateOfBirth,
      gender: _inferGender(firebasePatient.fullNames),
      treatmentType: _determineTreatmentType(firebasePatient),
      treatmentStartDate: firebasePatient.createdAt,
      country: firebasePatient.countryName,
      isActive: _determineActiveStatus(firebasePatient),
      notes: _buildPatientNotes(firebasePatient),
    );
  }

  /// Build comprehensive patient notes from Firebase data
  String _buildPatientNotes(FirebasePatient firebasePatient) {
    List<String> notes = [];
    
    if (firebasePatient.allergies.isNotEmpty) {
      notes.add('Allergies: ${firebasePatient.allergies}');
    }
    
    if (firebasePatient.currentMedications.isNotEmpty) {
      notes.add('Medications: ${firebasePatient.currentMedications}');
    }
    
    if (firebasePatient.baselineWounds.isNotEmpty) {
      notes.add('Wounds: ${firebasePatient.baselineWounds.length} baseline wounds');
    }
    
    if (firebasePatient.baselineWeight > 0) {
      notes.add('Baseline weight: ${firebasePatient.baselineWeight}kg');
    }
    
    return notes.join(' | ');
  }

  /// Infer gender from names (simplified approach)
  String _inferGender(String fullNames) {
    // This is a simplified approach - in a real app you might store gender separately
    final commonMaleNames = ['john', 'michael', 'david', 'james', 'robert', 'william', 'charles', 'joseph'];
    final commonFemaleNames = ['mary', 'patricia', 'jennifer', 'linda', 'elizabeth', 'barbara', 'susan', 'jessica'];
    
    final firstName = fullNames.toLowerCase().split(' ').first;
    if (commonMaleNames.contains(firstName)) return 'Male';
    if (commonFemaleNames.contains(firstName)) return 'Female';
    return 'Other'; // Default when uncertain
  }

  /// Determine treatment type based on patient data
  TreatmentType _determineTreatmentType(FirebasePatient firebasePatient) {
    // Check if patient has weight baseline data
    final hasWeightData = firebasePatient.baselineWeight > 0;
    
    // Check if patient has wound data
    final hasWoundData = firebasePatient.baselineWounds.isNotEmpty;
    
    if (hasWeightData && hasWoundData) {
      return TreatmentType.both;
    } else if (hasWeightData) {
      return TreatmentType.weightLoss;
    } else {
      return TreatmentType.woundHealing; // Default
    }
  }

  /// Determine if patient is active based on recent activity
  bool _determineActiveStatus(FirebasePatient firebasePatient) {
    // Consider patient active if they were updated within the last 90 days
    final daysSinceUpdate = DateTime.now().difference(firebasePatient.lastUpdated).inDays;
    return daysSinceUpdate <= 90;
  }

  void _loadMockDataBackup() {
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

  /// Set country filter and reload data
  Future<void> setCountryFilter(String? country) async {
    if (_countryFilter != country) {
      _countryFilter = country;
      // Reload data with new filter
      await _loadFirebaseData();
    }
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

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh data manually
  Future<void> refresh() async {
    await _loadFirebaseData();
  }

  /// Load patients for a specific provider
  Future<void> loadPatientsForProvider(String providerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Cancel existing subscription
      await _patientsSubscription?.cancel();

      // Load patients for specific provider
      _patientsSubscription = _firebasePatientService
          .getPatients(practitionerId: providerId, country: _countryFilter)
          .listen(
        (firebasePatients) {
          _patients = firebasePatients.map(_convertFirebasePatientToPatient).toList();
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _error = 'Error loading patients: $error';
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoading = false;
      _error = 'Error loading patients for provider: $e';
      notifyListeners();
    }
  }

  /// Search patients using Firebase search functionality
  Future<List<Patient>> searchPatientsInFirebase(String query) async {
    try {
      final searchResults = await _firebasePatientService.searchPatients(
        query: query,
        country: _countryFilter,
      );
      return searchResults.map(_convertFirebasePatientToPatient).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching patients in Firebase: $e');
      }
      return [];
    }
  }

  /// Load session data for patients
  Future<void> _loadSessionData() async {
    try {
      final patientIds = _patients.map((p) => p.id).toList();
      if (patientIds.isEmpty) return;

      // Load recent sessions for analytics
      _sessionsSubscription = _firebaseSessionService
          .getRecentSessions(limitCount: 200)
          .listen(
        (sessions) {
          // Group sessions by patient ID
          _patientSessions.clear();
          for (final session in sessions) {
            if (!_patientSessions.containsKey(session.patientId)) {
              _patientSessions[session.patientId] = [];
            }
            _patientSessions[session.patientId]!.add(session);
          }
          notifyListeners();
        },
        onError: (error) {
          if (kDebugMode) {
            print('Error loading session data: $error');
          }
        },
      );

      // Load patient statistics
      for (final patient in _patients) {
        final stats = await _firebaseSessionService.getPatientSessionStats(patient.id);
        _patientStats[patient.id] = stats;
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading session data: $e');
      }
    }
  }

  /// Get sessions for a specific patient
  List<Session> getPatientSessions(String patientId) {
    return _patientSessions[patientId] ?? [];
  }

  /// Get patient statistics including session data
  Map<String, dynamic> getPatientStats(String patientId) {
    return _patientStats[patientId] ?? {
      'totalSessions': 0,
      'lastSessionDate': null,
      'averageVasScore': 0.0,
      'weightProgress': 0.0,
      'painReduction': 0.0,
    };
  }

  /// Clean up streams when provider is disposed
  @override
  void dispose() {
    _patientsSubscription?.cancel();
    _sessionsSubscription?.cancel();
    super.dispose();
  }
}
