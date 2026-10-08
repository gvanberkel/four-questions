import 'package:action_design_system/action_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:four_questions/app_controller.dart';
import 'package:four_questions/application.dart';
import 'package:four_questions/auth/browser.dart';
import 'package:four_questions/auth/google_auth.dart';
import 'package:four_questions/auth/sign_in_service.dart';
import 'package:four_questions/config.dart';
import 'package:four_questions/data/demo_sheets_gateway.dart';
import 'package:four_questions/data/google_sheets_gateway.dart';
import 'package:four_questions/data/local_store.dart';
import 'package:four_questions/splash/splash_handoff.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> bootstrapApplication({required ActionBrand brand}) async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  final local = await LocalStore.open();
  final browser = Browser();
  final demo = AppConfig.demo
      ? DemoSheetsGateway(prefs: await SharedPreferences.getInstance())
      : null;

  final controller = AppConfig.demo
      ? AppController(
          local: local,
          browser: browser,
          signIn: DemoSignInService(),
          openGateway: (_) => demo!,
        )
      : AppController(
          local: local,
          browser: browser,
          signIn: GoogleSignInService(GoogleAuth(
            browser: browser,
            clientId: AppConfig.googleClientId,
          )),
          openGateway: (token) => GoogleSheetsGateway(accessToken: token),
        );

  // Reads Google's answer out of the address bar before anything routes.
  controller.start();

  holdSplashNoLongerThan(const Duration(seconds: 8));
  runApp(Application(brand: brand, controller: controller));
}
