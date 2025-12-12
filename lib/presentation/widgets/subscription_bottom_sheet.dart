import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';

/// Bottom sheet to show subscription options when daily attempts are exhausted
class SubscriptionBottomSheet extends StatelessWidget {
  final int remainingAttempts;
  final int maxAttempts;
  
  const SubscriptionBottomSheet({
    super.key,
    required this.remainingAttempts,
    required this.maxAttempts,
  });
  
  /// Show the subscription bottom sheet
  static Future<void> show({
    int remainingAttempts = 0,
    int maxAttempts = 5,
  }) {
    return Get.bottomSheet(
      SubscriptionBottomSheet(
        remainingAttempts: remainingAttempts,
        maxAttempts: maxAttempts,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isLimitReached = remainingAttempts <= 0;
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Icon and title
                  _buildHeader(context, isLimitReached),
                  
                  const SizedBox(height: 24),
                  
                  // Usage info
                  if (!isLimitReached) _buildUsageInfo(context),
                  
                  const SizedBox(height: 24),
                  
                  // Subscription plans
                  _buildSubscriptionPlans(context),
                  
                  const SizedBox(height: 16),
                  
                  // Close button
                  if (!isLimitReached)
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('ليس الآن'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 300.ms);
  }
  
  Widget _buildHeader(BuildContext context, bool isLimitReached) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLimitReached 
                ? Colors.red.withValues(alpha: 0.1)
                : Colors.orange.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isLimitReached ? Icons.block : Icons.warning_amber,
            color: isLimitReached ? Colors.red : Colors.orange,
            size: 48,
          ),
        ).animate().scale(delay: 100.ms),
        
        const SizedBox(height: 16),
        
        Text(
          isLimitReached 
              ? 'انتهت محاولاتك اليومية!'
              : 'محاولاتك على وشك الانتهاء',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
        
        const SizedBox(height: 8),
        
        Text(
          isLimitReached
              ? 'اشترك الآن للحصول على محاولات غير محدودة'
              : 'اشترك للاستمتاع بمحاولات غير محدودة',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }
  
  Widget _buildUsageInfo(BuildContext context) {
    final progress = remainingAttempts / maxAttempts;
    
    return Card(
      color: Colors.blue.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'المحاولات المتبقية',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$remainingAttempts / $maxAttempts',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                remainingAttempts <= 2 ? Colors.red : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
  
  Widget _buildSubscriptionPlans(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'اختر خطة الاشتراك',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        
        const SizedBox(height: 16),
        
        // Weekly plan
        _buildPlanCard(
          context,
          title: 'أسبوعي',
          price: '\$5',
          period: 'أسبوع',
          color: Colors.green,
          onTap: () {
            Get.back();
            Get.toNamed(AppRoutes.enhancedSubscription);
          },
        ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2, end: 0),
        
        const SizedBox(height: 12),
        
        // Monthly plan (recommended)
        _buildPlanCard(
          context,
          title: 'شهري',
          price: '\$10',
          period: 'شهر',
          color: Theme.of(context).primaryColor,
          isRecommended: true,
          onTap: () {
            Get.back();
            Get.toNamed(AppRoutes.enhancedSubscription);
          },
        ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.95, 0.95)),
        
        const SizedBox(height: 12),
        
        // Yearly plan (best value)
        _buildPlanCard(
          context,
          title: 'سنوي',
          price: '\$30',
          period: 'سنة',
          originalPrice: '\$120',
          discount: '75% توفير',
          color: Colors.amber[700]!,
          onTap: () {
            Get.back();
            Get.toNamed(AppRoutes.enhancedSubscription);
          },
        ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.2, end: 0),
      ],
    );
  }
  
  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    String? originalPrice,
    String? discount,
    required Color color,
    bool isRecommended = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isRecommended ? color : Colors.grey[300]!,
            width: isRecommended ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isRecommended 
              ? color.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.workspace_premium,
                color: color,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Plan details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: color,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'الأكثر شعبية',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (originalPrice != null) ...[
                        Text(
                          originalPrice,
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        '$price / $period',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (discount != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            discount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
