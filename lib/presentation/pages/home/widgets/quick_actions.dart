import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Quick Actions Widget for HomePage
class QuickActions extends StatelessWidget {
  final VoidCallback? onOpenBrowser;
  final VoidCallback? onVoiceSearch;
  final VoidCallback? onSettings;
  final VoidCallback? onNewTab;
  final VoidCallback? onIncognito;
  
  const QuickActions({
    super.key,
    this.onOpenBrowser,
    this.onVoiceSearch,
    this.onSettings,
    this.onNewTab,
    this.onIncognito,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'إجراءات سريعة',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textDirection: TextDirection.rtl,
        ),
        SizedBox(height: 16.h),
        
        // Quick Action Buttons Grid
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            _QuickActionButton(
              icon: Icons.web,
              label: 'فتح المتصفح',
              color: Colors.blue,
              onTap: onOpenBrowser,
              isDark: isDark,
            ),
            _QuickActionButton(
              icon: Icons.add,
              label: 'تبويب جديد',
              color: Colors.green,
              onTap: onNewTab,
              isDark: isDark,
            ),
            _QuickActionButton(
              icon: Icons.privacy_tip_outlined,
              label: 'وضع التخفي',
              color: Colors.deepPurple,
              onTap: onIncognito,
              isDark: isDark,
            ),
            _QuickActionButton(
              icon: Icons.mic,
              label: 'البحث الصوتي',
              color: Colors.orange,
              onTap: onVoiceSearch,
              isDark: isDark,
            ),
            _QuickActionButton(
              icon: Icons.settings,
              label: 'الإعدادات',
              color: Colors.grey,
              onTap: onSettings,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }
}

/// Quick Action Button Widget
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isDark;
  
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: (Get.width - 48.w) / 2 - 6.w,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isDark 
              ? color.withValues(alpha: 0.2)
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32.sp,
              color: color,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}
