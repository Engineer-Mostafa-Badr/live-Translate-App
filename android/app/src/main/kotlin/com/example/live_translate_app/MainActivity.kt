package com.example.live_translate_app

import android.content.*
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.provider.Settings

class MainActivity : FlutterFragmentActivity() {

    private val OVERLAY_CHANNEL = "com.livetranslate.app/overlay"
    private lateinit var engine: FlutterEngine

    // ============================
    // Overlay Click Receiver
    // ============================
    private val overlayReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            MethodChannel(
                engine.dartExecutor.binaryMessenger,
                OVERLAY_CHANNEL
            ).invokeMethod("overlay_clicked", null)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        engine = flutterEngine

        // Register receiver
        val filter = IntentFilter(ScreenOverlayService.BROADCAST_OVERLAY_CLICK)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(overlayReceiver, filter, RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(overlayReceiver, filter)
        }

        // Overlay Channel
        MethodChannel(engine.dartExecutor.binaryMessenger, OVERLAY_CHANNEL)
            .setMethodCallHandler { call, result ->

                when (call.method) {

                    "start_overlay" -> {
                        if (!Settings.canDrawOverlays(this)) {
                            result.error("NO_PERMISSION", "Overlay permission not granted", null)
                            return@setMethodCallHandler
                        }

                        val intent = Intent(this, ScreenOverlayService::class.java)

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                            startForegroundService(intent)
                        else
                            startService(intent)

                        result.success(true)
                    }

                    "stop_overlay" -> {
                        stopService(Intent(this, ScreenOverlayService::class.java))
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }

            }
    }

    override fun onDestroy() {
        super.onDestroy()
        kotlin.runCatching {
            unregisterReceiver(overlayReceiver)
        }
    }
}
