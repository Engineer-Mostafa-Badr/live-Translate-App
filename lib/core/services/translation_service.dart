import 'package:get/get.dart';
import '../utils/logger.dart';
import 'storage_service.dart';

/// Service for managing translation state and operations
class TranslationService extends GetxService {
  final StorageService _storage = Get.find<StorageService>();
  
  // Observable states
  final RxBool isTranslating = false.obs;
  final RxString sourceLanguage = 'العربية'.obs;
  final RxString targetLanguage = 'الإنجليزية'.obs;
  final RxBool autoTranslate = true.obs;
  final RxDouble translationProgress = 0.0.obs;
  final RxString detectedLanguage = ''.obs;
  final RxMap<String, String> translatedTexts = <String, String>{}.obs;
  
  // Translation history
  final RxList<TranslationHistory> history = <TranslationHistory>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }
  
  void _loadSettings() {
    sourceLanguage.value = _storage.sourceLanguage;
    targetLanguage.value = _storage.targetLanguage;
    autoTranslate.value = _storage.autoTranslate;
    isTranslating.value = _storage.translationEnabled;
    
    Logger.log('Translation settings loaded');
  }
  
  /// Toggle translation on/off
  Future<void> toggleTranslation() async {
    isTranslating.value = !isTranslating.value;
    await _storage.setTranslationEnabled(isTranslating.value);
    
    if (isTranslating.value) {
      Logger.log('Translation enabled');
      await startTranslation();
    } else {
      Logger.log('Translation disabled');
      stopTranslation();
    }
  }
  
  /// Start translation process
  Future<void> startTranslation() async {
    if (!isTranslating.value) return;
    
    Logger.log('Starting translation: $sourceLanguage → $targetLanguage');
    translationProgress.value = 0.0;
    
    // Simulate translation progress
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      translationProgress.value = i / 100;
    }
    
    Logger.success('Translation completed');
  }
  
  /// Stop translation
  void stopTranslation() {
    translationProgress.value = 0.0;
    Logger.log('Translation stopped');
  }
  
  /// Detect language of text
  String _detectLanguage(String text) {
    if (text.isEmpty) return 'en';
    
    // Simple language detection based on character patterns
    final arabicPattern = RegExp(r'[\u0600-\u06FF]');
    final chinesePattern = RegExp(r'[\u4E00-\u9FFF]');
    final japanesePattern = RegExp(r'[\u3040-\u309F\u30A0-\u30FF]');
    
    if (arabicPattern.hasMatch(text)) {
      detectedLanguage.value = 'ar';
      return 'ar';
    } else if (chinesePattern.hasMatch(text)) {
      detectedLanguage.value = 'zh';
      return 'zh';
    } else if (japanesePattern.hasMatch(text)) {
      detectedLanguage.value = 'ja';
      return 'ja';
    }
    
    detectedLanguage.value = 'en';
    return 'en';
  }
  
  /// Translate text with automatic language detection (Online only)
  Future<String> translateText(String text, {String? fromLanguage}) async {
    if (text.isEmpty) return '';
    
    final from = fromLanguage ?? _detectLanguage(text);
    final to = _getLanguageCode(targetLanguage.value);
    
    Logger.log('Translating (Online): ${text.substring(0, text.length > 50 ? 50 : text.length)}... ($from → $to)');
    
    try {
      // Call Google Translate API or similar online service
      final translatedText = await _callOnlineTranslationAPI(text, from, to);
      
      // Store translated text
      translatedTexts[text] = translatedText;
      
      // Add to history
      addToHistory(text, translatedText);
      
      return translatedText;
    } catch (e) {
      Logger.error('Translation error: $e');
      return text; // Return original text on error
    }
  }
  
  /// Call online translation API (Google Translate or similar)
  Future<String> _callOnlineTranslationAPI(String text, String from, String to) async {
    try {
      // TODO: Implement actual API call to Google Translate, Microsoft Translator, or similar
      // For now, simulate the API call
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Placeholder: In production, replace with actual API call
      Logger.log('Calling online translation API: $from → $to');
      
      // Simulated response
      return '[Translated from $from to $to]: $text';
    } catch (e) {
      Logger.error('Online translation API error: $e');
      rethrow;
    }
  }
  
  /// Translate image text (OCR + Translation)
  Future<Map<String, String>> translateImageText(List<String> extractedTexts) async {
    final Map<String, String> translations = {};
    
    for (final text in extractedTexts) {
      if (text.isNotEmpty) {
        final translated = await translateText(text);
        translations[text] = translated;
      }
    }
    
    return translations;
  }
  
  /// Get language code from language name
  String _getLanguageCode(String languageName) {
    final languageCodes = {
      'العربية': 'ar',
      'الإنجليزية': 'en',
      'الفرنسية': 'fr',
      'الإسبانية': 'es',
      'الألمانية': 'de',
      'الصينية': 'zh',
      'اليابانية': 'ja',
      'الكورية': 'ko',
      'الروسية': 'ru',
      'البرتغالية': 'pt',
      'الإيطالية': 'it',
      'الهندية': 'hi',
      'التركية': 'tr',
      'الهولندية': 'nl',
      'السويدية': 'sv',
    };
    return languageCodes[languageName] ?? 'en';
  }
  
  /// Translate page content
  Future<Map<String, String>> translatePageContent(List<String> texts) async {
    final Map<String, String> translations = {};
    
    for (final text in texts) {
      final translated = await translateText(text);
      translations[text] = translated;
    }
    
    return translations;
  }
  
  /// Change source language
  Future<void> setSourceLanguage(String language) async {
    sourceLanguage.value = language;
    await _storage.setSourceLanguage(language);
    Logger.log('Source language changed to: $language');
    
    if (isTranslating.value && autoTranslate.value) {
      await startTranslation();
    }
  }
  
  /// Change target language
  Future<void> setTargetLanguage(String language) async {
    targetLanguage.value = language;
    await _storage.setTargetLanguage(language);
    Logger.log('Target language changed to: $language');
    
    if (isTranslating.value && autoTranslate.value) {
      await startTranslation();
    }
  }
  
  /// Toggle auto translate
  Future<void> setAutoTranslate(bool value) async {
    autoTranslate.value = value;
    await _storage.setAutoTranslate(value);
    Logger.log('Auto translate: $value');
  }
  
  /// Add to history
  void addToHistory(String originalText, String translatedText) {
    final historyItem = TranslationHistory(
      originalText: originalText,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage.value,
      targetLanguage: targetLanguage.value,
      timestamp: DateTime.now(),
    );
    
    history.insert(0, historyItem);
    
    // Keep only last 100 items
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }
    
    Logger.log('Added to translation history');
  }
  
  /// Clear history
  void clearHistory() {
    history.clear();
    Logger.log('Translation history cleared');
  }
  
  /// Get available languages
  List<String> getAvailableLanguages() {
    return [
      'العربية',
      'الإنجليزية',
      'الفرنسية',
      'الإسبانية',
      'الألمانية',
      'الصينية',
      'اليابانية',
      'الكورية',
      'الروسية',
      'البرتغالية',
      'الإيطالية',
      'الهندية',
      'التركية',
      'الهولندية',
      'السويدية',
    ];
  }
}

/// Translation history model
class TranslationHistory {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;
  
  TranslationHistory({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'originalText': originalText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory TranslationHistory.fromJson(Map<String, dynamic> json) {
    return TranslationHistory(
      originalText: json['originalText'],
      translatedText: json['translatedText'],
      sourceLanguage: json['sourceLanguage'],
      targetLanguage: json['targetLanguage'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
