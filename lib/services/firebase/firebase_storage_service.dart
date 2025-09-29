import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'firebase_config.dart';

/// Firebase Storage Service for MedWave Admin Panel
/// 
/// Handles file operations for:
/// - Practitioner license documents
/// - Patient consent forms and photos
/// - Session wound images
/// - Generated reports and exports
class FirebaseStorageService {
  static final FirebaseStorageService _instance = FirebaseStorageService._internal();
  factory FirebaseStorageService() => _instance;
  FirebaseStorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload file to Firebase Storage
  Future<String?> uploadFile({
    required Uint8List fileData,
    required String fileName,
    required String folder,
    String? userId,
    String? patientId,
    String? sessionId,
    ProgressCallback? onProgress,
  }) async {
    try {
      // Construct the file path based on the folder structure
      final filePath = _constructFilePath(
        folder: folder,
        fileName: fileName,
        userId: userId,
        patientId: patientId,
        sessionId: sessionId,
      );

      if (kDebugMode) {
        print('Uploading file to: $filePath');
      }

      // Create reference to the file location
      final ref = _storage.ref().child(filePath);

      // Set metadata
      final metadata = SettableMetadata(
        contentType: _getContentType(fileName),
        customMetadata: {
          'uploadedBy': userId ?? 'admin',
          'uploadedAt': DateTime.now().toIso8601String(),
          'originalName': fileName,
        },
      );

      // Upload the file
      final uploadTask = ref.putData(fileData, metadata);

      // Listen to progress if callback provided
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      if (kDebugMode) {
        print('File uploaded successfully: $downloadUrl');
      }

      return downloadUrl;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Firebase Storage error: ${e.code} - ${e.message}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      return null;
    }
  }

  /// Upload practitioner license document
  Future<String?> uploadLicenseDocument({
    required Uint8List fileData,
    required String fileName,
    required String userId,
    ProgressCallback? onProgress,
  }) async {
    return uploadFile(
      fileData: fileData,
      fileName: fileName,
      folder: FirebaseConfig.usersStoragePath,
      userId: userId,
      onProgress: onProgress,
    );
  }

  /// Upload patient consent form
  Future<String?> uploadConsentForm({
    required Uint8List fileData,
    required String fileName,
    required String patientId,
    String? userId,
    ProgressCallback? onProgress,
  }) async {
    return uploadFile(
      fileData: fileData,
      fileName: fileName,
      folder: '${FirebaseConfig.patientsStoragePath}/consent_forms',
      userId: userId,
      patientId: patientId,
      onProgress: onProgress,
    );
  }

  /// Upload patient baseline photo
  Future<String?> uploadBaselinePhoto({
    required Uint8List fileData,
    required String fileName,
    required String patientId,
    String? userId,
    ProgressCallback? onProgress,
  }) async {
    return uploadFile(
      fileData: fileData,
      fileName: fileName,
      folder: '${FirebaseConfig.patientsStoragePath}/baseline_photos',
      userId: userId,
      patientId: patientId,
      onProgress: onProgress,
    );
  }

  /// Upload session wound image
  Future<String?> uploadWoundImage({
    required Uint8List fileData,
    required String fileName,
    required String patientId,
    required String sessionId,
    String? userId,
    ProgressCallback? onProgress,
  }) async {
    return uploadFile(
      fileData: fileData,
      fileName: fileName,
      folder: '${FirebaseConfig.sessionsStoragePath}/wound_images',
      userId: userId,
      patientId: patientId,
      sessionId: sessionId,
      onProgress: onProgress,
    );
  }

  /// Upload session progress photo
  Future<String?> uploadProgressPhoto({
    required Uint8List fileData,
    required String fileName,
    required String patientId,
    required String sessionId,
    String? userId,
    ProgressCallback? onProgress,
  }) async {
    return uploadFile(
      fileData: fileData,
      fileName: fileName,
      folder: '${FirebaseConfig.sessionsStoragePath}/progress_photos',
      userId: userId,
      patientId: patientId,
      sessionId: sessionId,
      onProgress: onProgress,
    );
  }

