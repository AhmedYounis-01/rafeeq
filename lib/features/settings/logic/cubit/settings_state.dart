part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final bool isAdhanSoundEnabled;

  const SettingsState({this.isAdhanSoundEnabled = true});

  SettingsState copyWith({bool? isAdhanSoundEnabled}) {
    return SettingsState(
      isAdhanSoundEnabled: isAdhanSoundEnabled ?? this.isAdhanSoundEnabled,
    );
  }

  @override
  List<Object> get props => [isAdhanSoundEnabled];
}
