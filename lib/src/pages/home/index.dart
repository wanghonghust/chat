import 'dart:io';

import 'package:chat/src/database/models/conversation.dart';
import 'package:expandable_menu/expandable_menu.dart';
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
      body: Stack(
        children: [
          Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: ExpandableMenu(
                width: 40.0,
                height: 40.0,
                items: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  Icon(
                    Icons.access_alarm,
                    color: Colors.white,
                  ),
                  Icon(
                    Icons.accessible_forward,
                    color: Colors.white,
                  ),
                  Icon(
                    Icons.accessibility_new_sharp,
                    color: Colors.white,
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
