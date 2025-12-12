import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/logger.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/translation_service.dart';

class BrowserController extends GetxController {
  final TextEditingController urlController = TextEditingController();
  final StorageService _storage = Get.find<StorageService>();
  final TranslationService _translation = Get.find<TranslationService>();
  
  WebViewController? webViewController;
  
  final RxBool isLoading = false.obs;
  final RxBool canGoBack = false.obs;
  final RxBool canGoForward = false.obs;
  final RxString pageTitle = ''.obs;
  final RxString currentUrl = ''.obs;
  final RxDouble scrollPosition = 0.0.obs;
  final RxBool showScrollToTop = false.obs;
  final RxDouble loadingProgress = 0.0.obs;
  final RxBool isDesktopSite = false.obs;
  final RxBool showTranslationNotification = false.obs;
  final RxBool showTranslationBar = false.obs;
  final RxString detectedPageLanguage = ''.obs;
  
  // Translation state from service
  RxBool get isTranslating => _translation.isTranslating;
  
  @override
  void onInit() {
    super.onInit();
    _initializeWebView();
    _loadLastVisitedUrl();
  }
  
  void _initializeWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            isLoading.value = true;
            loadingProgress.value = 0.0;
            currentUrl.value = url;
            Logger.log('Page started loading: $url');
          },
          onProgress: (progress) {
            loadingProgress.value = progress / 100.0;
          },
          onPageFinished: (url) async {
            isLoading.value = false;
            loadingProgress.value = 1.0;
            urlController.text = url;
            currentUrl.value = url;
            
            // Save last visited URL
            await _storage.setLastVisitedUrl(url);
            
            // Get page title
            final title = await webViewController?.getTitle();
            if (title != null) {
              pageTitle.value = title;
            }
            
            // Update navigation buttons
            canGoBack.value = await webViewController?.canGoBack() ?? false;
            canGoForward.value = await webViewController?.canGoForward() ?? false;
            
            // Setup scroll listener
            _setupScrollListener();
            
            Logger.success('Page loaded: $url');
            
            // Detect page language and show translation bar if needed
            await _detectPageLanguage();
            
            // Apply translation if active
            if (isTranslating.value) {
              await _applyTranslation();
            }
          },
          onWebResourceError: (error) {
            Logger.error('WebView error: ${error.description}');
            Get.snackbar(
              'خطأ',
              'فشل تحميل الصفحة',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      );
  }
  
  void _loadLastVisitedUrl() {
    final lastUrl = _storage.lastVisitedUrl;
    if (lastUrl.isNotEmpty) {
      urlController.text = lastUrl;
      Logger.log('Last visited URL loaded: $lastUrl');
    }
  }
  
  /// Detect page language and show translation bar if different from target
  Future<void> _detectPageLanguage() async {
    try {
      // Get page language from HTML lang attribute or meta tags
      final langResult = await webViewController?.runJavaScriptReturningResult('''
        (function() {
          var lang = document.documentElement.lang || 
                     document.querySelector('meta[http-equiv="content-language"]')?.content ||
                     document.querySelector('meta[name="language"]')?.content ||
                     '';
          
          // If no lang attribute, try to detect from content
          if (!lang) {
            var text = document.body.innerText.substring(0, 500);
            // Simple detection based on character patterns
            if (/[\u0600-\u06FF]/.test(text)) lang = 'ar';
            else if (/[\u4E00-\u9FFF]/.test(text)) lang = 'zh';
            else if (/[\u3040-\u309F\u30A0-\u30FF]/.test(text)) lang = 'ja';
            else if (/[\uAC00-\uD7AF]/.test(text)) lang = 'ko';
            else lang = 'en';
          }
          
          return lang.substring(0, 2).toLowerCase();
        })();
      ''');
      
      final detectedLang = langResult?.toString().replaceAll('"', '') ?? 'en';
      detectedPageLanguage.value = detectedLang;
      _translation.detectedLanguage.value = detectedLang;
      
      Logger.log('Detected page language: $detectedLang');
      
      // Get user's preferred language code
      final userLangCode = _getLanguageCode(_translation.targetLanguage.value);
      
      // Show translation bar if page language differs from user's target language
      // and auto-translate is enabled
      if (detectedLang != userLangCode && _translation.autoTranslate.value) {
        showTranslationBar.value = true;
        Logger.log('Translation bar shown - page: $detectedLang, target: $userLangCode');
      }
    } catch (e) {
      Logger.error('Error detecting page language: $e');
    }
  }
  
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
  
  /// Dismiss translation bar
  void dismissTranslationBar() {
    showTranslationBar.value = false;
  }
  
  void _setupScrollListener() {
    // Inject JavaScript to monitor scroll position
    webViewController?.runJavaScript('''
      window.addEventListener('scroll', function() {
        var scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        var scrollHeight = document.documentElement.scrollHeight;
        var clientHeight = document.documentElement.clientHeight;
        var scrollPercent = (scrollTop / (scrollHeight - clientHeight)) * 100;
        
        // Send scroll position to Flutter
        window.flutter_inappwebview.callHandler('scrollPosition', scrollTop, scrollPercent);
      });
    ''');
    
    Logger.log('Scroll listener setup complete');
  }
  
  void onScroll(double position, double percent) {
    scrollPosition.value = position;
    showScrollToTop.value = position > 200;
    
    // Save scroll position periodically
    if (position % 100 == 0) {
      _storage.setScrollPosition(position);
    }
  }
  
  void scrollToTop() async {
    await webViewController?.runJavaScript('''
      window.scrollTo({top: 0, behavior: 'smooth'});
    ''');
    Logger.log('Scrolled to top');
  }
  
  void loadUrl(String url) {
    if (url.isEmpty) return;
    
    // Add https:// if not present
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    
    Logger.log('Loading URL: $url');
    webViewController?.loadRequest(Uri.parse(url));
  }
  
  void goBack() async {
    if (await webViewController?.canGoBack() ?? false) {
      webViewController?.goBack();
    }
  }
  
  void goForward() async {
    if (await webViewController?.canGoForward() ?? false) {
      webViewController?.goForward();
    }
  }
  
  @override
  void refresh() {
    webViewController?.reload();
    Logger.log('Page refreshed');
  }
  
  void clearUrl() {
    urlController.clear();
  }
  
  void toggleTranslation() async {
    await _translation.toggleTranslation();
    
    if (isTranslating.value) {
      await _applyTranslation();
      // Show temporary notification
      showTranslationNotification.value = true;
      Future.delayed(const Duration(seconds: 3), () {
        showTranslationNotification.value = false;
      });
    } else {
      _removeTranslation();
      Get.snackbar(
        'تم الإيقاف',
        'تم إيقاف الترجمة الحية',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  Future<void> _applyTranslation() async {
    Logger.log('Applying translation to current page');
    
    // Start translation service (online only)
    await _translation.startTranslation();
    
    Logger.success('Translation started - Online service active');
  }
  
  void _removeTranslation() {
    Logger.log('Translation stopped');
  }
  
  void openSettings() {
    Get.toNamed(AppRoutes.settings);
  }
  
  void voiceSearch() {
    Get.snackbar(
      'Voice Search',
      'Voice search feature coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void toggleDesktopSite() {
    isDesktopSite.value = !isDesktopSite.value;
    
    // Set user agent
    final userAgent = isDesktopSite.value
        ? 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        : null;
    
    webViewController?.setUserAgent(userAgent);
    refresh();
    
    Get.snackbar(
      isDesktopSite.value ? 'Desktop Site' : 'Mobile Site',
      isDesktopSite.value ? 'Switched to desktop site' : 'Switched to mobile site',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void newTab() {
    Get.snackbar(
      'New Tab',
      'Multiple tabs feature coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void newIncognitoTab() {
    Get.snackbar(
      'Incognito Tab',
      'Incognito mode coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void openBookmarks() {
    Get.snackbar(
      'Bookmarks',
      'Bookmarks feature coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void openHistory() {
    Get.snackbar(
      'History',
      'History feature coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void openDownloads() {
    Get.snackbar(
      'Downloads',
      'Downloads feature coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void sharePage() {
    Get.snackbar(
      'Share',
      'Share feature coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void findInPage() {
    Get.snackbar(
      'Find in Page',
      'Find in page feature coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void onMenuSelected([String? value]) {
    // Menu is now handled by ChromeMenu widget in browser_page
  }
  
  void dismissTranslationNotification() {
    showTranslationNotification.value = false;
  }
  
  @override
  void onClose() {
    urlController.dispose();
    super.onClose();
  }
}
