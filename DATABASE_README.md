# MedWave Firebase Database Structure Documentation

## Project Overview
MedWave is a comprehensive wound care management platform built with Flutter and Firebase. This document provides a complete overview of the Firebase database structure, data models, security rules, and implementation details for the Admin section development team.

## Firebase Project Configuration

### Project Details
- **Project ID**: `medx-ai`
- **Database Location**: `nam5` (North America)
- **Authentication**: Firebase Auth with email/password
- **Storage**: Firebase Storage for file uploads
- **Database**: Cloud Firestore (NoSQL)

### Platform Support
- **Web**: Supported with API key `AIzaSyC_medx_ai_web_api_key` (Replace with actual medx.ai web API key)
- **Android**: Supported with API key `AIzaSyC_medx_ai_android_api_key` (Replace with actual medx.ai Android API key)
- **iOS**: Supported with API key `AIzaSyC_medx_ai_ios_api_key` (Replace with actual medx.ai iOS API key)

## Database Collections Structure

### 1. USERS Collection (`users`)
**Purpose**: Store practitioner profiles and user account information

**Document Structure**:
```json
{
  "id": "string (document ID matches Firebase Auth UID)",
  "firstName": "string",
  "lastName": "string", 
  "email": "string",
  "phoneNumber": "string",
  "licenseNumber": "string",
  "specialization": "string",
  "yearsOfExperience": "number",
  "practiceLocation": "string",
  
  // Location Information
  "country": "string (country code)",
  "countryName": "string",
  "province": "string",
  "city": "string", 
  "address": "string",
  "postalCode": "string",
  
  // Approval Workflow
  "accountStatus": "string (pending|approved|rejected|suspended)",
  "applicationDate": "timestamp",
  "approvalDate": "timestamp",
  "approvedBy": "string (admin user ID)",
  "rejectionReason": "string",
  
  // Professional Verification
  "licenseVerified": "boolean",
  "licenseVerificationDate": "timestamp",
  "professionalReferences": [
    {
      "name": "string",
      "organization": "string",
      "email": "string", 
      "phone": "string",
      "relationship": "string"
    }
  ],
  
  // App Settings
  "settings": {
    "notificationsEnabled": "boolean",
    "darkModeEnabled": "boolean",
    "biometricEnabled": "boolean",
    "language": "string",
    "timezone": "string"
  },
  
  // Metadata
  "createdAt": "timestamp",
  "lastUpdated": "timestamp",
  "lastLogin": "timestamp",
  "role": "string (practitioner|super_admin|country_admin)",
  
  // Analytics Support
  "totalPatients": "number",
  "totalSessions": "number", 
  "lastActivityDate": "timestamp"
}
```

**Security Rules**: Users can only read/write their own profile (request.auth.uid == userId)

---

### 2. PATIENTS Collection (`patients`)
**Purpose**: Store patient demographics, medical history, and baseline measurements

