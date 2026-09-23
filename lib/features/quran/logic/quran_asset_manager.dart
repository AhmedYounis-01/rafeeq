import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:rafeeq/core/helpers/app_logger.dart';

class QuranAssetManager {
  static const String kPrefsKey = 'quran_assets_downloaded';

  // Hosted ZIP file location (v1.1.0 pages only)
  static const String downloadUrl =
      'https://github.com/AhmedYounis-01/rafeeq-assets/releases/download/v1.1.0/quran_pages.zip';

  static const int kParallelConnections = 4;
  static const int kKnownTotalBytes = 126655726;

  static Future<String> getAssetsPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return p.join(appDir.path, 'quran_assets');
  }

  static Future<String> getPagesPath() async {
    final base = await getAssetsPath();
    return p.join(base, 'pages');
  }

  static Future<String> getFontsPath() async {
    final base = await getAssetsPath();
    return p.join(base, 'fonts');
  }

  static String _getPartPath(String basePath, int index) =>
      '$basePath.part$index';

  // Cache result so we only scan files once per session
  static bool? _assetsVerified;

  /// Deletes leftover zip files, download parts, and obsolete font folders to free storage.
  static Future<void> cleanupOrphanedFiles() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();

      // 1. Delete all temporary zip and part files
      final entries = appDir.listSync();
      for (final entry in entries) {
        if (entry is File) {
          final name = p.basename(entry.path).toLowerCase();
          if (name.endsWith('.zip') ||
              name.contains('.part') ||
              name.contains('.tmp') ||
              name.contains('temp')) {
            try {
              entry.deleteSync();
            } catch (_) {}
          }
        }
      }

      // 2. Delete obsolete fonts directory if it exists from previous versions
      final fontsDir = Directory(p.join(appDir.path, 'quran_assets', 'fonts'));
      if (fontsDir.existsSync()) {
        try {
          fontsDir.deleteSync(recursive: true);
        } catch (_) {}
      }

      // 3. Delete obsolete mushaf_assets directory if it exists
      final oldMushafDir = Directory(p.join(appDir.path, 'mushaf_assets'));
      if (oldMushafDir.existsSync()) {
        try {
          oldMushafDir.deleteSync(recursive: true);
        } catch (_) {}
      }
    } catch (e) {
      AppLogger.error(
        'Failed cleanupOrphanedFiles',
        error: e,
        tag: 'QuranAssetManager',
      );
    }
  }

  static Future<bool> isAssetsDownloaded() async {
    if (_assetsVerified == true) return true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final isDownloaded = prefs.getBool(kPrefsKey) ?? false;
      if (!isDownloaded) return false;

      final pagesPath = await getPagesPath();
      final pagesDir = Directory(pagesPath);

      if (!await pagesDir.exists()) {
        return false;
      }

      // Check if all Quran page images exist (604 pages)
      final pagesCount = pagesDir.listSync().whereType<File>().length;
      if (pagesCount < 604) {
        return false;
      }

      _assetsVerified = true;
      // Clean up any leftover temporary files or obsolete font folders now that pages are verified
      cleanupOrphanedFiles();
      return true;
    } catch (e) {
      AppLogger.error(
        'Failed checking assets existence',
        error: e,
        tag: 'QuranAssetManager',
      );
      return false;
    }
  }

  static Future<int> getPartialDownloadSize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final tempZipPath = p.join(appDir.path, 'quran_assets_temp.zip');
      final tempFile = File(tempZipPath);
      if (await tempFile.exists()) {
        return await tempFile.length();
      }
      int total = 0;
      for (int i = 0; i < kParallelConnections; i++) {
        final partFile = File(_getPartPath(tempZipPath, i));
        if (await partFile.exists()) {
          total += await partFile.length();
        }
      }
      return total;
    } catch (_) {}
    return 0;
  }

  static Future<void> clearPartialDownload() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final tempZipPath = p.join(appDir.path, 'quran_assets_temp.zip');
      final tempFile = File(tempZipPath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      for (int i = 0; i < kParallelConnections; i++) {
        final partFile = File(_getPartPath(tempZipPath, i));
        if (await partFile.exists()) {
          await partFile.delete();
        }
      }
    } catch (_) {}
  }

  static Future<void> downloadAndExtract({
    required CancelToken cancelToken,
    required void Function({
      required int downloadedBytes,
      required int totalBytes,
      required double progress,
      required bool isExtracting,
      required String statusText,
    })
    onProgress,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final tempZipPath = p.join(appDir.path, 'quran_assets_temp.zip');
    final targetPath = await getAssetsPath();
    final tempFile = File(tempZipPath);
    final dio = Dio();

    try {
      // ── Step 1: Resolve final CDN URL (avoids losing Range header on redirect) ──
      String finalUrl = downloadUrl;
      int totalBytes = kKnownTotalBytes;

      try {
        final resolveResp = await dio.head(
          downloadUrl,
          options: Options(
            followRedirects: true,
            validateStatus: (s) => s != null && s < 400,
          ),
        );
        final realUri = resolveResp.realUri;
        if (realUri.toString().isNotEmpty &&
            realUri.toString() != downloadUrl) {
          finalUrl = realUri.toString();
        }
        final cl = resolveResp.headers.value(HttpHeaders.contentLengthHeader);
        if (cl != null) {
          totalBytes = int.tryParse(cl) ?? kKnownTotalBytes;
        }
      } catch (_) {
        finalUrl = downloadUrl;
      }

      // ── Step 2: Check if file already fully downloaded or assembled ────────
      bool needDownload = true;
      if (await tempFile.exists() && (await tempFile.length()) >= totalBytes) {
        AppLogger.log(
          'Zip file already assembled on disk, skipping download.',
          tag: 'QuranAssetManager',
        );
        needDownload = false;
      }

      if (needDownload) {
        // Calculate chunk ranges for parallel download
        final int chunkSize = (totalBytes / kParallelConnections).ceil();
        final List<int> partStarts = [];
        final List<int> partEnds = [];
        final List<int> downloadedPerPart = List.filled(
          kParallelConnections,
          0,
        );

        for (int i = 0; i < kParallelConnections; i++) {
          final start = i * chunkSize;
          final end = (i == kParallelConnections - 1)
              ? (totalBytes - 1)
              : ((i + 1) * chunkSize - 1);
          partStarts.add(start);
          partEnds.add(end);

          final partFile = File(_getPartPath(tempZipPath, i));
          if (await partFile.exists()) {
            downloadedPerPart[i] = await partFile.length();
          }
        }

        int lastReportTime = 0;
        void reportProgress() {
          final now = DateTime.now().millisecondsSinceEpoch;
          if (now - lastReportTime > 80) {
            lastReportTime = now;
            final sum = downloadedPerPart.fold<int>(0, (a, b) => a + b);
            onProgress(
              downloadedBytes: sum,
              totalBytes: totalBytes,
              progress: (sum / totalBytes * 0.85).clamp(0.0, 0.85),
              isExtracting: false,
              statusText: 'جاري تحميل صفحات المصحف...',
            );
          }
        }

        reportProgress();

        // ── Step 3: Run 4 parallel chunk downloads ────────────────────────
        AppLogger.log(
          'Launching $kParallelConnections parallel streams for Quran assets...',
          tag: 'QuranAssetManager',
        );

        await Future.wait(
          List.generate(kParallelConnections, (i) async {
            final partStart = partStarts[i];
            final partEnd = partEnds[i];
            final currentPartBytes = downloadedPerPart[i];
            final expectedLength = partEnd - partStart + 1;

            if (currentPartBytes >= expectedLength) {
              return; // Part is already finished
            }

            final fetchStart = partStart + currentPartBytes;
            final partFile = File(_getPartPath(tempZipPath, i));
            final partDio = Dio();

            final response = await partDio.get<ResponseBody>(
              finalUrl,
              options: Options(
                responseType: ResponseType.stream,
                followRedirects: true,
                headers: {'Range': 'bytes=$fetchStart-$partEnd'},
                validateStatus: (status) =>
                    status != null && (status == 200 || status == 206),
              ),
              cancelToken: cancelToken,
            );

            final sink = partFile.openWrite(
              mode: currentPartBytes > 0 ? FileMode.append : FileMode.write,
            );

            try {
              await for (final chunk in response.data!.stream) {
                if (cancelToken.isCancelled) {
                  await sink.flush();
                  await sink.close();
                  return;
                }
                sink.add(chunk);
                downloadedPerPart[i] += chunk.length;
                reportProgress();
              }
              await sink.flush();
              await sink.close();
            } catch (e) {
              await sink.flush();
              await sink.close();
              rethrow;
            }
          }),
        );

        if (cancelToken.isCancelled) return;

        // Verify all parts are complete before assembling
        bool allPartsComplete = true;
        for (int i = 0; i < kParallelConnections; i++) {
          final expected = partEnds[i] - partStarts[i] + 1;
          final partFile = File(_getPartPath(tempZipPath, i));
          final actual = await partFile.exists() ? await partFile.length() : 0;
          if (actual < expected) {
            allPartsComplete = false;
            break;
          }
        }

        if (!allPartsComplete) {
          AppLogger.log(
            'Parts incomplete (stream paused/dropped). Progress saved.',
            tag: 'QuranAssetManager',
          );
          return;
        }

        // ── Step 4: Rapidly assemble parts into final zip (takes ~0.1s) ─────
        AppLogger.log(
          'All parts downloaded! Assembling zip...',
          tag: 'QuranAssetManager',
        );
        final outputSink = tempFile.openWrite(mode: FileMode.write);
        for (int i = 0; i < kParallelConnections; i++) {
          final partFile = File(_getPartPath(tempZipPath, i));
          await outputSink.addStream(partFile.openRead());
        }
        await outputSink.flush();
        await outputSink.close();

        // Remove part files
        for (int i = 0; i < kParallelConnections; i++) {
          final partFile = File(_getPartPath(tempZipPath, i));
          if (await partFile.exists()) {
            await partFile.delete();
          }
        }
      }

      if (cancelToken.isCancelled) return;

      // ── Step 5: Background Isolate Extraction (Zero UI thread freeze) ───
      AppLogger.log(
        'Extracting Quran assets zip in background Isolate...',
        tag: 'QuranAssetManager',
      );
      onProgress(
        downloadedBytes: totalBytes,
        totalBytes: totalBytes,
        progress: 0.88,
        isExtracting: true,
        statusText: 'جاري فك ضغط صفحات المصحف وتجهيزها...',
      );

      await compute(_extractZipWorker, (tempZipPath, targetPath));

      // Cleanup ZIP on success
      if (await tempFile.exists()) await tempFile.delete();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kPrefsKey, true);
      _assetsVerified = true;

      AppLogger.log(
        'Quran assets downloaded and extracted successfully.',
        tag: 'QuranAssetManager',
      );

      onProgress(
        downloadedBytes: totalBytes,
        totalBytes: totalBytes,
        progress: 1.0,
        isExtracting: false,
        statusText: 'تم التحميل بنجاح!',
      );
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        AppLogger.log('Download paused by user.', tag: 'QuranAssetManager');
        return;
      }

      if (e is DioException) {
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          AppLogger.log(
            'Network error during download. Progress saved.',
            tag: 'QuranAssetManager',
          );
          return;
        }
      }

      AppLogger.error(
        'Failed to download or extract Quran assets',
        error: e,
        tag: 'QuranAssetManager',
      );
      rethrow;
    }
  }

  static Future<void> loadFonts(
    void Function(double progress)? onProgress,
  ) async {
    // Fonts are no longer required as Quran pages are rendered directly from PNG images.
    onProgress?.call(1.0);
  }
}

/// Standalone top-level worker function for isolate extraction.
/// Must remain top-level so it has no lexical closure scope, ensuring
/// objects like CancelToken or ports are never captured.
void _extractZipWorker((String, String) paths) {
  final (tempZipPath, targetPath) = paths;
  final zipFile = File(tempZipPath);
  final bytes = zipFile.readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);

  final targetDir = Directory(targetPath);
  if (targetDir.existsSync()) {
    targetDir.deleteSync(recursive: true);
  }
  targetDir.createSync(recursive: true);

  for (final file in archive) {
    if (file.isFile) {
      final data = file.content as List<int>;
      String relativePath = file.name;
      if (relativePath.startsWith('quran_assets/')) {
        relativePath = relativePath.substring('quran_assets/'.length);
      } else if (relativePath.startsWith('mushaf_assets/')) {
        relativePath = relativePath.substring('mushaf_assets/'.length);
      }
      final outPath = p.join(targetPath, relativePath);
      final outFile = File(outPath);
      outFile.parent.createSync(recursive: true);
      outFile.writeAsBytesSync(data, flush: false);
    }
  }
}
