import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/logger.dart';

/// Service to download OCR models and language packs from Firebase Storage or CDN
class ModelDownloadService extends GetxService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Observable values
  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final RxString currentDownload = ''.obs;
  
  // Model paths in Firebase Storage
  static const String OCR_MODELS_PATH = 'models/ocr/';
  static const String LANGUAGE_PACKS_PATH = 'models/translation/';
  
  // Model files for PaddleOCR v5
  static const List<String> OCR_MODEL_FILES = [
    'ch_PP-OCRv4_det_infer.nb',      // Detection model
    'ch_PP-OCRv4_rec_infer.nb',      // Recognition model
    'ch_ppocr_mobile_v2.0_cls_infer.nb', // Classification model
    'ppocr_keys_v1.txt',             // Character dictionary
  ];
  
  // Supported languages for offline translation
  static const Map<String, String> LANGUAGE_PACKS = {
    'ar': 'arabic.dict',
    'en': 'english.dict',
    'zh': 'chinese.dict',
    'ja': 'japanese.dict',
    'ko': 'korean.dict',
    'fr': 'french.dict',
    'de': 'german.dict',
    'es': 'spanish.dict',
  };
  
  /// Download OCR models from Firebase Storage
  Future<bool> downloadOCRModels({Function(double)? onProgress}) async {
    try {
      Logger.log('Starting OCR models download...', tag: 'DOWNLOAD');
      isDownloading.value = true;
      currentDownload.value = 'OCR Models';
      downloadProgress.value = 0.0;
      
      final appDir = await getApplicationDocumentsDirectory();
      final modelsDir = Directory('${appDir.path}/paddle_ocr_models');
      
      if (!await modelsDir.exists()) {
        await modelsDir.create(recursive: true);
      }
      
      int completedFiles = 0;
      final totalFiles = OCR_MODEL_FILES.length;
      
      for (final modelFile in OCR_MODEL_FILES) {
        try {
          Logger.log('Downloading $modelFile...', tag: 'DOWNLOAD');
          
          final ref = _storage.ref('$OCR_MODELS_PATH$modelFile');
          final localFile = File('${modelsDir.path}/$modelFile');
          
          // Check if file already exists
          if (await localFile.exists()) {
            Logger.log('$modelFile already exists, skipping...', tag: 'DOWNLOAD');
            completedFiles++;
            downloadProgress.value = completedFiles / totalFiles;
            onProgress?.call(downloadProgress.value);
            continue;
          }
          
          // Download with progress tracking
          final downloadTask = ref.writeToFile(localFile);
          
          downloadTask.snapshotEvents.listen((taskSnapshot) {
            final progress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
            final overallProgress = (completedFiles + progress) / totalFiles;
            downloadProgress.value = overallProgress;
            onProgress?.call(overallProgress);
            
            Logger.log(
              '$modelFile: ${(progress * 100).toStringAsFixed(1)}%',
              tag: 'DOWNLOAD',
            );
          });
          
          await downloadTask;
          completedFiles++;
          
          Logger.success('Downloaded $modelFile', tag: 'DOWNLOAD');
        } catch (e) {
          Logger.error('Error downloading $modelFile: $e', tag: 'DOWNLOAD');
          
          // Try CDN fallback
          final success = await _downloadFromCDN(
            modelFile,
            '${modelsDir.path}/$modelFile',
            onProgress: (progress) {
              final overallProgress = (completedFiles + progress) / totalFiles;
              downloadProgress.value = overallProgress;
              onProgress?.call(overallProgress);
            },
          );
          
          if (success) {
            completedFiles++;
          } else {
            throw Exception('Failed to download $modelFile from both Firebase and CDN');
          }
        }
      }
      
      isDownloading.value = false;
      downloadProgress.value = 1.0;
      Logger.success('All OCR models downloaded successfully', tag: 'DOWNLOAD');
      return true;
    } catch (e) {
      Logger.error('Error downloading OCR models: $e', tag: 'DOWNLOAD');
      isDownloading.value = false;
      return false;
    }
  }
  
  /// Download language pack from Firebase Storage
  Future<bool> downloadLanguagePack(
    String languageCode, {
    Function(double)? onProgress,
  }) async {
    try {
      final packFile = LANGUAGE_PACKS[languageCode];
      if (packFile == null) {
        Logger.error('Unsupported language: $languageCode', tag: 'DOWNLOAD');
        return false;
      }
      
      Logger.log('Downloading language pack: $languageCode...', tag: 'DOWNLOAD');
      isDownloading.value = true;
      currentDownload.value = 'Language Pack ($languageCode)';
      downloadProgress.value = 0.0;
      
      final appDir = await getApplicationDocumentsDirectory();
      final langDir = Directory('${appDir.path}/language_packs');
      
      if (!await langDir.exists()) {
        await langDir.create(recursive: true);
      }
      
      final ref = _storage.ref('$LANGUAGE_PACKS_PATH$packFile');
      final localFile = File('${langDir.path}/$packFile');
      
      // Check if file already exists
      if (await localFile.exists()) {
        Logger.log('Language pack already exists: $languageCode', tag: 'DOWNLOAD');
        isDownloading.value = false;
        downloadProgress.value = 1.0;
        return true;
      }
      
      // Download with progress tracking
      final downloadTask = ref.writeToFile(localFile);
      
      downloadTask.snapshotEvents.listen((taskSnapshot) {
        final progress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
        downloadProgress.value = progress;
        onProgress?.call(progress);
        
        Logger.log(
          'Language pack $languageCode: ${(progress * 100).toStringAsFixed(1)}%',
          tag: 'DOWNLOAD',
        );
      });
      
      await downloadTask;
      
      isDownloading.value = false;
      downloadProgress.value = 1.0;
      Logger.success('Language pack downloaded: $languageCode', tag: 'DOWNLOAD');
      return true;
    } catch (e) {
      Logger.error('Error downloading language pack: $e', tag: 'DOWNLOAD');
      isDownloading.value = false;
      
      // Try CDN fallback
      return await _downloadLanguagePackFromCDN(languageCode, onProgress: onProgress);
    }
  }
  
  /// Download from CDN as fallback
  Future<bool> _downloadFromCDN(
    String fileName,
    String localPath, {
    Function(double)? onProgress,
  }) async {
    try {
      // Replace with your CDN URL
      const cdnBaseUrl = 'https://your-cdn.com/models/ocr/';
      final url = '$cdnBaseUrl$fileName';
      
      Logger.log('Trying CDN download: $url', tag: 'DOWNLOAD');
      
      // TODO: Implement HTTP download with progress
      // For now, return false to indicate CDN is not configured
      Logger.warning('CDN download not configured', tag: 'DOWNLOAD');
      return false;
    } catch (e) {
      Logger.error('CDN download failed: $e', tag: 'DOWNLOAD');
      return false;
    }
  }
  
  /// Download language pack from CDN
  Future<bool> _downloadLanguagePackFromCDN(
    String languageCode, {
    Function(double)? onProgress,
  }) async {
    try {
      final packFile = LANGUAGE_PACKS[languageCode];
      if (packFile == null) return false;
      
      const cdnBaseUrl = 'https://your-cdn.com/models/translation/';
      final url = '$cdnBaseUrl$packFile';
      
      Logger.log('Trying CDN download for language pack: $url', tag: 'DOWNLOAD');
      
      // TODO: Implement HTTP download with progress
      Logger.warning('CDN download not configured', tag: 'DOWNLOAD');
      return false;
    } catch (e) {
      Logger.error('CDN language pack download failed: $e', tag: 'DOWNLOAD');
      return false;
    }
  }
  
  /// Check if OCR models are downloaded
  Future<bool> areOCRModelsDownloaded() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final modelsDir = Directory('${appDir.path}/paddle_ocr_models');
      
      if (!await modelsDir.exists()) {
        return false;
      }
      
      for (final modelFile in OCR_MODEL_FILES) {
        final file = File('${modelsDir.path}/$modelFile');
        if (!await file.exists()) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      Logger.error('Error checking OCR models: $e', tag: 'DOWNLOAD');
      return false;
    }
  }
  
  /// Check if language pack is downloaded
  Future<bool> isLanguagePackDownloaded(String languageCode) async {
    try {
      final packFile = LANGUAGE_PACKS[languageCode];
      if (packFile == null) return false;
      
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/language_packs/$packFile');
      
      return await file.exists();
    } catch (e) {
      Logger.error('Error checking language pack: $e', tag: 'DOWNLOAD');
      return false;
    }
  }
  
  /// Delete OCR models
  Future<bool> deleteOCRModels() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final modelsDir = Directory('${appDir.path}/paddle_ocr_models');
      
      if (await modelsDir.exists()) {
        await modelsDir.delete(recursive: true);
        Logger.success('OCR models deleted', tag: 'DOWNLOAD');
      }
      
      return true;
    } catch (e) {
      Logger.error('Error deleting OCR models: $e', tag: 'DOWNLOAD');
      return false;
    }
  }
  
  /// Delete language pack
  Future<bool> deleteLanguagePack(String languageCode) async {
    try {
      final packFile = LANGUAGE_PACKS[languageCode];
      if (packFile == null) return false;
      
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/language_packs/$packFile');
      
      if (await file.exists()) {
        await file.delete();
        Logger.success('Language pack deleted: $languageCode', tag: 'DOWNLOAD');
      }
      
      return true;
    } catch (e) {
      Logger.error('Error deleting language pack: $e', tag: 'DOWNLOAD');
      return false;
    }
  }
  
  /// Get total size of downloaded models
  Future<int> getTotalModelsSize() async {
    try {
      int totalSize = 0;
      
      final appDir = await getApplicationDocumentsDirectory();
      
      // OCR models
      final modelsDir = Directory('${appDir.path}/paddle_ocr_models');
      if (await modelsDir.exists()) {
        await for (final entity in modelsDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
      
      // Language packs
      final langDir = Directory('${appDir.path}/language_packs');
      if (await langDir.exists()) {
        await for (final entity in langDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
      
      return totalSize;
    } catch (e) {
      Logger.error('Error calculating models size: $e', tag: 'DOWNLOAD');
      return 0;
    }
  }
  
  /// Format bytes to human readable string
  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
