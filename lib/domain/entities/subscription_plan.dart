import 'package:equatable/equatable.dart';

/// Subscription Plan Entity
/// Represents a subscription tier with its features and pricing
class SubscriptionPlan extends Equatable {
  final String id;
  final String tier; // free, basic, pro, premium
  final String name;
  final String description;
  final double price;
  final String billingPeriod; // monthly, yearly
  final String stripePriceId;
  final List<String> features;
  final SubscriptionLimits limits;
  final bool isPopular;
  final int? trialDays;

  const SubscriptionPlan({
    required this.id,
    required this.tier,
    required this.name,
    required this.description,
    required this.price,
    required this.billingPeriod,
    required this.stripePriceId,
    required this.features,
    required this.limits,
    this.isPopular = false,
    this.trialDays,
  });

  /// Free plan factory
  factory SubscriptionPlan.free() {
    return const SubscriptionPlan(
      id: 'free',
      tier: 'free',
      name: 'Free',
      description: 'Basic features for casual users',
      price: 0,
      billingPeriod: 'monthly',
      stripePriceId: '',
      features: [
        '10 translations per day',
        '5 OCR scans per day',
        '5 voice translations per day',
        'Basic features only',
        'Ads supported',
      ],
      limits: SubscriptionLimits(
        dailyTranslations: 10,
        dailyOCR: 5,
        dailyVoice: 5,
        offlineMode: false,
        adFree: false,
        prioritySupport: false,
      ),
    );
  }

  /// Basic plan factory
  factory SubscriptionPlan.basic({
    required String billingPeriod,
    required String stripePriceId,
  }) {
    final isYearly = billingPeriod == 'yearly';
    return SubscriptionPlan(
      id: 'basic_$billingPeriod',
      tier: 'basic',
      name: 'Basic',
      description: 'Perfect for regular users',
      price: isYearly ? 49.99 : 4.99,
      billingPeriod: billingPeriod,
      stripePriceId: stripePriceId,
      features: [
        '100 translations per day',
        '50 OCR scans per day',
        '50 voice translations per day',
        'Offline mode',
        'Ad-free experience',
        'Email support',
      ],
      limits: const SubscriptionLimits(
        dailyTranslations: 100,
        dailyOCR: 50,
        dailyVoice: 50,
        offlineMode: true,
        adFree: true,
        prioritySupport: false,
      ),
      trialDays: 7,
    );
  }

  /// Pro plan factory
  factory SubscriptionPlan.pro({
    required String billingPeriod,
    required String stripePriceId,
  }) {
    final isYearly = billingPeriod == 'yearly';
    return SubscriptionPlan(
      id: 'pro_$billingPeriod',
      tier: 'pro',
      name: 'Pro',
      description: 'For power users and professionals',
      price: isYearly ? 99.99 : 9.99,
      billingPeriod: billingPeriod,
      stripePriceId: stripePriceId,
      features: [
        '500 translations per day',
        '200 OCR scans per day',
        '200 voice translations per day',
        'Offline mode',
        'Ad-free experience',
        'Priority support',
        'Advanced features',
      ],
      limits: const SubscriptionLimits(
        dailyTranslations: 500,
        dailyOCR: 200,
        dailyVoice: 200,
        offlineMode: true,
        adFree: true,
        prioritySupport: true,
      ),
      isPopular: true,
      trialDays: 7,
    );
  }

  /// Premium plan factory
  factory SubscriptionPlan.premium({
    required String billingPeriod,
    required String stripePriceId,
  }) {
    final isYearly = billingPeriod == 'yearly';
    return SubscriptionPlan(
      id: 'premium_$billingPeriod',
      tier: 'premium',
      name: 'Premium',
      description: 'Unlimited everything',
      price: isYearly ? 199.99 : 19.99,
      billingPeriod: billingPeriod,
      stripePriceId: stripePriceId,
      features: [
        'Unlimited translations',
        'Unlimited OCR scans',
        'Unlimited voice translations',
        'Offline mode',
        'Ad-free experience',
        'Priority support',
        'All advanced features',
        'Early access to new features',
      ],
      limits: const SubscriptionLimits(
        dailyTranslations: -1, // -1 = unlimited
        dailyOCR: -1,
        dailyVoice: -1,
        offlineMode: true,
        adFree: true,
        prioritySupport: true,
      ),
      trialDays: 14,
    );
  }

