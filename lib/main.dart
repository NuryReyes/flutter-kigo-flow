import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const KigoApp());
}

class KigoApp extends StatelessWidget {
  const KigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kigo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        backgroundColor: AppColors.primary,
        body: const Center(
          child: Text(
            'Kigo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}