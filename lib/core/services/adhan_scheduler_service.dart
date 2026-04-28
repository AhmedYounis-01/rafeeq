import 'dart:async';
import 'dart:io';

import 'package:adhan/adhan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rafeeq/core/helpers/app_logger.dart';
import 'package:rafeeq/core/utils/prayer_time_calculator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz_lib;

/// خدمة جدولة إشعارات الأذان — تربط مواقيت الصلاة بالإشعارات والصوت
class AdhanSchedulerService {
  AdhanSchedulerService._();
  static final AdhanSchedulerService instance = AdhanSchedulerService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Audio player for full adhan on notification tap (iOS mainly)
  AudioPlayer? _audioPlayer;

  /// Adhan sound toggle (for scheduled notifications)
  static const String _soundEnabledKey = 'adhan_sound_enabled';
  final StreamController<bool> _soundEnabledController =
      StreamController<bool>.broadcast();
  Stream<bool> get soundEnabledStream => _soundEnabledController.stream;

  /// Schedule 7 days × 5 prayers = 35 notifications (IDs 200–234)
  /// iOS allows max 64 pending notifications, so 35 adhan + 3 daily = 38 ✅
  static const int _scheduleDays = 7;
  static const int _prayersPerDay = 5;
  static const int _baseId = 200;
  static const int _maxId = _baseId + (_scheduleDays * _prayersPerDay); // 235

  /// The 5 prayers to schedule adhan for (no Sunrise)
  static const List<Prayer> _adhanPrayers = [
    Prayer.fajr,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  /// Arabic prayer names for notification body
  static const Map<Prayer, String> _prayerNames = {
    Prayer.fajr: 'الفجر',
    Prayer.dhuhr: 'الظهر',
    Prayer.asr: 'العصر',
    Prayer.maghrib: 'المغرب',
    Prayer.isha: 'العشاء',
  };

  // ═══════════════════════ Setting Global Status ═══════════════════════

  /// Is Adhan sound enabled for scheduled notifications? (default: true)
  Future<bool> isAdhanSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  /// Toggle Adhan sound and re-schedule notifications to apply the change
  Future<void> setAdhanSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, enabled);
    _soundEnabledController.add(enabled);

    AppLogger.log(
      'Adhan sound toggled: $enabled — Re-scheduling...',
      tag: 'ADHAN',
    );

    // Apply the change immediately by re-scheduling
    await scheduleAdhanNotifications();
  }

  // ═══════════════════════ الجدولة ═══════════════════════

  /// Cancel old adhan notifications and schedule for 7 days ahead.
  /// Also refreshes timezone to handle DST changes.
  Future<void> scheduleAdhanNotifications() async {
    // Refresh timezone on every schedule call (handles DST changes)
    await refreshTimezone();

    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('location_lat');
    final lon = prefs.getDouble('location_lon');

    if (lat == null || lon == null) {
      AppLogger.warning(
        'No saved location — skipping adhan scheduling',
        tag: 'ADHAN',
      );
      return;
    }

    // Cancel all adhan notification IDs (200–234)
    for (int id = _baseId; id < _maxId; id++) {
      await _plugin.cancel(id: id);
    }

    final now = DateTime.now();
    int notificationId = _baseId;
    int scheduledCount = 0;

    // Schedule for 7 days (today + 6 more days)
    for (int day = 0; day < _scheduleDays; day++) {
      final date = now.add(Duration(days: day));
      final prayerTimes = PrayerTimeCalculator.calculateForDate(
        lat: lat,
        lon: lon,
        date: date,
      );

      for (int i = 0; i < _adhanPrayers.length; i++) {
        final prayer = _adhanPrayers[i];
        final time = prayerTimes.timeForPrayer(prayer);
        if (time == null) continue;

        // Skip times that already passed
        if (time.isBefore(now)) {
          notificationId++;
          continue;
        }

        final prayerName = _prayerNames[prayer] ?? '';
        await _scheduleAdhanNotification(
          id: notificationId,
          prayerName: prayerName,
          scheduledTime: time,
        );
        scheduledCount++;
        notificationId++;
      }
    }

    AppLogger.log(
      'Adhan: $scheduledCount notifications scheduled for $_scheduleDays days '
      '(lat=$lat, lon=$lon)',
      tag: 'ADHAN',
    );
  }

  /// Refresh timezone to pick up DST changes
  Future<void> refreshTimezone() async {
    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz_lib.setLocalLocation(tz_lib.getLocation(timeZoneName));
      AppLogger.log('Timezone refreshed: $timeZoneName', tag: 'ADHAN');
    } catch (e) {
      AppLogger.warning(
        'Timezone refresh failed: $e (using previous)',
        tag: 'ADHAN',
      );
    }
  }

  /// Schedule a single adhan notification
  Future<void> _scheduleAdhanNotification({
    required int id,
    required String prayerName,
    required DateTime scheduledTime,
  }) async {
    final tzTime = tz_lib.TZDateTime.from(scheduledTime, tz_lib.local);
    final soundEnabled = await isAdhanSoundEnabled();

    // Android: full adhan from raw resource
    final androidDetails = AndroidNotificationDetails(
      'adhan_channel',
      'إشعارات الأذان',
      channelDescription: 'تشغيل الأذان عند دخول وقت الصلاة',
      importance: Importance.max,
      priority: Priority.high,
      sound: soundEnabled
          ? const RawResourceAndroidNotificationSound('adhan')
          : null,
      playSound: soundEnabled,
      enableVibration: true,
      category: AndroidNotificationCategory.alarm,
    );

    // iOS: short adhan clip (must be ≤30s .aiff/.caf/.wav)
    final iosDetails = DarwinNotificationDetails(
      sound: soundEnabled ? 'adhan.aiff' : null,
      presentAlert: true,
      presentBadge: true,
      presentSound: soundEnabled,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id: id,
      title: 'حان الآن موعد أذان $prayerName',
      body: 'حان وقت صلاة $prayerName — صلِّ على النبي ﷺ',
      scheduledDate: tzTime,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'adhan_tap',
    );

    AppLogger.log('Adhan #$id ($prayerName) → $tzTime', tag: 'ADHAN');
  }

  // ═══════════════════════ تشغيل الأذان الكامل ═══════════════════════

  /// Play full adhan audio (called on notification tap, mainly for iOS)
  Future<void> playFullAdhan() async {
    try {
      // Dispose previous player if any
      await _audioPlayer?.dispose();

      _audioPlayer = AudioPlayer();
      await _audioPlayer!.setAsset('assets/azan.mp3');
      _audioPlayer!.play();

      // Auto-dispose when playback completes
      _audioPlayer!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _audioPlayer?.dispose();
          _audioPlayer = null;
          AppLogger.log('Full adhan playback completed', tag: 'ADHAN');
        }
      });

      AppLogger.log('Playing full adhan audio', tag: 'ADHAN');
    } catch (e) {
      AppLogger.error('Failed to play adhan', error: e, tag: 'ADHAN');
    }
  }

  /// Stop adhan if playing
  Future<void> stopAdhan() async {
    await _audioPlayer?.stop();
    await _audioPlayer?.dispose();
    _audioPlayer = null;
  }

  // ═══════════════════════ Notification Tap Handler ═══════════════════════

  /// Handle notification tap — plays full adhan if payload matches
  void handleNotificationTap(String? payload) {
    if (payload == 'adhan_tap') {
      // On iOS: play full adhan when user taps notification
      // On Android: adhan already played via notification sound
      if (Platform.isIOS) {
        playFullAdhan();
      }
    }
  }
}
