import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../core/services/supabase_subscription_service.dart';
import '../../core/utils/logger.dart';

class SubscriptionController extends GetxController {
  final SupabaseSubscriptionService _subscriptionService = Get.find();

  // Observable state
  final isLoading = false.obs;
  final isYearly = false.obs;
  final Rx<UserSubscription?> currentPlan = Rx<UserSubscription?>(null);
  final RxList<SubscriptionPlan> availablePlans = <SubscriptionPlan>[].obs;

  // Stripe Price IDs (Placeholders - Replace with actual IDs from Stripe Dashboard)
  static const String basicMonthlyPriceId = 'price_basic_monthly_placeholder';
  static const String basicYearlyPriceId = 'price_basic_yearly_placeholder';
  static const String proMonthlyPriceId = 'price_pro_monthly_placeholder';
  static const String proYearlyPriceId = 'price_pro_yearly_placeholder';
  static const String premiumMonthlyPriceId = 'price_premium_monthly_placeholder';
  static const String premiumYearlyPriceId = 'price_premium_yearly_placeholder';

  @override
  void onInit() {
    super.onInit();
    _initPlans();
    loadCurrentSubscription();
  }

  /// Initialize available plans
  void _initPlans() {
    availablePlans.value = [
      SubscriptionPlan.free(),
      SubscriptionPlan.basic(
        billingPeriod: 'monthly',
        stripePriceId: basicMonthlyPriceId,
      ),
      SubscriptionPlan.basic(
        billingPeriod: 'yearly',
        stripePriceId: basicYearlyPriceId,
      ),
      SubscriptionPlan.pro(
        billingPeriod: 'monthly',
        stripePriceId: proMonthlyPriceId,
      ),
      SubscriptionPlan.pro(
        billingPeriod: 'yearly',
        stripePriceId: proYearlyPriceId,
      ),
      SubscriptionPlan.premium(
        billingPeriod: 'monthly',
        stripePriceId: premiumMonthlyPriceId,
      ),
      SubscriptionPlan.premium(
        billingPeriod: 'yearly',
        stripePriceId: premiumYearlyPriceId,
      ),
    ];
  }

  /// Load current user subscription
  Future<void> loadCurrentSubscription() async {
    try {
      isLoading.value = true;
      final subscription = await _subscriptionService.getCurrentSubscription();
      currentPlan.value = subscription;
      Logger.success('Current subscription loaded: ${subscription?.tier}');
    } catch (e) {
      Logger.error('Failed to load subscription: $e');
      Get.snackbar(
        'Error',
        'Failed to load subscription details',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get plans for current billing period
  List<SubscriptionPlan> getPlansForBillingPeriod() {
    final period = isYearly.value ? 'yearly' : 'monthly';
    return availablePlans
        .where((plan) => plan.tier == 'free' || plan.billingPeriod == period)
        .toList();
  }

  /// Subscribe to a plan
  Future<void> subscribeToPlan(SubscriptionPlan plan) async {
    if (plan.tier == 'free') {
      Get.snackbar(
        'Info',
        'You are already on the free plan',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Create checkout session
      final sessionUrl = await _subscriptionService.createCheckoutSession(
        priceId: plan.stripePriceId,
      );

      // Close loading dialog
      Get.back();

      if (sessionUrl != null) {
        // In a real app, you would open this URL in a webview or browser
        // For now, we'll show a placeholder message
        Get.dialog(
          AlertDialog(
            title: const Text('Checkout'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Checkout URL generated successfully!'),
                const SizedBox(height: 16),
                Text(
                  'In production, this would open Stripe Checkout.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Plan: ${plan.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Price: \$${plan.price}/${plan.billingPeriod}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Close'),
              ),
            ],
          ),
        );

        Logger.success('Checkout session created for plan: ${plan.name}');
      } else {
        throw Exception('Failed to create checkout session');
      }
    } catch (e) {
      Logger.error('Failed to subscribe: $e');
      Get.back(); // Close loading dialog if open
      Get.snackbar(
        'Error',
        'Failed to start checkout process: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Cancel current subscription
  Future<void> cancelSubscription({bool immediately = false}) async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Cancel Subscription'),
          content: Text(
            immediately
                ? 'Are you sure you want to cancel your subscription immediately? You will lose access to premium features right away.'
                : 'Are you sure you want to cancel your subscription? You will retain access until the end of your billing period.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('No, Keep It'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Yes, Cancel'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      isLoading.value = true;

      final success = await _subscriptionService.cancelSubscription(
        immediately: immediately,
      );

      if (success) {
        await loadCurrentSubscription();
        Get.snackbar(
          'Success',
          immediately
              ? 'Subscription cancelled immediately'
              : 'Subscription will be cancelled at period end',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception('Failed to cancel subscription');
      }
    } catch (e) {
      Logger.error('Failed to cancel subscription: $e');
      Get.snackbar(
        'Error',
        'Failed to cancel subscription: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Restore subscription (if cancelled but still in period)
  Future<void> restoreSubscription() async {
    try {
      isLoading.value = true;

      // In a real implementation, you would call Stripe API to restore
      // For now, this is a placeholder
      Get.snackbar(
        'Info',
        'Subscription restoration is not yet implemented',
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadCurrentSubscription();
    } catch (e) {
      Logger.error('Failed to restore subscription: $e');
      Get.snackbar(
        'Error',
        'Failed to restore subscription: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if user can use feature based on subscription
  bool canUseFeature(String feature) {
    if (currentPlan.value == null) return false;

    switch (feature) {
      case 'offline_mode':
        return currentPlan.value!.limits.offlineMode;
      case 'ad_free':
        return currentPlan.value!.limits.adFree;
      case 'priority_support':
        return currentPlan.value!.limits.prioritySupport;
      default:
        return false;
    }
  }

  /// Get remaining daily limit for a feature
  Future<int> getRemainingLimit(String usageType) async {
    try {
      return await _subscriptionService.getRemainingDailyLimit(usageType);
    } catch (e) {
      Logger.error('Failed to get remaining limit: $e');
      return 0;
    }
  }

  /// Check if user has reached daily limit
  Future<bool> hasReachedLimit(String usageType) async {
    final remaining = await getRemainingLimit(usageType);
    return remaining <= 0;
  }

  /// Track usage
  Future<void> trackUsage(String usageType, {Map<String, dynamic>? metadata}) async {
    try {
      await _subscriptionService.trackUsage(
        usageType: usageType,
        metadata: metadata,
      );
      Logger.log('Usage tracked: $usageType');
    } catch (e) {
      Logger.error('Failed to track usage: $e');
    }
  }
}
