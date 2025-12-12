import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';
import '../../domain/entities/subscription_plan.dart';

/// Service to manage subscriptions using Supabase
class SupabaseSubscriptionService extends GetxService {
  final _supabase = Supabase.instance.client;
  
  // Observable values
  final RxBool isPremium = false.obs;
  final RxInt dailyAttempts = 0.obs;
  final RxInt maxAttempts = 5.obs;
  final RxString subscriptionType = 'free'.obs;
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final Rx<DateTime?> lastResetDate = Rx<DateTime?>(null);
  
  // Subscription types
  static const String FREE_PLAN = 'free';
  static const String WEEKLY_PLAN = 'weekly';
  static const String MONTHLY_PLAN = 'monthly';
  static const String YEARLY_PLAN = 'yearly';
  
  // Pricing (in USD)
  static const Map<String, double> SUBSCRIPTION_PRICES = {
    WEEKLY_PLAN: 5.0,
    MONTHLY_PLAN: 10.0,
    YEARLY_PLAN: 30.0,
  };
  
  // Duration in days
  static const Map<String, int> SUBSCRIPTION_DURATION = {
    WEEKLY_PLAN: 7,
    MONTHLY_PLAN: 30,
    YEARLY_PLAN: 365,
  };
  
  @override
  Future<SupabaseSubscriptionService> onInit() async {
    super.onInit();
    await getUserSubscriptionStatus();
    await resetDailyAttemptsIfNeeded();
    return this;
  }
  
  /// Get user subscription status from Supabase
  Future<Map<String, dynamic>?> getUserSubscriptionStatus() async {
    try {
      final user = _supabase.auth.currentUser;
      
      if (user == null) {
        Logger.warning('No user logged in', tag: 'SUPABASE_SUB');
        return null;
      }
      
      // Query user subscription data
      final response = await _supabase
          .from('user_subscriptions')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();
      
      if (response != null) {
        // Update observable values
        isPremium.value = response['is_premium'] ?? false;
        dailyAttempts.value = response['daily_attempts'] ?? 0;
        maxAttempts.value = response['max_attempts'] ?? 5;
        subscriptionType.value = response['subscription_type'] ?? FREE_PLAN;
        
        if (response['subscription_end_date'] != null) {
          endDate.value = DateTime.parse(response['subscription_end_date']);
        }
        
        if (response['last_reset_date'] != null) {
          lastResetDate.value = DateTime.parse(response['last_reset_date']);
        }
        
        Logger.success('Subscription status loaded from Supabase', tag: 'SUPABASE_SUB');
        return response;
      } else {
        // Create new subscription record for user
        await _createUserSubscription(user.id);
        return await getUserSubscriptionStatus();
      }
    } catch (e) {
      Logger.error('Error getting subscription status: $e', tag: 'SUPABASE_SUB');
      return null;
    }
  }
  
  /// Create new user subscription record
  Future<void> _createUserSubscription(String userId) async {
    try {
      await _supabase.from('user_subscriptions').insert({
        'user_id': userId,
        'is_premium': false,
        'daily_attempts': 0,
        'max_attempts': 5,
        'subscription_type': FREE_PLAN,
        'subscription_end_date': null,
        'last_reset_date': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });
      
      Logger.success('User subscription created', tag: 'SUPABASE_SUB');
    } catch (e) {
      Logger.error('Error creating user subscription: $e', tag: 'SUPABASE_SUB');
    }
  }
  
  /// Increment daily attempts
  Future<bool> incrementDailyAttempts() async {
    try {
      final user = _supabase.auth.currentUser;
      
      if (user == null) {
        Logger.warning('No user logged in', tag: 'SUPABASE_SUB');
        return false;
      }
      
      // Check if user can use OCR
      if (!isPremium.value && dailyAttempts.value >= maxAttempts.value) {
        Logger.warning('Daily limit reached', tag: 'SUPABASE_SUB');
        return false;
      }
      
      // Increment attempts
      dailyAttempts.value++;
      
      // Update in Supabase
      await _supabase
          .from('user_subscriptions')
          .update({'daily_attempts': dailyAttempts.value})
          .eq('user_id', user.id);
      
      Logger.log('Daily attempts incremented: ${dailyAttempts.value}/${maxAttempts.value}', 
                 tag: 'SUPABASE_SUB');
      return true;
    } catch (e) {
      Logger.error('Error incrementing attempts: $e', tag: 'SUPABASE_SUB');
      return false;
    }
  }
  
