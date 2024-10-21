import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CashHeart',
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("CashHeart"),
        ),
        body: const Center(
          child: Text("Welcome to CashHeart"),
        ),
      ),
    );
  }
}
