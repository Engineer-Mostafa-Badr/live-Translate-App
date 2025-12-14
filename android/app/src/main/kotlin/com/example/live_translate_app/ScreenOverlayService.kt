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

        params.gravity = Gravity.END or Gravity.CENTER_VERTICAL

        // تحريك الفقاعة بحرية وبسلاسة
        var initialX = 0
        var initialY = 0
        var initialTouchX = 0f
        var initialTouchY = 0f

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
                    val dx = (event.rawX - initialTouchX).toInt()
                    val dy = (event.rawY - initialTouchY).toInt()

                    params.x = initialX + dx
                    params.y = initialY + dy

                    windowManager.updateViewLayout(view, params)
                    true
                }

                MotionEvent.ACTION_UP -> true
                else -> false
            }
        }

        // تشغيل / إيقاف
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

        // إغلاق الفقاعة
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
