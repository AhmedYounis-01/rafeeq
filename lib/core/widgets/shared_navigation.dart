// ═══════════════════════════════════════════════════════════════════════════
// FILE: core/widgets/shared_navigation.dart
// ═══════════════════════════════════════════════════════════════════════════
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rafeeq/core/gen/assets.gen.dart';
import '../routing/app_router.dart';
import '../themes/app_colors.dart';
import '../extensions/theme_extension.dart';
import '../constants/app_constants.dart';
import 'responsive_layout.dart';

// ─── Bottom Nav Visibility ────────────────────────────────────────────────────
class BottomNavVisibility extends InheritedWidget {
  final ValueNotifier<bool> _notifier;

  const BottomNavVisibility({
    super.key,
    required ValueNotifier<bool> notifier,
    required super.child,
  }) : _notifier = notifier;

  static ValueNotifier<bool>? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<BottomNavVisibility>()
        ?._notifier;
  }

  /// Hide the bottom nav bar
  static void hide(BuildContext context) {
    of(context)?.value = false;
  }

  /// Show the bottom nav bar
  static void show(BuildContext context) {
    of(context)?.value = true;
  }

  /// Toggle the bottom nav bar visibility
  static void toggle(BuildContext context) {
    final n = of(context);
    if (n != null) n.value = !n.value;
  }

  @override
  bool updateShouldNotify(BottomNavVisibility old) =>
      _notifier != old._notifier;
}

// ─── Responsive Config ────────────────────────────────────────────────────────
class _NavCfg {
  final double side;
  _NavCfg(BuildContext ctx) : side = MediaQuery.of(ctx).size.shortestSide;

  bool get isTablet => side >= 600;
  bool get isDesktop => side >= 900;

  double get sidebarW => (side * 0.32).clamp(220.0, 300.0);
  double get collapsedW => (side * 0.11).clamp(64.0, 88.0);
  double get bottomNavH => (side * 0.155).clamp(54.0, 68.0);
  double get iconSize => (side * 0.058).clamp(20.0, 28.0);
  double get labelFont => (side * 0.033).clamp(11.0, 15.0);
  double get headerH => (side * 0.18).clamp(64.0, 90.0);
  double get itemVPad => (side * 0.026).clamp(10.0, 16.0);
  double get radius => isTablet ? 12.0 : 10.0;
}

