import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../features/overlay/overlay_controller.dart';
import '../../../features/overlay/overlay_permission_page.dart';
import 'home_controller.dart';
import '../../widgets/chrome_url_bar.dart';
import '../../widgets/chrome_menu.dart';
import '../../widgets/chrome_bottom_nav.dart';
import 'widgets/quick_actions.dart';
import 'widgets/features_grid.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.web_rounded, size: 32.sp, color: Colors.white),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'مرحباً بك في متصفح الترجمة الفورية! 👋',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              'تصفح الإنترنت مع ترجمة فورية لجميع المحتويات',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
              ),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _buildWelcomeFeature(Icons.translate, 'ترجمة فورية'),
                SizedBox(width: 16.w),
                _buildWelcomeFeature(Icons.security, 'تصفح آمن'),
                SizedBox(width: 16.w),
                _buildWelcomeFeature(Icons.speed, 'سريع'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeFeature(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.sp, color: Colors.white.withValues(alpha: 0.9)),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  Widget _buildChromeTipsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber, size: 24.sp),
                SizedBox(width: 12.w),
                Text(
                  'نصائح سريعة',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildTipItem(
              context,
              Icons.bookmark_border,
              'احفظ مواقعك المفضلة',
              'اضغط على أيقونة الإشارة المرجعية لحفظ الصفحات المهمة',
            ),
            SizedBox(height: 12.h),
            _buildTipItem(
              context,
              Icons.translate,
              'ترجمة تلقائية',
              'فعّل الترجمة الفورية لترجمة المحتوى أثناء التصفح',
            ),
            SizedBox(height: 12.h),
            _buildTipItem(
              context,
              Icons.privacy_tip_outlined,
              'وضع التخفي',
              'استخدم وضع التخفي للتصفح بدون حفظ السجل',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 20.sp, color: Theme.of(context).primaryColor),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showChromeMenu(BuildContext context) {
    ChromeMenu.show(
      context,
      onNewTab: controller.newTab,
      onNewIncognitoTab: controller.newIncognitoTab,
      onBookmarks: controller.openBookmarks,
      onHistory: controller.openHistory,
      onDownloads: controller.openDownloads,
      onSettings: controller.openSettings,
      onShare: controller.sharePage,
      onFindInPage: controller.findInPage,
      onDesktopSite: controller.toggleDesktopSite,
      isDesktopSite: controller.isDesktopSite.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final HomeController controller = Get.put(HomeController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Chrome-style URL Bar
              Obx(
                () => ChromeUrlBar(
                  controller: controller.urlController,
                  onSubmitted: controller.loadUrl,
                  onRefresh: controller.openBrowser,
                  onClear: controller.clearUrl,
                  onMicrophone: controller.voiceSearch,
                  isLoading: controller.isLoading.value,
                  pageTitle: 'ابحث أو اكتب عنوان URL',
                  currentUrl: '',
                ),
              ),

              // Main Content
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Welcome Card
                        _buildWelcomeCard(context),

                        SizedBox(height: 24.h),

                        // Quick Actions
                        QuickActions(
                          onOpenBrowser: controller.openBrowser,
                          onVoiceSearch: controller.voiceSearch,
                          onSettings: controller.openSettings,
                          onNewTab: controller.newTab,
                          onIncognito: controller.newIncognitoTab,
                        ),

                        SizedBox(height: 24.h),

                        // Features Grid
                        FeaturesGrid(
                          onBookmarks: controller.openBookmarks,
                          onHistory: controller.openHistory,
                          onDownloads: controller.openDownloads,
                          onTranslate: controller.openTextTranslation,
                          onVoiceTranslate: controller.openVoiceTranslation,
                          onCameraTranslate: controller.openCameraTranslation,
                          onShare: controller.sharePage,
                          onFindInPage: controller.findInPage,
                        ),

                        SizedBox(height: 24.h),

                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () async {
                            final hasPermission =
                                await OverlayController.checkPermission();

                            if (!hasPermission) {
                              Get.to(() => const OverlayPermissionPage());
                              return;
                            }

                            final started =
                                await OverlayController.startOverlay();

                            if (!started) {
                              Get.snackbar("خطأ", "تعذّر تشغيل الفقاعة");
                            }
                          },
                          icon: const Icon(Icons.bubble_chart, size: 26),
                          label: const Text(
                            "تشغيل الترجمه الفوريه ",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Chrome Tips Card
                        _buildChromeTipsCard(context),

                        SizedBox(height: 16.h),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        // Chrome-style Bottom Navigation
        bottomNavigationBar: ChromeBottomNav(
          onBack: () => Get.back(),
          onForward: () => controller.openBrowser(),
          onHome: () {
            // Already on home
            Get.snackbar(
              'الصفحة الرئيسية',
              'أنت بالفعل في الصفحة الرئيسية',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 1),
            );
          },
          onTabs: controller.newTab,
          onNewTab: controller.newTab,
          onMenu: () => _showChromeMenu(context),
          canGoBack: false,
          canGoForward: false,
          tabCount: 1,
        ),

        // Floating Action Button for Quick Browser Access
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openBrowser,
          backgroundColor: Theme.of(context).primaryColor,
          icon: Icon(Icons.web, size: 24.sp),
          label: Text(
            'فتح المتصفح',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          tooltip: 'فتح المتصفح المدمج',
        ),
      ),
    );
  }
}
