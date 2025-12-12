import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'enhanced_subscription_controller.dart';

class EnhancedSubscriptionPage extends GetView<EnhancedSubscriptionController> {
  const EnhancedSubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(EnhancedSubscriptionController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('خطط الاشتراك'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(context),
              
              const SizedBox(height: 32),
              
              // Current Usage Info (if free user)
              if (!controller.isPremium.value) _buildUsageInfo(context),
              
              // Subscription Plans
              _buildSubscriptionPlans(context),
              
              const SizedBox(height: 24),
              
              // Current Subscription Info (if premium)
              if (controller.isPremium.value) _buildCurrentSubscription(context),
              
              const SizedBox(height: 24),
              
              // Features Comparison
              _buildFeaturesComparison(context),
              
              const SizedBox(height: 24),
              
              // FAQ
              _buildFAQ(context),
            ],
          ),
        );
      }),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.workspace_premium,
          size: 64,
          color: Theme.of(context).primaryColor,
        ).animate().scale(delay: 100.ms),
        
        const SizedBox(height: 16),
        
        Text(
          'اختر الخطة المناسبة لك',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
        
        const SizedBox(height: 8),
        
        Text(
          'استمتع بترجمة غير محدودة وميزات حصرية',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }
  
  Widget _buildUsageInfo(BuildContext context) {
    final remaining = controller.remainingAttempts.value;
    final total = controller.maxDailyAttempts.value;
    final progress = remaining / total;
    
    return Card(
      color: remaining <= 2 ? Colors.red.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  remaining <= 2 ? Icons.warning_amber : Icons.info_outline,
                  color: remaining <= 2 ? Colors.red : Colors.blue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'المحاولات المتبقية اليوم',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Text(
                  '$remaining / $total',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: remaining <= 2 ? Colors.red : Colors.blue,
                      ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                remaining <= 2 ? Colors.red : Colors.blue,
              ),
            ),
            
            if (remaining <= 2) ...[
              const SizedBox(height: 12),
              Text(
                'محاولاتك على وشك الانتهاء! اشترك للحصول على محاولات غير محدودة',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red[700],
                    ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
  
  Widget _buildSubscriptionPlans(BuildContext context) {
    return Column(
      children: [
        // Weekly Plan
        _buildPlanCard(
          context,
          title: 'أسبوعي',
          price: '\$5',
          period: 'أسبوع',
          duration: 7,
          features: [
            'محاولات OCR غير محدودة',
            'ترجمة دون اتصال',
            'دعم جميع اللغات',
            'بدون إعلانات',
          ],
          color: Colors.green,
          planType: 'weekly',
        ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2, end: 0),
        
        const SizedBox(height: 16),
        
        // Monthly Plan (Most Popular)
        _buildPlanCard(
          context,
          title: 'شهري',
          price: '\$10',
          period: 'شهر',
          duration: 30,
          features: [
            'محاولات OCR غير محدودة',
            'ترجمة دون اتصال',
            'دعم جميع اللغات',
            'بدون إعلانات',
            'دعم فني أولوية',
          ],
          color: Theme.of(context).primaryColor,
          planType: 'monthly',
          isPopular: true,
        ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
        
        const SizedBox(height: 16),
        
        // Yearly Plan (Best Value)
        _buildPlanCard(
          context,
          title: 'سنوي',
          price: '\$30',
          period: 'سنة',
          duration: 365,
          originalPrice: '\$120',
          discount: '75% توفير',
          features: [
            'محاولات OCR غير محدودة',
            'ترجمة دون اتصال',
            'دعم جميع اللغات',
            'بدون إعلانات',
            'دعم فني متميز',
            'ميزات حصرية قادمة',
          ],
          color: Colors.amber[700]!,
          planType: 'yearly',
          isBestValue: true,
        ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.2, end: 0),
      ],
    );
  }
  
  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    required int duration,
    String? originalPrice,
    String? discount,
    required List<String> features,
    required Color color,
    required String planType,
    bool isPopular = false,
    bool isBestValue = false,
  }) {
    final isCurrentPlan = controller.isPremium.value && 
                          controller.currentPlanType.value == planType;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          elevation: isPopular || isBestValue ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isPopular || isBestValue
                ? BorderSide(color: color, width: 2)
                : BorderSide.none,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isPopular || isBestValue
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
                // Title
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                
                const SizedBox(height: 16),
                
                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (originalPrice != null) ...[
                      Text(
                        originalPrice,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                      ),
                      const SizedBox(width: 8),
                    ],
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
                        '/ $period',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ),
                  ],
                ),
                
                if (discount != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      discount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                
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
                
                // Subscribe Button
                SizedBox(
                  width: double.infinity,
                  child: isCurrentPlan
                      ? OutlinedButton(
                          onPressed: null,
                          child: const Text('الخطة الحالية'),
                        )
                      : ElevatedButton(
                          onPressed: () => controller.subscribeToPlan(planType),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: controller.isProcessing.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('اشترك الآن'),
                        ),
                ),
              ],
            ),
          ),
        ),
        
        // Popular/Best Value Badge
        if (isPopular || isBestValue)
          Positioned(
            top: -10,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                isPopular ? 'الأكثر شعبية' : 'أفضل قيمة',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildCurrentSubscription(BuildContext context) {
    final daysRemaining = controller.daysRemaining.value;
    
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
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اشتراكك النشط',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'باقي $daysRemaining يوم',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
              value: daysRemaining / 30,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.manageSubscription,
                    icon: const Icon(Icons.settings),
                    label: const Text('إدارة'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.cancelSubscription,
                    icon: const Icon(Icons.cancel),
                    label: const Text('إلغاء'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 800.ms);
  }
  
  Widget _buildFeaturesComparison(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مقارنة المميزات',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ).animate().fadeIn(delay: 900.ms),
        
        const SizedBox(height: 16),
        
        _buildComparisonRow(context, 'محاولات OCR اليومية', 'مجاني', '5', 'مدفوع', 'غير محدود'),
        _buildComparisonRow(context, 'الترجمة دون اتصال', 'مجاني', '✗', 'مدفوع', '✓'),
        _buildComparisonRow(context, 'عدد اللغات', 'مجاني', '10', 'مدفوع', '+100'),
        _buildComparisonRow(context, 'الإعلانات', 'مجاني', 'نعم', 'مدفوع', 'لا'),
        _buildComparisonRow(context, 'الدعم الفني', 'مجاني', 'عادي', 'مدفوع', 'متميز'),
      ],
    );
  }
  
  Widget _buildComparisonRow(
    BuildContext context,
    String feature,
    String freeLabel,
    String freeValue,
    String premiumLabel,
    String premiumValue,
  ) {
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
              freeValue,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              premiumValue,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 950.ms);
  }
  
  Widget _buildFAQ(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الأسئلة الشائعة',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        
        const SizedBox(height: 16),
        
        _buildFAQItem(
          context,
          'هل يمكنني إلغاء الاشتراك في أي وقت؟',
          'نعم، يمكنك إلغاء اشتراكك في أي وقت من صفحة الإعدادات.',
        ),
        
        _buildFAQItem(
          context,
          'هل تُحفظ بياناتي بعد إلغاء الاشتراك؟',
          'نعم، جميع بياناتك محفوظة ويمكنك الوصول إليها في أي وقت.',
        ),
        
        _buildFAQItem(
          context,
          'كيف يتم الدفع؟',
          'يتم الدفع بشكل آمن عبر Google Play أو App Store أو Stripe.',
        ),
      ],
    );
  }
  
  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
