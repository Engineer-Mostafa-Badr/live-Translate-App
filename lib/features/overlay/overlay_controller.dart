import 'package:flutter/services.dart';

class OverlayController {
  static const MethodChannel _channel = MethodChannel(
    'com.livetranslate.app/overlay',
  );

  /// ✅ التحقق من إذن الظهور فوق التطبيقات
  static Future<bool> checkPermission() async {
    try {
      final bool result = await _channel.invokeMethod(
        'check_overlay_permission',
      );
      return result;
    } catch (e) {
      return false;
    }
  }

  /// 🔓 فتح صفحة إعدادات الإذن
  static Future<bool> openOverlayPermissionSettings() async {
    try {
      await _channel.invokeMethod('open_overlay_settings');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// ▶️ تشغيل الفقاعة
  static Future<bool> startOverlay() async {
    try {
      final res = await _channel.invokeMethod('start_overlay');
      return res == true;
    } catch (_) {
      return false;
    }
  }

  /// ⏹️ إيقاف الفقاعة
  static Future<void> stopOverlay() async {
    await _channel.invokeMethod('stop_overlay');
  }

  /// 👂 الاستماع لضغط الفقاعة
  static void listen(Function onClick) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'overlay_clicked') {
        onClick();
      }
    });
  }
}
