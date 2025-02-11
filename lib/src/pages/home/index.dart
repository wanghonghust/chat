import 'dart:io';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int count = 0;
  final MaterialTextSelectionControls materialTextControls =
      MaterialTextSelectionControls();
  bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
