import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:rafeeq/features/tasbih/data/model/tasbih_model.dart';

class TasbihRepository {
  // ── per-language cache ──────────────────────────────────────────────────────
  static final Map<String, List<TasbihModel>> _cache = {};

  /// Returns the full list of adhkar for [langCode] ('ar' or 'en').
  /// Reads the matching asset file on first call, returns cache after that.
  static Future<List<TasbihModel>> loadAll(String langCode) async {
    if (_cache.containsKey(langCode)) return _cache[langCode]!;

    final file = langCode == 'ar'
        ? 'assets/data/tasbih_ar.json'
        : 'assets/data/tasbih_en.json';

    final raw = await rootBundle.loadString(file);
    final list = jsonDecode(raw) as List<dynamic>;

    _cache[langCode] = list
        .map((e) => TasbihModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);

    return _cache[langCode]!;
  }

  /// Returns unique category names for [langCode].
  static Future<List<String>> categories(String langCode) async {
    final all = await loadAll(langCode);
    final seen = <String>{};
    return all.map((d) => d.cat).where(seen.add).toList();
  }

  /// Filters adhkar by category. Pass null to get all.
  static Future<List<TasbihModel>> byCategory(
    String langCode,
    String? cat,
  ) async {
    final all = await loadAll(langCode);
    if (cat == null) return all;
    return all.where((d) => d.cat == cat).toList();
  }

  /// Simple search — matches Arabic text, transliteration, or category.
  static Future<List<TasbihModel>> search(
    String langCode,
    String query,
  ) async {
    if (query.isEmpty) return loadAll(langCode);
    final q = query.toLowerCase();
    final all = await loadAll(langCode);
    return all.where((d) {
      return d.text.contains(q) ||
          d.transliteration.toLowerCase().contains(q) ||
          d.cat.toLowerCase().contains(q) ||
          d.meaning.toLowerCase().contains(q);
    }).toList();
  }

  /// Clears the cache — useful for hot-reload during development.
  static void clearCache() => _cache.clear();
}