import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:rafeeq/core/helpers/app_logger.dart';
import 'package:rafeeq/core/services/adhan_scheduler_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// خدمة الإشعارات المحلية — تجدول إشعارات يومية بتوزيع ذكي
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ─────────────────────── رسائل الدعاء لعبدالرحمن ───────────────────────
  static const List<String> _duaMessages = [
    'ولا تنسوا رفيقك عبدالرحمن ووالده والمسلمين من دعائك',
    'اجعل لعبدالرحمن ووالده نصيبًا من دعائك اليوم',
    'تذكر الدعاء لعبدالرحمن ووالده ولجميع المسلمين',
    'دعوة بسيطة قد تكون سببًا في خير لعبدالرحمن ووالده',
    'إن دعوت، فلا تنس عبدالرحمن ووالده والمسلمين',
    'اجعل في دعائك خيرًا لعبدالرحمن ووالده والمسلمين',
  ];

  // ─────────────────────── رسائل عامة (القرآن) ───────────────────────
  static const List<String> _generalMessages = [
    'ابدأ يومك بآية من القرآن، قد تمنحك هدوءًا تحتاجه',
    'دقائق مع القرآن قد تغيّر شعورك بهدوء',
    'اقرأ ولو قليلًا، فالقليل مع القرآن له أثر',
    'حين تقرأ القرآن، يأخذ قلبك فرصة للراحة',
    'اجعل لك وردًا بسيطًا من القرآن كل يوم',
    'قد تكون هذه اللحظة مناسبة لقراءة شيء من القرآن',
    'لا يلزم الكثير، فقط وقت هادئ مع كتاب الله',
    'القرآن قد يضيف ليومك سكينة خفيفة تشعر بها',
  ];

  // ─────────────────────── رسائل إضافية (أذكار) ───────────────────────
  static const List<String> _extraMessages = [
    'يمكنك أن تذكر الله قليلًا الآن',
    'تسبيحة بسيطة قد تضيف راحة ليومك',
    'لحظة ذكر قد تصنع فرقًا هادئًا',
    'يمكنك قراءة دعاء قصير الآن',
    'تعرف على اسم من أسماء الله الحسنى اليوم',
    'خذ دقيقة لقراءة شيء من السيرة',
    'الرقية الشرعية قد تكون نافعة في هذا الوقت',
  ];

  // ─────────────── أوقات الإشعارات ومعرّفاتها ───────────────
  static const List<_ScheduleEntry> _schedule = [
    _ScheduleEntry(id: 100, hour: 9, type: _MsgType.general), // صباح — قرآن
    _ScheduleEntry(id: 101, hour: 13, type: _MsgType.dua), // بعد الظهر — دعاء
    _ScheduleEntry(id: 102, hour: 21, type: _MsgType.extra), // ليل — ذكر
  ];

  // ═══════════════════════ التهيئة ═══════════════════════

  Future<void> init() async {
    if (_initialized) return;

    // تهيئة المناطق الزمنية
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // Fallback to UTC if timezone detection fails
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // إعدادات iOS — طلب الأذونات عند التهيئة
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // طلب إذن الإشعارات على Android 13+
    // طلب إذن الإشعارات وإعداد القنوات للأندرويد
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();

      // Daily reminders channel
      const remindersChannel = AndroidNotificationChannel(
        'rafeeq_daily_reminders',
        'تذكيرات رفيق اليومية',
        description: 'إشعارات يومية للقرآن والأذكار والدعاء',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
      await androidPlugin.createNotificationChannel(remindersChannel);

      // Adhan channel with custom sound
      const adhanChannel = AndroidNotificationChannel(
        'adhan_channel',
        'إشعارات الأذان',
        description: 'تشغيل الأذان عند دخول وقت الصلاة',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('adhan'),
      );
      await androidPlugin.createNotificationChannel(adhanChannel);

      await androidPlugin.requestExactAlarmsPermission();
    }

    _initialized = true;
    AppLogger.log('NotificationService initialized', tag: 'NOTIFICATION');
  }

  void _onNotificationTap(NotificationResponse response) {
    AppLogger.log(
      'Notification tapped: ${response.payload}',
      tag: 'NOTIFICATION',
    );

    // Route adhan taps to the adhan service
    if (response.payload != null && response.payload!.startsWith('adhan_tap')) {
      AdhanSchedulerService.instance.handleNotificationTap(response.payload);
    }
  }

  // ═══════════════════════ جدولة الإشعارات ═══════════════════════

  /// يلغي كل الإشعارات القديمة ويجدول إشعارات يومية متكررة
  Future<void> scheduleDailyNotifications() async {
    // Cancel only daily reminder IDs (100, 101, 102) — NOT adhan IDs
    for (final entry in _schedule) {
      await _plugin.cancel(id: entry.id);
    }

    final now = tz.TZDateTime.now(tz.local);
    final dayOfYear = _dayOfYear(now);

    for (final entry in _schedule) {
      final body = _pickMessage(entry.type, dayOfYear, entry.id);
      await _scheduleDaily(
        id: entry.id,
        hour: entry.hour,
        title: 'رفيق',
        body: body,
        now: now,
      );
    }

    AppLogger.log(
      'Scheduled ${_schedule.length} daily notifications',
      tag: 'NOTIFICATION',
    );
  }

  /// جدولة إشعار يومي متكرر في ساعة محددة
  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required String title,
    required String body,
    required tz.TZDateTime now,
  }) async {
    // حساب وقت الإشعار القادم
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
    );
    // لو الوقت فات النهاردة، نجدوله بكرة
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'rafeeq_daily_reminders',
      'تذكيرات رفيق اليومية',
      channelDescription: 'إشعارات يومية للقرآن والأذكار والدعاء',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // يتكرر يوميًا
    );

    if (kDebugMode) {
      AppLogger.log(
        'Notification #$id scheduled at $scheduledDate → $body',
        tag: 'NOTIFICATION',
      );
    }
  }

  // ═══════════════════════ التوزيع الذكي ═══════════════════════

  /// يختار رسالة بناءً على نوعها واليوم، بحيث تتغير يوميًا
  String _pickMessage(_MsgType type, int dayOfYear, int entryId) {
    // دمج اليوم مع معرّف الإشعار لتنويع الرسائل بين الفترات
    final seed = dayOfYear + entryId;

    switch (type) {
      case _MsgType.general:
        return _generalMessages[seed % _generalMessages.length];
      case _MsgType.dua:
        return _duaMessages[seed % _duaMessages.length];
      case _MsgType.extra:
        return _extraMessages[seed % _extraMessages.length];
    }
  }

  /// رقم اليوم من بداية السنة (1‑366)
  int _dayOfYear(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    return date.difference(firstDay).inDays + 1;
  }
}

// ────────────────────── أنواع مساعدة ──────────────────────

enum _MsgType { general, dua, extra }

class _ScheduleEntry {
  final int id;
  final int hour;
  final _MsgType type;

  const _ScheduleEntry({
    required this.id,
    required this.hour,
    required this.type,
  });
}
