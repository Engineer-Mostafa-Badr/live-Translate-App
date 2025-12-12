import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/services/translation_service.dart';
import '../../core/services/ocr_service.dart';

class TranslationOverlay extends StatelessWidget {
  const TranslationOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final translation = Get.find<TranslationService>();
    final ocr = Get.find<OCRService>();
    
    return Obx(() {
      if (!translation.isTranslating.value) {
        return const SizedBox.shrink();
      }
      
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.withValues(alpha: 0.95),
              Colors.green.withValues(alpha: 0.85),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    // Animated Icon
                    _buildAnimatedIcon(),
                    
                    const SizedBox(width: 12),
                    
                    // Status Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الترجمة الحية نشطة',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() => Text(
                                ocr.isProcessing.value
                                    ? ocr.currentStatus.value
                                    : translation.detectedLanguage.value.isNotEmpty
                                        ? 'تم اكتشاف: ${translation.detectedLanguage.value}'
                                        : 'جاري تحليل النص...',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                              )),
                        ],
                      ),
                    ),
                    
                    // Close Button
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => translation.toggleTranslation(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Language Selection (Chrome-like)
                _buildLanguageSelector(context, translation),
                
                const SizedBox(height: 12),
                
                // Progress Indicator
                Obx(() => _buildProgressIndicator(
                      context,
                      ocr.isProcessing.value
                          ? ocr.processingProgress.value
                          : translation.translationProgress.value,
                    )),
                
                const SizedBox(height: 12),
                
                // Stats
                Obx(() => _buildStats(context, ocr)),
              ],
            ),
          ),
        ),
      )
          .animate()
          .slideY(begin: -1, end: 0, duration: 300.ms, curve: Curves.easeOut)
          .fadeIn();
    });
  }
  
  Widget _buildLanguageSelector(BuildContext context, TranslationService translation) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showLanguageOptions(context, translation, isSource: true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Obx(() => Text(
                      translation.sourceLanguage.value,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                    )),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward, color: Colors.white.withValues(alpha: 0.7), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => _showLanguageOptions(context, translation, isSource: false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Obx(() => Text(
                      translation.targetLanguage.value,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showLanguageOptions(BuildContext context, TranslationService translation, {required bool isSource}) {
    final languages = translation.getAvailableLanguages();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                isSource ? 'اختر اللغة الأصلية' : 'اختر اللغة المستهدفة',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  return ListTile(
                    title: Text(lang),
                    onTap: () {
                      if (isSource) {
                        translation.setSourceLanguage(lang);
                      } else {
                        translation.setTargetLanguage(lang);
                      }
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnimatedIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.translate,
        color: Colors.white,
        size: 24,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 1000.ms,
        )
        .then()
        .scale(
          begin: const Offset(1.1, 1.1),
          end: const Offset(1, 1),
          duration: 1000.ms,
        );
  }
  
  Widget _buildProgressIndicator(BuildContext context, double progress) {
    return Column(
      children: [
        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Percentage
        Text(
          '${(progress * 100).toInt()}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
  
  Widget _buildStats(BuildContext context, OCRService ocr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          context,
          icon: Icons.text_fields,
          label: 'نصوص مكتشفة',
          value: '${ocr.detectedTextBlocks.value}',
        ),
        _buildStatItem(
          context,
          icon: Icons.language,
          label: 'اللغات',
          value: '2',
        ),
        _buildStatItem(
          context,
          icon: Icons.speed,
          label: 'الدقة',
          value: '95%',
        ),
      ],
    );
  }
  
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
              ),
        ),
      ],
    );
  }
}
