import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:rafeeq/core/helpers/app_logger.dart';
import 'package:rafeeq/features/quran/logic/quran_asset_manager.dart';
import 'quran_download_state.dart';

class QuranDownloadCubit extends Cubit<QuranDownloadState> {
  QuranDownloadCubit() : super(QuranDownloadInitial());

  CancelToken? _cancelToken;

  Future<void> checkAssets() async {
    emit(QuranDownloadChecking());
    try {
      final downloaded = await QuranAssetManager.isAssetsDownloaded();
      final pagesPath = await QuranAssetManager.getPagesPath();
      if (downloaded) {
        emit(QuranDownloadSuccess(pagesPath: '$pagesPath/'));
        return;
      }

      final partialSize = await QuranAssetManager.getPartialDownloadSize();
      if (partialSize > 0) {
        // Approximate progress (~120 MB total)
        final progress = (partialSize / 126655726).clamp(0.0, 0.85);
        emit(QuranDownloadPaused(progress: progress));
      } else {
        emit(QuranDownloadNotDownloaded());
      }
    } catch (e) {
      AppLogger.error(
        'Failed checking Quran assets',
        error: e,
        tag: 'QuranDownloadCubit',
      );
      emit(QuranDownloadNotDownloaded());
    }
  }

  Future<void> startOrResumeDownload() async {
    _cancelToken = CancelToken();
    double currentProgress = 0.0;
    if (state is QuranDownloadPaused) {
      currentProgress = (state as QuranDownloadPaused).progress;
    }
    emit(
      QuranDownloading(
        progress: currentProgress,
        statusText: 'جاري بدء التحميل...',
      ),
    );

    try {
      await QuranAssetManager.downloadAndExtract(
        cancelToken: _cancelToken!,
        onProgress: ({
          required int downloadedBytes,
          required int totalBytes,
          required double progress,
          required bool isExtracting,
          required String statusText,
        }) {
          if (isClosed) return;
          emit(
            QuranDownloading(
              progress: progress,
              statusText: statusText,
              isExtracting: isExtracting,
            ),
          );
        },
      );

      if (_cancelToken?.isCancelled ?? false) {
        return;
      }

      final isReady = await QuranAssetManager.isAssetsDownloaded();
      if (isReady) {
        final pagesPath = await QuranAssetManager.getPagesPath();
        emit(QuranDownloadSuccess(pagesPath: '$pagesPath/'));
      } else if (!(_cancelToken?.isCancelled ?? false)) {
        emit(
          QuranDownloadPaused(
            progress: currentProgress,
            statusText: 'تم حفظ التقدم — اضغط متابعة التحميل للاستئناف',
          ),
        );
      }
    } catch (e) {
      if (_cancelToken?.isCancelled ?? false) {
        return;
      }
      AppLogger.error('Download error', error: e, tag: 'QuranDownloadCubit');
      emit(
        QuranDownloadError(
          'تعذر إكمال التحميل. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.',
        ),
      );
    }
  }

  void pauseDownload() {
    _cancelToken?.cancel();
    double progress = 0.0;
    if (state is QuranDownloading) {
      progress = (state as QuranDownloading).progress;
    }
    emit(
      QuranDownloadPaused(
        progress: progress,
        statusText: 'تم إيقاف التحميل مؤقتاً',
      ),
    );
  }

  Future<void> resetDownload() async {
    _cancelToken?.cancel();
    await QuranAssetManager.clearPartialDownload();
    emit(QuranDownloadNotDownloaded());
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel();
    return super.close();
  }
}
