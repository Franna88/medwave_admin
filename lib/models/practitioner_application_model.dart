import 'package:cloud_firestore/cloud_firestore.dart';

/// Practitioner Application Model - Represents applications in practitioner_applications collection
/// This matches the PRACTITIONER_APPLICATIONS collection structure from DATABASE_README.md
class PractitionerApplication {
  final String id; // Document ID
  final String userId; // Firebase Auth UID
  final String email;
  final String firstName;
  final String lastName;
  
  // Professional Information
  final String licenseNumber;
  final String specialization;
  final int yearsOfExperience;
  final String practiceLocation;
  
  // Location Information
  final String country;
  final String countryName;
  final String province;
  final String city;
  
  // Application Status
  final String status; // pending|under_review|approved|rejected
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy; // Admin user ID
  final String? reviewNotes;
  final String? rejectionReason;
  
  // Supporting Documents (Firebase Storage references)
  final ApplicationDocuments documents;
  
  // Verification Status
  final bool documentsVerified;
  final bool licenseVerified;
  final bool referencesVerified;

  PractitionerApplication({
    required this.id,
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.licenseNumber,
    required this.specialization,
    required this.yearsOfExperience,
    required this.practiceLocation,
    required this.country,
    required this.countryName,
    required this.province,
    required this.city,
    this.status = 'pending',
    required this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewNotes,
    this.rejectionReason,
    required this.documents,
    this.documentsVerified = false,
    this.licenseVerified = false,
    this.referencesVerified = false,
  });

  /// Create from Firestore document
  factory PractitionerApplication.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return PractitionerApplication(
      id: doc.id,
      userId: data['userId'] ?? '',
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      licenseNumber: data['licenseNumber'] ?? '',
      specialization: data['specialization'] ?? '',
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
      practiceLocation: data['practiceLocation'] ?? '',
      country: data['country'] ?? '',
      countryName: data['countryName'] ?? '',
      province: data['province'] ?? '',
      city: data['city'] ?? '',
      status: data['status'] ?? 'pending',
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
      reviewedBy: data['reviewedBy'],
      reviewNotes: data['reviewNotes'],
      rejectionReason: data['rejectionReason'],
      documents: data['documents'] != null
          ? ApplicationDocuments.fromMap(data['documents'])
          : ApplicationDocuments.empty(),
      documentsVerified: data['documentsVerified'] ?? false,
      licenseVerified: data['licenseVerified'] ?? false,
      referencesVerified: data['referencesVerified'] ?? false,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'licenseNumber': licenseNumber,
      'specialization': specialization,
      'yearsOfExperience': yearsOfExperience,
      'practiceLocation': practiceLocation,
      'country': country,
      'countryName': countryName,
      'province': province,
      'city': city,
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewedBy': reviewedBy,
      'reviewNotes': reviewNotes,
      'rejectionReason': rejectionReason,
      'documents': documents.toMap(),
      'documentsVerified': documentsVerified,
      'licenseVerified': licenseVerified,
      'referencesVerified': referencesVerified,
    };
  }

  /// Copy with new values
  PractitionerApplication copyWith({
    String? userId,
    String? email,
    String? firstName,
    String? lastName,
    String? licenseNumber,
    String? specialization,
    int? yearsOfExperience,
    String? practiceLocation,
    String? country,
    String? countryName,
    String? province,
    String? city,
    String? status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? reviewNotes,
    String? rejectionReason,
    ApplicationDocuments? documents,
    bool? documentsVerified,
    bool? licenseVerified,
    bool? referencesVerified,
  }) {
    return PractitionerApplication(
      id: id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      specialization: specialization ?? this.specialization,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      practiceLocation: practiceLocation ?? this.practiceLocation,
      country: country ?? this.country,
      countryName: countryName ?? this.countryName,
      province: province ?? this.province,
      city: city ?? this.city,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      documents: documents ?? this.documents,
      documentsVerified: documentsVerified ?? this.documentsVerified,
      licenseVerified: licenseVerified ?? this.licenseVerified,
      referencesVerified: referencesVerified ?? this.referencesVerified,
    );
  }

  // Getters
  String get fullName => '$firstName $lastName';
  bool get isPending => status == 'pending';
  bool get isUnderReview => status == 'under_review';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isFullyVerified => documentsVerified && licenseVerified && referencesVerified;
  
  /// Calculate completion percentage for application review
  double get completionPercentage {
    int completed = 0;
    if (documentsVerified) completed++;
    if (licenseVerified) completed++;
    if (referencesVerified) completed++;
    return (completed / 3) * 100;
  }
}

/// Application Documents model for file references
class ApplicationDocuments {
  final String? licenseDocument; // Storage URL
  final String? idDocument; // Storage URL
  final String? qualificationCertificate; // Storage URL

  ApplicationDocuments({
    this.licenseDocument,
    this.idDocument,
    this.qualificationCertificate,
  });

  factory ApplicationDocuments.fromMap(Map<String, dynamic> map) {
    return ApplicationDocuments(
      licenseDocument: map['licenseDocument'],
      idDocument: map['idDocument'],
      qualificationCertificate: map['qualificationCertificate'],
    );
  }

  factory ApplicationDocuments.empty() {
    return ApplicationDocuments();
  }

  Map<String, dynamic> toMap() {
    return {
      'licenseDocument': licenseDocument,
      'idDocument': idDocument,
      'qualificationCertificate': qualificationCertificate,
    };
  }

  bool get hasAllDocuments {
    return licenseDocument != null && 
           idDocument != null && 
           qualificationCertificate != null;
  }

  List<String> get missingDocuments {
    final missing = <String>[];
    if (licenseDocument == null) missing.add('License Document');
    if (idDocument == null) missing.add('ID Document');
    if (qualificationCertificate == null) missing.add('Qualification Certificate');
    return missing;
  }
}

/// Extension for status colors and display
extension PractitionerApplicationStatus on PractitionerApplication {
  /// Get status color for UI display
  String get statusColor {
    switch (status) {
      case 'pending':
        return '#FF9800'; // Orange
      case 'under_review':
        return '#2196F3'; // Blue
      case 'approved':
        return '#4CAF50'; // Green
      case 'rejected':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get human-readable status
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending Review';
      case 'under_review':
        return 'Under Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }
}
