import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:rafeeq/bloc_observer.dart';
import 'package:rafeeq/core/cache/storage_manager.dart';
import 'package:rafeeq/rafeeq.dart';

void main() async {
  final watch = Stopwatch()..start();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  debugPrint(
    'Startup: WidgetsBinding initialized in ${watch.elapsedMilliseconds}ms',
  );

  // Initialize easy_localization and StorageManager in parallel
  final initWatch = Stopwatch()..start();
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    StorageManager.instance.init(),
  ]);
  debugPrint(
    'Startup: Parallel initialization completed in ${initWatch.elapsedMilliseconds}ms',
  );

  Bloc.observer = MyBlocObserver();

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
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('ar'),
      child: const Rafeeq(),
    ),
  );

  // Remove splash screen after first frame is drawn
  FlutterNativeSplash.remove();
}
