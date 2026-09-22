import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:rafeeq/core/helpers/app_logger.dart';

/// فئة مسؤولة حصرياً عن تنظيف ملفات الكاش والمجلدات المؤقتة
/// (Temporary Cache Directory فقط)
///
/// ⚠️ تنبيه أمان:
/// هذه الفئة لا تلمس إطلاقاً:
/// 1. SharedPreferences (مكان حفظ الموقع الجغرافي، مواقيت الصلاة، حالة الأذان، الثيم، تقدم القراءة).
/// 2. AlarmManager أو خدمة الإشعارات (المسؤولة عن تنبيهات الصلاة).
/// 3. Documents Directory (مكان حفظ صفحات القرآن الكريم بعد تحميلها).
class CacheCleaner {
  /// يقوم بمسح ملفات الكاش المؤقتة من مجلد (Temporary Directory / cacheDir)
  /// هذا المجلد مخصص من نظام أندرويد/iOS للملفات سريعة الزوال فقط مثل:
  /// - كاش الصور المؤقت للـ Network
  /// - ملفات التخزين المؤقت للـ Buffer
  static Future<void> clearTemporaryCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        final entries = tempDir.listSync(recursive: false);
        for (final entry in entries) {
          try {
            if (entry is File) {
              entry.deleteSync();
            } else if (entry is Directory) {
              entry.deleteSync(recursive: true);
            }
          } catch (_) {
            // الملفات المفتوحة حالياً في الذاكرة يتم تخطيها بأمان
          }
        }
        AppLogger.log('Temporary cache cleared safely', tag: 'CacheCleaner');
      }
    } catch (e) {
      AppLogger.error('Failed to clear temporary cache', error: e, tag: 'CacheCleaner');
    }
  }
}
