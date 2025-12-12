import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/subscription_controller.dart';
import '../../../domain/entities/subscription_plan.dart';

class SubscriptionPlansPage extends GetView<SubscriptionController> {
  const SubscriptionPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'subscription_plans'.tr,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 30.h),
              _buildBillingToggle(),
              SizedBox(height: 30.h),
              _buildPlanCards(),
              SizedBox(height: 30.h),
              _buildFeatureComparison(),
              SizedBox(height: 30.h),
              _buildFAQ(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/loading.json',
            width: 150.w,
            height: 150.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 20.h),
          Text(
            'loading_plans'.tr,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'choose_your_plan'.tr,
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().fadeIn(duration: 600.ms).slideX(),
        SizedBox(height: 10.h),
        Text(
          'unlock_premium_features'.tr,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white60,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              'monthly'.tr,
              !controller.isYearly.value,
              () => controller.isYearly.value = false,
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              'yearly'.tr,
              controller.isYearly.value,
              () => controller.isYearly.value = true,
              badge: 'save_20'.tr,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms);
  }

  Widget _buildToggleButton(
    String text,
    bool isSelected,
    VoidCallback onTap, {
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.white60,
                ),
              ),
            ),
            if (badge != null && isSelected)
              Positioned(
                top: -8.h,
                right: 10.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCards() {
    final plans = controller.getPlansForBillingPeriod();

    return Column(
      children: plans.asMap().entries.map((entry) {
        final index = entry.key;
        final plan = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: _buildPlanCard(plan, index),
        );
      }).toList(),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, int index) {
    final isCurrentPlan = controller.currentPlan.value?.tier == plan.tier;
    final isPopular = plan.tier == 'pro';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPopular
              ? [const Color(0xFF6C63FF), const Color(0xFF5A52D5)]
              : [const Color(0xFF1D1E33), const Color(0xFF1D1E33)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isCurrentPlan
              ? const Color(0xFF4CAF50)
              : isPopular
                  ? const Color(0xFF6C63FF)
                  : Colors.transparent,
          width: 2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: isPopular
                ? const Color(0xFF6C63FF).withOpacity(0.3)
                : Colors.black26,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          plan.description,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    if (isCurrentPlan)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'current'.tr,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${plan.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        '/ ${plan.billingPeriod}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                ...plan.features.map((feature) => _buildFeatureItem(feature)),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan
                        ? null
                        : () => controller.subscribeToPlan(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentPlan
                          ? Colors.grey
                          : isPopular
                              ? Colors.white
                              : const Color(0xFF6C63FF),
                      foregroundColor: isPopular ? const Color(0xFF6C63FF) : Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isCurrentPlan ? 'current_plan'.tr : 'subscribe_now'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: 0,
              right: 20.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.r),
                    bottomRight: Radius.circular(12.r),
                  ),
                ),
                child: Text(
                  'most_popular'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (600 + index * 200).ms, duration: 600.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: const Color(0xFF4CAF50),
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureComparison() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'feature_comparison'.tr,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),
          _buildComparisonRow('translations_per_day'.tr, '10', '100', '500', 'Unlimited'),
          _buildComparisonRow('ocr_scans_per_day'.tr, '5', '50', '200', 'Unlimited'),
          _buildComparisonRow('voice_translations'.tr, '5', '50', '200', 'Unlimited'),
          _buildComparisonRow('offline_mode'.tr, '✗', '✓', '✓', '✓'),
          _buildComparisonRow('ad_free'.tr, '✗', '✓', '✓', '✓'),
          _buildComparisonRow('priority_support'.tr, '✗', '✗', '✓', '✓'),
          _buildComparisonRow('advanced_features'.tr, '✗', '✗', '✗', '✓'),
        ],
      ),
    ).animate().fadeIn(delay: 1200.ms, duration: 600.ms);
  }

  Widget _buildComparisonRow(
    String feature,
    String free,
    String basic,
    String pro,
    String premium,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white70,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                free,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white60,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                basic,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                pro,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF6C63FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                premium,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'faq'.tr,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),
          _buildFAQItem(
            'can_i_cancel_anytime'.tr,
            'yes_cancel_anytime'.tr,
          ),
          _buildFAQItem(
            'what_payment_methods'.tr,
            'we_accept_cards'.tr,
          ),
          _buildFAQItem(
            'is_there_free_trial'.tr,
            'yes_7_days_trial'.tr,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1400.ms, duration: 600.ms);
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            answer,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
