// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:go_router/go_router.dart';
// import '../routing/app_router.dart';
// import '../themes/app_colors.dart';
// import '../extensions/theme_extension.dart';
// import '../constants/app_constants.dart';
// import 'responsive_layout.dart';
// import 'custom_drawer.dart';

// class SharedNavigation extends StatelessWidget {
//   final Widget child;
//   final int currentIndex;

//   const SharedNavigation({
//     super.key,
//     required this.child,
//     required this.currentIndex,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ResponsiveBuilder(
//       builder: (context, deviceType) {
//         switch (deviceType) {
//           case AppDeviceType.desktop:
//             return _buildDesktopLayout(context);
//           case AppDeviceType.tablet:
//             return _buildTabletLayout(context);
//           case AppDeviceType.mobile:
//             return _buildMobileLayout(context);
//         }
//       },
//     );
//   }

//   Widget _buildDesktopLayout(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           // Side Navigation
//           Container(
//             width: 280.w,
//             decoration: BoxDecoration(
//               color: AppColors.navBackground,
//               border: Border(
//                 right: BorderSide(
//                   color: context.colorScheme.outlineVariant,
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: _buildSideNavigation(context, isExpanded: true),
//           ),
//           // Main Content
//           Expanded(child: child),
//         ],
//       ),
//     );
//   }

//   Widget _buildTabletLayout(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           // Collapsed Side Navigation
//           Container(
//             width: 80.w,
//             decoration: BoxDecoration(
//               color: AppColors.navBackground,
//               border: Border(
//                 right: BorderSide(
//                   color: context.colorScheme.outlineVariant,
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: _buildSideNavigation(context, isExpanded: false),
//           ),
//           // Main Content
//           Expanded(child: child),
//         ],
//       ),
//     );
//   }

//   Widget _buildMobileLayout(BuildContext context) {
//     return Scaffold(
//       drawer: const CustomDrawer(),
//       body: child,
//       bottomNavigationBar: _buildBottomNavigation(context),
//     );
//   }

//   Widget _buildSideNavigation(
//     BuildContext context, {
//     required bool isExpanded,
//   }) {
//     return Column(
//       children: [
//         // Header
//         Container(
//           height: 80.h,
//           padding: EdgeInsets.symmetric(horizontal: 16.w),
//           child: Row(
//             children: [
//               Container(
//                 width: 40.w,
//                 height: 40.w,
//                 decoration: BoxDecoration(
//                   color: context.colorScheme.primary,
//                   borderRadius: BorderRadius.circular(8.r),
//                 ),
//                 child: Icon(
//                   Icons.admin_panel_settings,
//                   color: context.colorScheme.onPrimary,
//                   size: 24.w,
//                 ),
//               ),
//               if (isExpanded) ...[
//                 SizedBox(width: 12.w),
//                 Expanded(
//                   child: Text(
//                     AppConstants.appName,
//                     style: TextStyle(
//                       fontSize: 18.sp,
//                       fontWeight: FontWeight.bold,
//                       color: context.colorScheme.onSurface,
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),

//         Divider(height: 1, color: context.colorScheme.outlineVariant),

//         // Navigation Items
//         Expanded(
//           child: ListView(
//             padding: EdgeInsets.symmetric(vertical: 8.h),
//             children: _getNavigationItems().asMap().entries.map((entry) {
//               final index = entry.key;
//               final item = entry.value;
//               final isSelected = index == currentIndex;

//               return _buildNavigationItem(
//                 context,
//                 item: item,
//                 isSelected: isSelected,
//                 isExpanded: isExpanded,
//                 onTap: () => _onNavigationTap(context, item.route),
//               );
//             }).toList(),
//           ),
//         ),

//         // User Profile Section
//         if (isExpanded) _buildUserProfile(context),
//       ],
//     );
//   }

//   Widget _buildNavigationItem(
//     BuildContext context, {
//     required NavigationItemData item,
//     required bool isSelected,
//     required bool isExpanded,
//     required VoidCallback onTap,
//   }) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(8.r),
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//             decoration: BoxDecoration(
//               color: isSelected ? AppColors.navSelected.withValues(alpha:0.08) : null,
//               borderRadius: BorderRadius.circular(8.r),
//               border: isSelected
//                   ? Border.all(color: AppColors.navSelected.withValues(alpha:0.25))
//                   : null,
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   item.icon,
//                   size: 24.w,
//                   color: isSelected
//                       ? AppColors.navSelected
//                       : AppColors.navUnselected,
//                 ),
//                 if (isExpanded) ...[
//                   SizedBox(width: 16.w),
//                   Expanded(
//                     child: Text(
//                       item.label.tr(),
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         fontWeight: isSelected
//                             ? FontWeight.w600
//                             : FontWeight.normal,
//                         color: isSelected
//                             ? AppColors.navSelected
//                             : AppColors.navUnselected,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomNavigation(BuildContext context) {
//     // final isDark = context.theme.brightness == Brightness.dark;
//     return Container(
//       decoration: BoxDecoration(
//         color: context.colorScheme.surface,
//         border: Border(
//           top: BorderSide(color: context.colorScheme.outlineVariant, width: 1),
//         ),
//       ),
//       child: SafeArea(
//         child: Container(
//           height: 70.h,
//           padding: EdgeInsets.symmetric(horizontal: 8.w),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: _getNavigationItems().asMap().entries.map((entry) {
//               final index = entry.key;
//               final item = entry.value;
//               final isSelected = index == currentIndex;