  /// Upload generated report
  Future<String?> uploadReport({
    required Uint8List fileData,
    required String fileName,
    required String reportId,
    String? userId,
    ProgressCallback? onProgress,
  }) async {
    return uploadFile(
      fileData: fileData,
      fileName: fileName,
      folder: FirebaseConfig.reportsStoragePath,
      userId: userId,
      onProgress: onProgress,
    );
  }

  /// Download file from Firebase Storage
  Future<Uint8List?> downloadFile(String downloadUrl) async {
    try {
      if (kDebugMode) {
        print('Downloading file from: $downloadUrl');
      }

      // Create reference from download URL
      final ref = _storage.refFromURL(downloadUrl);

      // Download the file
      final data = await ref.getData();

      if (kDebugMode) {
        print('File downloaded successfully');
      }

      return data;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Firebase Storage download error: ${e.code} - ${e.message}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading file: $e');
      }
      return null;
    }
  }

  /// Delete file from Firebase Storage
  Future<bool> deleteFile(String downloadUrl) async {
    try {
      if (kDebugMode) {
        print('Deleting file: $downloadUrl');
      }

      // Create reference from download URL
      final ref = _storage.refFromURL(downloadUrl);

      // Delete the file
      await ref.delete();

      if (kDebugMode) {
        print('File deleted successfully');
      }

      return true;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Firebase Storage delete error: ${e.code} - ${e.message}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting file: $e');
      }
      return false;
    }
  }

  /// Get file metadata
  Future<FullMetadata?> getFileMetadata(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      return await ref.getMetadata();
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Firebase Storage metadata error: ${e.code} - ${e.message}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting file metadata: $e');
      }
      return null;
    }
  }

  /// List files in a directory
  Future<ListResult?> listFiles({
    required String folder,
    String? userId,
    String? patientId,
    String? sessionId,
    int? maxResults,
  }) async {
    try {
      final folderPath = _constructFolderPath(
        folder: folder,
        userId: userId,
        patientId: patientId,
        sessionId: sessionId,
      );

      final ref = _storage.ref().child(folderPath);
      
      return await ref.list(ListOptions(
        maxResults: maxResults ?? 100,
      ));
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Firebase Storage list error: ${e.code} - ${e.message}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error listing files: $e');
      }
      return null;
    }
  }

  /// Get download URLs for multiple files
  Future<List<String>> getDownloadUrls(List<Reference> refs) async {
    final urls = <String>[];

    for (final ref in refs) {
      try {
        final url = await ref.getDownloadURL();
        urls.add(url);
      } catch (e) {
        if (kDebugMode) {
          print('Error getting download URL for ${ref.fullPath}: $e');
        }
      }
    }

    return urls;
  }

  /// Upload multiple files
  Future<List<String?>> uploadMultipleFiles({
    required List<FileUploadData> files,
    required String folder,
    String? userId,
    String? patientId,
    String? sessionId,
    ProgressCallback? onProgress,
  }) async {
    final results = <String?>[];
    int completed = 0;

    for (final file in files) {
      final result = await uploadFile(
        fileData: file.data,
        fileName: file.fileName,
        folder: folder,
        userId: userId,
        patientId: patientId,
        sessionId: sessionId,
        onProgress: (progress) {
          // Calculate overall progress
          final overallProgress = (completed + progress) / files.length;
          onProgress?.call(overallProgress);
        },
      );

      results.add(result);
      completed++;
    }

    return results;
  }

  /// Clean up temporary files (admin function)
  Future<int> cleanupTempFiles({Duration? olderThan}) async {
    try {
      final cutoffDate = olderThan != null 
          ? DateTime.now().subtract(olderThan)
          : DateTime.now().subtract(const Duration(days: 1));

      final tempRef = _storage.ref().child(FirebaseConfig.tempStoragePath);
      final listResult = await tempRef.listAll();

      int deletedCount = 0;

      for (final ref in listResult.items) {
        try {
          final metadata = await ref.getMetadata();
          final uploadedAt = DateTime.parse(
            metadata.customMetadata?['uploadedAt'] ?? '1970-01-01T00:00:00Z'
          );

          if (uploadedAt.isBefore(cutoffDate)) {
            await ref.delete();
            deletedCount++;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error processing temp file ${ref.fullPath}: $e');
          }
        }
      }

      if (kDebugMode) {
        print('Cleanup completed: $deletedCount files deleted');
      }

      return deletedCount;
    } catch (e) {
      if (kDebugMode) {
        print('Error during cleanup: $e');
      }
      return 0;
    }
  }

  /// Helper method to construct file path based on the storage structure
  String _constructFilePath({
    required String folder,
    required String fileName,
    String? userId,
    String? patientId,
    String? sessionId,
  }) {
    final pathSegments = <String>[];

    // Add base folder
    pathSegments.add(folder);

    // Add user ID if provided
    if (userId != null) {
      pathSegments.add(userId);
    }

    // Add patient ID if provided
    if (patientId != null) {
      pathSegments.add(patientId);
    }

    // Add session ID if provided
    if (sessionId != null) {
      pathSegments.add(sessionId);
    }

    // Add filename
    pathSegments.add(fileName);

    return pathSegments.join('/');
  }

  /// Helper method to construct folder path
  String _constructFolderPath({
    required String folder,
    String? userId,
    String? patientId,
    String? sessionId,
  }) {
    final pathSegments = <String>[];

    pathSegments.add(folder);

    if (userId != null) {
      pathSegments.add(userId);
    }

    if (patientId != null) {
      pathSegments.add(patientId);
    }

    if (sessionId != null) {
      pathSegments.add(sessionId);
    }

    return pathSegments.join('/');
  }

  /// Get content type based on file extension
  String _getContentType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;

    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      case 'csv':
        return 'text/csv';
      case 'json':
        return 'application/json';
      default:
        return 'application/octet-stream';
    }
  }
}

