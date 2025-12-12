import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/logger.dart';
import '../utils/subscription_helper.dart';

/// PaddleOCR v5 Service for text recognition
/// 
/// This service handles OCR operations using PaddleOCR v5
/// For Flutter integration, we use platform channels to communicate with native code
class PaddleOCRService extends GetxService {
  static const platform = MethodChannel('com.livetranslate.app/paddle_ocr');
  
  final RxBool isInitialized = false.obs;
  final RxBool isProcessing = false.obs;
  final RxDouble progress = 0.0.obs;
  
  /// Initialize PaddleOCR service
  Future<PaddleOCRService> init() async {
    try {
      Logger.log('Initializing PaddleOCR service...', tag: 'OCR');
      
      // Check if models are downloaded
      final modelsExist = await _checkModelsExist();
      
      if (!modelsExist) {
        Logger.warning('OCR models not found. Download required.', tag: 'OCR');
        isInitialized.value = false;
        return this;
      }
      
      // Initialize native OCR
      final result = await platform.invokeMethod('initOCR');
      
      if (result == true) {
        isInitialized.value = true;
        Logger.success('PaddleOCR initialized successfully', tag: 'OCR');
      } else {
        Logger.error('Failed to initialize PaddleOCR', tag: 'OCR');
      }
    } catch (e) {
      Logger.error('Error initializing PaddleOCR: $e', tag: 'OCR');
    }
    
    return this;
  }
  
  /// Check if OCR models exist locally
  Future<bool> _checkModelsExist() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final modelsDir = Directory('${appDir.path}/paddle_ocr_models');
      
      if (!await modelsDir.exists()) {
        return false;
      }
      
      // Check for required model files
      final detectionModel = File('${modelsDir.path}/ch_PP-OCRv4_det_infer.nb');
      final recognitionModel = File('${modelsDir.path}/ch_PP-OCRv4_rec_infer.nb');
      final clsModel = File('${modelsDir.path}/ch_ppocr_mobile_v2.0_cls_infer.nb');
      
