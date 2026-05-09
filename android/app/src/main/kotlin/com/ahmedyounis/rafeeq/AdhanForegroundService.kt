package com.ahmedyounis.rafeeq

import android.app.*
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

/**
 * Foreground Service يشغّل الأذان الكامل حتى لو التطبيق مقفول
 */
class AdhanForegroundService : Service() {

    private var mediaPlayer: MediaPlayer? = null

    companion object {
        const val ACTION_PLAY = "PLAY_ADHAN"
        const val ACTION_STOP = "STOP_ADHAN"
        const val CHANNEL_ID = "adhan_foreground_channel"
        const val NOTIF_ID = 999
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_PLAY -> {
                startForeground(NOTIF_ID, buildNotification())
                playAdhan()
            }
            ACTION_STOP -> {
                stopAdhan()
                stopSelf()
            }
        }
        return START_NOT_STICKY
    }

    private fun playAdhan() {
        try {
            mediaPlayer?.release()
            // ملف الأذان في assets — انسخه لـ res/raw أسهل
            // ملاحظة: المسار الصحيح للملف في flutter_assets
            val afd = assets.openFd("flutter_assets/assets/azan.mp3")
            mediaPlayer = MediaPlayer().apply {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    setAudioAttributes(
                        AudioAttributes.Builder()
                            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                            .setUsage(AudioAttributes.USAGE_ALARM)
                            .build()
                    )
                } else {
                    @Suppress("DEPRECATION")
                    setAudioStreamType(AudioManager.STREAM_ALARM)
                }
                setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                prepare()
                start()
                setOnCompletionListener {
                    stopSelf()
                }
            }
        } catch (e: Exception) {
            stopSelf()
        }
    }

    private fun stopAdhan() {
        mediaPlayer?.stop()
        mediaPlayer?.release()
        mediaPlayer = null
    }

    private fun buildNotification(): Notification {
        val stopIntent = Intent(this, AdhanForegroundService::class.java).apply {
            action = ACTION_STOP
        }
        val stopPending = PendingIntent.getService(
            this, 0, stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("الأذان")
            .setContentText("حان وقت الصلاة")
            .setSmallIcon(R.mipmap.ic_launcher)
            .addAction(android.R.drawable.ic_media_pause, "إيقاف", stopPending)
            .setOngoing(true)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "تشغيل الأذان",
                NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java)
                ?.createNotificationChannel(channel)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        stopAdhan()
        super.onDestroy()
    }
}
