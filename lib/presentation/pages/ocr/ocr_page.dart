import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/paddle_ocr_service.dart';
import '../../../core/services/offline_translation_service.dart';
import '../../../core/services/supabase_subscription_service.dart';
import '../subscription/enhanced_subscription_page.dart';

class OCRPage extends StatefulWidget {
  const OCRPage({super.key});

  @override
  State<OCRPage> createState() => _OCRPageState();
}

class _OCRPageState extends State<OCRPage> {
  final _ocrService = Get.find<PaddleOCRService>();
  final _translationService = Get.find<OfflineTranslationService>();
  final _subscriptionService = Get.find<SupabaseSubscriptionService>();
  final _picker = ImagePicker();
  
  String? _imagePath;
  OCRResult? _ocrResult;
  String? _translatedText;
  bool _isProcessing = false;
  String _selectedLanguage = 'ar';

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Check if user can use OCR
      if (!_subscriptionService.canUseOCR()) {
        _showSubscriptionDialog();
        return;
      }
      
      final image = await _picker.pickImage(source: source);
      
      if (image != null) {
        setState(() {
          _imagePath = image.path;
          _ocrResult = null;
          _translatedText = null;
        });
        
        await _performOCR();
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل اختيار الصورة: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _performOCR() async {
    if (_imagePath == null) return;
    
    setState(() => _isProcessing = true);
    
    try {
      // Increment OCR attempt
      final success = await _subscriptionService.incrementDailyAttempts();
      
      if (!success) {
        setState(() => _isProcessing = false);
        _showSubscriptionDialog();
        return;
      }
      
      final result = await _ocrService.recognizeText(
        _imagePath!,
        language: _selectedLanguage,
      );
      
      setState(() {
        _ocrResult = result;
        _isProcessing = false;
      });
      
      if (result != null) {
        final remaining = _subscriptionService.getRemainingAttempts();
        Get.snackbar(
          'نجح',
          remaining >= 0 
            ? 'تم التعرف على النص بنجاح. المحاولات المتبقية: $remaining'
            : 'تم التعرف على النص بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      Get.snackbar(
        'خطأ',
        'فشل التعرف على النص: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _translateText() async {
    if (_ocrResult == null || _ocrResult!.text.isEmpty) return;
    
    setState(() => _isProcessing = true);
    
    try {
      final result = await _translationService.translate(
        _ocrResult!.text,
        from: _selectedLanguage,
        to: _selectedLanguage == 'ar' ? 'en' : 'ar',
      );
      
      setState(() {
        _translatedText = result;
        _isProcessing = false;
      });
      
      if (result != null) {
        Get.snackbar(
          'نجح',
          'تمت الترجمة بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      Get.snackbar(
        'خطأ',
        'فشلت الترجمة: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  /// Show subscription dialog when limit is reached
  void _showSubscriptionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('انتهت المحاولات المجانية'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لقد استخدمت جميع محاولاتك المجانية اليوم (5 محاولات).',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'اشترك الآن للحصول على:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• محاولات OCR غير محدودة'),
            Text('• ترجمة دون اتصال'),
            Text('• دعم جميع اللغات'),
            Text('• بدون إعلانات'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('لاحقاً'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.to(() => const EnhancedSubscriptionPage());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('اشترك الآن'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التعرف على النص (OCR)'),
          centerTitle: true,
          actions: [
            // Show remaining attempts
            Obx(() {
              final remaining = _subscriptionService.getRemainingAttempts();
              final isPremium = _subscriptionService.isPremium.value;
              
              if (isPremium) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.workspace_premium, size: 16.sp, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text(
                            'Premium',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: remaining <= 2 ? Colors.red : Colors.blue,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '$remaining / 5',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }
            }),
            PopupMenuButton<String>(
              icon: const Icon(Icons.language),
              onSelected: (value) {
                setState(() => _selectedLanguage = value);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'ar', child: Text('العربية')),
                const PopupMenuItem(value: 'en', child: Text('English')),
                const PopupMenuItem(value: 'ch', child: Text('中文')),
                const PopupMenuItem(value: 'ja', child: Text('日本語')),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview
              if (_imagePath != null)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Image.file(
                      File(_imagePath!),
                      height: 300.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  height: 300.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.grey[400]!,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 64.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'اختر صورة للتعرف على النص',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              
              SizedBox(height: 24.h),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('الكاميرا'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 56.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('المعرض'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 56.h),
                      ),
                    ),
                  ),
                ],
              ),
              
              if (_isProcessing) ...[
                SizedBox(height: 24.h),
                const Center(child: CircularProgressIndicator()),
                SizedBox(height: 12.h),
                Center(
                  child: Text(
                    'جاري المعالجة...',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
              
              // OCR Result
              if (_ocrResult != null && !_isProcessing) ...[
                SizedBox(height: 24.h),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.text_fields,
                              color: Theme.of(context).primaryColor,
                              size: 24.sp,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'النص المستخرج',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        SelectableText(
                          _ocrResult!.text,
                          style: TextStyle(
                            fontSize: 16.sp,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                'الدقة: ${(_ocrResult!.confidence * 100).toStringAsFixed(1)}%',
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Chip(
                              label: Text(
                                'الوقت: ${_ocrResult!.processingTime}ms',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        ElevatedButton.icon(
                          onPressed: _translateText,
                          icon: const Icon(Icons.translate),
                          label: const Text('ترجمة النص'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 48.h),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              // Translation Result
              if (_translatedText != null && !_isProcessing) ...[
                SizedBox(height: 16.h),
                Card(
                  elevation: 2,
                  color: Colors.green[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.translate,
                              color: Colors.green,
                              size: 24.sp,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'الترجمة',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[900],
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        SelectableText(
                          _translatedText!,
                          style: TextStyle(
                            fontSize: 16.sp,
                            height: 1.5,
                            color: Colors.green[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
