import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'overlay_controller.dart';

class OverlayPermissionPage extends StatelessWidget {
  const OverlayPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("السماح بالظهور فوق التطبيقات"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            const Icon(Icons.layers, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "لكي تعمل الفقاعة العائمة يجب السماح للتطبيق بالظهور فوق التطبيقات الأخرى.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.blue,
              ),
              onPressed: () async {
                bool ok =
                    await OverlayController.openOverlayPermissionSettings();
                if (!ok) {
                  Get.snackbar("تنبيه", "لم يتم منح الإذن بعد");
                } else {
                  Get.snackbar("نجاح", "تم فتح صفحة الصلاحيات");
                }
              },
              child: const Text("افتح صفحة الإذن"),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
