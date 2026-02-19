import 'dart:io';
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

  // Set portrait mode only for mobile
  if (Platform.isAndroid || Platform.isIOS) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const Rafeeq(),
    ),
  );
}
