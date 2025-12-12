import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'browser_controller.dart';
import '../../widgets/text_analysis_widget.dart';
import '../../widgets/chrome_url_bar.dart';
import '../../widgets/chrome_bottom_nav.dart';
import '../../widgets/chrome_menu.dart';
import '../../widgets/chrome_translation_bar.dart';
import '../../widgets/translation_badge.dart';

class BrowserPage extends GetView<BrowserController> {
  const BrowserPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(BrowserController());
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Chrome-style URL Bar
            Obx(() => ChromeUrlBar(
                  controller: controller.urlController,
                  onSubmitted: () => controller.loadUrl(controller.urlController.text),
                  onRefresh: controller.refresh,
                  onClear: controller.clearUrl,
                  onMicrophone: controller.voiceSearch,
                  isLoading: controller.isLoading.value,
                  pageTitle: controller.pageTitle.value,
                  currentUrl: controller.currentUrl.value,
                  loadingProgress: controller.loadingProgress.value,
                )),
            
            // Chrome-style Translation Bar (Google Translate style)
            Obx(() => controller.showTranslationBar.value
                ? ChromeTranslationBar(
                    onTranslate: controller.toggleTranslation,
                    onDismiss: controller.dismissTranslationBar,
                  )
                : const SizedBox.shrink()),
            
            // WebView with Pull-to-Refresh
            Expanded(
              child: controller.webViewController == null
                  ? _buildEmptyState(context)
                  : RefreshIndicator(
                      onRefresh: () async {
                        controller.refresh();
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: _buildWebViewStack(),
                    ),
            ),
          ],
        ),
      ),
      
      // Chrome-style Bottom Navigation
      bottomNavigationBar: Obx(() => ChromeBottomNav(
            onBack: controller.goBack,
            onForward: controller.goForward,
            onHome: () => controller.loadUrl('https://www.google.com'),
            onTabs: () => Get.snackbar('Tabs', 'Tabs feature coming soon'),
            onNewTab: controller.newTab,
            onMenu: () => _showChromeMenu(context),
            canGoBack: controller.canGoBack.value,
            canGoForward: controller.canGoForward.value,
            tabCount: 1,
          )),
      
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.public,
            size: 80.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'Search or type URL',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWebViewStack() {
    return Builder(
      builder: (context) => Stack(
        children: [
          // WebView
          WebViewWidget(
            controller: controller.webViewController!,
          ),
          
          // Text Analysis Widget (Center)
          const Positioned.fill(
            child: TextAnalysisWidget(),
          ),
          
          // Translation Badge Indicator
          Obx(() => TranslationBadge(
                isActive: controller.isTranslating.value,
                sourceLanguage: 'EN',
                targetLanguage: 'AR',
              )),
          
          // Translation Activated Notification
          Obx(() => controller.showTranslationNotification.value
              ? TranslationActivatedNotification(
                  onDismiss: controller.dismissTranslationNotification,
                )
              : const SizedBox.shrink()),
          
          // Scroll to Top Button
          Obx(() => controller.showScrollToTop.value
              ? Positioned(
                  bottom: 80.h,
                  right: 16.w,
                  child: FloatingActionButton.small(
                    onPressed: controller.scrollToTop,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    tooltip: 'Scroll to top',
                    child: const Icon(Icons.arrow_upward),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
  
  void _showChromeMenu(BuildContext context) {
    ChromeMenu.show(
      context,
      onNewTab: controller.newTab,
      onNewIncognitoTab: controller.newIncognitoTab,
      onBookmarks: controller.openBookmarks,
      onHistory: controller.openHistory,
      onDownloads: controller.openDownloads,
      onSettings: controller.openSettings,
      onShare: controller.sharePage,
      onFindInPage: controller.findInPage,
      onDesktopSite: controller.toggleDesktopSite,
      onTranslate: controller.toggleTranslation,
      isDesktopSite: controller.isDesktopSite.value,
      isTranslating: controller.isTranslating.value,
    );
  }
  
}
