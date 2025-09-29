import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase User Model - Represents practitioners in the users collection
/// This matches the USERS collection structure from DATABASE_README.md
class FirebaseUser {
  final String id; // Document ID (matches Firebase Auth UID)
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String licenseNumber;
  final String specialization;
  final int yearsOfExperience;
  final String practiceLocation;
  
  // Location Information
  final String country; // Country code (e.g., 'USA', 'RSA')
  final String countryName; // Full country name
  final String province;
  final String city;
  final String address;
  final String postalCode;
  
  // Approval Workflow
  final String accountStatus; // pending|approved|rejected|suspended
  final DateTime applicationDate;
  final DateTime? approvalDate;
  final String? approvedBy; // Admin user ID
  final String? rejectionReason;
  
  // Professional Verification
  final bool licenseVerified;
  final DateTime? licenseVerificationDate;
  final List<ProfessionalReference> professionalReferences;
  
  // App Settings
  final UserSettings settings;
  
  // Metadata
  final DateTime createdAt;
  final DateTime lastUpdated;
  final DateTime? lastLogin;
  final String role; // practitioner|super_admin|country_admin
  
  // Analytics Support
  final int totalPatients;
  final int totalSessions;
  final DateTime? lastActivityDate;

  FirebaseUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.licenseNumber,
    required this.specialization,
    required this.yearsOfExperience,
    required this.practiceLocation,
    required this.country,
    required this.countryName,
    required this.province,
    required this.city,
    required this.address,
    required this.postalCode,
    required this.accountStatus,
    required this.applicationDate,
    this.approvalDate,
    this.approvedBy,
    this.rejectionReason,
    this.licenseVerified = false,
    this.licenseVerificationDate,
    this.professionalReferences = const [],
    required this.settings,
    required this.createdAt,
    required this.lastUpdated,
    this.lastLogin,
    this.role = 'practitioner',
    this.totalPatients = 0,
    this.totalSessions = 0,
    this.lastActivityDate,
  });

  /// Create from Firestore document
  factory FirebaseUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return FirebaseUser(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      licenseNumber: data['licenseNumber'] ?? '',
      specialization: data['specialization'] ?? '',
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
      practiceLocation: data['practiceLocation'] ?? '',
      country: data['country'] ?? '',
      countryName: data['countryName'] ?? '',
      province: data['province'] ?? '',
      city: data['city'] ?? '',
      address: data['address'] ?? '',
      postalCode: data['postalCode'] ?? '',
      accountStatus: data['accountStatus'] ?? 'pending',
      applicationDate: (data['applicationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approvalDate: (data['approvalDate'] as Timestamp?)?.toDate(),
      approvedBy: data['approvedBy'],
      rejectionReason: data['rejectionReason'],
      licenseVerified: data['licenseVerified'] ?? false,
      licenseVerificationDate: (data['licenseVerificationDate'] as Timestamp?)?.toDate(),
      professionalReferences: (data['professionalReferences'] as List?)
          ?.map((ref) => ProfessionalReference.fromMap(ref))
          .toList() ?? [],
      settings: data['settings'] != null 
          ? UserSettings.fromMap(data['settings'])
          : UserSettings.defaultSettings(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      role: data['role'] ?? 'practitioner',
      totalPatients: data['totalPatients'] ?? 0,
      totalSessions: data['totalSessions'] ?? 0,
      lastActivityDate: (data['lastActivityDate'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'licenseNumber': licenseNumber,
      'specialization': specialization,
      'yearsOfExperience': yearsOfExperience,
      'practiceLocation': practiceLocation,
      'country': country,
      'countryName': countryName,
      'province': province,
      'city': city,
      'address': address,
      'postalCode': postalCode,
      'accountStatus': accountStatus,
      'applicationDate': Timestamp.fromDate(applicationDate),
      'approvalDate': approvalDate != null ? Timestamp.fromDate(approvalDate!) : null,
      'approvedBy': approvedBy,
      'rejectionReason': rejectionReason,
      'licenseVerified': licenseVerified,
      'licenseVerificationDate': licenseVerificationDate != null 
          ? Timestamp.fromDate(licenseVerificationDate!) : null,
      'professionalReferences': professionalReferences.map((ref) => ref.toMap()).toList(),
      'settings': settings.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'role': role,
      'totalPatients': totalPatients,
      'totalSessions': totalSessions,
      'lastActivityDate': lastActivityDate != null 
          ? Timestamp.fromDate(lastActivityDate!) : null,
    };
  }

  /// Copy with new values
  FirebaseUser copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? licenseNumber,
    String? specialization,
    int? yearsOfExperience,
    String? practiceLocation,
    String? country,
    String? countryName,
    String? province,
    String? city,
    String? address,
    String? postalCode,
    String? accountStatus,
    DateTime? applicationDate,
    DateTime? approvalDate,
    String? approvedBy,
    String? rejectionReason,
    bool? licenseVerified,
    DateTime? licenseVerificationDate,
    List<ProfessionalReference>? professionalReferences,
    UserSettings? settings,
    DateTime? createdAt,
    DateTime? lastUpdated,
    DateTime? lastLogin,
    String? role,
    int? totalPatients,
    int? totalSessions,
    DateTime? lastActivityDate,
  }) {
    return FirebaseUser(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      specialization: specialization ?? this.specialization,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      practiceLocation: practiceLocation ?? this.practiceLocation,
      country: country ?? this.country,
      countryName: countryName ?? this.countryName,
      province: province ?? this.province,
      city: city ?? this.city,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      accountStatus: accountStatus ?? this.accountStatus,
      applicationDate: applicationDate ?? this.applicationDate,
      approvalDate: approvalDate ?? this.approvalDate,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      licenseVerified: licenseVerified ?? this.licenseVerified,
      licenseVerificationDate: licenseVerificationDate ?? this.licenseVerificationDate,
      professionalReferences: professionalReferences ?? this.professionalReferences,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastLogin: lastLogin ?? this.lastLogin,
      role: role ?? this.role,
      totalPatients: totalPatients ?? this.totalPatients,
      totalSessions: totalSessions ?? this.totalSessions,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }

  // Getters
  String get fullName => '$firstName $lastName';
  bool get isApproved => accountStatus == 'approved';
  bool get isPending => accountStatus == 'pending';
  bool get isRejected => accountStatus == 'rejected';
  bool get isSuspended => accountStatus == 'suspended';
  bool get isAdmin => role == 'super_admin' || role == 'country_admin';
}

/// Professional Reference model
class ProfessionalReference {
  final String name;
  final String organization;
  final String email;
  final String phone;
  final String relationship;

  ProfessionalReference({
    required this.name,
    required this.organization,
    required this.email,
    required this.phone,
    required this.relationship,
  });

  factory ProfessionalReference.fromMap(Map<String, dynamic> map) {
    return ProfessionalReference(
      name: map['name'] ?? '',
      organization: map['organization'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      relationship: map['relationship'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'organization': organization,
      'email': email,
      'phone': phone,
      'relationship': relationship,
    };
  }
}

/// User Settings model
class UserSettings {
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final bool biometricEnabled;
  final String language;
  final String timezone;

  UserSettings({
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.biometricEnabled = false,
    this.language = 'en',
    this.timezone = 'UTC',
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      darkModeEnabled: map['darkModeEnabled'] ?? false,
      biometricEnabled: map['biometricEnabled'] ?? false,
      language: map['language'] ?? 'en',
      timezone: map['timezone'] ?? 'UTC',
    );
  }

  factory UserSettings.defaultSettings() {
    return UserSettings();
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'biometricEnabled': biometricEnabled,
      'language': language,
      'timezone': timezone,
    };
  }
}
