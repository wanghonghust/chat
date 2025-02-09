import 'dart:io';

import 'package:chat/src/database/models/conversation.dart';
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
      body: Center(
        child: Column(
          children: [
            OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
                child: Text("Settings $count")),
            OutlinedButton(
                onPressed: () {
                  var con = Conversation(
                    title: 'Fido'
                  );

                  Conversation.insertConversation(con);
                },
                child: Text("Add")),
            SelectableRegion(
              selectionControls: materialTextControls,
              focusNode: FocusNode(),
              child: GestureDetector(
                onTap: () {}, // 避免覆盖默认手势
                behavior: HitTestBehavior.translucent,
                child: Text('可点击且可选择的文本'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
