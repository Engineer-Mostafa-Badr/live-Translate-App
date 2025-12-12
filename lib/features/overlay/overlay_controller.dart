import 'package:flutter/services.dart';

class OverlayController {
  static const MethodChannel _channel = MethodChannel(
    'com.livetranslate.app/overlay',
  );

  /// تشغيل الـ Overlay (سيفتح الصلاحية لو مش موجودة)
  static Future<bool> startOverlay() async {
    try {
      final res = await _channel.invokeMethod('start_overlay');
      return res == true;
    } catch (e) {
      return false;
    }
  }

  /// ايقاف الفقاعة
  static Future<void> stopOverlay() async {
    await _channel.invokeMethod('stop_overlay');
  }

  /// استقبال الضغطات من الفقاعة
  static void listen(Function() onClick) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'overlay_clicked') {
        onClick();
      }
    });
  }
}
