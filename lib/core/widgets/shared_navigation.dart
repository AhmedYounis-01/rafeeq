import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../routing/app_router.dart';
import '../themes/app_colors.dart';
import '../extensions/theme_extension.dart';
import '../constants/app_constants.dart';
import 'responsive_layout.dart';

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

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Side Navigation
          Container(
            width: 280.w,
            decoration: BoxDecoration(
              color: AppColors.navBackground,
              border: Border(
                right: BorderSide(
                  color: context.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: _buildSideNavigation(context, isExpanded: true),
          ),
          // Main Content
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Collapsed Side Navigation
          Container(
            width: 80.w,
            decoration: BoxDecoration(
              color: AppColors.navBackground,
              border: Border(
                right: BorderSide(
                  color: context.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: _buildSideNavigation(context, isExpanded: false),
          ),
          // Main Content
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildSideNavigation(
    BuildContext context, {
    required bool isExpanded,
  }) {
    return Column(
      children: [
        // Header
        Container(
          height: 80.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: context.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: context.colorScheme.onPrimary,
                  size: 24.w,
                ),
              ),
              if (isExpanded) ...[
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        Divider(height: 1, color: context.colorScheme.outlineVariant),

        // Navigation Items
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            children: _getNavigationItems().asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return _buildNavigationItem(
                context,
                item: item,
                isSelected: isSelected,
                isExpanded: isExpanded,
                onTap: () => _onNavigationTap(context, item.route),
              );
            }).toList(),
          ),
        ),

        // User Profile Section
        if (isExpanded) _buildUserProfile(context),
      ],
    );
  }

  Widget _buildNavigationItem(
    BuildContext context, {
    required NavigationItemData item,
    required bool isSelected,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.navSelected.withOpacity(0.08)
                  : null,
              borderRadius: BorderRadius.circular(8.r),
              border: isSelected
                  ? Border.all(color: AppColors.navSelected.withOpacity(0.25))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 24.w,
                  color: isSelected
                      ? AppColors.navSelected
                      : AppColors.navUnselected,
                ),
                if (isExpanded) ...[
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      item.label.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? AppColors.navSelected
                            : AppColors.navUnselected,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navBackground,
        border: Border(
          top: BorderSide(color: context.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 70.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _getNavigationItems().asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onNavigationTap(context, item.route),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 24.w,
                            color: isSelected
                                ? AppColors.navSelected
                                : AppColors.navUnselected.withOpacity(0.6),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            item.label.tr(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w600
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
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: context.colorScheme.primary,
            child: Text(
              'M',
              style: TextStyle(
                color: context.colorScheme.onPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mahmoud',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<NavigationItemData> _getNavigationItems() {
    return [
      NavigationItemData(
        icon: Icons.home_outlined,
        label: 'nav.home',
        route: AppRouter.home,
      ),
      NavigationItemData(
        icon: Icons.explore_outlined,
        label: 'nav.qibla',
        route: AppRouter.qibla,
      ),
      NavigationItemData(
        icon: Icons.menu_book_outlined,
        label: 'nav.quran',
        route: AppRouter.quran,
      ),
      NavigationItemData(
        icon: Icons.auto_awesome_outlined,
        label: 'nav.tasbih',
        route: AppRouter.tasbih,
      ),
    ];
  }

  void _onNavigationTap(BuildContext context, String route) {
    if (GoRouterState.of(context).uri.toString() != route) {
      context.go(route);
    }
  }
}

class NavigationItemData {
  final IconData icon;
  final String label;
  final String route;

  const NavigationItemData({
    required this.icon,
    required this.label,
    required this.route,
  });
}
