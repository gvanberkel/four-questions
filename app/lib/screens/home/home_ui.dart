import 'package:action_design_system/action_design_system.dart';
import 'package:flutter/widgets.dart';

class HomeUi extends StatelessWidget {
  const HomeUi({super.key});

  @override
  Widget build(BuildContext context) {
    return const ActionScaffold.blank(
      child: ActionPage(
        title: 'Four Questions',
        width: ActionPageWidth.focus,
        centerVertically: true,
        child: ActionBodyText('Hello World!'),
      ),
    );
  }
}
