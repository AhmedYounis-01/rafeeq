import 'package:flutter_test/flutter_test.dart';
import 'package:rafeeq/features/quran/logic/cubit/download/quran_download_cubit.dart';
import 'package:rafeeq/features/quran/logic/cubit/download/quran_download_state.dart';
import 'package:rafeeq/features/quran/logic/quran_asset_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuranAssetManager', () {
    test('downloadUrl matches the valid v1.1.0 release asset url', () {
      expect(
        QuranAssetManager.downloadUrl,
        'https://github.com/AhmedYounis-01/rafeeq-assets/releases/download/v1.1.0/quran_pages.zip',
      );
    });

    test('isDownloadedSync returns false by default before download', () {
      expect(QuranAssetManager.isDownloadedSync(), isFalse);
    });
  });

  group('QuranDownloadCubit', () {
    test('initial state is QuranDownloadInitial', () {
      final cubit = QuranDownloadCubit();
      expect(cubit.state, isA<QuranDownloadInitial>());
      cubit.close();
    });

    test('pauseDownload transitions state to QuranDownloadPaused', () {
      final cubit = QuranDownloadCubit();
      cubit.pauseDownload();
      expect(cubit.state, isA<QuranDownloadPaused>());
      cubit.close();
    });
  });
}
