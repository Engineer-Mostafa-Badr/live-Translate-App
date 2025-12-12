import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import '../utils/subscription_helper.dart';

/// Offline Translation Service
/// 
/// Provides translation capabilities without internet connection
/// Uses local dictionaries and ML models for translation
class OfflineTranslationService extends GetxService {
  static const platform = MethodChannel('com.livetranslate.app/offline_translation');
  
  final RxBool isInitialized = false.obs;
  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final RxMap<String, bool> downloadedLanguages = <String, bool>{}.obs;
  
  // Local dictionary cache
  final Map<String, Map<String, String>> _dictionaries = {};
  
  /// Initialize offline translation service
  Future<OfflineTranslationService> init() async {
    try {
      Logger.log('Initializing offline translation service...', tag: 'OFFLINE_TRANS');
      
      // Load downloaded languages info
      await _loadDownloadedLanguages();
      
      // Initialize native translation engine if available
      try {
        final result = await platform.invokeMethod('initTranslation');
        if (result == true) {
          Logger.success('Native translation engine initialized', tag: 'OFFLINE_TRANS');
        }
      } catch (e) {
        Logger.warning('Native translation not available, using fallback', tag: 'OFFLINE_TRANS');
      }
      
      isInitialized.value = true;
      Logger.success('Offline translation service initialized', tag: 'OFFLINE_TRANS');
    } catch (e) {
      Logger.error('Error initializing offline translation: $e', tag: 'OFFLINE_TRANS');
    }
    
    return this;
  }
  
  /// Load information about downloaded language packs
  Future<void> _loadDownloadedLanguages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languagesJson = prefs.getString('downloaded_languages');
      
      if (languagesJson != null) {
        final Map<String, dynamic> languages = json.decode(languagesJson);
        downloadedLanguages.value = languages.map(
          (key, value) => MapEntry(key, value as bool),
        );
      }
      
      // Verify files exist
      for (final lang in downloadedLanguages.keys.toList()) {
        final exists = await _checkLanguagePackExists(lang);
        if (!exists) {
          downloadedLanguages.remove(lang);
        }
      }
      
