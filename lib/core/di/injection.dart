import 'package:get_it/get_it.dart';
import 'package:kigo_app/features/home/repositories/fake_home_repository.dart';
import 'package:kigo_app/features/home/repositories/home_repository.dart';
import 'package:kigo_app/features/home/stores/home_store.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  // Home
  getIt.registerLazySingleton<HomeRepository>(() => FakeHomeRepository());
  getIt.registerLazySingleton<HomeStore>(() => HomeStore(getIt()));
}
