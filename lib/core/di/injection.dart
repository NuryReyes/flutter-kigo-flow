import 'package:get_it/get_it.dart';
import 'package:kigo_app/features/auth/repositories/auth_repository.dart';
import 'package:kigo_app/features/auth/repositories/fake_auth_repository.dart';
import 'package:kigo_app/features/auth/stores/auth_store.dart';
import 'package:kigo_app/features/home/repositories/fake_home_repository.dart';
import 'package:kigo_app/features/home/repositories/home_repository.dart';
import 'package:kigo_app/features/home/stores/home_store.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  // Auth
  getIt.registerLazySingleton<AuthRepository>(() => FakeAuthRepository());
  getIt.registerLazySingleton<AuthStore>(() => AuthStore(getIt()));

  // Home
  getIt.registerLazySingleton<HomeRepository>(() => FakeHomeRepository());
  getIt.registerLazySingleton<HomeStore>(() => HomeStore(getIt()));
}
