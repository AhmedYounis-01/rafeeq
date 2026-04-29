package com.ahmedyounis.rafeeq

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * BroadcastReceiver يتم استدعاؤه تلقائياً عند وصول إشعار الأذان
 * ليبدأ الـ Foreground Service ويشغّل صوت الأذان الكامل
 */
class AdhanReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_PLAY_ADHAN = "com.ahmedyounis.rafeeq.PLAY_ADHAN"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == ACTION_PLAY_ADHAN) {
            val serviceIntent = Intent(context, AdhanForegroundService::class.java).apply {
                action = AdhanForegroundService.ACTION_PLAY
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
        }
    }
}
