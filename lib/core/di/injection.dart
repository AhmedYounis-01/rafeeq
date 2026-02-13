import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../networking/api/api_consumer.dart';
import '../networking/api/dio_consumer.dart';
import '../networking/api/api_interceptor.dart';


final GetIt getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  //! Reset getIt on every initialization (crucial for Hot Restart)
  await getIt.reset();

  //! Dio (For general use if needed)
  final dio = Dio();
  getIt.registerLazySingleton<Dio>(() => dio);

  //! API Interceptor with Supabase management
  getIt.registerLazySingleton<ApiInterceptor>(() => ApiInterceptor());

  //! Api Consumer (Networking Layer)
  getIt.registerLazySingleton<ApiConsumer>(() => DioConsumer());

  // Datasources
  // getIt.registerLazySingleton<ProductsRemoteDataSource>(
  //   () => ProductsRemoteDataSourceImpl(getIt<ApiConsumer>()),
  // );

  //! Services
  // getIt.registerLazySingleton<CloudinaryService>(() => CloudinaryService());

  // Repositories
  // getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());
  // getIt.registerLazySingleton<DashboardRepository>(
  //   () => DashboardRepository(apiConsumer: getIt<ApiConsumer>()),
  // );

  //! Cubits
  // getIt.registerLazySingleton<AuthCubit>(
  //   () => AuthCubit(getIt<AuthRepository>()),
  // );
  // getIt.registerFactory<DashboardCubit>(
  //   () =>
  //       DashboardCubit(getIt<DashboardRepository>(), getIt<OrderRepository>()),
  // );
}
