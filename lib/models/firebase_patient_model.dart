import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Patient Model - Represents patients in the patients collection
/// This matches the PATIENTS collection structure from DATABASE_README.md
class FirebasePatient {
  final String id; // Document ID
  
  // Basic Patient Details
  final String surname;
  final String fullNames;
  final String idNumber;
  final DateTime dateOfBirth;
  final String workNameAndAddress;
  final String workPostalAddress;
  final String workTelNo;
  final String patientCell;
  final String homeTelNo;
  final String email;
  final String maritalStatus;
  final String occupation;
  
  // Person Responsible for Account (Main Member)
  final ResponsiblePerson responsiblePerson;
  
  // Medical Aid Details
  final MedicalAidDetails medicalAid;
  
  // Referring Doctor/Specialist
  final ReferringDoctor referringDoctor;
  
  // Medical History
  final Map<String, bool> medicalConditions;
  final Map<String, String> medicalConditionDetails;
  final String currentMedications;
  final String allergies;
  final bool isSmoker;
  final String naturalTreatments;
  
  // Consent and Signatures
  final ConsentInfo consentInfo;
  
  final DateTime createdAt;
  final DateTime lastUpdated;
  
  // Firebase-specific fields
  final String practitionerId; // Reference to user who created patient
  final String country; // Inherited from practitioner
  final String countryName; // Inherited from practitioner
  final String province; // Inherited from practitioner
  
  // Baseline measurements
  final double baselineWeight;
  final int baselineVasScore; // 0-10 pain scale
  final List<WoundRecord> baselineWounds;
  final List<String> baselinePhotos; // Storage URLs
  
  // Current measurements (updated during treatment)
  final double currentWeight;
  final int currentVasScore;
  final List<WoundRecord> currentWounds;
  
  // Calculated progress metrics
  final double weightChange;
  final double painReduction;
  final double woundHealingProgress;

  FirebasePatient({
    required this.id,
    required this.surname,
    required this.fullNames,
    required this.idNumber,
    required this.dateOfBirth,
    required this.workNameAndAddress,
    required this.workPostalAddress,
    required this.workTelNo,
    required this.patientCell,
    required this.homeTelNo,
    required this.email,
    required this.maritalStatus,
    required this.occupation,
    required this.responsiblePerson,
    required this.medicalAid,
    required this.referringDoctor,
    required this.medicalConditions,
    required this.medicalConditionDetails,
    required this.currentMedications,
    required this.allergies,
    required this.isSmoker,
    required this.naturalTreatments,
    required this.consentInfo,
    required this.createdAt,
    required this.lastUpdated,
    required this.practitionerId,
    required this.country,
    required this.countryName,
    required this.province,
    this.baselineWeight = 0.0,
    this.baselineVasScore = 0,
    this.baselineWounds = const [],
    this.baselinePhotos = const [],
    this.currentWeight = 0.0,
    this.currentVasScore = 0,
    this.currentWounds = const [],
    this.weightChange = 0.0,
    this.painReduction = 0.0,
    this.woundHealingProgress = 0.0,
  });

  /// Create from Firestore document
  factory FirebasePatient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return FirebasePatient(
      id: doc.id,
      surname: data['surname'] ?? '',
      fullNames: data['fullNames'] ?? '',
      idNumber: data['idNumber'] ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
      workNameAndAddress: data['workNameAndAddress'] ?? '',
      workPostalAddress: data['workPostalAddress'] ?? '',
      workTelNo: data['workTelNo'] ?? '',
      patientCell: data['patientCell'] ?? '',
      homeTelNo: data['homeTelNo'] ?? '',
      email: data['email'] ?? '',
      maritalStatus: data['maritalStatus'] ?? '',
      occupation: data['occupation'] ?? '',
      responsiblePerson: ResponsiblePerson.fromMap(data),
      medicalAid: MedicalAidDetails.fromMap(data),
      referringDoctor: ReferringDoctor.fromMap(data),
      medicalConditions: Map<String, bool>.from(data['medicalConditions'] ?? {}),
      medicalConditionDetails: Map<String, String>.from(data['medicalConditionDetails'] ?? {}),
      currentMedications: data['currentMedications'] ?? '',
      allergies: data['allergies'] ?? '',
      isSmoker: data['isSmoker'] ?? false,
      naturalTreatments: data['naturalTreatments'] ?? '',
      consentInfo: ConsentInfo.fromMap(data),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      practitionerId: data['practitionerId'] ?? '',
      country: data['country'] ?? '',
      countryName: data['countryName'] ?? '',
      province: data['province'] ?? '',
      baselineWeight: (data['baselineWeight'] ?? 0).toDouble(),
      baselineVasScore: data['baselineVasScore'] ?? 0,
      baselineWounds: (data['baselineWounds'] as List?)
          ?.map((wound) => WoundRecord.fromMap(wound))
          .toList() ?? [],
      baselinePhotos: List<String>.from(data['baselinePhotos'] ?? []),
      currentWeight: (data['currentWeight'] ?? 0).toDouble(),
      currentVasScore: data['currentVasScore'] ?? 0,
      currentWounds: (data['currentWounds'] as List?)
          ?.map((wound) => WoundRecord.fromMap(wound))
          .toList() ?? [],
      weightChange: (data['weightChange'] ?? 0).toDouble(),
      painReduction: (data['painReduction'] ?? 0).toDouble(),
      woundHealingProgress: (data['woundHealingProgress'] ?? 0).toDouble(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'surname': surname,
      'fullNames': fullNames,
      'idNumber': idNumber,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'workNameAndAddress': workNameAndAddress,
      'workPostalAddress': workPostalAddress,
      'workTelNo': workTelNo,
      'patientCell': patientCell,
      'homeTelNo': homeTelNo,
      'email': email,
      'maritalStatus': maritalStatus,
      'occupation': occupation,
      'medicalConditions': medicalConditions,
      'medicalConditionDetails': medicalConditionDetails,
      'currentMedications': currentMedications,
      'allergies': allergies,
      'isSmoker': isSmoker,
      'naturalTreatments': naturalTreatments,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'practitionerId': practitionerId,
      'country': country,
      'countryName': countryName,
      'province': province,
      'baselineWeight': baselineWeight,
      'baselineVasScore': baselineVasScore,
      'baselineWounds': baselineWounds.map((wound) => wound.toMap()).toList(),
      'baselinePhotos': baselinePhotos,
      'currentWeight': currentWeight,
      'currentVasScore': currentVasScore,
      'currentWounds': currentWounds.map((wound) => wound.toMap()).toList(),
      'weightChange': weightChange,
      'painReduction': painReduction,
      'woundHealingProgress': woundHealingProgress,
    };

    // Add responsible person fields
    data.addAll(responsiblePerson.toMap());
    // Add medical aid fields
    data.addAll(medicalAid.toMap());
    // Add referring doctor fields
    data.addAll(referringDoctor.toMap());
    // Add consent info fields
    data.addAll(consentInfo.toMap());

    return data;
  }