**Document Structure**:
```json
{
  "id": "string (auto-generated)",
  
  // Basic Patient Details
  "surname": "string",
  "fullNames": "string",
  "idNumber": "string",
  "dateOfBirth": "timestamp",
  "workNameAndAddress": "string",
  "workPostalAddress": "string", 
  "workTelNo": "string",
  "patientCell": "string",
  "homeTelNo": "string",
  "email": "string",
  "maritalStatus": "string",
  "occupation": "string",
  
  // Person Responsible for Account (Main Member)
  "responsiblePersonSurname": "string",
  "responsiblePersonFullNames": "string",
  "responsiblePersonIdNumber": "string",
  "responsiblePersonDateOfBirth": "timestamp",
  "responsiblePersonWorkNameAndAddress": "string",
  "responsiblePersonWorkPostalAddress": "string",
  "responsiblePersonWorkTelNo": "string",
  "responsiblePersonCell": "string",
  "responsiblePersonHomeTelNo": "string",
  "responsiblePersonEmail": "string",
  "responsiblePersonMaritalStatus": "string",
  "responsiblePersonOccupation": "string",
  "relationToPatient": "string",
  
  // Medical Aid Details
  "medicalAidSchemeName": "string",
  "medicalAidNumber": "string",
  "planAndDepNumber": "string",
  "mainMemberName": "string",
  
  // Referring Doctor/Specialist
  "referringDoctorName": "string",
  "referringDoctorCell": "string",
  "additionalReferrerName": "string",
  "additionalReferrerCell": "string",
  
  // Medical History
  "medicalConditions": {
    "heart": "boolean",
    "lungs": "boolean",
    "diabetes": "boolean"
    // ... other conditions
  },
  "medicalConditionDetails": {
    "heart": "string (details if true)",
    "lungs": "string (details if true)"
    // ... corresponding details
  },
  "currentMedications": "string",
  "allergies": "string",
  "isSmoker": "boolean",
  "naturalTreatments": "string",
  
  // Consent and Signatures
  "accountResponsibilitySignature": "string",
  "accountResponsibilitySignatureDate": "timestamp",
  "woundPhotographyConsentSignature": "string", 
  "witnessSignature": "string",
  "woundPhotographyConsentDate": "timestamp",
  "trainingPhotosConsent": "boolean",
  "trainingPhotosConsentDate": "timestamp",
  
  "createdAt": "timestamp",
  "lastUpdated": "timestamp",
  
  // Firebase-specific fields
  "practitionerId": "string (reference to user who created patient)",
  "country": "string (inherited from practitioner)",
  "countryName": "string (inherited from practitioner)",
  "province": "string (inherited from practitioner)",
  
  // Baseline measurements
  "baselineWeight": "number",
  "baselineVasScore": "number (0-10 pain scale)",
  "baselineWounds": [
    {
      "id": "string",
      "location": "string",
      "type": "string", 
      "length": "number (cm)",
      "width": "number (cm)",
      "depth": "number (cm)",
      "description": "string",
      "photos": ["string (storage URLs)"],
      "assessedAt": "timestamp",
      "stage": "string (stage1|stage2|stage3|stage4|unstageable|deepTissueInjury)"
    }
  ],
  "baselinePhotos": ["string (storage URLs)"],
  
  // Current measurements (updated during treatment)
  "currentWeight": "number",
  "currentVasScore": "number", 
  "currentWounds": [
    // Same structure as baselineWounds
  ],
  
  // Calculated progress metrics
  "weightChange": "number",
  "painReduction": "number",
  "woundHealingProgress": "number"
}
```

**Subcollections**:
- `sessions/` - Treatment session records (see Sessions structure below)

**Security Rules**: Practitioners can read/write patients they created (practitionerId == auth.uid)

---

### 3. SESSIONS Subcollection (`patients/{patientId}/sessions`)
**Purpose**: Store individual treatment session data and progress tracking

**Document Structure**:
```json
{
  "id": "string (auto-generated)",
  "patientId": "string (parent patient ID)",
  "sessionNumber": "number (sequential)",
  "date": "timestamp",
  "weight": "number",
  "vasScore": "number (0-10 pain scale)",
  "wounds": [
    {
      "id": "string",
      "location": "string",
      "type": "string",
      "length": "number (cm)",
      "width": "number (cm)", 
      "depth": "number (cm)",
      "description": "string",
      "photos": ["string (storage URLs)"],
      "assessedAt": "timestamp",
      "stage": "string"
    }
  ],
  "notes": "string (session notes)",
  "photos": ["string (storage URLs)"],
  "practitionerId": "string",
  "createdAt": "timestamp",
  "lastUpdated": "timestamp"
}
```

**Indexes**:
- Composite index on `patientId` + `sessionNumber` (ascending/descending)

**Security Rules**: Practitioners can access sessions for patients they own

---

### 4. APPOINTMENTS Collection (`appointments`)
**Purpose**: Store appointment scheduling and management data

**Document Structure**:
```json
{
  "id": "string (auto-generated)",
  "patientId": "string",
  "patientName": "string",
  "title": "string",
  "description": "string",
  "startTime": "timestamp",
  "endTime": "timestamp", 
  "type": "string (consultation|followUp|treatment|assessment|emergency)",
  "status": "string (scheduled|confirmed|inProgress|completed|cancelled|noShow|rescheduled)",
  "practitionerId": "string",
  "practitionerName": "string",
  "location": "string",
  "notes": ["string"],
  "createdAt": "timestamp",
  "lastUpdated": "timestamp",
  "reminderSent": "string",
  "metadata": "object",
  
  // Additional Firebase fields
  "dateKey": "string (YYYY-MM-DD)",
  "timeSlot": "string (HH:MM)", 
  "duration": "number (minutes)"
}
```

**Security Rules**: Practitioners can read/write their own appointments (practitionerId == auth.uid)

---

### 5. NOTIFICATIONS Collection (`notifications`)
**Purpose**: Store app notifications for practitioners

