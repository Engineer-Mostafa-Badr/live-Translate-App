import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SubscriptionSuccessPage extends StatelessWidget {
  const SubscriptionSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Animation (Placeholder - add success.json to assets)
              Icon(
                Icons.check_circle,
                size: 120.sp,
                color: const Color(0xFF4CAF50),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              
              SizedBox(height: 40.h),
              
              // Success Title
              Text(
                'subscription_activated'.tr,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
              
              SizedBox(height: 16.h),
              
              // Success Message
              Text(
                'subscription_success_message'.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
              
              SizedBox(height: 40.h),
              
              // Features Unlocked
              _buildFeaturesList().animate().fadeIn(delay: 700.ms, duration: 600.ms),
              
              SizedBox(height: 60.h),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to home
                    Get.offAllNamed('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'start_using'.tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 900.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
              
              SizedBox(height: 16.h),
              
              // View Receipt Button
              TextButton(
                onPressed: () {
                  // Navigate to subscription details
                  Get.toNamed('/subscription/details');
                },
                child: Text(
                  'view_subscription_details'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF6C63FF),
                  ),
                ),
              ).animate().fadeIn(delay: 1100.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {'icon': Icons.translate, 'text': 'unlimited_translations'.tr},
      {'icon': Icons.camera_alt, 'text': 'unlimited_ocr'.tr},
      {'icon': Icons.mic, 'text': 'unlimited_voice'.tr},
      {'icon': Icons.offline_bolt, 'text': 'offline_mode_enabled'.tr},
      {'icon': Icons.block, 'text': 'ad_free_experience'.tr},
    ];

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'features_unlocked'.tr,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          ...features.map((feature) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      color: const Color(0xFF4CAF50),
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        feature['text'] as String,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