//               return Expanded(
//                 child: Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     onTap: () => _onNavigationTap(context, item.route),
//                     borderRadius: BorderRadius.circular(8.r),
//                     child: Container(
//                       padding: EdgeInsets.symmetric(vertical: 8.h),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             item.icon,
//                             size: 24.w,
//                             color: isSelected
//                                 ? AppColors.navSelected
//                                 : AppColors.navUnselected.withValues(alpha:0.6),
//                           ),
//                           SizedBox(height: 4.h),
//                           Text(
//                             item.label.tr(),
//                             style: TextStyle(
//                               fontSize: 12.sp,
//                               fontWeight: isSelected
//                                   ? FontWeight.w600
//                                   : FontWeight.normal,
//                               color: isSelected
//                                   ? AppColors.navSelected
//                                   : AppColors.navUnselected,
//                             ),
//                             textAlign: TextAlign.center,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserProfile(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 20.r,
//             backgroundColor: context.colorScheme.primary,
//             child: Text(
//               'M',
//               style: TextStyle(
//                 color: context.colorScheme.onPrimary,
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Mahmoud',
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w600,
//                     color: context.colorScheme.onSurface,
//                   ),
//                 ),
//                 Text(
//                   'Admin',
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     color: context.colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<NavigationItemData> _getNavigationItems() {
//     return [
//       NavigationItemData(
//         icon: Icons.home_outlined,
//         label: 'nav.home',
//         route: AppRouter.home,
//       ),
//       NavigationItemData(
//         icon: Icons.menu_book_outlined,
//         label: 'nav.quran',
//         route: AppRouter.quran,
//       ),
//       NavigationItemData(
//         icon: Icons.explore_outlined,
//         label: 'nav.qibla',
//         route: AppRouter.qibla,
//       ),
//       NavigationItemData(
//         icon: Icons.auto_awesome_outlined,
//         label: 'nav.tasbih',
//         route: AppRouter.tasbih,
//       ),
//     ];
//   }

//   void _onNavigationTap(BuildContext context, String route) {
//     if (GoRouterState.of(context).uri.toString() != route) {
//       context.go(route);
//     }
//   }
// }

// class NavigationItemData {
//   final IconData icon;
//   final String label;
//   final String route;

//   const NavigationItemData({
//     required this.icon,
//     required this.label,
//     required this.route,
//   });
// }
// ═══════════════════════════════════════════════════════════════════════════
// FILE: core/widgets/shared_navigation.dart
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../routing/app_router.dart';
import '../themes/app_colors.dart';
import '../extensions/theme_extension.dart';
import '../constants/app_constants.dart';
import 'responsive_layout.dart';
import 'custom_drawer.dart';

// ─── Responsive Config ────────────────────────────────────────────────────────
// نفس النهج اللي اتفقنا عليه — من shortestSide مش من ScreenUtil
class _NavCfg {
  final double side;
  _NavCfg(BuildContext ctx) : side = MediaQuery.of(ctx).size.shortestSide;

  bool get isTablet => side >= 600;
  bool get isDesktop => side >= 900;

  // Desktop sidebar width
  double get sidebarW => (side * 0.32).clamp(220.0, 300.0);
  // Tablet collapsed sidebar width
  double get collapsedW => (side * 0.11).clamp(64.0, 88.0);
  // Bottom nav height
  double get bottomNavH => (side * 0.155).clamp(54.0, 68.0);
  // Icon size
  double get iconSize => (side * 0.058).clamp(20.0, 28.0);
  // Label font
  double get labelFont => (side * 0.033).clamp(11.0, 15.0);
  // Header height (sidebar)
  double get headerH => (side * 0.18).clamp(64.0, 90.0);
  // Nav item vertical padding
  double get itemVPad => (side * 0.026).clamp(10.0, 16.0);
  // Radius
  double get radius => isTablet ? 12.0 : 10.0;
}

class SharedNavigation extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const SharedNavigation({
    super.key,
    required this.child,
    required this.currentIndex,
  });

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

  // ─── Desktop: wide sidebar ──────────────────────────────────────────────────
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
          Expanded(child: child),
        ],
      ),
    );
  }

  // ─── Tablet: icon-only sidebar ──────────────────────────────────────────────
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
          Expanded(child: child),
        ],
      ),
    );
  }

  // ─── Mobile: bottom nav + drawer ────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: child,
      bottomNavigationBar: _buildBottomNavigation(context),
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
            padding: EdgeInsets.symmetric(vertical: 8),
            children: _getNavigationItems().asMap().entries.map((entry) {
              final item = entry.value;
              final isSelected = entry.key == currentIndex;
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

        // ── User Profile (desktop only) ──
        if (isExpanded) _UserProfile(cfg: cfg),
      ],
    );
  }

  // ─── Bottom Navigation ───────────────────────────────────────────────────────
  Widget _buildBottomNavigation(BuildContext context) {
    final cfg = _NavCfg(context);
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          top: BorderSide(color: context.colorScheme.outlineVariant, width: 1),
        ),
        // subtle shadow
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _getNavigationItems().asMap().entries.map((entry) {
              final item = entry.value;
              final isSelected = entry.key == currentIndex;
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
          // ✅ بعد — استخدم SizedBox + Center بدل Padding
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 14.0 : 4.0,
                    vertical: 3.0, // ✅ أصغر
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
                const SizedBox(height: 2), // ✅ أصغر من 3
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
      padding: EdgeInsets.all(14.0),
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
