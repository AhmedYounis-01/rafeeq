import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'package:rafeeq/bloc_observer.dart';
import 'package:rafeeq/core/cache/storage_manager.dart';
import 'package:rafeeq/core/services/adhan_scheduler_service.dart';
import 'package:rafeeq/core/services/notification_service.dart';
import 'package:rafeeq/rafeeq.dart';
import 'package:audio_session/audio_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ إعداد الـ audio session للتشغيل في الخلفية
  final session = await AudioSession.instance;
  await session.configure(
    const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage:
            AndroidAudioUsage.alarm, // ✅ alarm يضمن الصوت حتى لو الصامت مفعّل
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
    ),
  );

  // ✅ تهيئة AdhanSchedulerService
  await AdhanSchedulerService.instance.initialize();

  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

  // Initialize Storage
  await StorageManager.instance.init();

  // Initialize Notifications
  await NotificationService.instance.init();

  // Schedule Adhan notifications (7 days ahead)
  await AdhanSchedulerService.instance.scheduleAdhanNotifications();

  // Schedule daily reminders (IDs 100-102 only)
  await NotificationService.instance.scheduleDailyNotifications();

  Bloc.observer = MyBlocObserver();

  // Handle orientation
  if (Platform.isAndroid || Platform.isIOS) {
    try {
      final view = WidgetsBinding.instance.platformDispatcher.views.first;
      final shortSide = view.physicalSize.shortestSide / view.devicePixelRatio;
      await SystemChrome.setPreferredOrientations(
        shortSide >= 600
            ? DeviceOrientation.values
            : [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
      );
    } catch (_) {}
  }

  // ✅ Edge-to-edge: شاشة كاملة مع status bar شفاف
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Minimal delay to let the engine breathe
  await Future.delayed(const Duration(milliseconds: 500));

  // runApp(
  //   EasyLocalization(
  //     supportedLocales: const [Locale('en'), Locale('ar')],
  //     path: 'assets/translations',
  //     fallbackLocale: const Locale('en'),
  //     startLocale: const Locale('ar'),
  //     child: const Rafeeq(),
  //   ),
  // );
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('ar'),
        child: const Rafeeq(),
      ),
    ),
  );
}
