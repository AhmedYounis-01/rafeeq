import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:rafeeq/features/quick_parts/data/models/dhikr_item.dart';
import 'package:rafeeq/features/quick_parts/data/models/asma_allah_item.dart';

enum QuickPartType { azkar, ruqiah, dua }

class QuickPartsRepository {
  QuickPartsRepository._();
  static final QuickPartsRepository instance = QuickPartsRepository._();

  // In-memory cache
  final Map<QuickPartType, List<DhikrItem>> _dhikrCache = {};
  List<AsmaAllahItem>? _asmaAllahCache;

  static const _paths = {
    QuickPartType.azkar: 'assets/data/azkar.json',
    QuickPartType.ruqiah: 'assets/data/ruqiah.json',
    QuickPartType.dua:
        'assets/data/dua.json', // Not used anymore for Asma Allah but keeping for compatibility
  };

  Future<List<DhikrItem>> loadDhikr(QuickPartType type) async {
    if (_dhikrCache.containsKey(type)) return _dhikrCache[type]!;

    final jsonStr = await rootBundle.loadString(_paths[type]!);
    final List<dynamic> jsonList = json.decode(jsonStr);
    final items = jsonList.map((e) => DhikrItem.fromJson(e)).toList();
    _dhikrCache[type] = items;
    return items;
  }

  Future<List<AsmaAllahItem>> loadAsmaAllah() async {
    if (_asmaAllahCache != null) return _asmaAllahCache!;

    final jsonStr = await rootBundle.loadString('assets/data/asma_allah.json');
    final List<dynamic> jsonList = json.decode(jsonStr);
    final items = jsonList.map((e) => AsmaAllahItem.fromJson(e)).toList();
    _asmaAllahCache = items;
    return items;
  }

  /// Groups dhikr items by category (preserves JSON order).
  Map<String, List<DhikrItem>> groupByCategory(
    List<DhikrItem> items,
    bool isArabic,
  ) {
    final map = <String, List<DhikrItem>>{};
    for (final item in items) {
      final key = isArabic ? item.cat : item.catEn;
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }
}
