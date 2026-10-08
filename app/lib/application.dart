import 'package:action_design_system/action_design_system.dart';
import 'package:flutter/material.dart';
import 'package:four_questions/screens/home/home_ui.dart';

class Application extends StatelessWidget {
  const Application({super.key, required this.brand});

  final ActionBrand brand;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: brand.name,
      debugShowCheckedModeBanner: false,
      theme: buildActionTheme(brand),
      darkTheme: buildActionTheme(brand, brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const HomeUi(),
    );
  }
}
