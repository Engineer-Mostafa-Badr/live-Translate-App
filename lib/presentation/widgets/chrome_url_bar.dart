import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';

/// Chrome-style URL bar widget
class ChromeUrlBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSubmitted;
  final VoidCallback? onRefresh;
  final VoidCallback? onClear;
  final VoidCallback? onMicrophone;
  final bool isLoading;
  final String? pageTitle;
  final String? currentUrl;
  final double loadingProgress;
  
  const ChromeUrlBar({
    super.key,
    required this.controller,
    this.onSubmitted,
    this.onRefresh,
    this.onClear,
    this.onMicrophone,
    this.isLoading = false,
    this.pageTitle,
    this.currentUrl,
    this.loadingProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSecure = currentUrl?.startsWith('https://') ?? false;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.chromeDarkSurface : AppTheme.chromeLightSurface,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppTheme.chromeDarkBorder : AppTheme.chromeLightBorder,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Leading Icon (Lock/Globe) - Shows secure status
              Icon(
                isSecure ? Icons.lock : Icons.public,
                size: 18.sp,
                color: isSecure 
                    ? Colors.green 
                    : (isDark ? AppTheme.chromeDarkIcon : AppTheme.chromeLightIcon),
              ),
              
              SizedBox(width: 8.w),
              
              // URL TextField Container
              Expanded(
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: isDark 
                        ? AppTheme.chromeDarkBackground.withValues(alpha: 0.3)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: isDark ? AppTheme.chromeDarkBorder : AppTheme.chromeLightBorder,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Search Icon
                      Padding(
                        padding: EdgeInsets.only(left: 12.w, right: 8.w),
                        child: Icon(
                          Icons.search,
                          size: 18.sp,
                          color: isDark ? AppTheme.chromeDarkIcon : AppTheme.chromeLightIcon,
                        ),
                      ),
                      
                      // URL TextField
                      Expanded(
                        child: TextField(
                          controller: controller,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark ? AppTheme.chromeDarkUrlText : AppTheme.chromeLightUrlText,
                          ),
                          decoration: InputDecoration(
                            hintText: pageTitle?.isNotEmpty == true ? pageTitle : 'Search or type URL',
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              color: isDark 
                                  ? AppTheme.chromeDarkIcon 
                                  : AppTheme.chromeLightIcon,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          onSubmitted: (_) => onSubmitted?.call(),
                        ),
                      ),
                      
                      // Clear Button
                      if (controller.text.isNotEmpty)
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 18.sp,
                            color: isDark ? AppTheme.chromeDarkIcon : AppTheme.chromeLightIcon,
                          ),
                          onPressed: onClear,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Clear',
                        ),
                      
                      // Microphone Button
                      IconButton(
                        icon: Icon(
                          Icons.mic_none,
                          size: 18.sp,
                          color: isDark ? AppTheme.chromeDarkIcon : AppTheme.chromeLightIcon,
                        ),
                        onPressed: onMicrophone,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Voice search',
                      ),
                      
                      SizedBox(width: 8.w),
                    ],
                  ),
                ),
              ),
              
              SizedBox(width: 8.w),
              
              // Reload Button
              IconButton(
                icon: isLoading
                    ? SizedBox(
                        width: 18.sp,
                        height: 18.sp,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? AppTheme.chromeDarkIcon : AppTheme.chromeLightIcon,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.refresh,
                        size: 22.sp,
                        color: isDark ? AppTheme.chromeDarkIcon : AppTheme.chromeLightIcon,
                      ),
                onPressed: isLoading ? null : onRefresh,
                padding: EdgeInsets.all(8.w),
                tooltip: 'Reload',
              ),
            ],
          ),
        ),
        
        // Loading Progress Bar
        if (isLoading && loadingProgress > 0)
          LinearProgressIndicator(
            value: loadingProgress,
            minHeight: 2,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
      ],
    );
  }
}
