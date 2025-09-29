import 'package:cloud_firestore/cloud_firestore.dart';

/// Session Model - Represents treatment sessions in patients/{patientId}/sessions subcollection
/// This matches the SESSIONS subcollection structure from DATABASE_README.md
class Session {
  final String id; // Document ID
  final String patientId; // Parent patient ID
  final int sessionNumber; // Sequential session number
  final DateTime date;
  final double weight;
  final int vasScore; // 0-10 pain scale
  final List<SessionWound> wounds;
  final String notes; // Session notes
  final List<String> photos; // Storage URLs
  final String practitionerId;
  final DateTime createdAt;
  final DateTime lastUpdated;

  Session({
    required this.id,
    required this.patientId,
    required this.sessionNumber,
    required this.date,
    required this.weight,
    required this.vasScore,
    required this.wounds,
    required this.notes,
    required this.photos,
    required this.practitionerId,
    required this.createdAt,
    required this.lastUpdated,
  });

  /// Create from Firestore document
  factory Session.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Session(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      sessionNumber: data['sessionNumber'] ?? 0,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      weight: (data['weight'] ?? 0).toDouble(),
      vasScore: data['vasScore'] ?? 0,
      wounds: (data['wounds'] as List?)
          ?.map((wound) => SessionWound.fromMap(wound))
          .toList() ?? [],
      notes: data['notes'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      practitionerId: data['practitionerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'sessionNumber': sessionNumber,
      'date': Timestamp.fromDate(date),
      'weight': weight,
      'vasScore': vasScore,
      'wounds': wounds.map((wound) => wound.toMap()).toList(),
      'notes': notes,
      'photos': photos,
      'practitionerId': practitionerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Copy with new values
  Session copyWith({
    String? patientId,
    int? sessionNumber,
    DateTime? date,
    double? weight,
    int? vasScore,
    List<SessionWound>? wounds,
    String? notes,
    List<String>? photos,
    String? practitionerId,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return Session(
      id: id,
      patientId: patientId ?? this.patientId,
      sessionNumber: sessionNumber ?? this.sessionNumber,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      vasScore: vasScore ?? this.vasScore,
      wounds: wounds ?? this.wounds,
      notes: notes ?? this.notes,
      photos: photos ?? this.photos,
      practitionerId: practitionerId ?? this.practitionerId,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Getters
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  double get totalWoundArea {
    return wounds.fold(0.0, (sum, wound) => sum + wound.area);
  }

  double get averageWoundDepth {
    if (wounds.isEmpty) return 0.0;
    final totalDepth = wounds.fold(0.0, (sum, wound) => sum + wound.depth);
    return totalDepth / wounds.length;
  }

  /// Calculate progress compared to previous session
  double calculateProgress(Session? previousSession) {
    if (previousSession == null) return 0.0;

    double progress = 0.0;
    int factors = 0;

    // Weight progress (if both sessions have weight)
    if (weight > 0 && previousSession.weight > 0) {
      final weightChange = weight - previousSession.weight;
      progress += weightChange > 0 ? 25.0 : 0.0; // 25% for weight gain
      factors++;
    }

    // Pain reduction progress
    final painReduction = previousSession.vasScore - vasScore;
    if (painReduction > 0) {
      progress += (painReduction / 10.0) * 25.0; // 25% for pain reduction
    }
    factors++;

    // Wound healing progress
    final woundAreaReduction = previousSession.totalWoundArea - totalWoundArea;
    if (woundAreaReduction > 0 && previousSession.totalWoundArea > 0) {
      progress += (woundAreaReduction / previousSession.totalWoundArea) * 50.0; // 50% for wound healing
    }
    factors++;

    return factors > 0 ? progress.clamp(0.0, 100.0) : 0.0;
  }
}

/// Session Wound - wound data specific to a session
class SessionWound {
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

  SessionWound({
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

  factory SessionWound.fromMap(Map<String, dynamic> data) {
    return SessionWound(
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

  // Getters
  double get area => length * width;
  double get volume => length * width * depth;

  /// Get stage display name
  String get stageDisplay {
    switch (stage) {
      case 'stage1':
        return 'Stage 1';
      case 'stage2':
        return 'Stage 2';
      case 'stage3':
        return 'Stage 3';
      case 'stage4':
        return 'Stage 4';
      case 'unstageable':
        return 'Unstageable';
      case 'deepTissueInjury':
        return 'Deep Tissue Injury';
      default:
        return 'Unknown';
    }
  }

  /// Get stage color for UI
  String get stageColor {
    switch (stage) {
      case 'stage1':
        return '#FFC107'; // Amber
      case 'stage2':
        return '#FF9800'; // Orange
      case 'stage3':
        return '#FF5722'; // Deep Orange
      case 'stage4':
        return '#F44336'; // Red
      case 'unstageable':
        return '#9C27B0'; // Purple
      case 'deepTissueInjury':
        return '#673AB7'; // Deep Purple
      default:
        return '#9E9E9E'; // Grey
    }
  }
}
