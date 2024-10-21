import 'package:cashheart/app.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CashHeart',
      theme: ThemeData(
        useMaterial3: false,
      ),
      home: const App(),
    );
  }
}