  /// Check if plan is unlimited
  bool get isUnlimited => limits.dailyTranslations == -1;

  /// Get monthly equivalent price
  double get monthlyPrice {
    if (billingPeriod == 'yearly') {
      return price / 12;
    }
    return price;
  }

  /// Get savings percentage for yearly plans
  double get savingsPercentage {
    if (billingPeriod == 'yearly') {
      return 20.0; // Assuming 20% discount for yearly
    }
    return 0.0;
  }

  @override
  List<Object?> get props => [
        id,
        tier,
        name,
        description,
        price,
        billingPeriod,
        stripePriceId,
        features,
        limits,
        isPopular,
        trialDays,
      ];
}

/// Subscription Limits
class SubscriptionLimits extends Equatable {
  final int dailyTranslations; // -1 = unlimited
  final int dailyOCR;
  final int dailyVoice;
  final bool offlineMode;
  final bool adFree;
  final bool prioritySupport;

  const SubscriptionLimits({
    required this.dailyTranslations,
    required this.dailyOCR,
    required this.dailyVoice,
    required this.offlineMode,
    required this.adFree,
    required this.prioritySupport,
  });

  /// Check if limit is unlimited
  bool get isUnlimitedTranslations => dailyTranslations == -1;
  bool get isUnlimitedOCR => dailyOCR == -1;
  bool get isUnlimitedVoice => dailyVoice == -1;

  @override
  List<Object?> get props => [
        dailyTranslations,
        dailyOCR,
        dailyVoice,
        offlineMode,
        adFree,
        prioritySupport,
      ];
}

/// User Subscription Entity
/// Represents a user's active subscription
class UserSubscription extends Equatable {
  final String id;
  final String userId;
  final String tier;
  final String status; // active, cancelled, expired, paused
  final String? stripeCustomerId;
  final String? stripeSubscriptionId;
  final String? stripePriceId;
  final String? billingPeriod;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime? trialStart;
  final DateTime? trialEnd;
  final bool isTrial;
  final SubscriptionLimits limits;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? cancelledAt;

  const UserSubscription({
    required this.id,
    required this.userId,
    required this.tier,
    required this.status,
    this.stripeCustomerId,
    this.stripeSubscriptionId,
    this.stripePriceId,
    this.billingPeriod,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.trialStart,
    this.trialEnd,
    this.isTrial = false,
    required this.limits,
    required this.createdAt,
    required this.updatedAt,
    this.cancelledAt,
  });

  /// Check if subscription is active
  bool get isActive {
    if (status != 'active') return false;
    if (currentPeriodEnd == null) return true;
    return currentPeriodEnd!.isAfter(DateTime.now());
  }

  /// Check if in trial period
  bool get isInTrial {
    if (!isTrial || trialEnd == null) return false;
    return trialEnd!.isAfter(DateTime.now());
  }

  /// Days remaining in current period
  int get daysRemaining {
    if (currentPeriodEnd == null) return 0;
    return currentPeriodEnd!.difference(DateTime.now()).inDays;
  }

  /// Copy with method
  UserSubscription copyWith({
    String? id,
    String? userId,
    String? tier,
    String? status,
    String? stripeCustomerId,
    String? stripeSubscriptionId,
    String? stripePriceId,
    String? billingPeriod,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    DateTime? trialStart,
    DateTime? trialEnd,
    bool? isTrial,
    SubscriptionLimits? limits,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cancelledAt,
  }) {
    return UserSubscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tier: tier ?? this.tier,
      status: status ?? this.status,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      stripeSubscriptionId: stripeSubscriptionId ?? this.stripeSubscriptionId,
      stripePriceId: stripePriceId ?? this.stripePriceId,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      currentPeriodStart: currentPeriodStart ?? this.currentPeriodStart,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      trialStart: trialStart ?? this.trialStart,
      trialEnd: trialEnd ?? this.trialEnd,
      isTrial: isTrial ?? this.isTrial,
      limits: limits ?? this.limits,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        tier,
        status,
        stripeCustomerId,
        stripeSubscriptionId,
        stripePriceId,
        billingPeriod,
        currentPeriodStart,
        currentPeriodEnd,
        trialStart,
        trialEnd,
        isTrial,
        limits,
        createdAt,
        updatedAt,
        cancelledAt,
      ];
}
