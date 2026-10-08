import 'package:action_design_system/action_design_system.dart';
import 'package:flutter/material.dart';
import 'package:four_questions/app_controller.dart';
import 'package:four_questions/config.dart';
import 'package:four_questions/screens/access/no_access_ui.dart';
import 'package:four_questions/screens/loading/loading_ui.dart';
import 'package:four_questions/screens/question/question_ui.dart';
import 'package:four_questions/screens/sign_in/sign_in_ui.dart';
import 'package:four_questions/screens/summary/summary_ui.dart';
import 'package:four_questions/screens/welcome/welcome_ui.dart';
import 'package:four_questions/splash/splash_handoff.dart';

class Application extends StatelessWidget {
  const Application({super.key, required this.brand, required this.controller});

  final ActionBrand brand;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.themeMode,
      builder: (context, themeMode, _) => MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: buildActionTheme(brand),
        darkTheme: buildActionTheme(brand, brightness: Brightness.dark),
        themeMode: themeMode,
        home: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final stage = controller.stage;
            final screen = switch (stage) {
              AppStage.signedOut ||
              AppStage.renewing =>
                SignInUi(controller: controller),
              AppStage.loading ||
              AppStage.failed =>
                LoadingUi(controller: controller),
              AppStage.noAccess => NoAccessUi(controller: controller),
              AppStage.welcome => WelcomeUi(controller: controller),
              AppStage.question => QuestionUi(controller: controller),
              AppStage.summary => SummaryUi(controller: controller),
            };
            // A token renewal (the page is about to leave for Google) and a
            // first visit waiting on the sheet stay behind the HTML splash;
            // anything else is the first real screen.
            return switch (stage) {
              AppStage.renewing || AppStage.loading => screen,
              _ => SplashHandoff(child: screen),
            };
          },
        ),
      ),
    );
  }
}
