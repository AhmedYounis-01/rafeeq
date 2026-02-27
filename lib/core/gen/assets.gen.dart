// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/Pacifico-Regular.ttf
  String get pacificoRegular => 'assets/fonts/Pacifico-Regular.ttf';

  /// File path: assets/fonts/Tajawal-Regular.ttf
  String get tajawalRegular => 'assets/fonts/Tajawal-Regular.ttf';

  /// List of all assets
  List<String> get values => [pacificoRegular, tajawalRegular];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/Duhr.png
  AssetGenImage get duhr => const AssetGenImage('assets/images/Duhr.png');

  /// File path: assets/images/asr.png
  AssetGenImage get asr => const AssetGenImage('assets/images/asr.png');

  /// File path: assets/images/azkar.png
  AssetGenImage get azkar => const AssetGenImage('assets/images/azkar.png');

  /// File path: assets/images/best.jpg
  AssetGenImage get best => const AssetGenImage('assets/images/best.jpg');

  /// File path: assets/images/dua.png
  AssetGenImage get dua => const AssetGenImage('assets/images/dua.png');

  /// File path: assets/images/fajr.png
  AssetGenImage get fajr => const AssetGenImage('assets/images/fajr.png');

  /// File path: assets/images/good.jpg
  AssetGenImage get good => const AssetGenImage('assets/images/good.jpg');

  /// File path: assets/images/good1.jpg
  AssetGenImage get good1 => const AssetGenImage('assets/images/good1.jpg');

  /// File path: assets/images/good2.jpg
  AssetGenImage get good2 => const AssetGenImage('assets/images/good2.jpg');

  /// File path: assets/images/good3.jpg
  AssetGenImage get good3 => const AssetGenImage('assets/images/good3.jpg');

  /// File path: assets/images/isha.png
  AssetGenImage get isha => const AssetGenImage('assets/images/isha.png');

  /// File path: assets/images/maghrb.png
  AssetGenImage get maghrb => const AssetGenImage('assets/images/maghrb.png');

  /// File path: assets/images/mosque1.jpg
  AssetGenImage get mosque1 => const AssetGenImage('assets/images/mosque1.jpg');

  /// File path: assets/images/mosque2.jpg
  AssetGenImage get mosque2 => const AssetGenImage('assets/images/mosque2.jpg');

  /// File path: assets/images/ruqiah.png
  AssetGenImage get ruqiah => const AssetGenImage('assets/images/ruqiah.png');

  /// File path: assets/images/seerah.png
  AssetGenImage get seerah => const AssetGenImage('assets/images/seerah.png');

  /// File path: assets/images/shrouq.png
  AssetGenImage get shrouq => const AssetGenImage('assets/images/shrouq.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    duhr,
    asr,
    azkar,
    best,
    dua,
    fajr,
    good,
    good1,
    good2,
    good3,
    isha,
    maghrb,
    mosque1,
    mosque2,
    ruqiah,
    seerah,
    shrouq,
  ];
}

class $AssetsTranslationsGen {
  const $AssetsTranslationsGen();

  /// File path: assets/translations/ar.json
  String get ar => 'assets/translations/ar.json';

  /// File path: assets/translations/en.json
  String get en => 'assets/translations/en.json';

  /// List of all assets
  List<String> get values => [ar, en];
}

class Assets {
  const Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsTranslationsGen translations = $AssetsTranslationsGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
