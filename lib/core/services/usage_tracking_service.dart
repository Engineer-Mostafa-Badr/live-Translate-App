import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Service to track daily OCR usage and manage subscription limits
class UsageTrackingService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Observable values
  final RxInt dailyOCRAttempts = 0.obs;
  final RxInt maxDailyAttempts = 5.obs;
  final RxBool isPremium = false.obs;
  final Rx<DateTime?> lastResetDate = Rx<DateTime?>(null);
  final Rx<DateTime?> subscriptionEndDate = Rx<DateTime?>(null);
  
  // Subscription types
  static const String FREE_PLAN = 'free';
  static const String WEEKLY_PLAN = 'weekly';
  static const String MONTHLY_PLAN = 'monthly';
  static const String YEARLY_PLAN = 'yearly';
  
  // Pricing
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
  Future<UsageTrackingService> onInit() async {
    super.onInit();
    await _loadUsageData();
    await _checkAndResetDaily();
    await _checkSubscriptionStatus();
    return this;
  }
  
  /// Load usage data from local storage and Firestore
  Future<void> _loadUsageData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load from local storage first
      dailyOCRAttempts.value = prefs.getInt('daily_ocr_attempts') ?? 0;
      isPremium.value = prefs.getBool('is_premium') ?? false;
      
      final lastResetStr = prefs.getString('last_reset_date');
      if (lastResetStr != null) {
        lastResetDate.value = DateTime.parse(lastResetStr);
      }
      
      final subEndStr = prefs.getString('subscription_end_date');
      if (subEndStr != null) {
        subscriptionEndDate.value = DateTime.parse(subEndStr);
      }
      
      // Sync with Firestore if user is logged in
      final user = _auth.currentUser;
      if (user != null) {
        await _syncWithFirestore(user.uid);
      }
      
      Logger.log('Usage data loaded: Attempts=$dailyOCRAttempts, Premium=$isPremium', tag: 'USAGE');
    } catch (e) {
      Logger.error('Error loading usage data: $e', tag: 'USAGE');
    }
  }
  
  /// Sync usage data with Firestore
  Future<void> _syncWithFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        
        // Update from Firestore
        isPremium.value = data['is_premium'] ?? false;
        dailyOCRAttempts.value = data['daily_ocr_attempts'] ?? 0;
        
        if (data['subscription_end_date'] != null) {
          subscriptionEndDate.value = (data['subscription_end_date'] as Timestamp).toDate();
        }
        
        if (data['last_reset_date'] != null) {
          lastResetDate.value = (data['last_reset_date'] as Timestamp).toDate();
        }
        
        // Save to local storage
        await _saveToLocalStorage();
        
        Logger.success('Synced with Firestore', tag: 'USAGE');
      } else {
        // Create new user document
        await _createUserDocument(userId);
      }
    } catch (e) {
      Logger.error('Error syncing with Firestore: $e', tag: 'USAGE');
    }
  }
  
  /// Create new user document in Firestore
  Future<void> _createUserDocument(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'is_premium': false,
        'daily_ocr_attempts': 0,
        'max_daily_attempts': 5,
        'subscription_type': FREE_PLAN,
        'subscription_end_date': null,
        'last_reset_date': DateTime.now(),
        'created_at': FieldValue.serverTimestamp(),
      });
      
      Logger.success('User document created', tag: 'USAGE');
    } catch (e) {
      Logger.error('Error creating user document: $e', tag: 'USAGE');
    }
  }
  
  /// Save usage data to local storage
  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('daily_ocr_attempts', dailyOCRAttempts.value);
      await prefs.setBool('is_premium', isPremium.value);
      
      if (lastResetDate.value != null) {
        await prefs.setString('last_reset_date', lastResetDate.value!.toIso8601String());
      }
      
      if (subscriptionEndDate.value != null) {
        await prefs.setString('subscription_end_date', subscriptionEndDate.value!.toIso8601String());
      }
    } catch (e) {
      Logger.error('Error saving to local storage: $e', tag: 'USAGE');
    }
  }
  
  /// Check and reset daily attempts if needed
  Future<void> _checkAndResetDaily() async {
    try {
      final now = DateTime.now();
      final lastReset = lastResetDate.value;
      
      if (lastReset == null || !_isSameDay(now, lastReset)) {
        // Reset daily attempts
        dailyOCRAttempts.value = 0;
        lastResetDate.value = now;
        
        await _saveToLocalStorage();
        
        // Update Firestore
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'daily_ocr_attempts': 0,
            'last_reset_date': now,
          });
        }
        
        Logger.log('Daily attempts reset', tag: 'USAGE');
      }
    } catch (e) {
      Logger.error('Error checking daily reset: $e', tag: 'USAGE');
    }
  }
  
  /// Check if subscription is still valid
  Future<void> _checkSubscriptionStatus() async {
    try {
      if (subscriptionEndDate.value != null) {
        final now = DateTime.now();
        
        if (now.isAfter(subscriptionEndDate.value!)) {
          // Subscription expired
          isPremium.value = false;
          subscriptionEndDate.value = null;
          
          await _saveToLocalStorage();
          
          // Update Firestore
          final user = _auth.currentUser;
          if (user != null) {
            await _firestore.collection('users').doc(user.uid).update({
              'is_premium': false,
              'subscription_type': FREE_PLAN,
              'subscription_end_date': null,
            });
          }
          
          Logger.warning('Subscription expired', tag: 'USAGE');
        }
      }
    } catch (e) {
      Logger.error('Error checking subscription: $e', tag: 'USAGE');
    }
  }
  
  /// Check if user can use OCR
  bool canUseOCR() {
    if (isPremium.value) {
      return true; // Premium users have unlimited access
    }
    
    return dailyOCRAttempts.value < maxDailyAttempts.value;
  }
  
  /// Increment OCR attempts
  Future<bool> incrementOCRAttempt() async {
    try {
      if (!canUseOCR()) {
        Logger.warning('OCR limit reached', tag: 'USAGE');
        return false;
      }
      
      dailyOCRAttempts.value++;
      await _saveToLocalStorage();
      
      // Update Firestore
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'daily_ocr_attempts': FieldValue.increment(1),
        });
      }
      
      Logger.log('OCR attempt incremented: ${dailyOCRAttempts.value}/${maxDailyAttempts.value}', tag: 'USAGE');
      return true;
    } catch (e) {
      Logger.error('Error incrementing OCR attempt: $e', tag: 'USAGE');
      return false;
    }
  }
  
  /// Get remaining attempts
  int getRemainingAttempts() {
    if (isPremium.value) {
      return -1; // Unlimited
    }
    
    return maxDailyAttempts.value - dailyOCRAttempts.value;
  }
  
  /// Activate subscription
  Future<bool> activateSubscription(String subscriptionType, {String? transactionId}) async {
    try {
      final duration = SUBSCRIPTION_DURATION[subscriptionType] ?? 30;
      final endDate = DateTime.now().add(Duration(days: duration));
      
      isPremium.value = true;
      subscriptionEndDate.value = endDate;
      
      await _saveToLocalStorage();
      
      // Update Firestore
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'is_premium': true,
          'subscription_type': subscriptionType,
          'subscription_end_date': endDate,
          'last_subscription_date': DateTime.now(),
        });
        
        // Log transaction
        if (transactionId != null) {
          await _firestore.collection('transactions').add({
            'user_id': user.uid,
            'subscription_type': subscriptionType,
            'amount': SUBSCRIPTION_PRICES[subscriptionType],
            'transaction_id': transactionId,
            'timestamp': FieldValue.serverTimestamp(),
            'status': 'completed',
          });
        }
      }
      
      Logger.success('Subscription activated: $subscriptionType', tag: 'USAGE');
      return true;
    } catch (e) {
      Logger.error('Error activating subscription: $e', tag: 'USAGE');
      return false;
    }
  }
  
  /// Cancel subscription
  Future<bool> cancelSubscription() async {
    try {
      isPremium.value = false;
      subscriptionEndDate.value = null;
      
      await _saveToLocalStorage();
      
      // Update Firestore
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'is_premium': false,
          'subscription_type': FREE_PLAN,
          'subscription_end_date': null,
        });
      }
      
      Logger.log('Subscription cancelled', tag: 'USAGE');
      return true;
    } catch (e) {
      Logger.error('Error cancelling subscription: $e', tag: 'USAGE');
      return false;
    }
  }
  
  /// Get days remaining in subscription
  int getDaysRemaining() {
    if (subscriptionEndDate.value == null) {
      return 0;
    }
    
    final now = DateTime.now();
    final difference = subscriptionEndDate.value!.difference(now);
    
    return difference.inDays;
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
      'daily_attempts': dailyOCRAttempts.value,
      'max_attempts': maxDailyAttempts.value,
      'remaining_attempts': getRemainingAttempts(),
      'days_remaining': getDaysRemaining(),
      'subscription_end_date': subscriptionEndDate.value,
    };
  }
}
