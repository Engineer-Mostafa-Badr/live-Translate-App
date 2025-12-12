import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';

/// Chrome-style menu bottom sheet
class ChromeMenu {
  static void show(
    BuildContext context, {
    VoidCallback? onNewTab,
    VoidCallback? onNewIncognitoTab,
    VoidCallback? onBookmarks,
    VoidCallback? onHistory,
    VoidCallback? onDownloads,
    VoidCallback? onSettings,
    VoidCallback? onShare,
    VoidCallback? onFindInPage,
    VoidCallback? onDesktopSite,
    VoidCallback? onTranslate,
    bool isDesktopSite = false,
    bool isTranslating = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.chromeDarkSurface
              : AppTheme.chromeLightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.chromeDarkIcon.withValues(alpha: 0.3)
                      : AppTheme.chromeLightIcon.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Menu Items
              _MenuItem(
                icon: Icons.add,
                title: 'New tab',
                onTap: () {
                  Navigator.pop(context);
                  onNewTab?.call();
                },
                isDark: isDark,
              ),

              _MenuItem(
                icon: Icons.privacy_tip_outlined,
                title: 'New incognito tab',
                onTap: () {
                  Navigator.pop(context);
                  onNewIncognitoTab?.call();
                },
                isDark: isDark,
              ),

              Divider(
                height: 1,
                color: isDark
                    ? AppTheme.chromeDarkBorder
                    : AppTheme.chromeLightBorder,
              ),

              _MenuItem(
                icon: Icons.bookmark_border,
                title: 'Bookmarks',
                onTap: () {
                  Navigator.pop(context);
                  onBookmarks?.call();
                },
                isDark: isDark,
              ),

              _MenuItem(
                icon: Icons.history,
                title: 'History',
                onTap: () {
                  Navigator.pop(context);
                  onHistory?.call();
                },
                isDark: isDark,
              ),

              _MenuItem(
                icon: Icons.download_outlined,
                title: 'Downloads',
                onTap: () {
                  Navigator.pop(context);
                  onDownloads?.call();
                },
                isDark: isDark,
              ),

              Divider(
                height: 1,
                color: isDark
                    ? AppTheme.chromeDarkBorder
                    : AppTheme.chromeLightBorder,
              ),

              _MenuItem(
                icon: Icons.share_outlined,
                title: 'Share',
                onTap: () {
                  Navigator.pop(context);
                  onShare?.call();
                },
                isDark: isDark,
              ),

              _MenuItem(
                icon: Icons.search,
                title: 'Find in page',
                onTap: () {
                  Navigator.pop(context);
                  onFindInPage?.call();
                },
                isDark: isDark,
              ),

              // Translation Option (Google Chrome style)
              _MenuItem(
                icon: Icons.g_translate,
                title: isTranslating ? 'إيقاف الترجمة' : 'ترجمة الصفحة',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isTranslating ? Colors.green : Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isTranslating ? 'نشط' : 'جديد',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onTranslate?.call();
                },
                isDark: isDark,
              ),

              _MenuItem(
                icon: Icons.computer,
                title: 'Desktop site',
                trailing: Switch(
                  value: isDesktopSite,
                  onChanged: (value) {
                    Navigator.pop(context);
                    onDesktopSite?.call();
                  },
                  activeThumbColor: Theme.of(context).primaryColor,
                ),
                onTap: () {
                  Navigator.pop(context);
                  onDesktopSite?.call();
                },
                isDark: isDark,
              ),

              Divider(
                height: 1,
                color: isDark
                    ? AppTheme.chromeDarkBorder
                    : AppTheme.chromeLightBorder,
              ),

              _MenuItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  onSettings?.call();
                },
                isDark: isDark,
              ),

              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}

/// Menu item widget
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDark;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: isDark
                  ? AppTheme.chromeDarkIcon
                  : AppTheme.chromeLightIcon,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: isDark
                      ? AppTheme.chromeDarkText
                      : AppTheme.chromeLightText,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
