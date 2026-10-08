import 'package:action_design_system/action_design_system.dart';
import 'package:flutter/material.dart';
import 'package:four_questions/application.dart';

void bootstrapApplication({required ActionBrand brand}) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Application(brand: brand));
}
