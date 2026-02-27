import 'package:flutter/material.dart';
import 'package:meteo_app/pages/principal.dart';
import 'package:meteo_app/screens/details.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Principal()
    );
}
}
