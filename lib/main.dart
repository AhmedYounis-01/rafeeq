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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Minimal delay to let the engine breathe
  await Future.delayed(const Duration(milliseconds: 500));

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('ar'),
      child: const Rafeeq(),
    ),
  );
}
