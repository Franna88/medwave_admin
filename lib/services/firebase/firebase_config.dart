import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration for MedWave Admin Panel
/// 
/// This class contains the Firebase configuration for connecting to the medx.ai
/// Firebase project that's used by the MedWave application.
class FirebaseConfig {
  static const String projectId = 'medx-ai';
  static const String databaseRegion = 'nam5';
  
  /// Get Firebase options for the current platform
  /// These API keys are from the DATABASE_README.md documentation
  static FirebaseOptions get firebaseOptions {
    if (kIsWeb) {
      // Web Configuration
      return const FirebaseOptions(
        apiKey: 'AIzaSyC_medx_ai_web_api_key', // Replace with actual medx.ai web API key
        authDomain: 'medx-ai.firebaseapp.com',
        projectId: projectId,
        storageBucket: 'medx-ai.firebasestorage.app',
        messagingSenderId: '987654321', // Replace with actual medx.ai messaging sender ID
        appId: '1:987654321:web:medx_ai_web_app_id', // Replace with actual medx.ai web app ID
        databaseURL: 'https://medx-ai-default-rtdb.firebaseio.com/',
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Android Configuration  
      return const FirebaseOptions(
        apiKey: 'AIzaSyC_medx_ai_android_api_key', // Replace with actual medx.ai Android API key
        authDomain: 'medx-ai.firebaseapp.com',
        projectId: projectId,
        storageBucket: 'medx-ai.firebasestorage.app',
        messagingSenderId: '987654321', // Replace with actual medx.ai messaging sender ID
        appId: '1:987654321:android:medx_ai_android_app_id', // Replace with actual medx.ai Android app ID
        databaseURL: 'https://medx-ai-default-rtdb.firebaseio.com/',
      );
    } else {
      // iOS Configuration
      return const FirebaseOptions(
        apiKey: 'AIzaSyC_medx_ai_ios_api_key', // Replace with actual medx.ai iOS API key
        authDomain: 'medx-ai.firebaseapp.com',
        projectId: projectId,
        storageBucket: 'medx-ai.firebasestorage.app',
        messagingSenderId: '987654321', // Replace with actual medx.ai messaging sender ID
        appId: '1:987654321:ios:medx_ai_ios_app_id', // Replace with actual medx.ai iOS app ID
        databaseURL: 'https://medx-ai-default-rtdb.firebaseio.com/',
      );
    }
  }

  /// Initialize Firebase with the correct configuration
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: firebaseOptions,
      );
      
      if (kDebugMode) {
        print('Firebase initialized successfully for MedWave Admin');
        print('Connected to medx.ai project: $projectId');
        print('Database region: $databaseRegion');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Firebase: $e');
      }
      rethrow;
    }
  }

  /// Collection names as defined in the database structure
  static const String usersCollection = 'users';
  static const String patientsCollection = 'patients';
  static const String sessionsSubcollection = 'sessions';
  static const String appointmentsCollection = 'appointments';
  static const String notificationsCollection = 'notifications';
  static const String practitionerApplicationsCollection = 'practitioner_applications';
  static const String icd10CodesCollection = 'icd10_codes';
  static const String pmbCodesCollection = 'pmb_codes';
  static const String conversationsCollection = 'conversations';
  static const String countryAnalyticsCollection = 'country_analytics';

  /// Storage paths as defined in the database structure
  static const String tempStoragePath = 'temp';
  static const String usersStoragePath = 'users';
  static const String patientsStoragePath = 'patients';
  static const String sessionsStoragePath = 'sessions';
  static const String reportsStoragePath = 'reports';

  /// Admin roles for access control
  static const String superAdminRole = 'super_admin';
  static const String countryAdminRole = 'country_admin';
  static const String practitionerRole = 'practitioner';

  /// Account status constants
  static const String pendingStatus = 'pending';
  static const String approvedStatus = 'approved';
  static const String rejectedStatus = 'rejected';
  static const String suspendedStatus = 'suspended';
}
