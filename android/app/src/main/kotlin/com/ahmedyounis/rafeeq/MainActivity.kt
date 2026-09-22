package com.ahmedyounis.rafeeq

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val FOREGROUND_CHANNEL = "adhan/foreground_service"
    private val ALARM_CHANNEL = "adhan/alarm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ✅ ربط Flutter بالـ Foreground Service
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            FOREGROUND_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startAdhan" -> {
                    val intent = Intent(this, AdhanForegroundService::class.java).apply {
                        action = AdhanForegroundService.ACTION_PLAY
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                    result.success(null)
                }
                "stopAdhan" -> {
                    val intent = Intent(this, AdhanForegroundService::class.java).apply {
                        action = AdhanForegroundService.ACTION_STOP
                    }
                    startService(intent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // ✅ جدولة أذان عبر AlarmManager — يضمن الصوت حتى في الخلفية
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ALARM_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAdhanAlarm" -> {
                    val id = call.argument<Int>("id") ?: 0
                    val timeMillis = call.argument<Long>("timeMillis") ?: 0L

                    scheduleAdhanAlarm(id, timeMillis)
                    result.success(null)
                }
                "cancelAdhanAlarm" -> {
                    val id = call.argument<Int>("id") ?: 0
                    cancelAdhanAlarm(id)
                    result.success(null)
                }
                "cancelAllAdhanAlarms" -> {
                    for (alarmId in 200..250) {
                        cancelAdhanAlarm(alarmId)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun scheduleAdhanAlarm(id: Int, timeMillis: Long) {
        if (timeMillis <= System.currentTimeMillis()) {
            // Do not schedule past times — AlarmManager would fire immediately!
            return
        }
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AdhanReceiver::class.java).apply {
            action = AdhanReceiver.ACTION_PLAY_ADHAN
            putExtra("alarm_id", id)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            this, id, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP, timeMillis, pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP, timeMillis, pendingIntent
                )
            }
        } catch (e: SecurityException) {
            // Fallback for devices that deny exact alarms
            alarmManager.set(AlarmManager.RTC_WAKEUP, timeMillis, pendingIntent)
        }
    }

    private fun cancelAdhanAlarm(id: Int) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AdhanReceiver::class.java).apply {
            action = AdhanReceiver.ACTION_PLAY_ADHAN
        }
        val pendingIntent = PendingIntent.getBroadcast(
            this, id, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.cancel(pendingIntent)
    }
}
