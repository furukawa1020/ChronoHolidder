import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronoholidder/features/chronosphere/home_screen.dart';

void main() {
  runApp(
    ProviderScope(
      child: const ChronoHolidderApp(),
    ),
  );
}

class ChronoHolidderApp extends StatelessWidget {
  const ChronoHolidderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChronoHolidder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
