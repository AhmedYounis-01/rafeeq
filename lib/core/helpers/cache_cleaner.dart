import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:rafeeq/core/helpers/app_logger.dart';

class CacheCleaner {
  /// يقوم بمسح جميع الملفات المؤقتة من مجلد التخزين المؤقت (Temporary/Cache Directory)
  /// لضمان عدم تراكم أي كاش زائد يثقل ذاكرة الهاتف.
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
            // بعض الملفات قد تكون قيد الاستخدام في تلك اللحظة
          }
        }
        AppLogger.log('Temporary cache cleared successfully', tag: 'CacheCleaner');
      }
    } catch (e) {
      AppLogger.error('Failed to clear temporary cache', error: e, tag: 'CacheCleaner');
    }
  }

  /// تنظيف شامل للملفات المؤقتة والملفات العالقة (.tmp, .part, .zip غير المكتملة)
  /// فور الانتهاء من عملية التهيئة الأولى أو بعد الـ Onboarding.
  static Future<void> clearAppOrphanedFiles() async {
    try {
      await clearTemporaryCache();

      final docDir = await getApplicationDocumentsDirectory();
      if (docDir.existsSync()) {
        final entries = docDir.listSync(recursive: false);
        for (final entry in entries) {
          if (entry is File) {
            final name = p.basename(entry.path).toLowerCase();
            if (name.endsWith('.tmp') ||
                name.contains('.part') ||
                name.contains('temp')) {
              try {
                entry.deleteSync();
              } catch (_) {}
            }
          }
        }
      }
      AppLogger.log('Orphaned temp files cleaned up', tag: 'CacheCleaner');
    } catch (e) {
      AppLogger.error('Failed to clean orphaned files', error: e, tag: 'CacheCleaner');
    }
  }
}
