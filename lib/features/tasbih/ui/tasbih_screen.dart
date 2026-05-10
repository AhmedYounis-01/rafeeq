import 'dart:async';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:rafeeq/features/tasbih/data/model/tasbih_model.dart';
import 'package:rafeeq/features/tasbih/logic/tasbih_cubit.dart';
import 'package:rafeeq/features/tasbih/logic/tasbih_state.dart';

// ════════════════════════════════════════════════════════════════════════════
// CACHED TEXT STYLES
// ════════════════════════════════════════════════════════════════════════════
abstract final class _TS {
  static TextStyle amiriBold(double size, Color color) => TextStyle(
    fontFamily: 'Tajawal',
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
  }) => TextStyle(
    fontFamily: 'Tajawal',
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
  }) => TextStyle(
    fontFamily: 'Tajawal',
    fontSize: size,
    color: color,
    height: height,
  );
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
class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TasbihCubit(),
      child: const _TasbihConsumer(),
    );
  }
}

class _TasbihConsumer extends StatefulWidget {
  const _TasbihConsumer();

  @override
  State<_TasbihConsumer> createState() => _TasbihConsumerState();
}

class _TasbihConsumerState extends State<_TasbihConsumer> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = context.locale.languageCode;
    context.read<TasbihCubit>().loadData(lang);
  }

  @override
  Widget build(BuildContext context) {
    final langCode = context.locale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cfg = _Cfg(context);
    final primary = AppColors.getPrimary(context);
    final isRtl = langCode == 'ar';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final state = context.read<TasbihCubit>().state;
        if (state.selectedIdx != null) {
          context.read<TasbihCubit>().selectDhikr(null);
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: BlocBuilder<TasbihCubit, TasbihState>(
          builder: (context, state) {
            if (state.loading) {
              return Center(child: CircularProgressIndicator(color: primary));
            }

            final cubit = context.read<TasbihCubit>();

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              transitionBuilder: (child, anim) => SlideTransition(
                position:
                    Tween<Offset>(
                      begin: state.selectedIdx != null
                          ? const Offset(1, 0)
                          : const Offset(-1, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                    ),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: state.selectedIdx == null
                  ? _SelectionScreen(
                      key: const ValueKey('selection'),
                      isDark: isDark,
                      isRtl: isRtl,
                      cfg: cfg,
                      primary: primary,
                      adhkar: state.adhkar,
                      searchQuery: state.searchQuery,
                      activeCat: state.activeCat,
                      onSearch: cubit.updateSearch,
                      onCategorySelect: cubit.updateCategory,
                      onSelect: cubit.selectDhikr,
                      sessions: state.sessions,
                      todayTotal: state.todayTotal,
                    )
                  : _CounterScreen(
                      key: const ValueKey('counter'),
                      isDark: isDark,
                      isRtl: isRtl,
                      cfg: cfg,
                      primary: primary,
                      dhikr: state.currentDhikr!,
                      count: state.count,
                      completed: state.completed,
                      silentMode: state.silent,
                      sessions: state.sessions,
                      todayTotal: state.todayTotal,
                      onTap: cubit.incrementCount,
                      onReset: cubit.resetCount,
                      onBack: () => cubit.selectDhikr(null),
                      onNext: cubit.goNext,
                      onPrev: cubit.goPrev,
                      onSilentToggle: cubit.toggleSilent,
                    ),
            );
          },
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SELECTION SCREEN
// ════════════════════════════════════════════════════════════════════════════
class _SelectionScreen extends StatefulWidget {
  final bool isDark, isRtl;
  final _Cfg cfg;
  final Color primary;
  final List<TasbihModel> adhkar;
  final void Function(int) onSelect;
  final List<TasbihSession> sessions;
  final int todayTotal;
  final String searchQuery;
  final String? activeCat;
  final void Function(String) onSearch;
  final void Function(String?) onCategorySelect;

  const _SelectionScreen({
    super.key,
    required this.isDark,
    required this.isRtl,
    required this.cfg,
    required this.primary,
    required this.adhkar,
    required this.onSelect,
    required this.sessions,
    required this.todayTotal,
    required this.searchQuery,
    required this.activeCat,
    required this.onSearch,
    required this.onCategorySelect,
  });

  @override
  State<_SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<_SelectionScreen>
    with AutomaticKeepAliveClientMixin {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _ctrl.text = widget.searchQuery;
  }

  late List<String> _cats = _buildCats();

  List<String> _buildCats() {
    final seen = <String>{};
    return widget.adhkar.map((d) => d.cat).where(seen.add).toList();
  }

  @override
  void didUpdateWidget(covariant _SelectionScreen old) {
    super.didUpdateWidget(old);
    if (old.adhkar != widget.adhkar) {
      _cats = _buildCats();
    }
  }

  List<_CatGroup> _buildGroups() {
    final map = <String, List<MapEntry<int, TasbihModel>>>{};
    final filterNorm = TasbihCubit.normalizeArabic(widget.searchQuery);

    for (final e in widget.adhkar.asMap().entries) {
      final d = e.value;
      if (filterNorm.isNotEmpty) {
        final match =
            TasbihCubit.normalizeArabic(d.text).contains(filterNorm) ||
            d.transliteration.toLowerCase().contains(filterNorm) ||
            TasbihCubit.normalizeArabic(d.cat).contains(filterNorm) ||
            TasbihCubit.normalizeArabic(d.meaning).contains(filterNorm);
        if (!match) continue;
      }
      if (widget.activeCat != null && d.cat != widget.activeCat) continue;
      map.putIfAbsent(d.cat, () => []).add(e);
    }
    return map.entries.map((e) => _CatGroup(e.key, e.value)).toList();
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      if (mounted) {
        widget.onSearch(v);
      }
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
      body: CustomScrollView(
        controller: _scroll,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header (SliverAppBar) ──
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: AppColors.background(context),
            toolbarHeight: 90,
            titleSpacing: 0,
            leading: const SizedBox.shrink(),
            title: Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.cfg.hPad),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'tasbih.selectTitle'.tr(),
                          style: _TS.amiriBold(
                            widget.cfg.titleFont * 1.15,
                            widget.isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'tasbih.selectSubtitle'.tr(),
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
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => showModalBottomSheet(
                          context: context,
                          useRootNavigator: true,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (_) => _SessionLogSheet(
                            sessions: widget.sessions,
                            isDark: widget.isDark,
                            cfg: widget.cfg,
                            primary: widget.primary,
                            todayTotal: widget.todayTotal,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
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
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Search & Categories ──
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.cfg.hPad),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 12),
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
                        textDirection: widget.isRtl
                            ? TextDirection.rtl
                            : TextDirection.ltr,
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
                          hintText: 'tasbih.search'.tr(),
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
                          suffixIcon: widget.searchQuery.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _ctrl.clear();
                                    widget.onSearch('');
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
                        onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      ),
                    ),
                  ),

                  // Category chips
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _cats.length + 1,
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          return _CategoryChip(
                            label: 'tasbih.all'.tr(),
                            isSelected: widget.activeCat == null,
                            primary: widget.primary,
                            isDark: widget.isDark,
                            onTap: () => widget.onCategorySelect(null),
                          );
                        }
                        final cat = _cats[i - 1];
                        return _CategoryChip(
                          label: cat,
                          isSelected: widget.activeCat == cat,
                          primary: widget.primary,
                          isDark: widget.isDark,
                          onTap: () => widget.onCategorySelect(
                            widget.activeCat == cat ? null : cat,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // ── List of Adhkar ──
          if (groups.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'tasbih.noResults'.tr(),
                  style: _TS.amiri(
                    widget.cfg.labelFont + 2,
                    widget.isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            _SliverGroupedList(
              groups: groups,
              primary: widget.primary,
              isDark: widget.isDark,
              cfg: widget.cfg,
              cardBg: cardBg,
              isRtl: widget.isRtl,
              onSelect: widget.onSelect,
            ),

          SliverToBoxAdapter(child: SizedBox(height: 110.h)),
        ],
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

class _SliverGroupedList extends StatelessWidget {
  final List<_CatGroup> groups;
  final Color primary, cardBg;
  final bool isDark, isRtl;
  final _Cfg cfg;
  final void Function(int) onSelect;

  const _SliverGroupedList({
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
            return _CatHeader(
              name: item,
              count: cnt,
              primary: primary,
              labelFont: cfg.labelFont,
            );
          }
          final e = item as MapEntry<int, TasbihModel>;
          return _DhikrSelectionCard(
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? primary : primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? primary : primary.withValues(alpha: 0.15),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: _TS.amiri(
          12.5,
          isSelected
              ? Colors.white
              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          weight: isSelected ? FontWeight.bold : FontWeight.w500,
          height: 1.1,
        ),
      ),
    ),
  );
}

// ─── Dhikr selection card ─────────────────────────────────────────────────────
class _DhikrSelectionCard extends StatelessWidget {
  final MapEntry<int, TasbihModel> entry;
  final Color primary, cardBg;
  final bool isDark, isRtl;
  final _Cfg cfg;
  final VoidCallback onTap;
  const _DhikrSelectionCard({
    required this.entry,
    required this.primary,
    required this.isDark,
    required this.isRtl,
    required this.cfg,
    required this.cardBg,
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
                    isRtl ? d.text : d.transliteration,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: isRtl
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    style: isRtl
                        ? _TS.amiriQuran(
                            cfg.dhikrFont * 0.9,
                            isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                            height: 1.6,
                          )
                        : _TS.amiri(
                            cfg.labelFont + 2,
                            isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                            weight: FontWeight.bold,
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
// COUNTER SCREEN
// ════════════════════════════════════════════════════════════════════════════
class _CounterScreen extends StatelessWidget {
  final bool isDark, isRtl, completed, silentMode;
  final _Cfg cfg;
  final Color primary;
  final TasbihModel dhikr;
  final int count, todayTotal;
  final List<TasbihSession> sessions;
  final VoidCallback onTap, onReset, onBack, onNext, onPrev, onSilentToggle;

  const _CounterScreen({
    super.key,
    required this.isDark,
    required this.isRtl,
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
    final iconColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Sliver AppBar for Navigation ──
          SliverAppBar(
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: AppColors.background(context),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                color: iconColor,
                style: IconButton.styleFrom(
                  backgroundColor: primary.withValues(alpha: 0.08),
                  shape: const CircleBorder(),
                ),
              ),
            ),
            actions: [
              if (sessions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () => _sheet(
                      context,
                      _SessionLogSheet(
                        sessions: sessions,
                        isDark: isDark,
                        cfg: cfg,
                        primary: primary,
                        todayTotal: todayTotal,
                      ),
                    ),
                    icon: const Icon(Icons.history_rounded, size: 20),
                    color: iconColor,
                    style: IconButton.styleFrom(
                      backgroundColor: primary.withValues(alpha: 0.08),
                      shape: const CircleBorder(),
                    ),
                  ),
                ),
            ],
          ),

          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: cfg.isTablet ? 600 : double.infinity,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Dhikr Card
                      _CounterDhikrCard(
                        dhikr: dhikr,
                        isRtl: isRtl,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        primary: primary,
                        isDark: isDark,
                        cfg: cfg,
                        onNext: onNext,
                        onPrev: onPrev,
                      ),

                      const SizedBox(height: 24),

                      // Stats Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatBox(
                                label: 'tasbih.totalBeads'.tr(),
                                value: '$_target',
                                primary: primary,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _StatBox(
                                label: 'tasbih.current'.tr(),
                                value: '$count',
                                primary: primary,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tap Button
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

                      // Subtitle
                      if (dhikr.sub.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          child: Text(
                            dhikr.sub,
                            textAlign: TextAlign.center,
                            maxLines: 8,
                            style: _TS.amiri(
                              cfg.labelFont,
                              subtextColor.withValues(alpha: 0.6),
                              style: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                        ),

                      // Reset Button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: onReset,
                            icon: const Icon(Icons.refresh_rounded, size: 20),
                            label: Text(
                              'tasbih.reset'.tr(),
                              style: _TS.amiriBold(
                                cfg.labelFont + 3,
                                Colors.white,
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

                      // Bottom Padding for Nav Bar
                      SizedBox(height: 110.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sheet(BuildContext ctx, Widget w) => showModalBottomSheet(
    context: ctx,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => w,
  );
}

class _CounterDhikrCard extends StatelessWidget {
  final TasbihModel dhikr;
  final bool isRtl, isDark;
  final Color textColor, subtextColor, primary;
  final _Cfg cfg;
  final VoidCallback onNext, onPrev;

  const _CounterDhikrCard({
    required this.dhikr,
    required this.isRtl,
    required this.isDark,
    required this.textColor,
    required this.subtextColor,
    required this.primary,
    required this.cfg,
    required this.onNext,
    required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark
        ? AppColors.backgroundCardDark
        : AppColors.backgroundCard;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
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
            onTap: isRtl ? onNext : onPrev,
            primary: primary,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isRtl)
                  Text(
                    dhikr.text,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: _TS.amiriQuran(
                      cfg.dhikrFont + 2,
                      textColor,
                      height: 1.8,
                    ),
                  )
                else
                  Text(
                    dhikr.transliteration,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: _TS.amiri(
                      cfg.dhikrFont + 1,
                      textColor,
                      weight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _NavArrow(
            icon: Icons.chevron_right_rounded,
            onTap: isRtl ? onPrev : onNext,
            primary: primary,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

// ─── Navigation Arrow ─────────────────────────────────────────────────────────
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
          style: _TS.amiri(
            13,
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            weight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: _TS.amiriBold(
            28,
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );
}

// ─── Tap Button ───────────────────────────────────────────────────────────────
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
              SizedBox(
                width: size * 0.86,
                height: size * 0.86,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  builder: (_, val, _) => CircularProgressIndicator(
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

// ─── Shared ───────────────────────────────────────────────────────────────────
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

// ─── Session Log Sheet ────────────────────────────────────────────────────────
class _SessionLogSheet extends StatelessWidget {
  final List<TasbihSession> sessions;
  final bool isDark;
  final _Cfg cfg;
  final Color primary;
  final int todayTotal;

  const _SessionLogSheet({
    required this.sessions,
    required this.isDark,
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
                'tasbih.sessionLog'.tr(),
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
                'tasbih.totalCount'.tr(namedArgs: {'total': '$todayTotal'}),
                style: _TS.amiriBold(cfg.labelFont + 2, primary),
              ),
            ],
          ),
        ),
        sessions.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'tasbih.noSessions'.tr(),
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
                            textDirection: TextDirection.rtl,
                            style: _TS.amiriQuran(
                              cfg.labelFont + 1,
                              isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            tr(
                              'tasbih.times',
                              namedArgs: {'count': '${s.count}'},
                            ),
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
