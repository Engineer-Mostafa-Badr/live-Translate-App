import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/services/translation_service.dart';

/// Chrome-style translation bar that appears at the top of the page
/// Similar to Google Chrome's automatic translation prompt
class ChromeTranslationBar extends StatelessWidget {
  final VoidCallback? onTranslate;
  final VoidCallback? onDismiss;
  final VoidCallback? onOptions;
  
  const ChromeTranslationBar({
    super.key,
    this.onTranslate,
    this.onDismiss,
    this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    final translation = Get.find<TranslationService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Obx(() {
      // Show bar when translation is detected or active
      if (!translation.isTranslating.value && translation.detectedLanguage.value.isEmpty) {
        return const SizedBox.shrink();
      }
      
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F3F4),
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Google Translate Icon with animation
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: isDark ? Colors.blue.shade800 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.g_translate,
                size: 18.sp,
                color: Colors.blue,
              ),
            ),
            
            SizedBox(width: 12.w),
            
            // Translation Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => Text(
                    translation.isTranslating.value
                        ? 'تمت الترجمة إلى ${translation.targetLanguage.value}'
                        : 'هل تريد ترجمة هذه الصفحة؟',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  )),
                  SizedBox(height: 3.h),
                  Obx(() => Text(
                    translation.isTranslating.value
                        ? '${translation.sourceLanguage.value} → ${translation.targetLanguage.value}'
                        : 'اكتشفنا أن اللغة: ${_getLanguageName(translation.detectedLanguage.value)}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  )),
                ],
              ),
            ),
            
            // Action Buttons
            if (!translation.isTranslating.value) ...[
              // Translate Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTranslate,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'ترجمة',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: 8.w),
              
              // Dismiss Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onDismiss,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    child: Text(
                      'لا',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Show Original Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTranslate,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    child: Text(
                      'إظهار الأصلي',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            
            // Options Menu
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                size: 20.sp,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              onSelected: (value) => _handleMenuOption(value, translation),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'always_translate',
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 18),
                      SizedBox(width: 12.w),
                      const Text('ترجمة دائماً'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'never_translate',
                  child: Row(
                    children: [
                      const Icon(Icons.block, size: 18),
                      SizedBox(width: 12.w),
                      const Text('عدم الترجمة أبداً'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'change_language',
                  child: Row(
                    children: [
                      const Icon(Icons.language, size: 18),
                      SizedBox(width: 12.w),
                      const Text('تغيير اللغة'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      const Icon(Icons.settings, size: 18),
                      SizedBox(width: 12.w),
                      const Text('إعدادات الترجمة'),
                    ],
                  ),
                ),
              ],
            ),
            
            // Close Button
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                size: 18.sp,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: 32.w,
                minHeight: 32.h,
              ),
              splashRadius: 20.w,
            ),
          ],
        ),
      );
    });
  }
  
  void _handleMenuOption(String value, TranslationService translation) {
    switch (value) {
      case 'always_translate':
        translation.setAutoTranslate(true);
        Get.snackbar(
          'تم التفعيل',
          'سيتم ترجمة الصفحات تلقائياً',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'never_translate':
        translation.setAutoTranslate(false);
        Get.snackbar(
          'تم الإيقاف',
          'لن يتم ترجمة الصفحات تلقائياً',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'change_language':
        _showLanguageSelector();
        break;
      case 'settings':
        Get.toNamed('/settings');
        break;
    }
  }
  
  void _showLanguageSelector() {
    final translation = Get.find<TranslationService>();
    final languages = translation.getAvailableLanguages();
    
    Get.bottomSheet(
      Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Drag indicator
                      Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'اختر اللغة المستهدفة',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Languages List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemCount: languages.length,
                    itemBuilder: (context, index) {
                      final lang = languages[index];
                      final isSelected = translation.targetLanguage.value == lang;
                      
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            translation.setTargetLanguage(lang);
                            Get.back();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                      ? Colors.blue.shade900.withValues(alpha: 0.3)
                                      : Colors.blue.shade50)
                                  : Colors.transparent,
                              border: Border(
                                bottom: BorderSide(
                                  color: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade100,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    lang,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.blue
                                          : (isDark
                                              ? Colors.white
                                              : Colors.black87),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.blue,
                                    size: 20.sp,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
  
  String _getLanguageName(String code) {
    final languageNames = {
      'ar': 'العربية',
      'en': 'الإنجليزية',
      'fr': 'الفرنسية',
      'es': 'الإسبانية',
      'de': 'الألمانية',
      'zh': 'الصينية',
      'ja': 'اليابانية',
      'ko': 'الكورية',
      'ru': 'الروسية',
      'pt': 'البرتغالية',
      'it': 'الإيطالية',
      'hi': 'الهندية',
      'tr': 'التركية',
      'nl': 'الهولندية',
      'sv': 'السويدية',
    };
    return languageNames[code] ?? code;
  }
}

/// Compact translation indicator that shows in the URL bar area
class TranslationIndicator extends StatelessWidget {
  final bool isTranslating;
  final String sourceLanguage;
  final String targetLanguage;
  final VoidCallback? onTap;
  
  const TranslationIndicator({
    super.key,
    required this.isTranslating,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isTranslating) return const SizedBox.shrink();
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.g_translate,
              size: 14.sp,
              color: Colors.blue,
            ),
            SizedBox(width: 4.w),
            Text(
              '$sourceLanguage → $targetLanguage',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
