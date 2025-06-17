import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const CarRentalApp());
}

class CarRentalApp extends StatelessWidget {
  const CarRentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hitung Saldo',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
// Wira Selfina Laydi
// 230441100184
// PEMBER 4D
// Asprak Kak Rakha