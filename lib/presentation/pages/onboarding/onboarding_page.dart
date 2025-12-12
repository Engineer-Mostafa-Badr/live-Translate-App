import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'onboarding_controller.dart';

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OnboardingController());
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topLeft,
              child: TextButton(
                onPressed: controller.skip,
                child: Text(
                  'تخطي',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ),
            ).animate().fadeIn(),
            
            // PageView
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.pages.length,
                itemBuilder: (context, index) {
                  final page = controller.pages[index];
                  return _buildPage(
                    context,
                    title: page['title']!,
                    description: page['description']!,
                    icon: page['icon'] as IconData,
                    color: page['color'] as Color,
                  );
                },
              ),
            ),
            
            // Dots Indicator
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    controller.pages.length,
                    (index) => _buildDot(
                      context,
                      isActive: index == controller.currentPage.value,
                    ),
                  ),
                )),
            
            const SizedBox(height: 30),
            
            // Action Buttons
            Obx(() => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: controller.currentPage.value ==
                          controller.pages.length - 1
                      ? Column(
                          children: [
                            // Start Free Button
                            ElevatedButton(
                              onPressed: controller.startFree,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 56),
                              ),
                              child: const Text('ابدأ مجانًا'),
                            ),
                            const SizedBox(height: 12),
                            // Subscribe Button
                            OutlinedButton(
                              onPressed: controller.subscribe,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 56),
                              ),
                              child: const Text('اشترك الآن'),
                            ),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: controller.nextPage,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                          ),
                          child: const Text('التالي'),
                        ),
                )),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPage(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 80,
              color: color,
            ),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .fadeIn(),
          
          const SizedBox(height: 40),
          
          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }
  
  Widget _buildDot(BuildContext context, {required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).primaryColor
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
