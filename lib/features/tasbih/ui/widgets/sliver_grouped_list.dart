import 'package:flutter/material.dart';
import 'package:rafeeq/features/tasbih/data/model/tasbih_model.dart';
import 'tasbih_config.dart';
import 'dhikr_selection_card.dart';

class CatGroup {
  final String name;
  final List<MapEntry<int, TasbihModel>> entries;
  const CatGroup(this.name, this.entries);
}

class CatHeader extends StatelessWidget {
  final String name;
  final int count;
  final Color primary;
  final double labelFont;

  const CatHeader({
    super.key,
    required this.name,
    required this.count,
    required this.primary,
    required this.labelFont,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 8),
    child: Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: TasbihTextStyles.amiriBold(labelFont + 3, primary),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: labelFont,
              color: primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class SliverGroupedList extends StatelessWidget {
  final List<CatGroup> groups;
  final Color primary, cardBg;
  final bool isDark, isRtl;
  final TasbihConfig cfg;
  final void Function(int) onSelect;

  const SliverGroupedList({
    super.key,
    required this.groups,
    required this.primary,
    required this.isDark,
    required this.isRtl,
    required this.cfg,
    required this.cardBg,
    required this.onSelect,
  });

  List<Object> _flat() {
    final out = <Object>[];
    for (final g in groups) {
      out.add(g.name);
      out.addAll(g.entries);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final items = _flat();
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: cfg.hPad),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, i) {
          final item = items[i];
          if (item is String) {
            final cnt = groups.firstWhere((g) => g.name == item).entries.length;
            return CatHeader(
              name: item,
              count: cnt,
              primary: primary,
              labelFont: cfg.labelFont,
            );
          }
          final e = item as MapEntry<int, TasbihModel>;
          return DhikrSelectionCard(
            entry: e,
            primary: primary,
            isDark: isDark,
            isRtl: isRtl,
            cfg: cfg,
            cardBg: cardBg,
            onTap: () => onSelect(e.key),
          );
        }, childCount: items.length),
      ),
    );
  }
}
