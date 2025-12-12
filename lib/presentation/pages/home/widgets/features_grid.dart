import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Features Grid Widget for HomePage
class FeaturesGrid extends StatelessWidget {
  final VoidCallback? onBookmarks;
  final VoidCallback? onHistory;
  final VoidCallback? onDownloads;
  final VoidCallback? onTranslate;
  final VoidCallback? onVoiceTranslate;
  final VoidCallback? onCameraTranslate;
  final VoidCallback? onShare;
  final VoidCallback? onFindInPage;
  
  const FeaturesGrid({
    super.key,
    this.onBookmarks,
    this.onHistory,
    this.onDownloads,
    this.onTranslate,
    this.onVoiceTranslate,
    this.onCameraTranslate,
    this.onShare,
    this.onFindInPage,
  });

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.translate,
        'title': 'ترجمة نصية',
        'description': 'ترجمة فورية للنصوص',
        'color': Colors.blue,
        'onTap': onTranslate,
      },
      {
        'icon': Icons.mic,
        'title': 'ترجمة صوتية',
        'description': 'تحدث واحصل على الترجمة',
        'color': Colors.orange,
        'onTap': onVoiceTranslate,
      },
      {
        'icon': Icons.camera_alt,
        'title': 'ترجمة مرئية',
        'description': 'التقط صورة وترجمها',
        'color': Colors.purple,
        'onTap': onCameraTranslate,
      },
      {
        'icon': Icons.bookmark_border,
        'title': 'الإشارات المرجعية',
        'description': 'المواقع المحفوظة',
        'color': Colors.amber,
        'onTap': onBookmarks,
      },
      {
        'icon': Icons.history,
        'title': 'السجل',
        'description': 'عرض سجل التصفح',
        'color': Colors.green,
        'onTap': onHistory,
      },
      {
        'icon': Icons.download_outlined,
        'title': 'التنزيلات',
        'description': 'الملفات المحملة',
        'color': Colors.teal,
        'onTap': onDownloads,
      },
      {
        'icon': Icons.share_outlined,
        'title': 'مشاركة',
        'description': 'شارك الصفحة',
        'color': Colors.indigo,
        'onTap': onShare,
      },
      {
        'icon': Icons.search,
        'title': 'البحث في الصفحة',
        'description': 'ابحث عن نص',
        'color': Colors.red,
        'onTap': onFindInPage,
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'الميزات الرئيسية',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textDirection: TextDirection.rtl,
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.0,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return _FeatureCard(
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              description: feature['description'] as String,
              color: feature['color'] as Color,
              onTap: feature['onTap'] as VoidCallback?,
            );
          },
        ),
      ],
    );
  }
}

/// Feature Card Widget
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback? onTap;
  
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark 
                    ? color.withValues(alpha: 0.2)
                    : color.withValues(alpha: 0.1),
                isDark 
                    ? color.withValues(alpha: 0.1)
                    : color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32.sp,
                  color: color,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
