import 'package:flutter/foundation.dart';

@immutable
sealed class QuranDownloadState {}

class QuranDownloadInitial extends QuranDownloadState {}

class QuranDownloadChecking extends QuranDownloadState {}

class QuranDownloadNotDownloaded extends QuranDownloadState {}

class QuranDownloading extends QuranDownloadState {
  final double progress;
  final String statusText;
  final bool isExtracting;

  QuranDownloading({
    required this.progress,
    required this.statusText,
    this.isExtracting = false,
  });
}

class QuranDownloadPaused extends QuranDownloadState {
  final double progress;
  final String statusText;

  QuranDownloadPaused({
    required this.progress,
    this.statusText = 'تم إيقاف التحميل مؤقتاً',
  });
}

class QuranDownloadSuccess extends QuranDownloadState {
  final String pagesPath;

  QuranDownloadSuccess({required this.pagesPath});
}

class QuranDownloadError extends QuranDownloadState {
  final String errorMessage;

  QuranDownloadError(this.errorMessage);
}