  /// Reset daily attempts if needed (new day)
  Future<void> resetDailyAttemptsIfNeeded() async {
    try {
      final user = _supabase.auth.currentUser;
      
      if (user == null) return;
      
      final now = DateTime.now();
      final lastReset = lastResetDate.value;
      
      // Check if it's a new day
      if (lastReset == null || !_isSameDay(now, lastReset)) {
        dailyAttempts.value = 0;
        lastResetDate.value = now;
        
        // Update in Supabase
        await _supabase
            .from('user_subscriptions')
            .update({
              'daily_attempts': 0,
              'last_reset_date': now.toIso8601String(),
            })
            .eq('user_id', user.id);
        
        Logger.log('Daily attempts reset', tag: 'SUPABASE_SUB');
      }
      
      // Also check if subscription expired
      await _checkSubscriptionExpiry();
    } catch (e) {
      Logger.error('Error resetting daily attempts: $e', tag: 'SUPABASE_SUB');
    }
  }
  
  /// Check if subscription has expired
  Future<void> _checkSubscriptionExpiry() async {
    try {
      if (endDate.value != null && isPremium.value) {
        final now = DateTime.now();
        
        if (now.isAfter(endDate.value!)) {
          // Subscription expired
          await _expireSubscription();
        }
      }
    } catch (e) {
      Logger.error('Error checking subscription expiry: $e', tag: 'SUPABASE_SUB');
    }
  }
  
  /// Expire subscription
  Future<void> _expireSubscription() async {
    try {
      final user = _supabase.auth.currentUser;
      
      if (user == null) return;
      
      isPremium.value = false;
      subscriptionType.value = FREE_PLAN;
      endDate.value = null;
      
      await _supabase
          .from('user_subscriptions')
          .update({
            'is_premium': false,
            'subscription_type': FREE_PLAN,
            'subscription_end_date': null,
          })
          .eq('user_id', user.id);
      
      Logger.warning('Subscription expired', tag: 'SUPABASE_SUB');
    } catch (e) {
      Logger.error('Error expiring subscription: $e', tag: 'SUPABASE_SUB');
    }
  }
  
  /// Upgrade subscription (sends payment request to Stripe Function)
  Future<Map<String, dynamic>?> upgradeSubscription(String type) async {
    try {
      final user = _supabase.auth.currentUser;
      
      if (user == null) {
        Logger.warning('No user logged in', tag: 'SUPABASE_SUB');
        return null;
      }
      
      final price = SUBSCRIPTION_PRICES[type];
      
      if (price == null) {
        Logger.error('Invalid subscription type: $type', tag: 'SUPABASE_SUB');
        return null;
      }
      
      // Call Supabase Edge Function to create Stripe payment intent
      final response = await _supabase.functions.invoke(
        'create-payment-intent',
        body: {
          'user_id': user.id,
          'subscription_type': type,
          'amount': (price * 100).toInt(), // Convert to cents
          'currency': 'usd',
        },
      );
      
      if (response.status == 200 && response.data != null) {
        Logger.success('Payment intent created', tag: 'SUPABASE_SUB');
        return response.data as Map<String, dynamic>;
      } else {
        Logger.error('Failed to create payment intent: ${response.status}', 
                     tag: 'SUPABASE_SUB');
        return null;
      }
    } catch (e) {
      Logger.error('Error upgrading subscription: $e', tag: 'SUPABASE_SUB');
      return null;
    }
  }
  
