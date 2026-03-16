import 'dart:io';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/bloc_observer.dart';
import 'package:rafeeq/rafeeq.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize easy_localization
  await EasyLocalization.ensureInitialized();

  Bloc.observer = MyBlocObserver();

  if (Platform.isAndroid || Platform.isIOS) {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final shortSide = view.physicalSize.shortestSide / view.devicePixelRatio;

    await SystemChrome.setPreferredOrientations(
      shortSide >= 600
          ? DeviceOrientation.values
          : [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const Rafeeq(),
      ),
    ),
  );
}
