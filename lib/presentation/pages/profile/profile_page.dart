import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Avatar
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().scale(duration: 600.ms),
            
            const SizedBox(height: 16),
            
            // User Name
            Obx(() => Text(
                  controller.userName.value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                )).animate().fadeIn(delay: 200.ms),
            
            const SizedBox(height: 4),
            
            // User Email
            Obx(() => Text(
                  controller.userEmail.value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                )).animate().fadeIn(delay: 300.ms),
            
            const SizedBox(height: 8),
            
            // Subscription Badge
            Obx(() => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: controller.isPremium.value
                        ? Colors.amber.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.isPremium.value
                            ? Icons.workspace_premium
                            : Icons.card_membership,
                        size: 20,
                        color: controller.isPremium.value
                            ? Colors.amber
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        controller.isPremium.value
                            ? 'حساب متميز'
                            : 'حساب مجاني',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: controller.isPremium.value
                              ? Colors.amber[700]
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                )).animate().fadeIn(delay: 400.ms),
            
            const SizedBox(height: 32),
            
            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.translate,
                    title: 'الترجمات',
                    value: '1,234',
                    color: Colors.blue,
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2, end: 0),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.web,
                    title: 'الصفحات',
                    value: '567',
                    color: Colors.green,
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.2, end: 0),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Profile Options
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('تعديل الملف الشخصي'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: controller.editProfile,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('تغيير كلمة المرور'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: controller.changePassword,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('سجل الترجمات'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: controller.viewHistory,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: const Text('المفضلة'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: controller.viewFavorites,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 700.ms),
            
            const SizedBox(height: 24),
            
            // Manage Subscription Button
            Obx(() => controller.isPremium.value
                ? ElevatedButton.icon(
                    onPressed: controller.manageSubscription,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.workspace_premium),
                    label: const Text('إدارة الاشتراك'),
                  )
                : ElevatedButton.icon(
                    onPressed: controller.upgradeSubscription,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    icon: const Icon(Icons.star),
                    label: const Text('الترقية إلى متميز'),
                  )).animate().fadeIn(delay: 800.ms),
            
            const SizedBox(height: 12),
            
            // Logout Button
            OutlinedButton.icon(
              onPressed: controller.logout,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('تسجيل الخروج'),
            ).animate().fadeIn(delay: 900.ms),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
