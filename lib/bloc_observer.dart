import 'package:rafeeq/core/helpers/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    AppLogger.log('onCreate -- ${bloc.runtimeType}', tag: 'BLOC');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    AppLogger.log('onChange -- ${bloc.runtimeType}, $change', tag: 'BLOC');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    AppLogger.error(
      'onError -- ${bloc.runtimeType}',
      error: error,
      stackTrace: stackTrace,
      tag: 'BLOC',
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    AppLogger.log('onClose -- ${bloc.runtimeType}', tag: 'BLOC');
  }
}
