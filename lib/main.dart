import 'dart:io';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/bloc_observer.dart';
import 'package:rafeeq/core/cache/storage_manager.dart';
import 'package:rafeeq/rafeeq.dart';

void main() async {
  final watch = Stopwatch()..start();
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint(
    'Startup: WidgetsBinding initialized in ${watch.elapsedMilliseconds}ms',
  );

  // Initialize easy_localization
  final locWatch = Stopwatch()..start();
  await EasyLocalization.ensureInitialized();
  debugPrint(
    'Startup: EasyLocalization initialized in ${locWatch.elapsedMilliseconds}ms',
  );

  Bloc.observer = MyBlocObserver();

  // Initialize StorageManager (SharedPreferences)
  final storageWatch = Stopwatch()..start();
  await StorageManager.instance.init();
  debugPrint(
    'Startup: StorageManager initialized in ${storageWatch.elapsedMilliseconds}ms',
  );

  if (Platform.isAndroid || Platform.isIOS) {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final shortSide = view.physicalSize.shortestSide / view.devicePixelRatio;

    try {
      await SystemChrome.setPreferredOrientations(
        shortSide >= 600
            ? DeviceOrientation.values
            : [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
      );
    } catch (e) {
      // Some Android 8.0 devices throw if the activity isn't fullscreen
      debugPrint('setPreferredOrientations failed: $e');
    }
  }

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