// ─── SharedNavigation ─────────────────────────────────────────────────────────
class SharedNavigation extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const SharedNavigation({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<SharedNavigation> createState() => _SharedNavigationState();
}

class _SharedNavigationState extends State<SharedNavigation> {
  late final ValueNotifier<bool> _bottomNavVisible;

  @override
  void initState() {
    super.initState();
    // In Quran tab (index 1), bottom nav starts hidden for immersive reading
    _bottomNavVisible = ValueNotifier(widget.currentIndex != 1);
  }

  @override
  void didUpdateWidget(SharedNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      if (widget.currentIndex == 1) {
        // Entering Quran tab -> hide bottom nav bar
        _bottomNavVisible.value = false;
      } else {
        // Leaving Quran tab -> show bottom nav bar
        _bottomNavVisible.value = true;
      }
    }
  }

  @override
  void dispose() {
    _bottomNavVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        switch (deviceType) {
          case AppDeviceType.desktop:
            return _buildDesktopLayout(context);
          case AppDeviceType.tablet:
            return _buildTabletLayout(context);
          case AppDeviceType.mobile:
            return _buildMobileLayout(context);
        }
      },
    );
  }

  // ─── Desktop ────────────────────────────────────────────────────────────────
  Widget _buildDesktopLayout(BuildContext context) {
    final cfg = _NavCfg(context);
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: cfg.sidebarW,
            decoration: BoxDecoration(
              color: AppColors.navBackground,
              border: Border(
                right: BorderSide(
                  color: context.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: _buildSideNavigation(context, cfg, isExpanded: true),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  // ─── Tablet ─────────────────────────────────────────────────────────────────
  Widget _buildTabletLayout(BuildContext context) {
    final cfg = _NavCfg(context);
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: cfg.collapsedW,
            decoration: BoxDecoration(
              color: AppColors.navBackground,
              border: Border(
                right: BorderSide(
                  color: context.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: _buildSideNavigation(context, cfg, isExpanded: false),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  // ─── Mobile ──────────────────────────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context) {
    final cfg = _NavCfg(context);

    return BottomNavVisibility(
      notifier: _bottomNavVisible,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            widget.child,
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<bool>(
                valueListenable: _bottomNavVisible,
                builder: (_, isVisible, child) {
                  return IgnorePointer(
                    ignoring: !isVisible,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOutCubic,
                      offset: isVisible ? Offset.zero : const Offset(0, 1.2),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeInOut,
                        opacity: isVisible ? 1.0 : 0.0,
                        child: child,
                      ),
                    ),
                  );
                },
                child: _buildBottomNavigation(context, cfg),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Side Navigation ────────────────────────────────────────────────────────
  Widget _buildSideNavigation(
    BuildContext context,
    _NavCfg cfg, {
    required bool isExpanded,
  }) {
    return Column(
      children: [
        Container(
          height: cfg.headerH,
          padding: EdgeInsets.symmetric(horizontal: isExpanded ? 16.0 : 8.0),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Container(
                width: cfg.iconSize + 16,
                height: cfg.iconSize + 16,
                decoration: BoxDecoration(
                  color: context.colorScheme.primary,
                  borderRadius: BorderRadius.circular(cfg.radius),
                ),
                child: Icon(
                  Icons.auto_awesome_mosaic_rounded,
                  color: context.colorScheme.onPrimary,
                  size: cfg.iconSize,
                ),
              ),
              if (isExpanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: cfg.labelFont + 4,
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
        Divider(height: 1, color: context.colorScheme.outlineVariant),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: NavigationItemData.items.asMap().entries.map((entry) {
              final item = entry.value;
              final isSelected = entry.key == widget.currentIndex;
              return _NavItem(
                item: item,
                isSelected: isSelected,
                isExpanded: isExpanded,
                cfg: cfg,
                onTap: () => _onNavigationTap(context, item.route),
              );
            }).toList(),
          ),
        ),
        if (isExpanded) _UserProfile(cfg: cfg),
      ],
    );
  }

  // ─── Bottom Navigation ──────────────────────────────────────────────────────
  Widget _buildBottomNavigation(BuildContext context, _NavCfg cfg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fadeColor = Theme.of(context).scaffoldBackgroundColor;

    return Stack(
      children: [
        // gradient الشفاف
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    fadeColor.withValues(alpha: 0.0),
                    fadeColor.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
        ),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: cfg.bottomNavH + 10,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.35)
                        : Colors.white.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.6),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.3 : 0.08,
                        ),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: NavigationItemData.items.asMap().entries.map((
                        entry,
                      ) {
                        final item = entry.value;
                        final isSelected = entry.key == widget.currentIndex;
                        return _BottomNavItem(
                          item: item,
                          isSelected: isSelected,
                          cfg: cfg,
                          onTap: () => _onNavigationTap(context, item.route),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onNavigationTap(BuildContext context, String route) {
    if (GoRouterState.of(context).uri.toString() != route) {
      context.go(route);
    }
  }
}

// ─── Nav Item (sidebar) ───────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final NavigationItemData item;
  final bool isSelected, isExpanded;
  final _NavCfg cfg;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.isExpanded,
    required this.cfg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.navSelected : AppColors.navUnselected;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isExpanded ? 8.0 : 4.0,
        vertical: 2.0,
      ),
      child: Tooltip(
        message: isExpanded ? '' : item.label.tr(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(cfg.radius),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isExpanded ? 14.0 : 0,
                vertical: cfg.itemVPad,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.navSelected.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(cfg.radius),
                border: isSelected
                    ? Border.all(
                        color: AppColors.navSelected.withValues(alpha: 0.22),
                      )
                    : null,
              ),
              child: Row(
                mainAxisAlignment: isExpanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    isSelected ? item.icon : item.iconOutlined,
                    width: cfg.iconSize,
                    height: cfg.iconSize,
                    colorFilter: ColorFilter.mode(
                      isSelected
                          ? AppColors.navSelected
                          : AppColors.navUnselected.withValues(alpha: 0.7),
                      BlendMode.srcIn,
                    ),
                  ),
                  if (isExpanded) ...[
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item.label.tr(),
                        style: TextStyle(
                          fontSize: cfg.labelFont + 1,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.navSelected,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Nav Item ──────────────────────────────────────────────────────────
class _BottomNavItem extends StatelessWidget {
  final NavigationItemData item;
  final bool isSelected;
  final _NavCfg cfg;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.item,
    required this.isSelected,
    required this.cfg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: isSelected ? 1.05 : 1.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colorScheme.primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SvgPicture.asset(
                    isSelected ? item.icon : item.iconOutlined,
                    width: cfg.iconSize,
                    height: cfg.iconSize,
                    colorFilter: ColorFilter.mode(
                      isSelected
                          ? context.theme.colorScheme.primary
                          : context.theme.colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.label.tr(),
                  style: TextStyle(
                    fontSize: cfg.labelFont - 1,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? context.theme.colorScheme.primary
                        : context.theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── User Profile ─────────────────────────────────────────────────────────────
class _UserProfile extends StatelessWidget {
  final _NavCfg cfg;
  const _UserProfile({required this.cfg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.3,
        ),
        borderRadius: BorderRadius.circular(cfg.radius + 2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: cfg.iconSize * 0.7,
            backgroundColor: context.colorScheme.primary,
            child: Text(
              'M',
              style: TextStyle(
                color: context.colorScheme.onPrimary,
                fontSize: cfg.labelFont + 1,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mahmoud',
                  style: TextStyle(
                    fontSize: cfg.labelFont + 1,
                    fontWeight: FontWeight.w700,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: cfg.labelFont,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.logout_rounded,
            size: cfg.iconSize * 0.75,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────
class NavigationItemData {
  final String icon;
  final String iconOutlined;
  final String label;
  final String route;

  const NavigationItemData({
    required this.icon,
    required this.iconOutlined,
    required this.label,
    required this.route,
  });

  static List<NavigationItemData> get items => [
    NavigationItemData(
      icon: Assets.images.mosque.path,
      iconOutlined: Assets.images.mosqueOutline.path,
      label: 'nav.home',
      route: AppRouter.home,
    ),
    NavigationItemData(
      icon: Assets.images.quran.path,
      iconOutlined: Assets.images.quranOutline.path,
      label: 'nav.quran',
      route: AppRouter.quran,
    ),
    NavigationItemData(
      icon: Assets.images.qibla.path,
      iconOutlined: Assets.images.qiblaOutline.path,
      label: 'nav.qibla',
      route: AppRouter.qibla,
    ),
    NavigationItemData(
      icon: Assets.images.tasbih.path,
      iconOutlined: Assets.images.tasbihOutline.path,
      label: 'nav.tasbih',
      route: AppRouter.tasbih,
    ),
  ];
}