**Document Structure**:
```json
{
  "id": "string (auto-generated)",
  "title": "string",
  "message": "string",
  "type": "string (appointment|improvement|reminder|alert)",
  "priority": "string (low|medium|high|urgent)",
  "createdAt": "timestamp",
  "isRead": "boolean",
  "patientId": "string",
  "patientName": "string", 
  "data": "object (additional metadata)",
  "userId": "string (recipient practitioner ID)"
}
```

**Security Rules**: Practitioners can read/write their own notifications (userId == auth.uid)

---

### 6. PRACTITIONER_APPLICATIONS Collection (`practitioner_applications`)
**Purpose**: Store practitioner registration applications for admin approval

**Document Structure**:
```json
{
  "id": "string (auto-generated)",
  "userId": "string (Firebase Auth UID)",
  "email": "string",
  "firstName": "string",
  "lastName": "string",
  
  // Professional Information
  "licenseNumber": "string",
  "specialization": "string", 
  "yearsOfExperience": "number",
  "practiceLocation": "string",
  
  // Location Information
  "country": "string",
  "countryName": "string",
  "province": "string", 
  "city": "string",
  
  // Application Status
  "status": "string (pending|under_review|approved|rejected)",
  "submittedAt": "timestamp",
  "reviewedAt": "timestamp",
  "reviewedBy": "string (admin user ID)",
  "reviewNotes": "string",
  "rejectionReason": "string",
  
  // Supporting Documents (Firebase Storage references)
  "documents": {
    "licenseDocument": "string (storage URL)",
    "idDocument": "string (storage URL)",
    "qualificationCertificate": "string (storage URL)"
  },
  
  // Verification Status
  "documentsVerified": "boolean",
  "licenseVerified": "boolean", 
  "referencesVerified": "boolean"
}
```

**Security Rules**: Authenticated users can read/write (admin access required)

---

### 7. ICD10_CODES Collection (`icd10_codes`)
**Purpose**: Store ICD-10 medical diagnosis codes for AI motivation letters

**Document Structure**:
```json
{
  "id": "string (auto-generated)",
  "number": "string",
  "chapter_no": "string",
  "chapter_desc": "string",
  "group_code": "string",
  "group_desc": "string",
  "icd10_3_code": "string",
  "icd10_3_code_desc": "string",
  "icd10_code": "string",
  "who_full_desc": "string",
  "valid_clinical_use": "boolean",
  "valid_primary": "boolean",
  "searchTerms": ["string (keywords for search)"],
  "created_at": "string (ISO date)"
}
```

**Note**: This is a reference collection uploaded from external ICD-10 data

---

### 8. PMB_CODES Collection (`pmb_codes`)
**Purpose**: Store Prescribed Minimum Benefits codes for medical aid coverage

**Document Structure**:
```json
{
  "id": "string (auto-generated)",
  "icd10_code": "string",
  "condition_name": "string", 
  "pmb_category": "string",
  "coverage_notes": "string",
  "effective_date": "string (ISO date)",
  "is_active": "boolean",
  "created_at": "string (ISO date)"
}
```

---

### 9. CONVERSATIONS Collection (`conversations`)
**Purpose**: Store AI motivation letter chat conversations and extracted data

**Document Structure**:
```json
{
  "id": "string (auto-generated)",
  "patient_id": "string",
  "practitioner_id": "string",
  "messages": [
    {
      "id": "string",
      "content": "string",
      "is_bot": "boolean",
      "timestamp": "string (ISO date)",
      "related_step": "string (conversation step)",
      "suggested_codes": [
        {
          "code": "object (ICD10Code)",
          "type": "string (primary|secondary|externalCause)",
          "pmb_eligible": "boolean",
          "explanation": "string",
          "confidence": "number"
        }
      ],
      "pmb_result": "object",
      "type": "string (text|codeSelection|confirmation|error)"
    }
  ],
  "extracted_data": {
    "patient_name": "string",
    "medical_aid": "string", 
    "membership_number": "string",
    "referring_doctor": "string",
    "practitioner_name": "string",
    "wound_history": "string",
    "wound_occurrence": "string",
    "comorbidities": ["string"],
    "infection_status": "string",
    "tests_performed": ["string"],
    "wound_details": {
      "type": "string",
      "classification": "string",
      "size": "string",
      "location": "string", 
      "current_treatment": "string",
      "times_assessment": {
        "tissue": "string",
        "inflammation": "string",
        "moisture": "string",
        "edges": "string", 
        "surrounding_skin": "string"
      }
    },
    "treatment_details": {
      "treatment_dates": ["string (ISO dates)"],
      "cleansing": "string",
      "skin_protectant": "string",
      "planned_treatments": ["string"],
      "treatment_codes": ["string"],
      "photobiomodulation_therapy": "string"
    },
    "additional_notes": "string",
    "in_lieu_of_hospitalization": "boolean"
  },
  "current_step": "string (conversation step enum)",
  "selected_icd10_codes": [
    // Array of selected ICD10 codes with context
  ],
  "treatment_codes": ["string"],
  "pmb_eligible": "boolean",
  "generated_report": "string",
  "status": "string (inProgress|completed|cancelled|error)",
  "created_at": "string (ISO date)",
  "completed_at": "string (ISO date)"
}
```

