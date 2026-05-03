import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/scientific/scientific_screen.dart';

class CalcStudioApp extends StatelessWidget {
  const CalcStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bilimsel Hesap Makinesi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ScientificScreen(),
    );
  }
}