  // Getters
  String get fullName => '$fullNames $surname';
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  double get overallProgress {
    // Calculate overall progress based on multiple factors
    double progress = 0.0;
    int factors = 0;

    // Weight progress (if baseline weight exists)
    if (baselineWeight > 0 && currentWeight > 0) {
      progress += weightChange > 0 ? 25.0 : 0.0; // 25% for weight improvement
      factors++;
    }

    // Pain reduction progress
    if (baselineVasScore > 0) {
      progress += (painReduction / 10.0) * 25.0; // 25% for pain reduction
      factors++;
    }

    // Wound healing progress
    if (baselineWounds.isNotEmpty) {
      progress += woundHealingProgress * 50.0; // 50% for wound healing
      factors++;
    }

    return factors > 0 ? progress / factors : 0.0;
  }
}

/// Responsible Person details
class ResponsiblePerson {
  final String surname;
  final String fullNames;
  final String idNumber;
  final DateTime dateOfBirth;
  final String workNameAndAddress;
  final String workPostalAddress;
  final String workTelNo;
  final String cell;
  final String homeTelNo;
  final String email;
  final String maritalStatus;
  final String occupation;
  final String relationToPatient;

  ResponsiblePerson({
    required this.surname,
    required this.fullNames,
    required this.idNumber,
    required this.dateOfBirth,
    required this.workNameAndAddress,
    required this.workPostalAddress,
    required this.workTelNo,
    required this.cell,
    required this.homeTelNo,
    required this.email,
    required this.maritalStatus,
    required this.occupation,
    required this.relationToPatient,
  });