---

### 10. COUNTRY_ANALYTICS Collection (`country_analytics`)
**Purpose**: Store aggregated analytics data by country for admin dashboards

**Document Structure**:
```json
{
  "id": "string (country code)",
  "countryName": "string",
  
  // Practitioner Statistics
  "totalPractitioners": "number",
  "activePractitioners": "number (last 30 days)",
  "pendingApplications": "number",
  "approvedThisMonth": "number",
  "rejectedThisMonth": "number",
  
  // Patient Statistics  
  "totalPatients": "number",
  "newPatientsThisMonth": "number",
  "totalSessions": "number",
  "sessionsThisMonth": "number",
  
  // Performance Metrics
  "averageSessionsPerPractitioner": "number",
  "averagePatientsPerPractitioner": "number", 
  "averageWoundHealingRate": "number",
  
  // Geographic Distribution
  "provinces": {
    "{province_name}": {
      "totalPractitioners": "number",
      "totalPatients": "number",
      "totalSessions": "number"
    }
  },
  
  // Last Updated
  "lastCalculated": "timestamp",
  "calculatedBy": "string (admin user ID)"
}
```

---

## Firebase Storage Structure

### Storage Buckets
**Root**: `gs://medx-ai.firebasestorage.app`

### Storage Paths:
```
/temp/{userId}/                          # Temporary uploads
/users/{userId}/                         # User profile documents
  ├── profile_photo.jpg
  ├── license_document.pdf
  ├── id_document.pdf
  └── qualification_certificate.pdf

/patients/{patientId}/                   # Patient files
  ├── consent_forms/
  ├── baseline_photos/
  └── documents/

/sessions/{patientId}/{sessionId}/       # Session files  
  ├── photos/
  ├── wound_images/
  └── progress_photos/

/reports/{reportId}/                     # Generated reports
  ├── progress_report.pdf
  ├── motivation_letter.pdf
  └── analytics_export.pdf
```

### Storage Security Rules:
- Users can read/write to their own directories
- Authenticated users can access patient and session files
- Temporary uploads are restricted to the uploading user

---

## Security Rules Summary

### Firestore Rules:
1. **Users**: Can only access their own profile (`request.auth.uid == userId`)
2. **Patients**: Practitioners can only access patients they created (`practitionerId == auth.uid`)
3. **Sessions**: Access through patient ownership verification
4. **Appointments**: Practitioners can only access their own appointments
5. **Notifications**: Users can only access their own notifications
6. **Applications**: Open read/write for authenticated users (admin management)

### Storage Rules:
- Path-based security using user IDs
- Authenticated access required for all operations
- Temporary upload restrictions

---

## Data Relationships

### Primary Relationships:
```
Users (1) ←→ (N) Patients
Users (1) ←→ (N) Appointments  
Users (1) ←→ (N) Notifications
Users (1) ←→ (1) PractitionerApplication

Patients (1) ←→ (N) Sessions
Patients (1) ←→ (N) Appointments
Patients (1) ←→ (N) Conversations

ICD10Codes (N) ←→ (N) Conversations
PMBCodes (N) ←→ (N) Conversations
```

### Foreign Key References:
- `practitionerId` in patients, appointments, sessions, notifications
- `patientId` in sessions, appointments, conversations  
- `userId` in practitioner_applications, notifications

---

## Indexes

### Existing Composite Indexes:
1. **Sessions Collection**:
   - `patientId` (ASC) + `sessionNumber` (DESC)
   - `patientId` (ASC) + `sessionNumber` (ASC)

