import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kigo_app/core/theme/app_theme.dart';
import 'package:kigo_app/features/auth/screens/splash_screen.dart';
import 'package:kigo_app/features/auth/screens/login_screen.dart';
import 'package:kigo_app/features/auth/screens/otp_screen.dart';
import 'package:kigo_app/features/home/screens/qr_screen.dart';
import 'package:kigo_app/features/home/screens/stub_screens.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final phoneNumber = state.extra as String? ?? '';
        return OtpScreen(phoneNumber: phoneNumber);
      },
    ),
    ShellRoute(
      builder: (context, state, child) => HomeShell(child: child),
      routes: [
        GoRoute(
          path: '/home/qr',
          builder: (context, state) => const QrScreen(),
        ),
        GoRoute(
          path: '/home/mapa',
          builder: (context, state) =>
              const StubScreen(title: 'Mapa', icon: Icons.map_outlined),
        ),
        GoRoute(
          path: '/home/control',
          builder: (context, state) =>
              const StubScreen(title: 'Control', icon: Icons.tune),
        ),
        GoRoute(
          path: '/home/servicios',
          builder: (context, state) =>
              const StubScreen(title: 'Servicios', icon: Icons.grid_view),
        ),
        GoRoute(
          path: '/home/perfil',
          builder: (context, state) =>
              const StubScreen(title: 'Perfil', icon: Icons.person_outline),
        ),
      ],
    ),
  ],
);

// The persistent shell that holds the bottom nav
class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;
    if (location.startsWith('/home/mapa')) currentIndex = 0;
    if (location.startsWith('/home/control')) currentIndex = 1;
    if (location.startsWith('/home/qr')) currentIndex = 2;
    if (location.startsWith('/home/servicios')) currentIndex = 3;
    if (location.startsWith('/home/perfil')) currentIndex = 4;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.greyUnactive,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home/mapa');
              break;
            case 1:
              context.go('/home/control');
              break;
            case 2:
              context.go('/home/qr');
              break;
            case 3:
              context.go('/home/servicios');
              break;
            case 4:
              context.go('/home/perfil');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Control'),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Servicios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
