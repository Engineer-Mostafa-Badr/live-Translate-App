import 'package:get/get.dart';
import '../services/supabase_subscription_service.dart';
import '../../presentation/widgets/subscription_bottom_sheet.dart';
import '../utils/logger.dart';

/// Helper class for subscription management
class SubscriptionHelper {
  /// Check if user can perform an action (OCR/Translation)
  /// Returns true if allowed, false otherwise
  /// Shows subscription dialog if limit reached
  static Future<bool> checkAndIncrementUsage({
    String action = 'action',
  }) async {
    try {
      final subscriptionService = Get.find<SupabaseSubscriptionService>();
      
      // Premium users have unlimited access
      if (subscriptionService.isPremium.value) {
        Logger.log('Premium user - unlimited access', tag: 'SUB_HELPER');
        return true;
      }
      
      // Check if user can use the feature
      if (!subscriptionService.canUseOCR()) {
        Logger.warning('Daily limit reached for $action', tag: 'SUB_HELPER');
        
        // Show subscription bottom sheet
        await SubscriptionBottomSheet.show(
          remainingAttempts: subscriptionService.getRemainingAttempts(),
          maxAttempts: subscriptionService.maxAttempts.value,
        );
        
        return false;
      }
      
      // Increment usage counter
      final success = await subscriptionService.incrementDailyAttempts();
      
      if (!success) {
        Logger.error('Failed to increment attempts for $action', tag: 'SUB_HELPER');
        return false;
      }
      
      // Show warning if running low (2 or less remaining)
      final remaining = subscriptionService.getRemainingAttempts();
      if (remaining > 0 && remaining <= 2) {
        Logger.warning('Low attempts remaining: $remaining', tag: 'SUB_HELPER');
        
        // Show warning bottom sheet (non-blocking)
        Future.delayed(const Duration(milliseconds: 500), () {
          SubscriptionBottomSheet.show(
            remainingAttempts: remaining,
            maxAttempts: subscriptionService.maxAttempts.value,
          );
        });
      }
      
      Logger.log('Usage incremented for $action. Remaining: $remaining', tag: 'SUB_HELPER');
      return true;
    } catch (e) {
      Logger.error('Error checking subscription: $e', tag: 'SUB_HELPER');
      // Allow usage if subscription service fails (graceful degradation)
      return true;
    }
  }
  
  /// Check subscription status without incrementing
  static Future<bool> canUseFeature() async {
    try {
      final subscriptionService = Get.find<SupabaseSubscriptionService>();
      return subscriptionService.canUseOCR();
    } catch (e) {
      Logger.error('Error checking feature access: $e', tag: 'SUB_HELPER');
      return true; // Allow if service unavailable
    }
  }
  
  /// Get remaining attempts
  static int getRemainingAttempts() {
    try {
      final subscriptionService = Get.find<SupabaseSubscriptionService>();
      return subscriptionService.getRemainingAttempts();
    } catch (e) {
      Logger.error('Error getting remaining attempts: $e', tag: 'SUB_HELPER');
      return 5; // Default
    }
  }
  
  /// Check if user is premium
  static bool isPremium() {
    try {
      final subscriptionService = Get.find<SupabaseSubscriptionService>();
      return subscriptionService.isPremium.value;
    } catch (e) {
      Logger.error('Error checking premium status: $e', tag: 'SUB_HELPER');
      return false;
    }
  }
  
  /// Show subscription page
  static void showSubscriptionPage() {
    Get.toNamed('/enhanced-subscription');
  }
  
  /// Show subscription bottom sheet
  static Future<void> showSubscriptionSheet() async {
    try {
      final subscriptionService = Get.find<SupabaseSubscriptionService>();
      await SubscriptionBottomSheet.show(
        remainingAttempts: subscriptionService.getRemainingAttempts(),
        maxAttempts: subscriptionService.maxAttempts.value,
      );
    } catch (e) {
      Logger.error('Error showing subscription sheet: $e', tag: 'SUB_HELPER');
    }
  }
  
  /// Get subscription info as formatted string
  static String getSubscriptionInfo() {
    try {
      final subscriptionService = Get.find<SupabaseSubscriptionService>();
      
      if (subscriptionService.isPremium.value) {
        final daysRemaining = subscriptionService.getDaysRemaining();
        return 'Premium - $daysRemaining يوم متبقي';
      } else {
        final remaining = subscriptionService.getRemainingAttempts();
        final max = subscriptionService.maxAttempts.value;
        return 'مجاني - $remaining/$max محاولة متبقية';
      }
    } catch (e) {
      return 'غير متاح';
    }
  }
}
