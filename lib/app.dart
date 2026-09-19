import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

class AgriSorterApp extends StatelessWidget {
  const AgriSorterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'General Agri-Sorter Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade700),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
