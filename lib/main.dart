import 'package:flutter/material.dart';
import 'package:kigo_app/core/di/injection.dart';
import 'package:kigo_app/core/router/app_router.dart';
import 'package:kigo_app/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDI();
  runApp(const KigoApp());
}

class KigoApp extends StatelessWidget {
  const KigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kigo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