### Recommended Additional Indexes for Admin:
1. **Users Collection**:
   - `accountStatus` + `createdAt`
   - `country` + `accountStatus`
   - `role` + `lastActivityDate`

2. **Patients Collection**:
   - `practitionerId` + `createdAt`
   - `country` + `createdAt`

3. **Appointments Collection**:  
   - `practitionerId` + `startTime`
   - `status` + `startTime`

4. **Applications Collection**:
   - `status` + `submittedAt`
   - `country` + `status`

---

## Admin Access Patterns

### Common Admin Queries:

#### User Management:
```dart
// Get pending practitioner applications
FirebaseFirestore.instance
  .collection('practitioner_applications')
  .where('status', isEqualTo: 'pending')
  .orderBy('submittedAt')
  .get()

// Get users by country and status  
FirebaseFirestore.instance
  .collection('users')
  .where('country', isEqualTo: 'ZA')
  .where('accountStatus', isEqualTo: 'approved')
  .get()
```

#### Analytics Queries:
```dart
// Get all patients for a country
FirebaseFirestore.instance
  .collection('patients') 
  .where('country', isEqualTo: 'ZA')
  .get()

// Get recent sessions across all practitioners
FirebaseFirestore.instance
  .collectionGroup('sessions')
  .where('date', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
  .get()
```

#### System Monitoring:
```dart
// Get error conversations
FirebaseFirestore.instance
  .collection('conversations')
  .where('status', isEqualTo: 'error')
  .get()
  
// Get inactive practitioners
FirebaseFirestore.instance
  .collection('users')
  .where('lastActivityDate', isLessThan: Timestamp.fromDate(sixtyDaysAgo))
  .get()
```

---

## Data Export Considerations

### For Analytics:
- Use collection group queries for cross-practitioner data
- Implement pagination for large datasets
- Consider data aggregation at country/province level

### For Backup:
- Export collections in dependency order: Users → Patients → Sessions
- Include storage file references
- Maintain referential integrity during export/import

### For Compliance:
- Patient data anonymization capabilities
- Audit trail requirements
- Data retention policies

---

## Performance Considerations

### Query Optimization:
1. Always use indexes for compound queries
2. Limit large collection scans
3. Use pagination for admin dashboards
4. Cache frequently accessed reference data (ICD-10, PMB codes)

### Real-time Updates:
- Use Firestore listeners for live admin dashboards
- Implement proper cleanup for listeners
- Consider batched updates for bulk operations

### Storage Optimization:
- Implement file compression for images
- Use appropriate image formats (WebP for web)
- Clean up orphaned storage files

---

## Integration Points for Admin Section

### Authentication:
- Integrate with existing Firebase Auth
- Implement role-based access (`super_admin`, `country_admin`)
- Use custom claims for advanced permissions

### Real-time Features:
- Live practitioner application status
- Real-time analytics dashboards  
- Notification systems for critical events

### Bulk Operations:
- Batch approval/rejection of applications
- Bulk export of patient data
- System-wide configuration updates

### Monitoring:
- Application error tracking
- Performance monitoring
- Usage analytics by country/region

---

## Error Handling Patterns

### Common Errors:
1. **Permission Denied**: Check security rules and user authentication
2. **Index Missing**: Create required composite indexes  
3. **Document Not Found**: Verify document IDs and references
4. **Quota Exceeded**: Monitor Firestore usage and implement pagination

### Recommended Error Handling:
```dart
try {
  final result = await FirebaseFirestore.instance
    .collection('patients')
    .where('practitionerId', isEqualTo: userId)
    .get();
} on FirebaseException catch (e) {
  if (e.code == 'permission-denied') {
    // Handle permission error
  } else if (e.code == 'unavailable') {
    // Handle network error
  }
  // Log error for admin monitoring
}
```

---

## Migration and Versioning

### Schema Changes:
- Use field presence checks for backward compatibility
- Implement gradual rollout for data model changes
- Maintain migration scripts for existing data

### Version Control:
- Document schema versions in each collection
- Implement feature flags for new functionality
- Plan deprecation strategy for old fields

---

This documentation provides a comprehensive overview of the MedWave Firebase database structure. For specific implementation questions or additional details about any collection or security rule, please refer to the corresponding Dart model files in the `/lib/models/` directory and service files in `/lib/services/firebase/`.

## Contact
For questions about this database structure, contact the development team or refer to the implementation files in the main application codebase.