/// File upload data wrapper
class FileUploadData {
  final Uint8List data;
  final String fileName;

  FileUploadData({
    required this.data,
    required this.fileName,
  });
}

/// Upload progress callback
typedef ProgressCallback = void Function(double progress);

/// Storage path helpers
class StoragePaths {
  static String userLicenseDocument(String userId, String fileName) =>
      '${FirebaseConfig.usersStoragePath}/$userId/$fileName';

  static String patientConsentForm(String patientId, String fileName) =>
      '${FirebaseConfig.patientsStoragePath}/$patientId/consent_forms/$fileName';

  static String patientBaselinePhoto(String patientId, String fileName) =>
      '${FirebaseConfig.patientsStoragePath}/$patientId/baseline_photos/$fileName';

  static String sessionWoundImage(String patientId, String sessionId, String fileName) =>
      '${FirebaseConfig.sessionsStoragePath}/$patientId/$sessionId/wound_images/$fileName';

  static String sessionProgressPhoto(String patientId, String sessionId, String fileName) =>
      '${FirebaseConfig.sessionsStoragePath}/$patientId/$sessionId/progress_photos/$fileName';

  static String generatedReport(String reportId, String fileName) =>
      '${FirebaseConfig.reportsStoragePath}/$reportId/$fileName';

  static String tempFile(String userId, String fileName) =>
      '${FirebaseConfig.tempStoragePath}/$userId/$fileName';
}

/// Storage utilities
class StorageUtils {
  /// Generate unique filename with timestamp
  static String generateUniqueFileName(String originalName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = originalName.split('.').last;
    final nameWithoutExtension = originalName.substring(0, originalName.lastIndexOf('.'));
    return '${nameWithoutExtension}_$timestamp.$extension';
  }

  /// Get file size in human readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Validate file type
  static bool isValidFileType(String fileName, List<String> allowedExtensions) {
    final extension = fileName.toLowerCase().split('.').last;
    return allowedExtensions.contains(extension);
  }

  /// Validate file size
  static bool isValidFileSize(int bytes, int maxSizeInBytes) {
    return bytes <= maxSizeInBytes;
  }
}