  factory ResponsiblePerson.fromMap(Map<String, dynamic> data) {
    return ResponsiblePerson(
      surname: data['responsiblePersonSurname'] ?? '',
      fullNames: data['responsiblePersonFullNames'] ?? '',
      idNumber: data['responsiblePersonIdNumber'] ?? '',
      dateOfBirth: (data['responsiblePersonDateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
      workNameAndAddress: data['responsiblePersonWorkNameAndAddress'] ?? '',
      workPostalAddress: data['responsiblePersonWorkPostalAddress'] ?? '',
      workTelNo: data['responsiblePersonWorkTelNo'] ?? '',
      cell: data['responsiblePersonCell'] ?? '',
      homeTelNo: data['responsiblePersonHomeTelNo'] ?? '',
      email: data['responsiblePersonEmail'] ?? '',
      maritalStatus: data['responsiblePersonMaritalStatus'] ?? '',
      occupation: data['responsiblePersonOccupation'] ?? '',
      relationToPatient: data['relationToPatient'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'responsiblePersonSurname': surname,
      'responsiblePersonFullNames': fullNames,
      'responsiblePersonIdNumber': idNumber,
      'responsiblePersonDateOfBirth': Timestamp.fromDate(dateOfBirth),
      'responsiblePersonWorkNameAndAddress': workNameAndAddress,
      'responsiblePersonWorkPostalAddress': workPostalAddress,
      'responsiblePersonWorkTelNo': workTelNo,
      'responsiblePersonCell': cell,
      'responsiblePersonHomeTelNo': homeTelNo,
      'responsiblePersonEmail': email,
      'responsiblePersonMaritalStatus': maritalStatus,
      'responsiblePersonOccupation': occupation,
      'relationToPatient': relationToPatient,
    };
  }
}

/// Medical Aid Details
class MedicalAidDetails {
  final String schemeName;
  final String number;
  final String planAndDepNumber;
  final String mainMemberName;

  MedicalAidDetails({
    required this.schemeName,
    required this.number,
    required this.planAndDepNumber,
    required this.mainMemberName,
  });

  factory MedicalAidDetails.fromMap(Map<String, dynamic> data) {
    return MedicalAidDetails(
      schemeName: data['medicalAidSchemeName'] ?? '',
      number: data['medicalAidNumber'] ?? '',
      planAndDepNumber: data['planAndDepNumber'] ?? '',
      mainMemberName: data['mainMemberName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicalAidSchemeName': schemeName,
      'medicalAidNumber': number,
      'planAndDepNumber': planAndDepNumber,
      'mainMemberName': mainMemberName,
    };
  }
}

/// Referring Doctor Details
class ReferringDoctor {
  final String name;
  final String cell;
  final String additionalReferrerName;
  final String additionalReferrerCell;

  ReferringDoctor({
    required this.name,
    required this.cell,
    required this.additionalReferrerName,
    required this.additionalReferrerCell,
  });

  factory ReferringDoctor.fromMap(Map<String, dynamic> data) {
    return ReferringDoctor(
      name: data['referringDoctorName'] ?? '',
      cell: data['referringDoctorCell'] ?? '',
      additionalReferrerName: data['additionalReferrerName'] ?? '',
      additionalReferrerCell: data['additionalReferrerCell'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'referringDoctorName': name,
      'referringDoctorCell': cell,
      'additionalReferrerName': additionalReferrerName,
      'additionalReferrerCell': additionalReferrerCell,
    };
  }
}

/// Consent Information
class ConsentInfo {
  final String accountResponsibilitySignature;
  final DateTime accountResponsibilitySignatureDate;
  final String woundPhotographyConsentSignature;
  final String witnessSignature;
  final DateTime woundPhotographyConsentDate;
  final bool trainingPhotosConsent;
  final DateTime? trainingPhotosConsentDate;

  ConsentInfo({
    required this.accountResponsibilitySignature,
    required this.accountResponsibilitySignatureDate,
    required this.woundPhotographyConsentSignature,
    required this.witnessSignature,
    required this.woundPhotographyConsentDate,
    required this.trainingPhotosConsent,
    this.trainingPhotosConsentDate,
  });

  factory ConsentInfo.fromMap(Map<String, dynamic> data) {
    return ConsentInfo(
      accountResponsibilitySignature: data['accountResponsibilitySignature'] ?? '',
      accountResponsibilitySignatureDate: (data['accountResponsibilitySignatureDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      woundPhotographyConsentSignature: data['woundPhotographyConsentSignature'] ?? '',
      witnessSignature: data['witnessSignature'] ?? '',
      woundPhotographyConsentDate: (data['woundPhotographyConsentDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      trainingPhotosConsent: data['trainingPhotosConsent'] ?? false,
      trainingPhotosConsentDate: (data['trainingPhotosConsentDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accountResponsibilitySignature': accountResponsibilitySignature,
      'accountResponsibilitySignatureDate': Timestamp.fromDate(accountResponsibilitySignatureDate),
      'woundPhotographyConsentSignature': woundPhotographyConsentSignature,
      'witnessSignature': witnessSignature,
      'woundPhotographyConsentDate': Timestamp.fromDate(woundPhotographyConsentDate),
      'trainingPhotosConsent': trainingPhotosConsent,
      'trainingPhotosConsentDate': trainingPhotosConsentDate != null 
          ? Timestamp.fromDate(trainingPhotosConsentDate!) : null,
    };
  }
}

/// Wound Record for baseline and current wounds
class WoundRecord {
  final String id;
  final String location;
  final String type;
  final double length; // in cm
  final double width; // in cm
  final double depth; // in cm
  final String description;
  final List<String> photos; // Storage URLs
  final DateTime assessedAt;
  final String stage; // stage1|stage2|stage3|stage4|unstageable|deepTissueInjury

  WoundRecord({
    required this.id,
    required this.location,
    required this.type,
    required this.length,
    required this.width,
    required this.depth,
    required this.description,
    required this.photos,
    required this.assessedAt,
    required this.stage,
  });

  factory WoundRecord.fromMap(Map<String, dynamic> data) {
    return WoundRecord(
      id: data['id'] ?? '',
      location: data['location'] ?? '',
      type: data['type'] ?? '',
      length: (data['length'] ?? 0).toDouble(),
      width: (data['width'] ?? 0).toDouble(),
      depth: (data['depth'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      assessedAt: (data['assessedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      stage: data['stage'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'location': location,
      'type': type,
      'length': length,
      'width': width,
      'depth': depth,
      'description': description,
      'photos': photos,
      'assessedAt': Timestamp.fromDate(assessedAt),
      'stage': stage,
    };
  }

  // Calculate wound area
  double get area => length * width;
  
  // Calculate wound volume
  double get volume => length * width * depth;
}