      return await detectionModel.exists() && 
             await recognitionModel.exists() && 
             await clsModel.exists();
    } catch (e) {
      Logger.error('Error checking models: $e', tag: 'OCR');
      return false;
    }
  }
  
  /// Download OCR models
  Future<bool> downloadModels({Function(double)? onProgress}) async {
    try {
      Logger.log('Starting OCR models download...', tag: 'OCR');
      isProcessing.value = true;
      progress.value = 0.0;
      
      // In production, download from your server or CDN
      // For now, we'll simulate the download
      final appDir = await getApplicationDocumentsDirectory();
      final modelsDir = Directory('${appDir.path}/paddle_ocr_models');
      
      if (!await modelsDir.exists()) {
        await modelsDir.create(recursive: true);
      }
      
      // Simulate download progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        progress.value = i / 100;
        onProgress?.call(progress.value);
      }
      
      // Call native method to download models
      final result = await platform.invokeMethod('downloadModels', {
        'modelsPath': modelsDir.path,
      });
      
      isProcessing.value = false;
      
      if (result == true) {
        Logger.success('OCR models downloaded successfully', tag: 'OCR');
        await init(); // Re-initialize after download
        return true;
      }
      
      return false;
    } catch (e) {
      Logger.error('Error downloading models: $e', tag: 'OCR');
      isProcessing.value = false;
      return false;
    }
  }
  
  /// Perform OCR on an image with subscription check
  Future<OCRResult?> recognizeText(String imagePath, {
    String language = 'ch', // ch, en, ar, etc.
  }) async {
    if (!isInitialized.value) {
      Logger.warning('OCR not initialized', tag: 'OCR');
      return null;
    }
    
    // Check subscription status
    final canUse = await _checkSubscriptionAndUsage();
    if (!canUse) {
      return null;
    }
    
    try {
      Logger.log('Performing OCR on image: $imagePath', tag: 'OCR');
      isProcessing.value = true;
      
      final result = await platform.invokeMethod('recognizeText', {
        'imagePath': imagePath,
        'language': language,
      });
      
      isProcessing.value = false;
      
      if (result != null) {
        return OCRResult.fromMap(Map<String, dynamic>.from(result));
      }
      
      return null;
    } catch (e) {
      Logger.error('Error performing OCR: $e', tag: 'OCR');
      isProcessing.value = false;
      return null;
    }
  }
  
  /// Check subscription and usage limits
  Future<bool> _checkSubscriptionAndUsage() async {
    return await SubscriptionHelper.checkAndIncrementUsage(action: 'OCR');
  }
  
  /// Perform OCR on image bytes with subscription check
  Future<OCRResult?> recognizeFromBytes(Uint8List imageBytes, {
    String language = 'ch',
  }) async {
    if (!isInitialized.value) {
      Logger.warning('OCR not initialized', tag: 'OCR');
      return null;
    }
    
    // Check subscription status
    final canUse = await _checkSubscriptionAndUsage();
    if (!canUse) {
      return null;
    }
    
    try {
      Logger.log('Performing OCR on image bytes', tag: 'OCR');
      isProcessing.value = true;
      
      final result = await platform.invokeMethod('recognizeFromBytes', {
        'imageBytes': imageBytes,
        'language': language,
      });
      
      isProcessing.value = false;
      
      if (result != null) {
        return OCRResult.fromMap(Map<String, dynamic>.from(result));
      }
      
      return null;
    } catch (e) {
      Logger.error('Error performing OCR: $e', tag: 'OCR');
      isProcessing.value = false;
      return null;
    }
  }
  
  /// Get supported languages
  List<String> getSupportedLanguages() {
    return [
      'ch', // Chinese
      'en', // English
      'ar', // Arabic
      'fr', // French
      'de', // German
      'es', // Spanish
      'ja', // Japanese
      'ko', // Korean
    ];
  }
  
  /// Clean up resources
  Future<void> dispose() async {
    try {
      await platform.invokeMethod('disposeOCR');
      Logger.log('PaddleOCR disposed', tag: 'OCR');
    } catch (e) {
      Logger.error('Error disposing OCR: $e', tag: 'OCR');
    }
  }
}

/// OCR Result model
class OCRResult {
  final String text;
  final List<TextBlock> blocks;
  final double confidence;
  final int processingTime; // milliseconds
  
  OCRResult({
    required this.text,
    required this.blocks,
    required this.confidence,
    required this.processingTime,
  });
  
  factory OCRResult.fromMap(Map<String, dynamic> map) {
    return OCRResult(
      text: map['text'] ?? '',
      blocks: (map['blocks'] as List?)
          ?.map((b) => TextBlock.fromMap(Map<String, dynamic>.from(b)))
          .toList() ?? [],
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      processingTime: map['processingTime'] ?? 0,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'blocks': blocks.map((b) => b.toMap()).toList(),
      'confidence': confidence,
      'processingTime': processingTime,
    };
  }
}

/// Text block detected by OCR
class TextBlock {
  final String text;
  final double confidence;
  final List<Point> boundingBox;
  
  TextBlock({
    required this.text,
    required this.confidence,
    required this.boundingBox,
  });
  
  factory TextBlock.fromMap(Map<String, dynamic> map) {
    return TextBlock(
      text: map['text'] ?? '',
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      boundingBox: (map['boundingBox'] as List?)
          ?.map((p) => Point.fromMap(Map<String, dynamic>.from(p)))
          .toList() ?? [],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'confidence': confidence,
      'boundingBox': boundingBox.map((p) => p.toMap()).toList(),
    };
  }
}

/// Point in 2D space
class Point {
  final double x;
  final double y;
  
  Point(this.x, this.y);
  
  factory Point.fromMap(Map<String, dynamic> map) {
    return Point(
      (map['x'] ?? 0.0).toDouble(),
      (map['y'] ?? 0.0).toDouble(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {'x': x, 'y': y};
  }
}