  /// Activate subscription after successful payment
  Future<bool> activateSubscription(String type, String transactionId) async {
    try {
      final user = _supabase.auth.currentUser;
      
      if (user == null) {
        Logger.warning('No user logged in', tag: 'SUPABASE_SUB');
        return false;
      }
      
      final duration = SUBSCRIPTION_DURATION[type] ?? 30;
      final newEndDate = DateTime.now().add(Duration(days: duration));
      
      // Update subscription status
      isPremium.value = true;
      subscriptionType.value = type;
      endDate.value = newEndDate;
      dailyAttempts.value = 0; // Reset attempts on upgrade
      
      // Update in Supabase
      await _supabase
          .from('user_subscriptions')
          .update({
            'is_premium': true,
            'subscription_type': type,
            'subscription_end_date': newEndDate.toIso8601String(),
            'daily_attempts': 0,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id);
      
      // Log transaction
      await _supabase.from('subscription_transactions').insert({
        'user_id': user.id,
        'subscription_type': type,
        'amount': SUBSCRIPTION_PRICES[type],
        'transaction_id': transactionId,
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
      });
      
      Logger.success('Subscription activated: $type', tag: 'SUPABASE_SUB');
      return true;
    } catch (e) {
      Logger.error('Error activating subscription: $e', tag: 'SUPABASE_SUB');
      return false;
    }
  }
  
  /// Cancel subscription (Legacy - for old schema)
  Future<bool> cancelSubscriptionOld() async {
    try {
      final user = _supabase.auth.currentUser;
      
      if (user == null) {
        Logger.warning('No user logged in', tag: 'SUPABASE_SUB');
        return false;
      }
      
      isPremium.value = false;
      subscriptionType.value = FREE_PLAN;
      endDate.value = null;
      
      await _supabase
          .from('user_subscriptions')
          .update({
            'is_premium': false,
            'subscription_type': FREE_PLAN,
            'subscription_end_date': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id);
      
      Logger.log('Subscription cancelled', tag: 'SUPABASE_SUB');
      return true;
    } catch (e) {
      Logger.error('Error cancelling subscription: $e', tag: 'SUPABASE_SUB');
      return false;
    }
  }
  
  /// Check if user can use OCR
  bool canUseOCR() {
    if (isPremium.value) {
      return true; // Premium users have unlimited access
    }
    
    return dailyAttempts.value < maxAttempts.value;
  }
  
  /// Get remaining attempts
  int getRemainingAttempts() {
    if (isPremium.value) {
      return -1; // Unlimited
    }
    
    return maxAttempts.value - dailyAttempts.value;
  }
  
  /// Get days remaining in subscription
  int getDaysRemaining() {
    if (endDate.value == null) {
      return 0;
    }
    
    final now = DateTime.now();
    final difference = endDate.value!.difference(now);
    
    return difference.inDays.clamp(0, 999);
  }
  
  /// Helper to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  /// Get subscription info
  Map<String, dynamic> getSubscriptionInfo() {
    return {
      'is_premium': isPremium.value,
      'daily_attempts': dailyAttempts.value,
      'max_attempts': maxAttempts.value,
      'remaining_attempts': getRemainingAttempts(),
      'subscription_type': subscriptionType.value,
      'days_remaining': getDaysRemaining(),
      'end_date': endDate.value?.toIso8601String(),
    };
  }
  
  /// Get current user subscription (new schema)
  Future<UserSubscription?> getCurrentSubscription() async {
    try {
      final user = _supabase.auth.currentUser;
      
      if (user == null) {
        Logger.warning('No user logged in', tag: 'SUPABASE_SUB');
        return null;
      }
      
      final response = await _supabase
          .from('user_subscriptions')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();
      
      if (response == null) {
        // Create default free subscription
        await _createDefaultSubscription(user.id);
        return await getCurrentSubscription();
      }
      
      // Parse response to UserSubscription entity
      return _parseUserSubscription(response);
    } catch (e) {
      Logger.error('Error getting current subscription: $e', tag: 'SUPABASE_SUB');
      return null;
    }
  }
  
  /// Create default free subscription for new users
  Future<void> _createDefaultSubscription(String userId) async {
    try {
      await _supabase.from('user_subscriptions').insert({
        'user_id': userId,
        'subscription_tier': 'free',
        'subscription_status': 'active',
        'daily_translation_limit': 10,
        'daily_ocr_limit': 5,
        'daily_voice_limit': 5,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      Logger.success('Default subscription created', tag: 'SUPABASE_SUB');
    } catch (e) {
      Logger.error('Error creating default subscription: $e', tag: 'SUPABASE_SUB');
    }
  }
  
  /// Parse Supabase response to UserSubscription entity
  UserSubscription _parseUserSubscription(Map<String, dynamic> data) {
    final tier = data['subscription_tier'] ?? 'free';
    
    return UserSubscription(
      id: data['id'],
      userId: data['user_id'],
      tier: tier,
      status: data['subscription_status'] ?? 'active',
      stripeCustomerId: data['stripe_customer_id'],
      stripeSubscriptionId: data['stripe_subscription_id'],
      stripePriceId: data['stripe_price_id'],
      billingPeriod: data['billing_period'],
      currentPeriodStart: data['current_period_start'] != null
          ? DateTime.parse(data['current_period_start'])
          : null,
      currentPeriodEnd: data['current_period_end'] != null
          ? DateTime.parse(data['current_period_end'])
          : null,
      trialStart: data['trial_start'] != null
          ? DateTime.parse(data['trial_start'])
          : null,
      trialEnd: data['trial_end'] != null
          ? DateTime.parse(data['trial_end'])
          : null,
      isTrial: data['is_trial'] ?? false,
      limits: _getLimitsForTier(tier, data),
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: DateTime.parse(data['updated_at']),
      cancelledAt: data['cancelled_at'] != null
          ? DateTime.parse(data['cancelled_at'])
          : null,
    );
  }
  
  /// Get subscription limits based on tier
  SubscriptionLimits _getLimitsForTier(String tier, Map<String, dynamic> data) {
    return SubscriptionLimits(
      dailyTranslations: data['daily_translation_limit'] ?? 10,
      dailyOCR: data['daily_ocr_limit'] ?? 5,
      dailyVoice: data['daily_voice_limit'] ?? 5,
      offlineMode: tier != 'free',
      adFree: tier != 'free',
      prioritySupport: tier == 'pro' || tier == 'premium',
    );
  }
  
  /// Create Stripe checkout session
  Future<String?> createCheckoutSession({required String priceId}) async {
    try {
      final user = _supabase.auth.currentUser;
      
      if (user == null) {
        Logger.warning('No user logged in', tag: 'SUPABASE_SUB');
        return null;
      }
      
      // Call Supabase Edge Function
      final response = await _supabase.functions.invoke(
        'create-payment-intent',
        body: {
          'priceId': priceId,
          'userId': user.id,
        },
      );
      
      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        Logger.success('Checkout session created', tag: 'SUPABASE_SUB');
        return data['url'] as String?;
      } else {
        Logger.error('Failed to create checkout session: ${response.status}',
            tag: 'SUPABASE_SUB');
        return null;
      }
    } catch (e) {
      Logger.error('Error creating checkout session: $e', tag: 'SUPABASE_SUB');
      return null;
    }
  }
  
  /// Cancel subscription with Stripe
  Future<bool> cancelSubscription({bool immediately = false}) async {
    try {
      final user = _supabase.auth.currentUser;
      
      if (user == null) {
        Logger.warning('No user logged in', tag: 'SUPABASE_SUB');
        return false;
      }
      
      // Call Supabase Edge Function
      final response = await _supabase.functions.invoke(
        'cancel-subscription',
        body: {
          'userId': user.id,
          'immediately': immediately,
        },
      );
      
      if (response.status == 200) {
        Logger.success('Subscription cancelled', tag: 'SUPABASE_SUB');
        return true;
      } else {
        Logger.error('Failed to cancel subscription: ${response.status}',
            tag: 'SUPABASE_SUB');
        return false;
      }
    } catch (e) {
      Logger.error('Error cancelling subscription: $e', tag: 'SUPABASE_SUB');
      return false;
    }
  }
  
  /// Get remaining daily limit for a usage type
  Future<int> getRemainingDailyLimit(String usageType) async {
    try {
      final user = _supabase.auth.currentUser;
      
      if (user == null) {
        Logger.warning('No user logged in', tag: 'SUPABASE_SUB');
        return 0;
      }
      
      // Get subscription limits
      final subscription = await getCurrentSubscription();
      if (subscription == null) return 0;
      
      // Get limit based on usage type
      int limit;
      switch (usageType) {
        case 'translation':
          limit = subscription.limits.dailyTranslations;
          break;
        case 'ocr':
          limit = subscription.limits.dailyOCR;
          break;
        case 'voice':
          limit = subscription.limits.dailyVoice;
          break;
        default:
          return 0;
      }
      
      // If unlimited, return -1
      if (limit == -1) return -1;
      
      // Get today's usage count
      final count = await _supabase.rpc(
        'get_daily_usage_count',
        params: {
          'p_user_id': user.id,
          'p_usage_type': usageType,
        },
      );
      
      final usageCount = count as int? ?? 0;
      final remaining = limit - usageCount;
      
      return remaining > 0 ? remaining : 0;
    } catch (e) {
      Logger.error('Error getting remaining limit: $e', tag: 'SUPABASE_SUB');
      return 0;
    }
  }
  
  /// Track usage for rate limiting
  Future<void> trackUsage({
    required String usageType,
    String? sourceLanguage,
    String? targetLanguage,
    int? characterCount,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      
      if (user == null) {
        Logger.warning('No user logged in', tag: 'SUPABASE_SUB');
        return;
      }
      
      await _supabase.from('usage_tracking').insert({
        'user_id': user.id,
        'usage_type': usageType,
        'source_language': sourceLanguage,
        'target_language': targetLanguage,
        'character_count': characterCount,
        'metadata': metadata,
        'created_at': DateTime.now().toIso8601String(),
        'date': DateTime.now().toIso8601String().split('T')[0],
      });
      
      Logger.log('Usage tracked: $usageType', tag: 'SUPABASE_SUB');
    } catch (e) {
      Logger.error('Error tracking usage: $e', tag: 'SUPABASE_SUB');
    }
  }
}
