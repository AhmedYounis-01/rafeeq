import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'shared_navigation.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final currentIndex = _getCurrentIndex(currentRoute);

    return SharedNavigation(
      currentIndex: currentIndex,
      child: child,
    );
  }

  int _getCurrentIndex(String route) {
    // Match by prefix to keep the correct tab selected on nested routes
    if (route.startsWith('/dashboard')) return 0;
    if (route.startsWith('/orders')) return 1;
    if (route.startsWith('/products')) return 2;
    if (route.startsWith('/customers')) return 3;
    if (route.startsWith('/settings')) return 4;
    return 0;
  }
}
