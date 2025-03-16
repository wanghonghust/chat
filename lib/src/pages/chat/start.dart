import 'package:chat/conf.dart';
import 'package:chat/src/data_provider/index.dart';
import 'package:chat/src/database/models/conversation.dart';
import 'package:chat/src/pages/chat/chat_input.dart';
import 'package:chat/src/types/chat_param.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatStart extends StatefulWidget {
  @override
  _ChatStartState createState() => _ChatStartState();
}

class _ChatStartState extends State<ChatStart> {
  String? model = "qwq-plus";
  AppDataProvider? dataProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dataProvider = Provider.of<AppDataProvider>(context, listen: true);
  }

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
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ChatInput(
                  maxWidth: constraints.maxWidth,
                  model: model,
                  supportModels: supportModels,
                  onSend: onSend,
                  onModelChange: (v) {
                    setState(() {
                      model = v;
                    });
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void onSend(String message) {
    String title =
        message.trim().replaceAll(RegExp(r"[\n\r]", multiLine: true), "");
    title = title.length > 10 ? title.substring(0, 20) : title;
    Conversation conversation = Conversation(title: title);
    conversation.save().then((id) {
      conversation = Conversation(id: id, title: title);
      dataProvider!.addConversation(conversation);
      ChatParam chatParam = ChatParam(
        conversation: conversation,
        isNew: true,
        model: model,
        message: message,
      );
      dataProvider!.navigatorKey.currentState!
          .pushNamed("/chat", arguments: chatParam);
    });
  }
}
