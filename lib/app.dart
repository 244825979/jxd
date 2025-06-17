import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/main_screen.dart';

class JXDApp extends StatelessWidget {
  const JXDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '静心岛',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
} 