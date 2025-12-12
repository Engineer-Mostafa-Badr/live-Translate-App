class OCRResult {
  final String text;
  final double confidence;
  final DateTime timestamp;
  final String? imagePath;
  final Map<String, dynamic>? metadata;

  OCRResult({
    required this.text,
    required this.confidence,
    required this.timestamp,
    this.imagePath,
    this.metadata,
  });

  factory OCRResult.fromJson(Map<String, dynamic> json) {
    return OCRResult(
      text: json['text'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      imagePath: json['image_path'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'image_path': imagePath,
      'metadata': metadata,
    };
  }

  bool get hasText => text.isNotEmpty;
  bool get isHighConfidence => confidence >= 0.8;
}
