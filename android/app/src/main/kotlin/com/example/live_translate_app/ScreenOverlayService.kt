package com.example.live_translate_app

import android.app.*
import android.content.*
import android.graphics.*
import android.os.Build
import android.os.IBinder
import android.view.*
import androidx.core.app.NotificationCompat

class ScreenOverlayService : Service() {

    companion object {
        const val CHANNEL_ID = "overlay_channel"
        const val NOTIF_ID = 101
        const val BROADCAST_OVERLAY_CLICK =
            "com.example.live_translate_app.OVERLAY_CLICKED"
    }

    private lateinit var windowManager: WindowManager
    private var bubble: View? = null

    override fun onCreate() {
        super.onCreate()
        createNotification()
        showBubble()
    }

    private fun createNotification() {
        if (Build.VERSION.SDK_INT >= 26) {
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
            .setContentText("Bubble Running")
            .setSmallIcon(android.R.drawable.ic_menu_info_details)
            .build()

        startForeground(NOTIF_ID, notification)
    }

    private fun showBubble() {
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

        val view = View(this).apply {
            setBackgroundColor(Color.BLUE)
        }
        bubble = view

        val params = WindowManager.LayoutParams(
            140,
            140,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        )

        params.gravity = Gravity.END or Gravity.CENTER_VERTICAL

        view.setOnTouchListener(object : View.OnTouchListener {
            var lastX = 0f
            var lastY = 0f
            var isClick = true

            override fun onTouch(v: View?, e: MotionEvent): Boolean {
                when (e.action) {
                    MotionEvent.ACTION_DOWN -> {
                        lastX = e.rawX
                        lastY = e.rawY
                        isClick = true
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        params.x -= (e.rawX - lastX).toInt()
                        params.y += (e.rawY - lastY).toInt()
                        windowManager.updateViewLayout(view, params)
                        lastX = e.rawX
                        lastY = e.rawY
                        isClick = false
                        return true
                    }
                    MotionEvent.ACTION_UP -> {
                        if (isClick) {
                            sendBroadcast(Intent(BROADCAST_OVERLAY_CLICK))
                        }
                        return true
                    }
                }
                return false
            }
        })

        windowManager.addView(view, params)
    }

    override fun onDestroy() {
        super.onDestroy()
        bubble?.let {
            kotlin.runCatching { windowManager.removeView(it) }
        }
        bubble = null
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
