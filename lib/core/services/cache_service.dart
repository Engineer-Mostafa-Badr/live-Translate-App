import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Service to cache OCR and translation results
class CacheService extends GetxService {
  static const String OCR_CACHE_PREFIX = 'ocr_cache_';
  static const String TRANSLATION_CACHE_PREFIX = 'translation_cache_';
  static const int MAX_CACHE_AGE_DAYS = 7;
  static const int MAX_CACHE_ITEMS = 100;
  
  SharedPreferences? _prefs;
  
  @override
  Future<CacheService> onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    await _cleanOldCache();
    return this;
  }
  
  /// Cache OCR result
  Future<void> cacheOCRResult(String imageHash, Map<String, dynamic> result) async {
    try {
      final key = '$OCR_CACHE_PREFIX$imageHash';
      final cacheData = {
        'result': result,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await _prefs?.setString(key, jsonEncode(cacheData));
      Logger.log('OCR result cached: $imageHash', tag: 'CACHE');
      
      // Clean up if too many items
      await _limitCacheSize(OCR_CACHE_PREFIX);
    } catch (e) {
      Logger.error('Error caching OCR result: $e', tag: 'CACHE');
    }
  }
  
  /// Get cached OCR result
  Map<String, dynamic>? getCachedOCRResult(String imageHash) {
    try {
      final key = '$OCR_CACHE_PREFIX$imageHash';
      final cachedString = _prefs?.getString(key);
      
      if (cachedString == null) {
        return null;
      }
      
      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      final maxAge = Duration(days: MAX_CACHE_AGE_DAYS).inMilliseconds;
      
      if (age > maxAge) {
        // Cache expired
        _prefs?.remove(key);
        Logger.log('OCR cache expired: $imageHash', tag: 'CACHE');
        return null;
      }
      
      Logger.log('OCR cache hit: $imageHash', tag: 'CACHE');
      return cacheData['result'] as Map<String, dynamic>;
    } catch (e) {
      Logger.error('Error getting cached OCR result: $e', tag: 'CACHE');
      return null;
    }
  }
  
  /// Cache translation result
  Future<void> cacheTranslation(
    String text,
    String fromLang,
    String toLang,
    String translation,
  ) async {
    try {
      final key = _getTranslationKey(text, fromLang, toLang);
      final cacheData = {
        'translation': translation,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await _prefs?.setString(key, jsonEncode(cacheData));
      Logger.log('Translation cached: ${text.substring(0, 20)}...', tag: 'CACHE');
      
      // Clean up if too many items
      await _limitCacheSize(TRANSLATION_CACHE_PREFIX);
    } catch (e) {
      Logger.error('Error caching translation: $e', tag: 'CACHE');
    }
  }
  
  /// Get cached translation
  String? getCachedTranslation(String text, String fromLang, String toLang) {
    try {
      final key = _getTranslationKey(text, fromLang, toLang);
      final cachedString = _prefs?.getString(key);
      
      if (cachedString == null) {
        return null;
      }
      
      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      final maxAge = Duration(days: MAX_CACHE_AGE_DAYS).inMilliseconds;
      
      if (age > maxAge) {
        // Cache expired
        _prefs?.remove(key);
        Logger.log('Translation cache expired', tag: 'CACHE');
        return null;
      }
      
      Logger.log('Translation cache hit', tag: 'CACHE');
      return cacheData['translation'] as String;
    } catch (e) {
      Logger.error('Error getting cached translation: $e', tag: 'CACHE');
      return null;
    }
  }
  
  /// Generate translation cache key
  String _getTranslationKey(String text, String fromLang, String toLang) {
    final hash = text.hashCode;
    return '$TRANSLATION_CACHE_PREFIX${fromLang}_${toLang}_$hash';
  }
  
  /// Clean old cache entries
  Future<void> _cleanOldCache() async {
    try {
      final keys = _prefs?.getKeys() ?? {};
      final now = DateTime.now().millisecondsSinceEpoch;
      final maxAge = Duration(days: MAX_CACHE_AGE_DAYS).inMilliseconds;
      int removed = 0;
      
      for (final key in keys) {
        if (key.startsWith(OCR_CACHE_PREFIX) || key.startsWith(TRANSLATION_CACHE_PREFIX)) {
          final cachedString = _prefs?.getString(key);
          if (cachedString != null) {
            try {
              final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
              final timestamp = cacheData['timestamp'] as int;
              final age = now - timestamp;
              
              if (age > maxAge) {
                await _prefs?.remove(key);
                removed++;
              }
            } catch (e) {
              // Invalid cache entry, remove it
              await _prefs?.remove(key);
              removed++;
            }
          }
        }
      }
      
      if (removed > 0) {
        Logger.log('Cleaned $removed old cache entries', tag: 'CACHE');
      }
    } catch (e) {
      Logger.error('Error cleaning old cache: $e', tag: 'CACHE');
    }
  }
  
  /// Limit cache size to prevent excessive storage usage
  Future<void> _limitCacheSize(String prefix) async {
    try {
      final keys = _prefs?.getKeys() ?? {};
      final cacheKeys = keys.where((k) => k.startsWith(prefix)).toList();
      
      if (cacheKeys.length > MAX_CACHE_ITEMS) {
        // Sort by timestamp and remove oldest
        final cacheEntries = <String, int>{};
        
        for (final key in cacheKeys) {
          final cachedString = _prefs?.getString(key);
          if (cachedString != null) {
            try {
              final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
              cacheEntries[key] = cacheData['timestamp'] as int;
            } catch (e) {
              // Invalid entry, will be removed
              cacheEntries[key] = 0;
            }
          }
        }
        
        // Sort by timestamp
        final sortedKeys = cacheEntries.keys.toList()
          ..sort((a, b) => cacheEntries[a]!.compareTo(cacheEntries[b]!));
        
        // Remove oldest entries
        final toRemove = cacheKeys.length - MAX_CACHE_ITEMS;
        for (int i = 0; i < toRemove; i++) {
          await _prefs?.remove(sortedKeys[i]);
        }
        
        Logger.log('Removed $toRemove old cache entries to limit size', tag: 'CACHE');
      }
    } catch (e) {
      Logger.error('Error limiting cache size: $e', tag: 'CACHE');
    }
  }
  
  /// Clear all OCR cache
  Future<void> clearOCRCache() async {
    try {
      final keys = _prefs?.getKeys() ?? {};
      int removed = 0;
      
      for (final key in keys) {
        if (key.startsWith(OCR_CACHE_PREFIX)) {
          await _prefs?.remove(key);
          removed++;
        }
      }
      
      Logger.success('Cleared $removed OCR cache entries', tag: 'CACHE');
    } catch (e) {
      Logger.error('Error clearing OCR cache: $e', tag: 'CACHE');
    }
  }
  
  /// Clear all translation cache
  Future<void> clearTranslationCache() async {
    try {
      final keys = _prefs?.getKeys() ?? {};
      int removed = 0;
      
      for (final key in keys) {
        if (key.startsWith(TRANSLATION_CACHE_PREFIX)) {
          await _prefs?.remove(key);
          removed++;
        }
      }
      
      Logger.success('Cleared $removed translation cache entries', tag: 'CACHE');
    } catch (e) {
      Logger.error('Error clearing translation cache: $e', tag: 'CACHE');
    }
  }
  
  /// Clear all cache
  Future<void> clearAllCache() async {
    await clearOCRCache();
    await clearTranslationCache();
  }
  
  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    try {
      final keys = _prefs?.getKeys() ?? {};
      int ocrCount = 0;
      int translationCount = 0;
      
      for (final key in keys) {
        if (key.startsWith(OCR_CACHE_PREFIX)) {
          ocrCount++;
        } else if (key.startsWith(TRANSLATION_CACHE_PREFIX)) {
          translationCount++;
        }
      }
      
      return {
        'ocr_cache_count': ocrCount,
        'translation_cache_count': translationCount,
        'total_cache_count': ocrCount + translationCount,
      };
    } catch (e) {
      Logger.error('Error getting cache stats: $e', tag: 'CACHE');
      return {
        'ocr_cache_count': 0,
        'translation_cache_count': 0,
        'total_cache_count': 0,
      };
    }
  }
}
