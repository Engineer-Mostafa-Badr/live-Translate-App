import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';

/// Chrome-style bottom navigation bar
class ChromeBottomNav extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onForward;
  final VoidCallback? onHome;
  final VoidCallback? onTabs;
  final VoidCallback? onNewTab;
  final VoidCallback? onMenu;
  final bool canGoBack;
  final bool canGoForward;
  final int tabCount;
  
  const ChromeBottomNav({
    super.key,
    this.onBack,
    this.onForward,
    this.onHome,
    this.onTabs,
    this.onNewTab,
    this.onMenu,
    this.canGoBack = false,
    this.canGoForward = false,
    this.tabCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.chromeDarkSurface : AppTheme.chromeLightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.chromeDarkBorder : AppTheme.chromeLightBorder,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Back Button
          _ChromeNavButton(
            icon: Icons.arrow_back,
            onTap: canGoBack ? onBack : null,
            enabled: canGoBack,
            isDark: isDark,
            tooltip: 'Back',
          ),
          
          // Forward Button
          _ChromeNavButton(
            icon: Icons.arrow_forward,
            onTap: canGoForward ? onForward : null,
            enabled: canGoForward,
            isDark: isDark,
            tooltip: 'Forward',
          ),
          
          // Home Button
          _ChromeNavButton(
            icon: Icons.home_outlined,
            onTap: onHome,
            enabled: true,
            isDark: isDark,
            tooltip: 'Home',
          ),
          
          // Tabs Button with Badge
          _ChromeTabsButton(
            tabCount: tabCount,
            onTap: onTabs,
            isDark: isDark,
          ),
          
          // New Tab Button
          _ChromeNavButton(
            icon: Icons.add,
            onTap: onNewTab,
            enabled: true,
            isDark: isDark,
            tooltip: 'New tab',
          ),
          
          // Menu Button
          _ChromeNavButton(
            icon: Icons.more_vert,
            onTap: onMenu,
            enabled: true,
            isDark: isDark,
            tooltip: 'Menu',
          ),
        ],
      ),
    );
  }
}

/// Chrome navigation button
class _ChromeNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;
  final bool isDark;
  final String? tooltip;
  
  const _ChromeNavButton({
    required this.icon,
    this.onTap,
    required this.enabled,
    required this.isDark,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        width: 48.w,
        height: 48.h,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 24.sp,
          color: enabled
              ? (isDark ? AppTheme.chromeDarkIcon : AppTheme.chromeLightIcon)
              : (isDark 
                  ? AppTheme.chromeDarkIcon.withValues(alpha: 0.3)
                  : AppTheme.chromeLightIcon.withValues(alpha: 0.3)),
        ),
      ),
    );
    
    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    
    return button;
  }
}

/// Chrome tabs button with count badge
class _ChromeTabsButton extends StatelessWidget {
  final int tabCount;
  final VoidCallback? onTap;
  final bool isDark;
  
  const _ChromeTabsButton({
    required this.tabCount,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        width: 48.w,
        height: 48.h,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Tab icon background
            Container(
              width: 28.w,
              height: 28.h,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? AppTheme.chromeDarkIcon : AppTheme.chromeLightIcon,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4.r),
              ),
              alignment: Alignment.center,
              child: Text(
                tabCount > 99 ? ':D' : tabCount.toString(),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.chromeDarkIcon : AppTheme.chromeLightIcon,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
