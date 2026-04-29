import 'dart:async';
import 'dart:io';

import 'package:adhan/adhan.dart';
import 'package:flutter/services.dart';
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

  // ✅ Channel للتواصل مع الـ Android foreground service
  static const _foregroundChannel = MethodChannel('adhan/foreground_service');

  // ✅ Channel للـ boot receiver
  static const _bootChannel = MethodChannel('adhan/boot');

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

  // ═══════════════════════ Init ═══════════════════════

  Future<void> initialize() async {
    // ✅ إعداد الـ boot channel handler
    _bootChannel.setMethodCallHandler((call) async {
      if (call.method == 'reschedule') {
        await scheduleAdhanNotifications();
      }
    });
  }

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

    final now = tz_lib.TZDateTime.now(tz_lib.local);
    int notificationId = _baseId;
    int scheduledCount = 0;

    // Schedule for 7 days (today + 6 more days)
    for (int day = 0; day < _scheduleDays; day++) {
      // Calculate times using a plain DateTime for the adhan pkg,
      // but compare using TZDateTime.
      final checkDate = now.add(Duration(days: day));
      final prayerTimes = PrayerTimeCalculator.calculateForDate(
        lat: lat,
        lon: lon,
        date: checkDate,
      );

      for (int i = 0; i < _adhanPrayers.length; i++) {
        final prayer = _adhanPrayers[i];
        final time = prayerTimes.timeForPrayer(prayer);
        if (time == null) {
          notificationId++;
          continue;
        }

        // Convert the adhan result to a TZDateTime for comparison
        final tzPrayerTime = PrayerTimeCalculator.toTZ(time);

        // Skip times that already passed (with 1-min grace)
        if (tzPrayerTime.isBefore(now.subtract(const Duration(minutes: 1)))) {
          notificationId++;
          continue;
        }

        final prayerName = _prayerNames[prayer] ?? '';
        await _scheduleAdhanNotification(
          id: notificationId,
          prayerName: prayerName,
          scheduledTime: tzPrayerTime,
        );
        scheduledCount++;
        notificationId++;
      }
    }

    AppLogger.log(
      'Adhan: $scheduledCount notifications scheduled for $_scheduleDays days',
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
    // Use TZDateTime.from to ensure the moment is correctly Translated
    // from the system-local (Standard) to the app-local (DST).
    final tz_lib.TZDateTime tzTime = scheduledTime is tz_lib.TZDateTime
        ? scheduledTime
        : tz_lib.TZDateTime.from(scheduledTime, tz_lib.local);

    final soundEnabled = await isAdhanSoundEnabled();

    // Android: الإشعار يطلق الـ foreground service عبر full-screen intent
    // الصوت القصير للإشعار فقط (أقل من 30 ثانية)
    final androidDetails = AndroidNotificationDetails(
      'adhan_channel',
      'إشعارات الأذان',
      channelDescription: 'تشغيل الأذان عند دخول وقت الصلاة',
      importance: Importance.max,
      priority: Priority.max,
      // ✅ صوت للإشعار (ملف adhan في res/raw)
      sound: soundEnabled
          ? const RawResourceAndroidNotificationSound('adhan')
          : null,
      playSound: soundEnabled,
      enableVibration: true,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true, // ✅ يشغّل full screen حتى لو الموبيل مقفول
      ticker: 'حان وقت $prayerName',
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
      // ✅ payload يحمل اسم الصلاة لتشغيل الأذان الكامل
      payload: 'adhan_tap|$prayerName',
    );

    AppLogger.log('Adhan #$id ($prayerName) → $tzTime', tag: 'ADHAN');
  }

  // ═══════════════════════ تشغيل الأذان الكامل ═══════════════════════

  /// ✅ يشغّل الأذان الكامل عبر Foreground Service على Android
  /// وعبر just_audio على iOS (لأن iOS يسمح بالصوت في الإشعار مباشرة)
  Future<void> playFullAdhan() async {
    if (Platform.isAndroid) {
      await _startAndroidForegroundService();
    } else {
      await _playIOSAdhan();
    }
  }

  Future<void> _startAndroidForegroundService() async {
    try {
      await _foregroundChannel.invokeMethod('startAdhan');
      AppLogger.log(
        'Android Foreground Service started for adhan',
        tag: 'ADHAN',
      );
    } on PlatformException catch (e) {
      AppLogger.error(
        'Failed to start foreground service',
        error: e,
        tag: 'ADHAN',
      );
      // Fallback: just_audio
      await _playIOSAdhan();
    }
  }

  Future<void> _playIOSAdhan() async {
    try {
      await _audioPlayer?.dispose();
      _audioPlayer = AudioPlayer();

      // ✅ تفعيل الصوت في الخلفية على iOS
      await _audioPlayer!.setAudioSource(AudioSource.asset('assets/azan.mp3'));
      await _audioPlayer!.play();

      _audioPlayer!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _audioPlayer?.dispose();
          _audioPlayer = null;
        }
      });
    } catch (e) {
      AppLogger.error('Failed to play adhan', error: e, tag: 'ADHAN');
    }
  }

  Future<void> stopAdhan() async {
    if (Platform.isAndroid) {
      await _foregroundChannel.invokeMethod('stopAdhan');
    }
    await _audioPlayer?.stop();
    await _audioPlayer?.dispose();
    _audioPlayer = null;
  }

  // ═══════════════════════ Notification Tap Handler ═══════════════════════

  /// Handle notification tap — plays full adhan if payload matches
  void handleNotificationTap(String? payload) {
    if (payload != null && payload.startsWith('adhan_tap')) {
      // على Android: الـ foreground service اشتغل بالفعل من الـ full-screen intent
      // على iOS: نشغّل الأذان يدوياً
      if (Platform.isIOS) {
        playFullAdhan();
      }
    }
  }
}
