import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/services/ocr_service.dart';

/// Widget to show text analysis progress
class TextAnalysisWidget extends StatelessWidget {
  const TextAnalysisWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ocr = Get.find<OCRService>();
    
    return Obx(() {
      if (!ocr.isProcessing.value) {
        return const SizedBox.shrink();
      }
      
      return Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Icon
              _buildAnalyzingIcon(),
              
              const SizedBox(height: 20),
              
              // Title
              Text(
                'جاري تحليل النص',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              
              const SizedBox(height: 8),
              
              // Status
              Obx(() => Text(
                    ocr.currentStatus.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  )),
              
              const SizedBox(height: 20),
              
              // Progress Bar
              Obx(() => Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: ocr.processingProgress.value,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(ocr.processingProgress.value * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                    ],
                  )),
              
              const SizedBox(height: 20),
              
              // Processing Steps
              _buildProcessingSteps(context, ocr),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms)
            .scale(begin: const Offset(0.8, 0.8), duration: 300.ms),
      );
    });
  }
  
  Widget _buildAnalyzingIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.document_scanner,
        size: 40,
        color: Colors.blue,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .rotate(duration: 2000.ms)
        .then()
        .rotate(begin: 1, end: 0, duration: 2000.ms);
  }
  
  Widget _buildProcessingSteps(BuildContext context, OCRService ocr) {
    final steps = [
      {'icon': Icons.image, 'label': 'تحليل الصورة'},
      {'icon': Icons.text_fields, 'label': 'اكتشاف النصوص'},
      {'icon': Icons.abc, 'label': 'قراءة النصوص'},
      {'icon': Icons.check_circle, 'label': 'معالجة النتائج'},
    ];
    
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final progress = ocr.processingProgress.value;
        final isActive = progress >= (index / steps.length);
        final isCompleted = progress > ((index + 1) / steps.length);
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                isCompleted
                    ? Icons.check_circle
                    : step['icon'] as IconData,
                size: 20,
                color: isActive
                    ? (isCompleted ? Colors.green : Colors.blue)
                    : Colors.grey[400],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step['label'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isActive ? Colors.black87 : Colors.grey[400],
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Compact analysis indicator
class CompactAnalysisIndicator extends StatelessWidget {
  const CompactAnalysisIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final ocr = Get.find<OCRService>();
    
    return Obx(() {
      if (!ocr.isProcessing.value) {
        return const SizedBox.shrink();
      }
      
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                value: ocr.processingProgress.value,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'جاري التحليل...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 200.ms)
          .slideX(begin: 0.3, end: 0, duration: 200.ms);
    });
  }
}
