import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rafeeq/core/services/adhan_scheduler_service.dart';
import 'package:rafeeq/core/cache/storage_manager.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
    : super(
        SettingsState(
          isAdhanSoundEnabled: StorageManager.instance.isAdhanSoundEnabled(),
        ),
      );

  Future<void> toggleAdhanSound(bool enabled) async {
    // Optimistic update
    emit(state.copyWith(isAdhanSoundEnabled: enabled));

    // Persist
    await AdhanSchedulerService.instance.setAdhanSoundEnabled(enabled);
  }
}
