import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/logger.dart';

class SubscriptionController extends GetxController {
  final RxBool isPremium = false.obs;
  final RxInt daysRemaining = 30.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadSubscriptionStatus();
  }
  
  void _loadSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isPremium.value = prefs.getBool('is_premium') ?? false;
    daysRemaining.value = prefs.getInt('days_remaining') ?? 30;
    
    Logger.log('Subscription status loaded: Premium=${isPremium.value}');
  }
  
  void selectFreePlan() {
    if (isPremium.value) {
      Get.dialog(
        AlertDialog(
          title: const Text('التبديل للخطة المجانية'),
          content: const Text(
            'هل أنت متأكد من التبديل للخطة المجانية؟ ستفقد جميع مميزات الخطة المتميزة.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('is_premium', false);
                isPremium.value = false;
                Get.back();
                
                Get.snackbar(
                  'تم',
                  'تم التبديل للخطة المجانية',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: const Text('تأكيد'),
            ),
          ],
        ),
      );
    }
  }
  
  void selectPremiumPlan() async {
    Logger.log('Premium plan selected');
    
    // Show payment dialog
    Get.dialog(
      AlertDialog(
        title: const Text('الاشتراك المتميز'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('سيتم تفعيل الاشتراك المتميز لمدة 30 يومًا'),
            SizedBox(height: 8),
            Text('السعر: 29.99 ر.س'),
            SizedBox(height: 16),
            Text(
              'ملاحظة: نظام الدفع قيد التطوير',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Mock subscription activation
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_premium', true);
              await prefs.setInt('days_remaining', 30);
              
              isPremium.value = true;
              daysRemaining.value = 30;
              
              Get.back();
              
              Get.snackbar(
                'مبروك! 🎉',
                'تم تفعيل الاشتراك المتميز بنجاح',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(seconds: 3),
              );
              
              Logger.success('Premium subscription activated');
            },
            child: const Text('تفعيل (تجريبي)'),
          ),
        ],
      ),
    );
  }
  
  void renewSubscription() {
    Get.dialog(
      AlertDialog(
        title: const Text('تجديد الاشتراك'),
        content: const Text('هل تريد تجديد اشتراكك لمدة 30 يومًا إضافية؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final newDays = daysRemaining.value + 30;
              await prefs.setInt('days_remaining', newDays);
              daysRemaining.value = newDays;
              
              Get.back();
              
              Get.snackbar(
                'تم التجديد',
                'تم تجديد اشتراكك بنجاح',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
              
              Logger.success('Subscription renewed');
            },
            child: const Text('تجديد'),
          ),
        ],
      ),
    );
  }
  
  void cancelSubscription() {
    Get.dialog(
      AlertDialog(
        title: const Text('إلغاء الاشتراك'),
        content: const Text(
          'هل أنت متأكد من إلغاء اشتراكك؟ ستفقد جميع المميزات المتميزة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('رجوع'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_premium', false);
              await prefs.setInt('days_remaining', 0);
              
              isPremium.value = false;
              daysRemaining.value = 0;
              
              Get.back();
              
              Get.snackbar(
                'تم الإلغاء',
                'تم إلغاء اشتراكك',
                snackPosition: SnackPosition.BOTTOM,
              );
              
              Logger.log('Subscription cancelled');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('إلغاء الاشتراك'),
          ),
        ],
      ),
    );
  }
}
