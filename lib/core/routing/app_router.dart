import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rafeeq/features/splash/ui/screens/splash_screen.dart';
import 'package:rafeeq/features/onboarding/ui/onboarding_screen.dart';
import 'package:rafeeq/features/quick_parts/ui/screens/dhikr_list_screen.dart';
import 'package:rafeeq/features/quick_parts/ui/screens/seerah_screen.dart';
import 'package:rafeeq/features/quick_parts/data/quick_parts_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rafeeq/core/widgets/main_layout.dart';
import 'package:rafeeq/features/home/ui/home_screen.dart';
import 'package:rafeeq/features/qibla/ui/qibla_screen.dart';
import 'package:rafeeq/features/quran/ui/quran_screen.dart';
import 'package:rafeeq/features/tasbih/ui/tasbih_screen.dart';
// import '../../features/dashboard/data/models/dashboard_models.dart'
//     as dashboardModels;

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/signIn';
  static const String signUp = '/signUp';

  // Navigation screens
  static const String home = '/home';
  static const String qibla = '/qibla';
  static const String quran = '/quran';
  static const String tasbih = '/tasbih';

  // Quick parts screens
  static const String azkar = '/azkar';
  static const String ruqiah = '/ruqiah';
  static const String dua = '/dua';
  static const String seerah = '/seerah';

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: splash,
    routes: [
      // Top-level shell route that provides the shared MainLayout/navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: qibla,
            name: 'qibla',
            builder: (context, state) => const QiblaScreen(),
          ),
          GoRoute(
            path: quran,
            name: 'quran',
            builder: (context, state) => const QuranScreen(),
          ),
          GoRoute(
            path: tasbih,
            name: 'tasbih',
            builder: (context, state) => const TasbihScreen(),
          ),
        ],
      ),

      // Uncomment and add additional routes (auth, dashboard subroutes, etc.) as needed
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: azkar,
        name: 'azkar',
        builder: (context, state) =>
            const DhikrListScreen(type: QuickPartType.azkar),
      ),
      GoRoute(
        path: ruqiah,
        name: 'ruqiah',
        builder: (context, state) =>
            const DhikrListScreen(type: QuickPartType.ruqiah),
      ),
      GoRoute(
        path: dua,
        name: 'dua',
        builder: (context, state) =>
            const DhikrListScreen(type: QuickPartType.dua),
      ),
      GoRoute(
        path: seerah,
        name: 'seerah',
        builder: (context, state) => const SeerahScreen(),
      ),
      // GoRoute(
      //   path: signIn,
      //   name: 'signIn',
      //   builder: (context, state) => const SignInScreen(),
      // ),
      // GoRoute(
      //   path: signUp,
      //   name: 'SignUp',
      //   builder: (context, state) => const SignUpScreen(),
      // ),

      // Dashboard with navigation
      // ShellRoute(
      //   builder: (context, state, child) {
      //     return MultiBlocProvider(
      //       providers: [
      //         BlocProvider<NotificationCubit>(
      //           create: (context) {
      //             final cubit = NotificationCubit(
      //               repository: getIt<NotificationRepository>(),
      //             );
      //             cubit.loadNotifications();
      //             return cubit;
      //           },
      //         ),
      //         BlocProvider<OrderCubit>(
      //           create: (context) => getIt<OrderCubit>(),
      //         ),
      //       ],
      //       child: MainLayout(child: child),
      //     );
      //   },
      //   routes: [
      //     GoRoute(
      //       path: dashboard,
      //       name: 'dashboard',
      //       builder: (context, state) => const DashboardScreen(),
      //       routes: [
      //         GoRoute(
      //           path: 'order-details/:orderId',
      //           name: 'dashboard-order-details',
      //           builder: (context, state) {
      //             final orderId = state.pathParameters['orderId']!;
      //             context.read<OrderCubit>().getOrderById(orderId);
      //             return OrderDetailsScreen(orderId: orderId);
      //           },
      //         ),
      //       ],
      //     ),
      //     GoRoute(
      //       path: '/recent-orders',
      //       name: 'recentOrders',
      //       builder: (context, state) {
      //         final orders = state.extra as List<dashboardModels.Order>? ?? [];
      //         return RecentOrderScreen(orders: orders);
      //       },
      //       routes: [
      //         GoRoute(
      //           path: 'order-details/:orderId',
      //           name: 'recent-order-details',
      //           builder: (context, state) {
      //             final orderId = state.pathParameters['orderId']!;
      //             context.read<OrderCubit>().getOrderById(orderId);
      //             return OrderDetailsScreen(orderId: orderId);
      //           },
      //         ),
      //       ],
      //     ),
      //     GoRoute(
      //       path: '/low-stock',
      //       name: 'lowStock',
      //       builder: (context, state) {
      //         final alerts = state.extra as List<dashboardModels.StockAlert>;
      //         return LowStockScreen(alerts: alerts);
      //       },
      //     ),
      //     GoRoute(
      //       path: notifications,
      //       name: notifications,
      //       builder: (context, state) => const NotificationsScreen(),
      //       routes: [
      //         GoRoute(
      //           path: sendNotification,
      //           name: sendNotification,
      //           builder: (context, state) => BlocProvider(
      //             create: (context) =>
      //                 CustomersCubit(getIt<CustomersRepository>())
      //                   ..loadCustomers(),
      //             child: const SendNotificationScreen(),
      //           ),
      //         ),
      //       ],
      //     ),
      //     GoRoute(
      //       path: orders,
      //       name: 'orders',
      //       builder: (context, state) => const OrdersScreen(),
      //       routes: [
      //         GoRoute(
      //           path: orderSearch,
      //           name: 'order-search',
      //           builder: (context, state) => const OrderSearchScreen(),
      //         ),
      //         GoRoute(
      //           path: '$orderDetails/:orderId',
      //           name: orderDetails,
      //           builder: (context, state) {
      //             final orderId = state.pathParameters['orderId']!;
      //             return OrderDetailsScreen(orderId: orderId);
      //           },
      //         ),
      //       ],
      //     ),
      //     GoRoute(
      //       path: products,
      //       name: 'products',
      //       builder: (context, state) => const ProductsScreen(),
      //       routes: [
      //         GoRoute(
      //           path: addProduct,
      //           name: addProduct,
      //           builder: (context, state) {
      //             final product = state.extra as Product?;
      //             return AddProductScreen(product: product);
      //           },
      //         ),
      //         GoRoute(
      //           path: 'categories',
      //           name: categories,
      //           builder: (context, state) => const CategoriesScreen(),
      //         ),
      //         GoRoute(
      //           path: 'add-category',
      //           name: addCategory,
      //           builder: (context, state) {
      //             final category = state.extra as CategoryModel?;
      //             return AddCategoryScreen(category: category);
      //           },
      //         ),
      //       ],
      //     ),
      //     GoRoute(
      //       path: customers,
      //       name: 'customers',
      //       builder: (context, state) => const CustomersScreen(),
      //       routes: [
      //         GoRoute(
      //           path: ':customerId',
      //           name: 'customer-details',
      //           builder: (context, state) {
      //             final customerId = state.pathParameters['customerId']!;
      //             return CustomerDetailScreen(customerId: customerId);
      //           },
      //         ),
      //       ],
      //     ),
      //     GoRoute(
      //       path: settings,
      //       name: 'settings',
      //       builder: (context, state) => const SettingsScreen(),
      //       routes: [
      //         GoRoute(
      //           path: banners,
      //           name: 'banners',
      //           builder: (context, state) => BlocProvider(
      //             create: (context) => getIt<BannersCubit>(),
      //             child: const BannersScreen(),
      //           ),
      //           routes: [
      //             GoRoute(
      //               path: addBanner,
      //               name: 'add-banner',
      //               builder: (context, state) {
      //                 final banner = state.extra as BannerModel?;
      //                 return BlocProvider(
      //                   create: (context) => getIt<BannersCubit>(),
      //                   child: AddBannerScreen(banner: banner),
      //                 );
      //               },
      //             ),
      //           ],
      //         ),
      //       ],
      //     ),
      //   ],
      // ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'errors.pageNotFound'.tr(namedArgs: {'path': state.uri.toString()}),
        ),
      ),
    ),
  );
}
