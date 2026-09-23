import 'dart:async';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:rafeeq/features/tasbih/data/model/tasbih_model.dart';
import 'package:rafeeq/features/tasbih/logic/tasbih_cubit.dart';
import 'package:rafeeq/features/tasbih/logic/tasbih_state.dart';
import 'tasbih_config.dart';
import 'category_chip.dart';
import 'sliver_grouped_list.dart';
import 'session_log_sheet.dart';

class SelectionScreen extends StatefulWidget {
  final bool isDark, isRtl;
  final TasbihConfig cfg;
  final Color primary;
  final List<TasbihModel> adhkar;
  final void Function(int) onSelect;
  final List<TasbihSession> sessions;
  final int todayTotal;
  final String searchQuery;
  final String? activeCat;
  final void Function(String) onSearch;
  final void Function(String?) onCategorySelect;

  const SelectionScreen({
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
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen>
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
  void didUpdateWidget(covariant SelectionScreen old) {
    super.didUpdateWidget(old);
    if (old.adhkar != widget.adhkar) {
      _cats = _buildCats();
    }
  }

  List<CatGroup> _buildGroups() {
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
    return map.entries.map((e) => CatGroup(e.key, e.value)).toList();
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
                          style: TasbihTextStyles.amiriBold(
                            widget.cfg.titleFont * 1.15,
                            widget.isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'tasbih.selectSubtitle'.tr(),
                          style: TasbihTextStyles.amiri(
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
                          builder: (_) => SessionLogSheet(
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
                        style: TasbihTextStyles.amiri(
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
                          hintStyle: TasbihTextStyles.amiri(
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
                          return CategoryChip(
                            label: 'tasbih.all'.tr(),
                            isSelected: widget.activeCat == null,
                            primary: widget.primary,
                            isDark: widget.isDark,
                            onTap: () => widget.onCategorySelect(null),
                          );
                        }
                        final cat = _cats[i - 1];
                        return CategoryChip(
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
                  style: TasbihTextStyles.amiri(
                    widget.cfg.labelFont + 2,
                    widget.isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            SliverGroupedList(
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
