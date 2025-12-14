package com.example.live_translate_app

import android.app.*
import android.content.*
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.*
import android.widget.ImageView
import androidx.core.app.NotificationCompat

class ScreenOverlayService : Service() {

    companion object {
        const val CHANNEL_ID = "overlay_channel"
        const val NOTIF_ID = 101
        const val BROADCAST_OVERLAY_CLICK =
            "com.example.live_translate_app.OVERLAY_CLICKED"
    }

    private lateinit var windowManager: WindowManager
    private var bubbleView: View? = null
    private var isRunning = true

    override fun onCreate() {
        super.onCreate()
        createNotification()
        showBubble()
    }

    private fun createNotification() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Overlay Service",
                NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Live Translate")
            .setContentText("Bubble running")
            .setSmallIcon(android.R.drawable.ic_menu_info_details)
            .build()

        startForeground(NOTIF_ID, notification)
    }

    private fun showBubble() {
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

        val view = LayoutInflater.from(this)
            .inflate(R.layout.overlay_bubble, null)

        bubbleView = view

        val toggleBtn = view.findViewById<ImageView>(R.id.btnToggle)
        val closeBtn = view.findViewById<ImageView>(R.id.btnClose)

        // تعديل LayoutParams لحركة الفقاعة
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        )

        // Gravity للتحكم الكامل في المكان
        params.gravity = Gravity.TOP or Gravity.START

        // تحديد الموقع الابتدائي: منتصف الشاشة على اليسار
        val displayMetrics = resources.displayMetrics
        params.x = 0
        params.y = displayMetrics.heightPixels / 2 - 64 // 64 = ارتفاع الفقاعة

        // متغيرات لتتبع حركة اللمس
        var initialX = params.x
        var initialY = params.y
        var initialTouchX = 0f
        var initialTouchY = 0f

        // OnTouchListener لتتبع حركة الفقاعة
        view.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params.x
                    initialY = params.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    true
                }

                MotionEvent.ACTION_MOVE -> {
                    params.x = initialX + (event.rawX - initialTouchX).toInt()
                    params.y = initialY + (event.rawY - initialTouchY).toInt()
                    windowManager.updateViewLayout(view, params)
                    true
                }

                MotionEvent.ACTION_UP -> true
                else -> false
            }
        }

        // زر التشغيل / الإيقاف
        toggleBtn.setOnClickListener {
            isRunning = !isRunning
            toggleBtn.setImageResource(
                if (isRunning)
                    android.R.drawable.ic_media_pause
                else
                    android.R.drawable.ic_media_play
            )

            sendBroadcast(
                Intent(BROADCAST_OVERLAY_CLICK)
                    .putExtra("running", isRunning)
            )
        }

        // زر الإغلاق
        closeBtn.setOnClickListener {
            stopSelf()
        }

        windowManager.addView(view, params)
    }

    override fun onDestroy() {
        super.onDestroy()
        bubbleView?.let {
            runCatching { windowManager.removeView(it) }
        }
        bubbleView = null
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