      await _saveDownloadedLanguages();
    } catch (e) {
      Logger.error('Error loading downloaded languages: $e', tag: 'OFFLINE_TRANS');
    }
  }
  
  /// Save downloaded languages info
  Future<void> _saveDownloadedLanguages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'downloaded_languages',
        json.encode(downloadedLanguages),
      );
    } catch (e) {
      Logger.error('Error saving downloaded languages: $e', tag: 'OFFLINE_TRANS');
    }
  }
  
  /// Check if language pack exists
  Future<bool> _checkLanguagePackExists(String languageCode) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final langFile = File('${appDir.path}/translations/$languageCode.json');
      return await langFile.exists();
    } catch (e) {
      return false;
    }
  }
  
  /// Download language pack
  Future<bool> downloadLanguagePack(
    String languageCode, {
    Function(double)? onProgress,
  }) async {
    try {
      Logger.log('Downloading language pack: $languageCode', tag: 'OFFLINE_TRANS');
      isDownloading.value = true;
      downloadProgress.value = 0.0;
      
      final appDir = await getApplicationDocumentsDirectory();
      final translationsDir = Directory('${appDir.path}/translations');
      
      if (!await translationsDir.exists()) {
        await translationsDir.create(recursive: true);
      }
      
      // In production, download from your server
      // For now, simulate download
      for (int i = 0; i <= 100; i += 5) {
        await Future.delayed(const Duration(milliseconds: 100));
        downloadProgress.value = i / 100;
        onProgress?.call(downloadProgress.value);
      }
      
      // Create sample dictionary file
      final langFile = File('${translationsDir.path}/$languageCode.json');
      final sampleDict = {
        'hello': _getTranslation('hello', languageCode),
        'goodbye': _getTranslation('goodbye', languageCode),
        'thank you': _getTranslation('thank you', languageCode),
        'welcome': _getTranslation('welcome', languageCode),
        // Add more translations...
      };
      
      await langFile.writeAsString(json.encode(sampleDict));
      
      // Mark as downloaded
      downloadedLanguages[languageCode] = true;
      await _saveDownloadedLanguages();
      
      isDownloading.value = false;
      Logger.success('Language pack downloaded: $languageCode', tag: 'OFFLINE_TRANS');
      
      return true;
    } catch (e) {
      Logger.error('Error downloading language pack: $e', tag: 'OFFLINE_TRANS');
      isDownloading.value = false;
      return false;
    }
  }
  
  /// Helper to get sample translations
  String _getTranslation(String word, String languageCode) {
    final translations = {
      'ar': {
        'hello': 'مرحبا',
        'goodbye': 'وداعا',
        'thank you': 'شكرا',
        'welcome': 'أهلا وسهلا',
      },
      'en': {
        'hello': 'Hello',
        'goodbye': 'Goodbye',
        'thank you': 'Thank you',
        'welcome': 'Welcome',
      },
      'fr': {
        'hello': 'Bonjour',
        'goodbye': 'Au revoir',
        'thank you': 'Merci',
        'welcome': 'Bienvenue',
      },
      'es': {
        'hello': 'Hola',
        'goodbye': 'Adiós',
        'thank you': 'Gracias',
        'welcome': 'Bienvenido',
      },
    };
    
    return translations[languageCode]?[word] ?? word;
  }
  
  /// Translate text offline with subscription check
  Future<String?> translate(
    String text, {
    required String from,
    required String to,
  }) async {
    if (!isInitialized.value) {
      Logger.warning('Offline translation not initialized', tag: 'OFFLINE_TRANS');
      return null;
    }
    
    // Check subscription status (only for non-premium users)
    final canUse = await _checkSubscriptionAndUsage();
    if (!canUse) {
      return null;
    }
    
    // Check if language packs are downloaded
    if (!isLanguageDownloaded(from) || !isLanguageDownloaded(to)) {
      Logger.warning('Language packs not downloaded: $from -> $to', tag: 'OFFLINE_TRANS');
      return null;
    }
    
    try {
      Logger.log('Translating offline: $from -> $to', tag: 'OFFLINE_TRANS');
      
      // Try native translation first
      try {
        final result = await platform.invokeMethod('translate', {
          'text': text,
          'from': from,
          'to': to,
        });
        
        if (result != null) {
          return result as String;
        }
      } catch (e) {
        Logger.warning('Native translation failed, using dictionary', tag: 'OFFLINE_TRANS');
      }
      
      // Fallback to dictionary-based translation
      return await _dictionaryTranslate(text, from, to);
    } catch (e) {
      Logger.error('Error translating offline: $e', tag: 'OFFLINE_TRANS');
      return null;
    }
  }
  
  /// Check subscription and usage limits for translation
  Future<bool> _checkSubscriptionAndUsage() async {
    return await SubscriptionHelper.checkAndIncrementUsage(action: 'Translation');
  }
  
  /// Dictionary-based translation (fallback)
  Future<String?> _dictionaryTranslate(String text, String from, String to) async {
    try {
      // Load dictionaries if not cached
      if (!_dictionaries.containsKey('$from-$to')) {
        await _loadDictionary(from, to);
      }
      
      final dict = _dictionaries['$from-$to'];
      if (dict == null) return null;
      
      // Simple word-by-word translation
      final words = text.toLowerCase().split(' ');
      final translated = words.map((word) {
        return dict[word] ?? word;
      }).join(' ');
      
      return translated;
    } catch (e) {
      Logger.error('Error in dictionary translation: $e', tag: 'OFFLINE_TRANS');
      return null;
    }
  }
  
  /// Load dictionary from file
  Future<void> _loadDictionary(String from, String to) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dictFile = File('${appDir.path}/translations/${from}_$to.json');
      
      if (await dictFile.exists()) {
        final content = await dictFile.readAsString();
        final Map<String, dynamic> data = json.decode(content);
        _dictionaries['$from-$to'] = data.map(
          (key, value) => MapEntry(key, value.toString()),
        );
      }
    } catch (e) {
      Logger.error('Error loading dictionary: $e', tag: 'OFFLINE_TRANS');
    }
  }
  
  /// Check if language is downloaded
  bool isLanguageDownloaded(String languageCode) {
    return downloadedLanguages[languageCode] == true;
  }
  
  /// Get list of available languages for download
  List<LanguagePack> getAvailableLanguages() {
    return [
      LanguagePack(
        code: 'ar',
        name: 'العربية',
        nativeName: 'Arabic',
        size: '45 MB',
        isDownloaded: isLanguageDownloaded('ar'),
      ),
      LanguagePack(
        code: 'en',
        name: 'الإنجليزية',
        nativeName: 'English',
        size: '42 MB',
        isDownloaded: isLanguageDownloaded('en'),
      ),
      LanguagePack(
        code: 'fr',
        name: 'الفرنسية',
        nativeName: 'French',
        size: '43 MB',
        isDownloaded: isLanguageDownloaded('fr'),
      ),
      LanguagePack(
        code: 'es',
        name: 'الإسبانية',
        nativeName: 'Spanish',
        size: '44 MB',
        isDownloaded: isLanguageDownloaded('es'),
      ),
      LanguagePack(
        code: 'de',
        name: 'الألمانية',
        nativeName: 'German',
        size: '46 MB',
        isDownloaded: isLanguageDownloaded('de'),
      ),
      LanguagePack(
        code: 'zh',
        name: 'الصينية',
        nativeName: 'Chinese',
        size: '50 MB',
        isDownloaded: isLanguageDownloaded('zh'),
      ),
      LanguagePack(
        code: 'ja',
        name: 'اليابانية',
        nativeName: 'Japanese',
        size: '48 MB',
        isDownloaded: isLanguageDownloaded('ja'),
      ),
      LanguagePack(
        code: 'ko',
        name: 'الكورية',
        nativeName: 'Korean',
        size: '47 MB',
        isDownloaded: isLanguageDownloaded('ko'),
      ),
    ];
  }
  
  /// Delete language pack
  Future<bool> deleteLanguagePack(String languageCode) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final langFile = File('${appDir.path}/translations/$languageCode.json');
      
      if (await langFile.exists()) {
        await langFile.delete();
      }
      
      downloadedLanguages.remove(languageCode);
      _dictionaries.remove(languageCode);
      await _saveDownloadedLanguages();
      
      Logger.success('Language pack deleted: $languageCode', tag: 'OFFLINE_TRANS');
      return true;
    } catch (e) {
      Logger.error('Error deleting language pack: $e', tag: 'OFFLINE_TRANS');
      return false;
    }
  }
  
  /// Get total size of downloaded language packs
  Future<int> getTotalDownloadedSize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final translationsDir = Directory('${appDir.path}/translations');
      
      if (!await translationsDir.exists()) {
        return 0;
      }
      
      int totalSize = 0;
      await for (final entity in translationsDir.list()) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}

/// Language Pack model
class LanguagePack {
  final String code;
  final String name;
  final String nativeName;
  final String size;
  final bool isDownloaded;
  
  LanguagePack({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.size,
    required this.isDownloaded,
  });
}
