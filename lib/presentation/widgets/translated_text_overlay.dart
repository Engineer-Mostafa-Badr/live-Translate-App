import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Widget to display translated text as overlay
class TranslatedTextOverlay extends StatelessWidget {
  final String originalText;
  final String translatedText;
  final double left;
  final double top;
  final double width;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  
  const TranslatedTextOverlay({
    super.key,
    required this.originalText,
    required this.translatedText,
    required this.left,
    required this.top,
    required this.width,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.withValues(alpha: 0.95),
                Colors.green.shade600.withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.translate,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'ترجمة',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (onDismiss != null)
                    GestureDetector(
                      onTap: onDismiss,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Translated Text
              Text(
                translatedText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              
              const SizedBox(height: 6),
              
              // Original Text (smaller)
              Text(
                originalText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 300.ms)
          .slideY(begin: -0.3, end: 0, duration: 300.ms, curve: Curves.easeOut),
    );
  }
}

/// Compact version for inline translation
class CompactTranslatedText extends StatelessWidget {
  final String translatedText;
  final VoidCallback? onTap;
  
  const CompactTranslatedText({
    super.key,
    required this.translatedText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          border: Border(
            bottom: BorderSide(
              color: Colors.green,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.translate,
              size: 14,
              color: Colors.green.shade700,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                translatedText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating translation bubble
class TranslationBubble extends StatelessWidget {
  final String text;
  final bool isOriginal;
  final VoidCallback? onTap;
  
  const TranslationBubble({
    super.key,
    required this.text,
    this.isOriginal = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isOriginal
              ? Colors.grey.shade200
              : Colors.green.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isOriginal ? Colors.black87 : Colors.white,
              ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .scale(begin: const Offset(0.8, 0.8), duration: 200.ms);
  }
}
