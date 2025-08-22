enum TreatmentType { woundHealing, weightLoss, both }

class Patient {
  final String id;
  final String providerId;
  final String name;
  final String email;
  final String phone;
  final DateTime dateOfBirth;
  final String gender;
  final TreatmentType treatmentType;
  final DateTime treatmentStartDate;
  final DateTime? treatmentEndDate;
  final List<ProgressRecord> progressRecords;
  final String notes;
  final bool isActive;

  Patient({
    required this.id,
    required this.providerId,
    required this.name,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    required this.treatmentType,
    required this.treatmentStartDate,
    this.treatmentEndDate,
    this.progressRecords = const [],
    this.notes = '',
    this.isActive = true,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      providerId: json['providerId'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      treatmentType: TreatmentType.values.firstWhere(
        (e) => e.toString() == 'TreatmentType.${json['treatmentType']}',
        orElse: () => TreatmentType.woundHealing,
      ),
      treatmentStartDate: DateTime.parse(json['treatmentStartDate']),
      treatmentEndDate: json['treatmentEndDate'] != null 
          ? DateTime.parse(json['treatmentEndDate']) 
          : null,
      progressRecords: (json['progressRecords'] as List?)
          ?.map((record) => ProgressRecord.fromJson(record))
          .toList() ?? [],
      notes: json['notes'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'name': name,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'treatmentType': treatmentType.toString().split('.').last,
      'treatmentStartDate': treatmentStartDate.toIso8601String(),
      'treatmentEndDate': treatmentEndDate?.toIso8601String(),
      'progressRecords': progressRecords.map((record) => record.toJson()).toList(),
      'notes': notes,
      'isActive': isActive,
    };
  }

  Patient copyWith({
    String? id,
    String? providerId,
    String? name,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    TreatmentType? treatmentType,
    DateTime? treatmentStartDate,
    DateTime? treatmentEndDate,
    List<ProgressRecord>? progressRecords,
    String? notes,
    bool? isActive,
  }) {
    return Patient(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      treatmentType: treatmentType ?? this.treatmentType,
      treatmentStartDate: treatmentStartDate ?? this.treatmentStartDate,
      treatmentEndDate: treatmentEndDate ?? this.treatmentEndDate,
      progressRecords: progressRecords ?? this.progressRecords,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }

  // Helper methods
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
    if (progressRecords.isEmpty) return 0.0;
    return progressRecords.last.overallProgress;
  }

  Duration get treatmentDuration {
    final endDate = treatmentEndDate ?? DateTime.now();
    return endDate.difference(treatmentStartDate);
  }
}

class ProgressRecord {
  final DateTime date;
  final double weight; // in kg
  final double woundSize; // in cm²
  final double woundDepth; // in cm
  final String woundDescription;
  final double painLevel; // 0-10 scale
  final double mobilityScore; // 0-100 scale
  final String notes;
  final List<String> images; // URLs to wound images

  ProgressRecord({
    required this.date,
    this.weight = 0.0,
    this.woundSize = 0.0,
    this.woundDepth = 0.0,
    this.woundDescription = '',
    this.painLevel = 0.0,
    this.mobilityScore = 0.0,
    this.notes = '',
    this.images = const [],
  });

  factory ProgressRecord.fromJson(Map<String, dynamic> json) {
    return ProgressRecord(
      date: DateTime.parse(json['date']),
      weight: json['weight']?.toDouble() ?? 0.0,
      woundSize: json['woundSize']?.toDouble() ?? 0.0,
      woundDepth: json['woundDepth']?.toDouble() ?? 0.0,
      woundDescription: json['woundDescription'] ?? '',
      painLevel: json['painLevel']?.toDouble() ?? 0.0,
      mobilityScore: json['mobilityScore']?.toDouble() ?? 0.0,
      notes: json['notes'] ?? '',
      images: List<String>.from(json['images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
      'woundSize': woundSize,
      'woundDepth': woundDepth,
      'woundDescription': woundDescription,
      'painLevel': painLevel,
      'mobilityScore': mobilityScore,
      'notes': notes,
      'images': images,
    };
  }

  // Calculate overall progress based on treatment type
  double get overallProgress {
    // This is a simplified calculation - in a real app, you'd have more sophisticated metrics
    double progress = 0.0;
    
    // Weight loss progress (if applicable)
    if (weight > 0) {
      progress += 50.0; // 50% weight for weight loss
    }
    
    // Wound healing progress
    if (woundSize > 0) {
      // Smaller wound size = better progress
      double woundProgress = (1.0 - (woundSize / 100.0)) * 50.0; // Assuming max wound size of 100cm²
      progress += woundProgress;
    }
    
    // Pain level improvement
    if (painLevel > 0) {
      double painProgress = (1.0 - (painLevel / 10.0)) * 25.0; // Lower pain = better progress
      progress += painProgress;
    }
    
    // Mobility improvement
    if (mobilityScore > 0) {
      double mobilityProgress = (mobilityScore / 100.0) * 25.0;
      progress += mobilityProgress;
    }
    
    return progress.clamp(0.0, 100.0);
  }
}
