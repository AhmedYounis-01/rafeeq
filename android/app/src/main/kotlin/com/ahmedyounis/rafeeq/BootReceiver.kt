package com.ahmedyounis.rafeeq

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * يُشغَّل بعد إعادة تشغيل الموبيل — يطلب من Flutter إعادة جدولة الأذان
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == Intent.ACTION_MY_PACKAGE_REPLACED) {

            // شغّل Flutter engine خفي لإعادة الجدولة
            val engine = FlutterEngine(context)
            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
            MethodChannel(engine.dartExecutor.binaryMessenger, "adhan/boot")
                .invokeMethod("reschedule", null)
        }
    }
}
