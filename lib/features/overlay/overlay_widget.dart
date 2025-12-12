import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayWidget extends StatelessWidget {
  const OverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          FlutterOverlayWindow.closeOverlay();
          print('Overlay clicked');
        },
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
          child: const Icon(Icons.translate, color: Colors.red),
        ),
      ),
    );
  }
}
