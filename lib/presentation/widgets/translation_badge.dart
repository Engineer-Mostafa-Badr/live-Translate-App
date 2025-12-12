import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Live Translation badge overlay indicator
class TranslationBadge extends StatelessWidget {
  final bool isActive;
  final String sourceLanguage;
  final String targetLanguage;
  final bool showTemporary;
  
  const TranslationBadge({
    super.key,
    required this.isActive,
    this.sourceLanguage = 'EN',
    this.targetLanguage = 'AR',
    this.showTemporary = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) return const SizedBox.shrink();
    
    return Positioned(
      top: 80.h,
      right: 16.w,
      child: _buildBadge(context),
    );
  }
  
  Widget _buildBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade400,
            Colors.green.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated translate icon
          Icon(
            Icons.translate,
            color: Colors.white,
            size: 18.sp,
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.5)),
          
          SizedBox(width: 8.w),
          
          // Language indicator
          Text(
            '$sourceLanguage → $targetLanguage',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(width: 4.w),
          
          // Active indicator dot
          Container(
            width: 8.w,
            height: 8.h,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .fadeOut(duration: 800.ms)
              .then()
              .fadeIn(duration: 800.ms),
        ],
      ),
    )
        .animate()
        .slideX(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOut)
        .fadeIn();
  }
}

/// Temporary notification badge for translation activation
class TranslationActivatedNotification extends StatelessWidget {
  final VoidCallback? onDismiss;
  
  const TranslationActivatedNotification({
    super.key,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      onDismiss?.call();
    });
    
    return Positioned(
      top: 80.h,
      left: 16.w,
      right: 16.w,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Live Translation Active',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Analyzing page content...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.white,
                size: 20.sp,
              ),
              onPressed: onDismiss,
            ),
          ],
        ),
      )
          .animate()
          .slideY(begin: -1, end: 0, duration: 400.ms, curve: Curves.easeOut)
          .fadeIn(),
    );
  }
}
