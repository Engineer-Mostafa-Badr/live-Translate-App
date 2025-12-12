import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/subscription_helper.dart';
import '../../../core/services/paddle_ocr_service.dart';
import '../../../core/services/offline_translation_service.dart';

/// مثال على كيفية استخدام نظام الاشتراكات في التطبيق
/// 
/// هذا الملف يوضح الطرق المختلفة لاستخدام نظام الاشتراكات
class SubscriptionUsageExample extends StatelessWidget {
  const SubscriptionUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أمثلة استخدام نظام الاشتراكات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // مثال 1: استخدام OCR
          _buildExampleCard(
            title: 'مثال 1: استخدام OCR',
            description: 'يتم التحقق تلقائياً من الاشتراك قبل تنفيذ OCR',
            onTap: _example1_UseOCR,
          ),
          
          const SizedBox(height: 16),
          
          // مثال 2: استخدام الترجمة
          _buildExampleCard(
            title: 'مثال 2: استخدام الترجمة',
            description: 'يتم التحقق تلقائياً من الاشتراك قبل الترجمة',
            onTap: _example2_UseTranslation,
          ),
          
          const SizedBox(height: 16),
          
          // مثال 3: التحقق اليدوي
          _buildExampleCard(
            title: 'مثال 3: التحقق اليدوي',
            description: 'التحقق من الاشتراك قبل تنفيذ أي عملية',
            onTap: _example3_ManualCheck,
          ),
          
          const SizedBox(height: 16),
          
          // مثال 4: عرض معلومات الاشتراك
          _buildExampleCard(
            title: 'مثال 4: معلومات الاشتراك',
            description: 'عرض معلومات الاشتراك الحالية',
            onTap: _example4_ShowSubscriptionInfo,
          ),
          
          const SizedBox(height: 16),
          
          // مثال 5: فتح صفحة الاشتراك
          _buildExampleCard(
            title: 'مثال 5: فتح صفحة الاشتراك',
            description: 'الانتقال إلى صفحة الاشتراك المحسنة',
            onTap: _example5_OpenSubscriptionPage,
          ),
          
          const SizedBox(height: 16),
          
