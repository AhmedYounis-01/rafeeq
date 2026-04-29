package com.ahmedyounis.rafeeq

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val FOREGROUND_CHANNEL = "adhan/foreground_service"

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
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
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
    }
}
