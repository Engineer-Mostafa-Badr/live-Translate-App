package com.example.live_translate_app

import android.content.*
import android.os.Build
import android.provider.Settings
import android.net.Uri
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context.RECEIVER_NOT_EXPORTED

class MainActivity : FlutterFragmentActivity() {

    private val OVERLAY_CHANNEL = "com.livetranslate.app/overlay"
    private lateinit var engine: FlutterEngine

    // ============================
    // Overlay Broadcast Receiver
    // ============================
    private val overlayReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {

            // استلام حالة التشغيل من Service
            val running = intent?.getBooleanExtra("running", false) ?: false

            MethodChannel(
                engine.dartExecutor.binaryMessenger,
                OVERLAY_CHANNEL
            ).invokeMethod(
                "overlay_clicked",
                running
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        engine = flutterEngine

        // ============================
        // Register Broadcast Receiver
        // ============================
        val filter = IntentFilter(
            ScreenOverlayService.BROADCAST_OVERLAY_CLICK
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(
                overlayReceiver,
                filter,
                RECEIVER_NOT_EXPORTED
            )
        } else {
            registerReceiver(overlayReceiver, filter)
        }

        // ============================
        // MethodChannel
        // ============================
        MethodChannel(
            engine.dartExecutor.binaryMessenger,
            OVERLAY_CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                // 🔍 check overlay permission
                "check_overlay_permission" -> {
                    result.success(
                        Settings.canDrawOverlays(this)
                    )
                }

                // ⚙️ open overlay permission settings
                "open_overlay_settings" -> {
                    val intent = Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:$packageName")
                    )
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }

                // ▶️ start overlay service
                "start_overlay" -> {
                    if (!Settings.canDrawOverlays(this)) {
                        result.error(
                            "NO_PERMISSION",
                            "Overlay permission not granted",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    val intent = Intent(
                        this,
                        ScreenOverlayService::class.java
                    )

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                        startForegroundService(intent)
                    else
                        startService(intent)

                    result.success(true)
                }

                // ⏹ stop overlay service
                "stop_overlay" -> {
                    stopService(
                        Intent(this, ScreenOverlayService::class.java)
                    )
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        runCatching {
            unregisterReceiver(overlayReceiver)
        }
    }
}
