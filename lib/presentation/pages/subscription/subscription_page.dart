import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'subscription_controller.dart';

class SubscriptionPage extends GetView<SubscriptionController> {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SubscriptionController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('خطط الاشتراك'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'اختر الخطة المناسبة لك',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            
            const SizedBox(height: 8),
            
            Text(
              'استمتع بمميزات حصرية مع الخطة المتميزة',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
            
            const SizedBox(height: 32),
            
            // Free Plan
            _buildPlanCard(
              context,
              title: 'خطة مجانية',
              price: 'مجانًا',
              period: 'للأبد',
              features: [
                'ترجمة أساسية',
                'حد أقصى 100 ترجمة يوميًا',
                'دعم 10 لغات',
                'إعلانات',
              ],
              color: Colors.grey,
              isCurrentPlan: !controller.isPremium.value,
              onSelect: () => controller.selectFreePlan(),
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2, end: 0),
            
            const SizedBox(height: 16),
            
            // Premium Plan
            _buildPlanCard(
              context,
              title: 'خطة متميزة',
              price: '29.99 ر.س',
              period: 'شهريًا',
              features: [
                'ترجمة غير محدودة',
                'ترجمة دون اتصال',
                'دعم +100 لغة',
                'وضع PaddleOCR',
                'بدون إعلانات',
                'دعم فني متميز',
              ],
              color: Theme.of(context).primaryColor,
              isCurrentPlan: controller.isPremium.value,
              isPremium: true,
              onSelect: () => controller.selectPremiumPlan(),
            ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2, end: 0),
            
            const SizedBox(height: 32),
            
            // Current Subscription Info
            Obx(() {
              if (controller.isPremium.value) {
                return Card(
                  color: Colors.amber.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.workspace_premium,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'اشتراكك النشط',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'باقي ${controller.daysRemaining.value} يوم',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: controller.daysRemaining.value / 30,
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.amber),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: controller.renewSubscription,
                                child: const Text('تجديد'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: controller.cancelSubscription,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                                child: const Text('إلغاء'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms);
              }
              return const SizedBox.shrink();
            }),
            
            const SizedBox(height: 24),
            
            // Features Comparison
            Text(
              'مقارنة المميزات',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 600.ms),
            
            const SizedBox(height: 16),
            
            _buildFeatureComparison(
              context,
              feature: 'عدد الترجمات',
              free: '100/يوم',
              premium: 'غير محدود',
            ).animate().fadeIn(delay: 700.ms),
            
            _buildFeatureComparison(
              context,
              feature: 'الترجمة دون اتصال',
              free: '✗',
              premium: '✓',
            ).animate().fadeIn(delay: 750.ms),
            
            _buildFeatureComparison(
              context,
              feature: 'وضع PaddleOCR',
              free: '✗',
              premium: '✓',
            ).animate().fadeIn(delay: 800.ms),
            
            _buildFeatureComparison(
              context,
              feature: 'الإعلانات',
              free: 'نعم',
              premium: 'لا',
            ).animate().fadeIn(delay: 850.ms),
            
            _buildFeatureComparison(
              context,
              feature: 'الدعم الفني',
              free: 'عادي',
              premium: 'متميز',
            ).animate().fadeIn(delay: 900.ms),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required Color color,
    required bool isCurrentPlan,
    bool isPremium = false,
    required VoidCallback onSelect,
  }) {
    return Card(
      elevation: isPremium ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPremium
            ? BorderSide(color: color, width: 2)
            : BorderSide.none,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isPremium
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.1),
                    Colors.white,
                  ],
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Title
            Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                if (isPremium) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.star, color: Colors.amber, size: 24),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    period,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Features
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: color,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
            
            const SizedBox(height: 24),
            
            // Select Button
            SizedBox(
              width: double.infinity,
              child: isCurrentPlan
                  ? OutlinedButton(
                      onPressed: null,
                      child: const Text('الخطة الحالية'),
                    )
                  : ElevatedButton(
                      onPressed: onSelect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(isPremium ? 'اشترك الآن' : 'اختر هذه الخطة'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureComparison(
    BuildContext context, {
    required String feature,
    required String free,
    required String premium,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              free,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              premium,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
