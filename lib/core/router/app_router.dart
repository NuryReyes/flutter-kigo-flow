import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kigo_app/shared/widgets/placeholder_screen.dart';
import 'package:kigo_app/features/auth/screens/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/login',
      builder: (context, state) => const PlaceholderScreen(title: 'Login'),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) => const PlaceholderScreen(title: 'OTP'),
    ),
    ShellRoute(
      builder: (context, state, child) => HomeShell(child: child),
      routes: [
        GoRoute(
          path: '/home/qr',
          builder: (context, state) =>
              const PlaceholderScreen(title: 'QR Home'),
        ),
        GoRoute(
          path: '/home/mapa',
          builder: (context, state) => const PlaceholderScreen(title: 'Mapa'),
        ),
        GoRoute(
          path: '/home/control',
          builder: (context, state) =>
              const PlaceholderScreen(title: 'Control'),
        ),
        GoRoute(
          path: '/home/servicios',
          builder: (context, state) =>
              const PlaceholderScreen(title: 'Servicios'),
        ),
        GoRoute(
          path: '/home/perfil',
          builder: (context, state) => const PlaceholderScreen(title: 'Perfil'),
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
        selectedItemColor: const Color(0xFFFF6B00),
        unselectedItemColor: Colors.grey,
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
