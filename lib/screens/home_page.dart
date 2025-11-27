import 'package:digia_ui/digia_ui.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DUIFactory().createInitialPage();
  }
}
