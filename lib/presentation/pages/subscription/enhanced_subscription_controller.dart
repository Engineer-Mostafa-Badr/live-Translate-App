import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../core/services/supabase_subscription_service.dart';
import '../../../core/utils/logger.dart';

class EnhancedSubscriptionController extends GetxController {
  final SupabaseSubscriptionService _subscriptionService = Get.find<SupabaseSubscriptionService>();
  
  // Observable values
  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;
  final RxBool isPremium = false.obs;
  final RxInt dailyAttempts = 0.obs;
  final RxInt maxDailyAttempts = 5.obs;
  final RxInt remainingAttempts = 5.obs;
  final RxInt daysRemaining = 0.obs;
  final RxString currentPlanType = 'free'.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadSubscriptionData();
  }
  
  /// Load subscription data from Supabase service
  Future<void> _loadSubscriptionData() async {
    try {
      isLoading.value = true;
      
      // Get data from Supabase service
      await _subscriptionService.getUserSubscriptionStatus();
      
      isPremium.value = _subscriptionService.isPremium.value;
      dailyAttempts.value = _subscriptionService.dailyAttempts.value;
      maxDailyAttempts.value = _subscriptionService.maxAttempts.value;
      remainingAttempts.value = _subscriptionService.getRemainingAttempts();
      daysRemaining.value = _subscriptionService.getDaysRemaining();
      currentPlanType.value = _subscriptionService.subscriptionType.value;
      
      // Listen to changes
      ever(_subscriptionService.isPremium, (value) {
        isPremium.value = value;
      });
      
      ever(_subscriptionService.dailyAttempts, (value) {
        dailyAttempts.value = value;
        remainingAttempts.value = _subscriptionService.getRemainingAttempts();
      });
      
      Logger.log('Subscription data loaded', tag: 'SUBSCRIPTION');
    } catch (e) {
      Logger.error('Error loading subscription data: $e', tag: 'SUBSCRIPTION');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Subscribe to a plan using Stripe with multiple payment methods
  Future<void> subscribeToPlan(String planType, {String? paymentMethod}) async {
    try {
      isProcessing.value = true;
      
      Logger.log('Subscribing to plan: $planType with method: ${paymentMethod ?? "default"}', tag: 'SUBSCRIPTION');
      
      // Get payment intent from Supabase
      final paymentData = await _subscriptionService.upgradeSubscription(planType);
      
      if (paymentData == null) {
        throw Exception('Failed to create payment intent');
      }
      
      final clientSecret = paymentData['client_secret'] as String?;
      
      if (clientSecret == null) {
        throw Exception('No client secret received');
      }
      
      // Initialize payment sheet with multiple payment options
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Live Translate App',
          style: ThemeMode.system,
          // Enable Google Pay
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true, // Set to false in production
            currencyCode: 'USD',
          ),
          // Enable Apple Pay (will be ignored on Android)
          applePay: const PaymentSheetApplePay(
            merchantCountryCode: 'US',
          ),
          // Customize appearance
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF6366F1),
            ),
          ),
          // Allow saving payment methods
          allowsDelayedPaymentMethods: true,
        ),
      );
      
      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();
      
      // Payment successful - activate subscription
      final transactionId = 'stripe_${DateTime.now().millisecondsSinceEpoch}';
      final success = await _subscriptionService.activateSubscription(
        planType,
        transactionId,
      );
      
      if (success) {
        currentPlanType.value = planType;
        await _loadSubscriptionData();
        
        Get.back(); // Close subscription page
        
        _showSuccessDialog(planType);
        
        Logger.success('Subscription activated: $planType', tag: 'SUBSCRIPTION');
      } else {
        throw Exception('Failed to activate subscription');
      }
    } on StripeException catch (e) {
      Logger.error('Stripe error: ${e.error.message}', tag: 'SUBSCRIPTION');
      
      if (e.error.code != FailureCode.Canceled) {
        _showErrorDialog(
          'خطأ في الدفع',
          e.error.localizedMessage ?? 'فشلت عملية الدفع. يرجى التحقق من بيانات الدفع والمحاولة مرة أخرى.',
        );
      }
    } catch (e) {
      Logger.error('Error subscribing: $e', tag: 'SUBSCRIPTION');
      
      _showErrorDialog(
        'خطأ',
        'فشل تفعيل الاشتراك. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
      );
    } finally {
      isProcessing.value = false;
    }
  }
  
  /// Show success dialog with animation
  void _showSuccessDialog(String planType) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'مبروك! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'تم تفعيل اشتراكك ${_getPlanName(planType)} بنجاح',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'يمكنك الآن الاستمتاع بجميع المميزات المتميزة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('رائع!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Show error dialog
  void _showErrorDialog(String title, String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        // Retry
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  
  /// Get plan name in Arabic
  String _getPlanName(String planType) {
    switch (planType) {
      case 'weekly':
        return 'أسبوعي';
      case 'monthly':
        return 'شهري';
      case 'yearly':
        return 'سنوي';
      default:
        return 'غير معروف';
    }
  }
  
  /// Manage subscription
  void manageSubscription() {
    Get.dialog(
      AlertDialog(
        title: const Text('إدارة الاشتراك'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الخطة الحالية: ${_getPlanName(currentPlanType.value)}'),
            const SizedBox(height: 8),
            Text('الأيام المتبقية: ${daysRemaining.value}'),
            const SizedBox(height: 16),
            const Text(
              'يمكنك تجديد أو ترقية اشتراكك من خلال اختيار خطة جديدة.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // User can select a new plan
            },
            child: const Text('ترقية'),
          ),
        ],
      ),
    );
  }
  
  /// Cancel subscription
  Future<void> cancelSubscription() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('إلغاء الاشتراك'),
        content: const Text(
          'هل أنت متأكد من إلغاء اشتراكك؟ ستفقد جميع المميزات المتميزة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('رجوع'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('إلغاء الاشتراك'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        isProcessing.value = true;
        
        final success = await _subscriptionService.cancelSubscription();
        
        if (success) {
          currentPlanType.value = 'free';
          await _loadSubscriptionData();
          
          Get.snackbar(
            'تم الإلغاء',
            'تم إلغاء اشتراكك بنجاح',
            snackPosition: SnackPosition.BOTTOM,
          );
          
          Logger.log('Subscription cancelled', tag: 'SUBSCRIPTION');
        }
      } catch (e) {
        Logger.error('Error cancelling subscription: $e', tag: 'SUBSCRIPTION');
        
        Get.snackbar(
          'خطأ',
          'فشل إلغاء الاشتراك',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isProcessing.value = false;
      }
    }
  }
  
  /// Refresh subscription data
  Future<void> refreshData() async {
    await _loadSubscriptionData();
  }
}
