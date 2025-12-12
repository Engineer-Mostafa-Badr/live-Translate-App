import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Settings Section
          _buildSectionTitle(context, 'إعدادات اللغة'),
          Card(
            child: Column(
              children: [
                Obx(() => ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('اللغة الأصلية'),
                      subtitle: Text(controller.sourceLanguage.value),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: controller.selectSourceLanguage,
                    )),
                const Divider(height: 1),
                Obx(() => ListTile(
                      leading: const Icon(Icons.translate),
                      title: const Text('اللغة الهدف'),
                      subtitle: Text(controller.targetLanguage.value),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: controller.selectTargetLanguage,
                    )),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Translation Settings Section
          _buildSectionTitle(context, 'إعدادات الترجمة'),
          Card(
            child: Column(
              children: [
                Obx(() => SwitchListTile(
                      secondary: const Icon(Icons.offline_bolt),
                      title: const Text('الترجمة دون اتصال'),
                      subtitle: Text(
                        controller.offlineTranslation.value
                            ? 'مفعّل (للمشتركين فقط)'
                            : 'غير مفعّل',
                      ),
                      value: controller.offlineTranslation.value,
                      onChanged: controller.isPremium.value
                          ? controller.toggleOfflineTranslation
                          : null,
                    )),
                const Divider(height: 1),
                Obx(() => SwitchListTile(
                      secondary: const Icon(Icons.camera_alt),
                      title: const Text('وضع PaddleOCR'),
                      subtitle: Text(
                        controller.paddleOCRMode.value
                            ? 'مفعّل (للمشتركين فقط)'
                            : 'غير مفعّل',
                      ),
                      value: controller.paddleOCRMode.value,
                      onChanged: controller.isPremium.value
                          ? controller.togglePaddleOCR
                          : null,
                    )),
                const Divider(height: 1),
                Obx(() => SwitchListTile(
                      secondary: const Icon(Icons.auto_awesome),
                      title: const Text('الترجمة التلقائية'),
                      subtitle: const Text('ترجمة الصفحات تلقائيًا'),
                      value: controller.autoTranslate.value,
                      onChanged: controller.toggleAutoTranslate,
                    )),
                const Divider(height: 1),
                Obx(() => SwitchListTile(
                      secondary: const Icon(Icons.touch_app),
                      title: const Text('إظهار زر الترجمة دائمًا'),
                      subtitle: const Text('عرض زر الترجمة الحية في المتصفح'),
                      value: controller.alwaysShowTranslationFAB.value,
                      onChanged: controller.toggleAlwaysShowFAB,
                    )),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('تنزيل حزمة اللغة'),
                  subtitle: const Text('للترجمة دون اتصال بالإنترنت'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: controller.downloadLanguagePack,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Subscription Section
          _buildSectionTitle(context, 'الاشتراك'),
          Card(
            child: Column(
              children: [
                Obx(() => ListTile(
                      leading: Icon(
                        controller.isPremium.value
                            ? Icons.workspace_premium
                            : Icons.card_membership,
                        color: controller.isPremium.value
                            ? Colors.amber
                            : null,
                      ),
                      title: Text(
                        controller.isPremium.value
                            ? 'حساب متميز'
                            : 'حساب مجاني',
                      ),
                      subtitle: Text(
                        controller.isPremium.value
                            ? 'باقي ${controller.daysRemaining.value} يوم'
                            : 'ترقية للحصول على مميزات إضافية',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: controller.manageSubscription,
                    )),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // App Settings Section
          _buildSectionTitle(context, 'إعدادات التطبيق'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_off),
                  title: const Text('إدارة المحتوى دون اتصال'),
                  subtitle: const Text('OCR وحزم اللغات'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: controller.openOfflineManager,
                ),
                const Divider(height: 1),
                Obx(() => SwitchListTile(
                      secondary: const Icon(Icons.dark_mode),
                      title: const Text('الوضع الداكن'),
                      value: controller.darkMode.value,
                      onChanged: controller.toggleDarkMode,
                    )),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('الإشعارات'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: controller.openNotificationSettings,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('حول التطبيق'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: controller.showAbout,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Logout Button
          ElevatedButton.icon(
            onPressed: controller.logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('تسجيل الخروج'),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }
}
