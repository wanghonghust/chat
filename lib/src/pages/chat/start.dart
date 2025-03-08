import 'package:chat/conf.dart';
import 'package:chat/src/pages/chat/chat_input.dart';
import 'package:flutter/material.dart';

class ChatStart extends StatefulWidget {
  @override
  _ChatStartState createState() => _ChatStartState();
}

class _ChatStartState extends State<ChatStart> {
  String? model = "qwen-plus";
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  "Chat",
                  maxLines: 1,
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )),
            Expanded(
              child: SizedBox.shrink(),
            ),
            ChatInput(
              maxWidth: constraints.maxWidth,
              model: model,
              supportModels: supportModels,
              onModelChange: (v) {
                setState(() {
                  model = v;
                });
              },
            ),
          ],
        );
      },
    );
  }
}
