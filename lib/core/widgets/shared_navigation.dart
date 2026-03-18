// ═══════════════════════════════════════════════════════════════════════════
// FILE: core/widgets/shared_navigation.dart
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:go_router/go_router.dart';
import '../routing/app_router.dart';
import '../themes/app_colors.dart';
import '../extensions/theme_extension.dart';
import '../constants/app_constants.dart';
import 'responsive_layout.dart';
import 'custom_drawer.dart';

// ─── Controller Provider ──────────────────────────────────────────────────────
// نمرر الـ controller عبر InheritedWidget عشان CustomAppBar يوصله بدون prop drilling
class AdvancedDrawerControllerProvider extends InheritedWidget {
  final AdvancedDrawerController drawerController;

  const AdvancedDrawerControllerProvider({
    super.key,
    required this.drawerController,
    required super.child,
  });

  static AdvancedDrawerController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AdvancedDrawerControllerProvider>()
        ?.drawerController;
  }

  @override
  bool updateShouldNotify(AdvancedDrawerControllerProvider old) =>
      drawerController != old.drawerController;
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
// StatefulWidget عشان نحتفظ بـ AdvancedDrawerController
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
  // controller واحد للـ drawer — يتشارك مع CustomAppBar عبر Provider
  final _drawerController = AdvancedDrawerController();

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ يسجل dependency على locale عشان يعمل rebuild فوراً عند تغيير اللغة
    final _ = context.locale;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return ResponsiveBuilder(
      builder: (context, deviceType) {
        switch (deviceType) {
          case AppDeviceType.desktop:
            return _buildDesktopLayout(context);
          case AppDeviceType.tablet:
            return _buildTabletLayout(context);
          case AppDeviceType.mobile:
            return _buildMobileLayout(context, isRtl);
        }
      },
    );
  }

  // ─── Desktop: wide sidebar ──────────────────────────────────────────────────
  Widget _buildDesktopLayout(BuildContext context) {
    final cfg = _NavCfg(context);
    return AdvancedDrawerControllerProvider(
      drawerController: _drawerController,
      child: Scaffold(
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
      ),
    );
  }

  // ─── Tablet: collapsed sidebar ──────────────────────────────────────────────
  Widget _buildTabletLayout(BuildContext context) {
    final cfg = _NavCfg(context);
    return AdvancedDrawerControllerProvider(
      drawerController: _drawerController,
      child: Scaffold(
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
      ),
    );
  }

  // ─── Mobile: AdvancedDrawer + bottom nav ────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context, bool isRtl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cfg = _NavCfg(context);

    return AdvancedDrawerControllerProvider(
      drawerController: _drawerController,
      child: AdvancedDrawer(
        controller: _drawerController,

        // ✅ RTL: الدرور يفتح من اليمين
        rtlOpening: isRtl,

        // ─── تأثيرات بصرية ──────────────────────────────────────────────
        animationCurve: Curves.easeInOutCubic,
        animationDuration: const Duration(milliseconds: 340),
        animateChildDecoration: true,
        openScale: 0.92, // كان 0.88 — كلما قرب من 1.0 كلما قل ظهور الخلفية
        openRatio: 0.68, // كان 0.72
        disabledGestures: false,

        // ─── الخلفية خلف الدرور ─────────────────────────────────────────
        backdrop: Container(color: Theme.of(context).scaffoldBackgroundColor),

        // ─── تأثير على الـ child عند الفتح ──────────────────────────────
        childDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        // ─── محتوى الدرور ───────────────────────────────────────────────
        drawer: const CustomDrawer(),

        // ✅ الحل — استخدم اللون الحقيقي للشاشة
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: widget.child,
          bottomNavigationBar: _buildBottomNavigation(context, cfg),
        ),
      ),
    );
  }

  // ─── Side Navigation (desktop/tablet) ───────────────────────────────────────
  Widget _buildSideNavigation(
    BuildContext context,
    _NavCfg cfg, {
    required bool isExpanded,
  }) {
    return Column(
      children: [
        // ── Header ──
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

        // ── Nav Items ──
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: _getNavigationItems().asMap().entries.map((entry) {
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

  // ─── Bottom Navigation ───────────────────────────────────────────────────────
  Widget _buildBottomNavigation(BuildContext context, _NavCfg cfg) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          top: BorderSide(color: context.colorScheme.outlineVariant, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: cfg.bottomNavH,
          // ✅ Row يعكس ترتيب العناصر تلقائياً مع Directionality
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _getNavigationItems().asMap().entries.map((entry) {
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
    );
  }

  List<NavigationItemData> _getNavigationItems() => [
    NavigationItemData(
      icon: Icons.home_rounded,
      iconOutlined: Icons.home_outlined,
      label: 'nav.home',
      route: AppRouter.home,
    ),
    NavigationItemData(
      icon: Icons.menu_book_rounded,
      iconOutlined: Icons.menu_book_outlined,
      label: 'nav.quran',
      route: AppRouter.quran,
    ),
    NavigationItemData(
      icon: Icons.explore_rounded,
      iconOutlined: Icons.explore_outlined,
      label: 'nav.qibla',
      route: AppRouter.qibla,
    ),
    NavigationItemData(
      icon: Icons.auto_awesome_rounded,
      iconOutlined: Icons.auto_awesome_outlined,
      label: 'nav.tasbih',
      route: AppRouter.tasbih,
    ),
  ];

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
                  Icon(
                    isSelected ? item.icon : item.iconOutlined,
                    size: cfg.iconSize,
                    color: color,
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
          borderRadius: BorderRadius.circular(cfg.radius),
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 14.0 : 4.0,
                    vertical: 3.0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.navSelected.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isSelected ? item.icon : item.iconOutlined,
                    size: cfg.iconSize,
                    color: isSelected
                        ? AppColors.navSelected
                        : AppColors.navUnselected.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.label.tr(),
                  style: TextStyle(
                    fontSize: cfg.labelFont,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.normal,
                    color: isSelected
                        ? AppColors.navSelected
                        : AppColors.navUnselected,
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
  final IconData icon;
  final IconData iconOutlined;
  final String label;
  final String route;

  const NavigationItemData({
    required this.icon,
    required this.iconOutlined,
    required this.label,
    required this.route,
  });
}
