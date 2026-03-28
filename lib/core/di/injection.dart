import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  // Auth
  // getIt.registerLazySingleton<AuthRepository>(() => FakeAuthRepository());
  // getIt.registerLazySingleton<AuthStore>(() => AuthStore(getIt()));

  // Home
  // getIt.registerLazySingleton<HomeRepository>(() => FakeHomeRepository());
  // getIt.registerLazySingleton<HomeStore>(() => HomeStore(getIt()));
}
