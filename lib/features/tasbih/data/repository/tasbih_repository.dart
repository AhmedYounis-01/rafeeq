import 'dart:convert';
import 'package:flutter/services.dart'; 
import 'package:rafeeq/features/tasbih/data/model/tasbih_model.dart';

class TasbihRepository {
  // ── private cache — loaded once, reused forever ──
  static List<TasbihModel>? _cache;

  /// Returns the full list of adhkar.
  /// Reads from assets on first call, returns cached list after that.
  static Future<List<TasbihModel>> loadAll() async {
    if (_cache != null) return _cache!;

    final raw = await rootBundle.loadString('assets/data/tasbih.json');
    final list = jsonDecode(raw) as List<dynamic>;

    _cache = list
        .map((e) => TasbihModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);

    return _cache!;
  }

  /// Returns unique category names in Arabic.
  static Future<List<String>> categoriesAr() async {
    final all = await loadAll();
    final seen = <String>{};
    return all.map((d) => d.cat).where(seen.add).toList();
  }

  /// Returns unique category names in English.
  static Future<List<String>> categoriesEn() async {
    final all = await loadAll();
    final seen = <String>{};
    return all.map((d) => d.catEn).where(seen.add).toList();
  }

  /// Filters adhkar by category (pass null to get all).
  static Future<List<TasbihModel>> byCategoryAr(String? cat) async {
    final all = await loadAll();
    if (cat == null) return all;
    return all.where((d) => d.cat == cat).toList();
  }

  static Future<List<TasbihModel>> byCategoryEn(String? catEn) async {
    final all = await loadAll();
    if (catEn == null) return all;
    return all.where((d) => d.catEn == catEn).toList();
  }

  /// Simple search — matches Arabic text, transliteration, or category name.
  static Future<List<TasbihModel>> search(String query) async {
    if (query.isEmpty) return loadAll();
    final q = query.toLowerCase();
    final all = await loadAll();
    return all.where((d) {
      return d.text.contains(q) ||
          d.transliteration.toLowerCase().contains(q) ||
          d.cat.contains(q) ||
          d.catEn.toLowerCase().contains(q);
    }).toList();
  }

  /// Clears the cache — useful for hot-reload during development.
  static void clearCache() => _cache = null;
}