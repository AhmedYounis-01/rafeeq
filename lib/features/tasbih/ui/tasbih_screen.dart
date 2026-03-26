import 'dart:async';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:rafeeq/features/tasbih/data/model/tasbih_model.dart';
import 'package:rafeeq/features/tasbih/data/repository/tasbih_repository.dart';

// ════════════════════════════════════════════════════════════════════════════
// CACHED TEXT STYLES — built once, reused everywhere (zero repeated allocations)
// ════════════════════════════════════════════════════════════════════════════
abstract final class _TS {
  static TextStyle amiriBold(double size, Color color) => GoogleFonts.amiri(
    fontSize: size,
    fontWeight: FontWeight.bold,
    color: color,
  );

  static TextStyle amiri(
    double size,
    Color color, {
    FontStyle style = FontStyle.normal,
    FontWeight weight = FontWeight.normal,
    double height = 1.0,
  }) => GoogleFonts.amiri(
    fontSize: size,
    color: color,
    fontStyle: style,
    fontWeight: weight,
    height: height,
  );

  static TextStyle amiriQuran(
    double size,
    Color color, {
    double height = 1.8,
  }) => GoogleFonts.amiriQuran(fontSize: size, color: color, height: height);
}

// ════════════════════════════════════════════════════════════════════════════
// SESSION + CFG
// ════════════════════════════════════════════════════════════════════════════
class _Session {
  final String dhikrText;
  final int count;
  final DateTime time;
  const _Session({
    required this.dhikrText,
    required this.count,
    required this.time,
  });
}

class _Cfg {
  final double side, width, height;
  _Cfg(BuildContext ctx)
    : side = MediaQuery.sizeOf(ctx).shortestSide,
      width = MediaQuery.sizeOf(ctx).width,
      height = MediaQuery.sizeOf(ctx).height;
  bool get isTablet => side >= 600;
  double get titleFont => (side * 0.058).clamp(18.0, 28.0);
  double get dhikrFont => (side * 0.046).clamp(15.0, 22.0);
  double get labelFont => (side * 0.033).clamp(11.0, 16.0);
  double get hPad => isTablet ? 28.0 : 18.0;
}

