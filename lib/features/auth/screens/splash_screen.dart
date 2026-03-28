import 'package:flutter/material.dart';
import 'package:kigo_app/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Logos centered
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/logo_kigo_splash.png',
                  height: 56,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            // Copyright footer
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                '© 2023 Kigo - Parkimovil\nTodos los derechos reservados',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
