import 'package:cashheart/home_screen.dart';
import 'package:cashheart/initializer/app_initializer.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.initialize();
  runApp(const HomeScreen());
}