// ════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ════════════════════════════════════════════════════════════════════════════
class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});
  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  // ── repo data ──────────────────────────────────────────────────────────────
  List<TasbihModel> _adhkar = [];
  bool _loading = true;

  int? _selectedIdx;
  int _count = 0;
  bool _completed = false;
  bool _silent = false;
  final List<_Session> _sessions = [];
  int _todayTotal = 0;

  // ── helpers ────────────────────────────────────────────────────────────────
  TasbihModel get _dhikr => _adhkar[_selectedIdx ?? 0];
  int get _target => _dhikr.count;
  bool get _isAr => context.locale.languageCode == 'ar';

  // ── lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await TasbihRepository.loadAll();
    if (mounted) {
      setState(() {
        _adhkar = data;
        _loading = false;
      });
    }
  }

  // ── actions ────────────────────────────────────────────────────────────────
  void _haptic(HapticFeedbackType t) {
    if (_silent) return;
    switch (t) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
      case HapticFeedbackType.select:
        HapticFeedback.selectionClick();
    }
  }

  void _select(int i) {
    _haptic(HapticFeedbackType.select);
    setState(() {
      _selectedIdx = i;
      _count = 0;
      _completed = false;
    });
  }

  void _goBack() {
    _haptic(HapticFeedbackType.select);
    setState(() {
      _selectedIdx = null;
      _count = 0;
      _completed = false;
    });
  }

  void _goNext() {
    if (_selectedIdx == null || _adhkar.isEmpty) return;
    _haptic(HapticFeedbackType.select);
    setState(() {
      _selectedIdx = (_selectedIdx! + 1) % _adhkar.length;
      _count = 0;
      _completed = false;
    });
  }

  void _goPrev() {
    if (_selectedIdx == null || _adhkar.isEmpty) return;
    _haptic(HapticFeedbackType.select);
    setState(() {
      _selectedIdx = (_selectedIdx! - 1 + _adhkar.length) % _adhkar.length;
      _count = 0;
      _completed = false;
    });
  }

  void _onTap() {
    if (_completed) {
      _haptic(HapticFeedbackType.medium);
      setState(() {
        _count = 1;
        _completed = false;
      });
      return;
    }
    _haptic(HapticFeedbackType.light);
    setState(() {
      _count++;
    });
    if (_count >= _target) {
      _haptic(HapticFeedbackType.heavy);
      Future.delayed(
        const Duration(milliseconds: 180),
        () => _haptic(HapticFeedbackType.heavy),
      );
      _sessions.add(
        _Session(dhikrText: _dhikr.text, count: _count, time: DateTime.now()),
      );
      setState(() {
        _completed = true;
        _todayTotal += _count;
      });
    }
  }

  void _reset() {
    _haptic(HapticFeedbackType.select);
    setState(() {
      _count = 0;
      _completed = false;
    });
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cfg = _Cfg(context);
    final primary = AppColors.getPrimary(context);

    // Loading state
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background(context),
        body: Center(child: CircularProgressIndicator(color: primary)),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      transitionBuilder: (child, anim) => SlideTransition(
        position: Tween<Offset>(
          begin: _selectedIdx != null
              ? const Offset(1, 0)
              : const Offset(-1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: _selectedIdx == null
          ? _SelectionScreen(
              key: const ValueKey('sel'),
              isDark: isDark,
              cfg: cfg,
              primary: primary,
              isAr: _isAr,
              adhkar: _adhkar,
              onSelect: _select,
              sessions: _sessions,
              todayTotal: _todayTotal,
            )
          : _CounterScreen(
              key: ValueKey('ctr_$_selectedIdx'),
              isDark: isDark,
              cfg: cfg,
              primary: primary,
              isAr: _isAr,
              dhikr: _dhikr,
              count: _count,
              completed: _completed,
              silentMode: _silent,
              sessions: _sessions,
              todayTotal: _todayTotal,
              onTap: _onTap,
              onReset: _reset,
              onBack: _goBack,
              onNext: _goNext,
              onPrev: _goPrev,
              onSilentToggle: () => setState(() => _silent = !_silent),
            ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SELECTION SCREEN
// ════════════════════════════════════════════════════════════════════════════
class _SelectionScreen extends StatefulWidget {
  final bool isDark, isAr;
  final _Cfg cfg;
  final Color primary;
  final List<TasbihModel> adhkar;
  final void Function(int) onSelect;
  final List<_Session> sessions;
  final int todayTotal;

  const _SelectionScreen({
    super.key,
    required this.isDark,
    required this.isAr,
    required this.cfg,
    required this.primary,
    required this.adhkar,
    required this.onSelect,
    required this.sessions,
    required this.todayTotal,
  });

  @override
  State<_SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<_SelectionScreen>
    with AutomaticKeepAliveClientMixin {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  String _filter = '';
  String? _activeCat;
  Timer? _debounce;

  @override
  bool get wantKeepAlive => true;

  late List<String> _cats = _buildCats();

  List<String> _buildCats() {
    final seen = <String>{};
    return widget.adhkar
        .map((d) => widget.isAr ? d.cat : d.catEn)
        .where(seen.add)
        .toList();
  }

  @override
  void didUpdateWidget(covariant _SelectionScreen old) {
    super.didUpdateWidget(old);
    if (old.adhkar != widget.adhkar || old.isAr != widget.isAr) {
      _cats = _buildCats();
    }
  }

  List<_CatGroup> _buildGroups() {
    final f = _filter;
    final map = <String, List<MapEntry<int, TasbihModel>>>{};

    for (final e in widget.adhkar.asMap().entries) {
      final d = e.value;
      if (f.isNotEmpty) {
        final match =
            d.text.contains(f) ||
            d.transliteration.toLowerCase().contains(f) ||
            d.cat.contains(f) ||
            d.catEn.toLowerCase().contains(f);
        if (!match) continue;
      }
      if (_activeCat != null && (widget.isAr ? d.cat : d.catEn) != _activeCat) {
        continue;
      }
      final cat = widget.isAr ? d.cat : d.catEn;
      map.putIfAbsent(cat, () => []).add(e);
    }
    return map.entries.map((e) => _CatGroup(e.key, e.value)).toList();
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      if (mounted) setState(() => _filter = v.toLowerCase());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cardBg = AppColors.cardBackground(context);
    final groups = _buildGroups();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(
                widget.cfg.hPad,
                20,
                widget.cfg.hPad,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.isAr ? 'اختر الذِكر' : 'Select Tasbih',
                              style: _TS.amiriBold(
                                widget.cfg.titleFont * 1.15,
                                widget.isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.isAr ? 'Choose your Tasbih' : 'اختر ذِكرك',
                              style: _TS.amiri(
                                widget.cfg.labelFont,
                                widget.primary.withValues(alpha: 0.65),
                                weight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.todayTotal > 0) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: widget.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: widget.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                color: widget.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${widget.todayTotal}',
                                style: TextStyle(
                                  color: widget.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: widget.cfg.labelFont + 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: widget.primary.withValues(alpha: 0.14),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.primary.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: TextField(
                        controller: _ctrl,
                        textDirection: TextDirection.rtl,
                        onChanged: _onSearch,
                        style: _TS.amiri(
                          widget.cfg.labelFont + 2,
                          widget.isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: cardBg,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: widget.isAr
                              ? 'ابحث... Search...'
                              : 'Search... ابحث...',
                          hintStyle: _TS.amiri(
                            widget.cfg.labelFont + 1,
                            widget.isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: widget.primary.withValues(alpha: 0.55),
                            size: 20,
                          ),
                          suffixIcon: _filter.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _ctrl.clear();
                                    setState(() => _filter = '');
                                  },
                                  child: Icon(
                                    Icons.clear_rounded,
                                    color: widget.primary,
                                    size: 18,
                                  ),
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category chips
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _cats.length + 1,
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          return _CategoryChip(
                            label: widget.isAr ? 'الكل' : 'All',
                            isSelected: _activeCat == null,
                            primary: widget.primary,
                            isDark: widget.isDark,
                            onTap: () => setState(() => _activeCat = null),
                          );
                        }
                        final cat = _cats[i - 1];
                        return _CategoryChip(
                          label: cat,
                          isSelected: _activeCat == cat,
                          primary: widget.primary,
                          isDark: widget.isDark,
                          onTap: () => setState(
                            () => _activeCat = _activeCat == cat ? null : cat,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // List
            Expanded(
              child: groups.isEmpty
                  ? Center(
                      child: Text(
                        widget.isAr ? 'لا توجد نتائج' : 'No results found',
                        style: _TS.amiri(
                          widget.cfg.labelFont + 2,
                          widget.isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    )
                  : _GroupedList(
                      groups: groups,
                      primary: widget.primary,
                      isDark: widget.isDark,
                      cfg: widget.cfg,
                      cardBg: cardBg,
                      isAr: widget.isAr,
                      scrollCtrl: _scroll,
                      onSelect: widget.onSelect,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Grouped list ─────────────────────────────────────────────────────────────
class _CatGroup {
  final String name;
  final List<MapEntry<int, TasbihModel>> entries;
  const _CatGroup(this.name, this.entries);
}

class _GroupedList extends StatelessWidget {
  final List<_CatGroup> groups;
  final Color primary, cardBg;
  final bool isDark, isAr;
  final _Cfg cfg;
  final ScrollController scrollCtrl;
  final void Function(int) onSelect;

  const _GroupedList({
    required this.groups,
    required this.primary,
    required this.isDark,
    required this.cfg,
    required this.cardBg,
    required this.isAr,
    required this.scrollCtrl,
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
    return ListView.builder(
      controller: scrollCtrl,
      padding: EdgeInsets.fromLTRB(cfg.hPad, 4, cfg.hPad, 36),
      itemCount: items.length + 1,
      itemBuilder: (_, i) {
        if (i == items.length) return const SizedBox(height: 20);
        final item = items[i];
        if (item is String) {
          final cnt = groups.firstWhere((g) => g.name == item).entries.length;
          return _CatHeader(
            name: item,
            count: cnt,
            primary: primary,
            labelFont: cfg.labelFont,
          );
        }
        final e = item as MapEntry<int, TasbihModel>;
        return RepaintBoundary(
          child: _DhikrSelectionCard(
            entry: e,
            primary: primary,
            isDark: isDark,
            cfg: cfg,
            cardBg: cardBg,
            isAr: isAr,
            onTap: () => onSelect(e.key),
          ),
        );
      },
    );
  }
}

// ─── Category header ──────────────────────────────────────────────────────────
class _CatHeader extends StatelessWidget {
  final String name;
  final int count;
  final Color primary;
  final double labelFont;
  const _CatHeader({
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
          child: Text(name, style: _TS.amiriBold(labelFont + 3, primary)),
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

// ─── Category chip ────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected, isDark;
  final Color primary;
  final VoidCallback onTap;
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.primary,
    required this.isDark,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? primary : primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? primary : primary.withValues(alpha: 0.15),
        ),
      ),
      child: Text(
        label,
        style: _TS.amiri(
          12,
          isSelected
              ? Colors.white
              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          weight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ),
  );
}

// ─── Dhikr selection card ─────────────────────────────────────────────────────
class _DhikrSelectionCard extends StatelessWidget {
  final MapEntry<int, TasbihModel> entry;
  final Color primary, cardBg;
  final bool isDark, isAr;
  final _Cfg cfg;
  final VoidCallback onTap;
  const _DhikrSelectionCard({
    required this.entry,
    required this.primary,
    required this.isDark,
    required this.cfg,
    required this.cardBg,
    required this.isAr,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final d = entry.value;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primary.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Count badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: 0.1),
                border: Border.all(color: primary.withValues(alpha: 0.2)),
              ),
              child: Center(
                child: Text(
                  '${d.count}',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: cfg.labelFont + 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    style: _TS.amiriQuran(
                      cfg.dhikrFont * 0.9,
                      isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    d.transliteration,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _TS.amiri(
                      cfg.labelFont,
                      isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: primary.withValues(alpha: 0.4),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// COUNTER SCREEN (Simple, clean, no heavy animations)
// ════════════════════════════════════════════════════════════════════════════
class _CounterScreen extends StatelessWidget {
  final bool isDark, isAr, completed, silentMode;
  final _Cfg cfg;
  final Color primary;
  final TasbihModel dhikr;
  final int count, todayTotal;
  final List<_Session> sessions;
  final VoidCallback onTap, onReset, onBack, onNext, onPrev, onSilentToggle;

  const _CounterScreen({
    super.key,
    required this.isDark,
    required this.isAr,
    required this.cfg,
    required this.primary,
    required this.dhikr,
    required this.count,
    required this.completed,
    required this.silentMode,
    required this.sessions,
    required this.todayTotal,
    required this.onTap,
    required this.onReset,
    required this.onBack,
    required this.onNext,
    required this.onPrev,
    required this.onSilentToggle,
  });

  int get _target => dhikr.count;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final subtextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final cardBg = isDark
        ? AppColors.backgroundCardDark
        : AppColors.backgroundCard;
    final iconColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Navigation Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                    color: iconColor,
                    style: IconButton.styleFrom(
                      backgroundColor: primary.withValues(alpha: 0.08),
                      shape: const CircleBorder(),
                    ),
                  ),
                  const Spacer(),
                  if (sessions.isNotEmpty)
                    IconButton(
                      onPressed: () => _sheet(
                        context,
                        _SessionLogSheet(
                          sessions: sessions,
                          isDark: isDark,
                          cfg: cfg,
                          primary: primary,
                          todayTotal: todayTotal,
                          isAr: isAr,
                        ),
                      ),
                      icon: const Icon(Icons.history_rounded, size: 20),
                      color: iconColor,
                      style: IconButton.styleFrom(
                        backgroundColor: primary.withValues(alpha: 0.08),
                        shape: const CircleBorder(),
                      ),
                    ),
                ],
              ),
            ),

            // ── Dhikr Card with Navigation Arrows ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primary.withValues(alpha: 0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _NavArrow(
                      icon: Icons.chevron_left_rounded,
                      onTap: isAr ? onNext : onPrev,
                      primary: primary,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        dhikr.text,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _TS.amiriQuran(
                          cfg.dhikrFont + 2,
                          textColor,
                          height: 1.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _NavArrow(
                      icon: Icons.chevron_right_rounded,
                      onTap: isAr ? onPrev : onNext,
                      primary: primary,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Stats Row ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      label: isAr ? 'عدد الحبات' : 'Total Beads',
                      value: '$_target',
                      primary: primary,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatBox(
                      label: isAr ? 'العدد الحالي' : 'Current',
                      value: '$count',
                      primary: primary,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),

            // ── Center Tap Button ──
            Expanded(
              child: Center(
                child: _TapButton(
                  onTap: onTap,
                  primary: primary,
                  count: count,
                  target: _target,
                  completed: completed,
                  isDark: isDark,
                ),
              ),
            ),

            // ── Subtitle / Source ──
            if (dhikr.sub.isNotEmpty || dhikr.subEn.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  isAr ? dhikr.sub : dhikr.subEn,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _TS.amiri(
                    cfg.labelFont,
                    subtextColor.withValues(alpha: 0.6),
                    style: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // ── Reset Button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(
                    isAr ? 'تصفير العدد' : 'Reset Count',
                    style: GoogleFonts.amiri(
                      fontSize: cfg.labelFont + 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sheet(BuildContext ctx, Widget w) => showModalBottomSheet(
    context: ctx,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => w,
  );
}

// ─── Navigation Arrow Button ──────────────────────────────────────────────────
class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color primary;
  final bool isDark;
  const _NavArrow({
    required this.icon,
    required this.onTap,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary.withValues(alpha: isDark ? 0.15 : 0.08),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, color: primary, size: 22),
    ),
  );
}

// ─── Stat Box ─────────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String label, value;
  final Color primary;
  final bool isDark;
  const _StatBox({
    required this.label,
    required this.value,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      color: isDark ? AppColors.backgroundCardDark : AppColors.backgroundCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: primary.withValues(alpha: 0.1)),
      boxShadow: [
        BoxShadow(
          color: primary.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          label,
          style: GoogleFonts.amiri(
            fontSize: 13,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.amiri(
            fontSize: 28,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

// ─── Tap Button (Center circle with touch icon) ──────────────────────────────
class _TapButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color primary;
  final int count, target;
  final bool completed, isDark;

  const _TapButton({
    required this.onTap,
    required this.primary,
    required this.count,
    required this.target,
    required this.completed,
    required this.isDark,
  });

  @override
  State<_TapButton> createState() => _TapButtonState();
}

class _TapButtonState extends State<_TapButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width * 0.52;
    final progress = widget.target > 0 ? widget.count / widget.target : 0.0;
    final coreBg = widget.isDark
        ? const Color(0xFF0F1E16)
        : const Color(0xFF143022);

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer soft glow
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.primary.withValues(
                        alpha: widget.isDark ? 0.12 : 0.08,
                      ),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),

              // Outer decorative ring
              Container(
                width: size * 0.95,
                height: size * 0.95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.primary.withValues(alpha: 0.18),
                    width: 1.5,
                  ),
                ),
              ),

              // Progress ring
              SizedBox(
                width: size * 0.86,
                height: size * 0.86,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  builder: (_, val, child) => CircularProgressIndicator(
                    value: val,
                    strokeWidth: 5,
                    backgroundColor: widget.primary.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.completed
                          ? const Color(0xFF4CAF50)
                          : widget.primary,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),

              // Decorative inner ring
              Container(
                width: size * 0.74,
                height: size * 0.74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.primary.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
              ),

              // Gradient mid-circle
              Container(
                width: size * 0.66,
                height: size * 0.66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.2),
                    radius: 0.9,
                    colors: [
                      widget.primary.withValues(alpha: 0.28),
                      widget.primary.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                  border: Border.all(
                    color: widget.primary.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
              ),

              // Core circle with icon
              Container(
                width: size * 0.48,
                height: size * 0.48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: coreBg,
                  border: Border.all(
                    color: widget.primary.withValues(alpha: 0.45),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.primary.withValues(alpha: 0.18),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: size * 0.16,
                      color: widget.completed
                          ? const Color(0xFF4CAF50)
                          : widget.primary,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.count}',
                      style: TextStyle(
                        fontSize: size * 0.08,
                        fontWeight: FontWeight.bold,
                        color: widget.completed
                            ? const Color(0xFF4CAF50)
                            : widget.primary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _Handle extends StatelessWidget {
  final Color primary;
  const _Handle({required this.primary});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 12, bottom: 4),
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: primary.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

// ─── Session Log Bottom Sheet ─────────────────────────────────────────────────
class _SessionLogSheet extends StatelessWidget {
  final List<_Session> sessions;
  final bool isDark, isAr;
  final _Cfg cfg;
  final Color primary;
  final int todayTotal;
  const _SessionLogSheet({
    required this.sessions,
    required this.isDark,
    required this.isAr,
    required this.cfg,
    required this.primary,
    required this.todayTotal,
  });
  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.7,
    ),
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
    decoration: BoxDecoration(
      color: isDark ? AppColors.backgroundCardDark : Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      border: Border.all(color: primary.withValues(alpha: 0.15)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Handle(primary: primary),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_rounded, color: primary, size: 20),
              const SizedBox(width: 8),
              Text(
                isAr ? 'سجل الجلسة' : 'Session Log',
                style: _TS.amiriBold(cfg.titleFont * 0.85, primary),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome_rounded, color: primary, size: 16),
              const SizedBox(width: 8),
              Text(
                isAr
                    ? 'المجموع: $todayTotal تسبيحة'
                    : 'Total: $todayTotal tasbih',
                style: _TS.amiriBold(cfg.labelFont + 2, primary),
              ),
            ],
          ),
        ),
        sessions.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  isAr
                      ? 'لا توجد جلسات بعد، ابدأ التسبيح!'
                      : 'No sessions yet, start your Tasbih!',
                  style: _TS.amiri(
                    cfg.labelFont + 1,
                    isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              )
            : Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sessions.length,
                  itemBuilder: (_, i) {
                    final s = sessions[sessions.length - 1 - i];
                    final t =
                        '${s.time.hour.toString().padLeft(2, '0')}:${s.time.minute.toString().padLeft(2, '0')}';
                    return Column(
                      children: [
                        if (i > 0)
                          Divider(
                            height: 1,
                            color: primary.withValues(alpha: 0.07),
                          ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primary.withValues(alpha: 0.1),
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: primary,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            s.dhikrText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.rtl,
                            style: _TS.amiriQuran(
                              cfg.labelFont + 1,
                              isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            '${s.count} ${isAr ? 'مرة' : 'times'}',
                            style: _TS.amiri(cfg.labelFont, primary),
                          ),
                          trailing: Text(
                            t,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ],
    ),
  );
}

enum HapticFeedbackType { light, medium, heavy, select }