          // مثال 6: عرض BottomSheet
          _buildExampleCard(
            title: 'مثال 6: عرض BottomSheet',
            description: 'عرض نافذة الاشتراك السريعة',
            onTap: _example6_ShowBottomSheet,
          ),
        ],
      ),
    );
  }
  
  Widget _buildExampleCard({
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
  
  // ============================================
  // مثال 1: استخدام OCR مع التحقق التلقائي
  // ============================================
  Future<void> _example1_UseOCR() async {
    try {
      final ocrService = Get.find<PaddleOCRService>();
      
      // التحقق من الاشتراك يتم تلقائياً داخل recognizeText
      final result = await ocrService.recognizeText(
        '/path/to/image.jpg',
        language: 'ar',
      );
      
      if (result != null) {
        Get.snackbar(
          'نجاح',
          'تم التعرف على النص: ${result.text}',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // إما أن المحاولات انتهت أو حدث خطأ
        Get.snackbar(
          'تنبيه',
          'لم يتم التعرف على النص',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // ============================================
  // مثال 2: استخدام الترجمة مع التحقق التلقائي
  // ============================================
  Future<void> _example2_UseTranslation() async {
    try {
      final translationService = Get.find<OfflineTranslationService>();
      
      // التحقق من الاشتراك يتم تلقائياً داخل translate
      final result = await translationService.translate(
        'Hello World',
        from: 'en',
        to: 'ar',
      );
      
      if (result != null) {
        Get.snackbar(
          'نجاح',
          'الترجمة: $result',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'تنبيه',
          'لم يتم الترجمة',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // ============================================
  // مثال 3: التحقق اليدوي من الاشتراك
  // ============================================
  Future<void> _example3_ManualCheck() async {
    // التحقق من إمكانية استخدام الميزة
    final canUse = await SubscriptionHelper.canUseFeature();
    
    if (!canUse) {
      // عرض نافذة الاشتراك
      await SubscriptionHelper.showSubscriptionSheet();
      return;
    }
    
    // تنفيذ العملية المطلوبة
    Get.snackbar(
      'نجاح',
      'يمكنك استخدام الميزة',
      snackPosition: SnackPosition.BOTTOM,
    );
    
    // بعد تنفيذ العملية، قم بزيادة العداد
    await SubscriptionHelper.checkAndIncrementUsage(action: 'Custom Action');
  }
  
  // ============================================
  // مثال 4: عرض معلومات الاشتراك
  // ============================================
  void _example4_ShowSubscriptionInfo() {
    final isPremium = SubscriptionHelper.isPremium();
    final remaining = SubscriptionHelper.getRemainingAttempts();
    final info = SubscriptionHelper.getSubscriptionInfo();
    
    Get.dialog(
      AlertDialog(
        title: const Text('معلومات الاشتراك'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الحالة: ${isPremium ? "Premium" : "Free"}'),
            const SizedBox(height: 8),
            if (!isPremium)
              Text('المحاولات المتبقية: $remaining'),
            const SizedBox(height: 8),
            Text('التفاصيل: $info'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق'),
          ),
          if (!isPremium)
            ElevatedButton(
              onPressed: () {
                Get.back();
                SubscriptionHelper.showSubscriptionPage();
              },
              child: const Text('ترقية'),
            ),
        ],
      ),
    );
  }
  
  // ============================================
  // مثال 5: فتح صفحة الاشتراك المحسنة
  // ============================================
  void _example5_OpenSubscriptionPage() {
    SubscriptionHelper.showSubscriptionPage();
  }
  
  // ============================================
  // مثال 6: عرض BottomSheet للاشتراك
  // ============================================
  Future<void> _example6_ShowBottomSheet() async {
    await SubscriptionHelper.showSubscriptionSheet();
  }
}

// ============================================
// مثال على استخدام النظام في Controller
// ============================================
class ExampleController extends GetxController {
  
  /// مثال: دالة لمعالجة صورة مع التحقق من الاشتراك
  Future<void> processImage(String imagePath) async {
    try {
      final ocrService = Get.find<PaddleOCRService>();
      
      // التحقق يتم تلقائياً
      final result = await ocrService.recognizeText(imagePath);
      
      if (result != null) {
        // معالجة النتيجة
        print('OCR Result: ${result.text}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  
  /// مثال: دالة لترجمة نص مع التحقق من الاشتراك
  Future<void> translateText(String text) async {
    try {
      final translationService = Get.find<OfflineTranslationService>();
      
      // التحقق يتم تلقائياً
      final result = await translationService.translate(
        text,
        from: 'en',
        to: 'ar',
      );
      
      if (result != null) {
        // معالجة النتيجة
        print('Translation: $result');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  
  /// مثال: التحقق قبل تنفيذ عملية مخصصة
  Future<void> performCustomAction() async {
    // التحقق من الاشتراك وزيادة العداد
    final canProceed = await SubscriptionHelper.checkAndIncrementUsage(
      action: 'Custom Feature',
    );
    
    if (!canProceed) {
      // المستخدم لم يشترك أو انتهت محاولاته
      return;
    }
    
    // تنفيذ العملية المطلوبة
    print('Performing custom action...');
  }
  
  /// مثال: عرض حالة الاشتراك في الواجهة
  String getSubscriptionStatusText() {
    return SubscriptionHelper.getSubscriptionInfo();
  }
  
  /// مثال: التحقق من حالة Premium
  bool isUserPremium() {
    return SubscriptionHelper.isPremium();
  }
}

// ============================================
// مثال على استخدام النظام في Widget
// ============================================
class SubscriptionStatusWidget extends StatelessWidget {
  const SubscriptionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isPremium = SubscriptionHelper.isPremium();
    final remaining = SubscriptionHelper.getRemainingAttempts();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPremium ? Colors.amber.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isPremium ? Icons.workspace_premium : Icons.info_outline,
            color: isPremium ? Colors.amber : Colors.blue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPremium ? 'Premium' : 'Free',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  isPremium 
                      ? 'استمتع بمميزات غير محدودة'
                      : 'المحاولات المتبقية: $remaining',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          if (!isPremium)
            ElevatedButton(
              onPressed: () => SubscriptionHelper.showSubscriptionPage(),
              child: const Text('ترقية'),
            ),
        ],
      ),
    );
  }
}
