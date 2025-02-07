import 'package:chat/env/env.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Widget> items = [];
  String message = "";
  TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Column(
                  children: items,
                ),
              ),
            )),
            _buildChatInput(context, constraints),
          ],
        );
      },
    );
  }

  Widget _buildChatBubble(Widget child, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        decoration: BoxDecoration(
            color: const Color.fromARGB(113, 220, 220, 220),
            borderRadius: BorderRadius.circular(5)),
        child: child,
      ),
    );
  }

  Widget _buildChatInput(BuildContext context, BoxConstraints constraints) {
    return IntrinsicHeight(
        child: Container(
          margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      width: constraints.maxWidth,
      constraints: BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: const Color.fromARGB(148, 255, 255, 255),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Expanded(
              child: TextField(
            controller: textEditingController,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
                fillColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                hintText: "给ChatGpt发送消息",
                border: InputBorder.none),
            keyboardType: TextInputType.multiline,
            maxLines: null,
          )),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    label: Text('深度思考'),
                    icon: Icon(Icons.emoji_objects),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {},
                    label: Text('联网搜索'),
                    icon: Icon(Icons.public),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    message = textEditingController.text;
                    textEditingController.clear();
                    if (message.trim().isNotEmpty) {
                      items.add(_buildChatBubble(Text(message), true));
                      chat(message);
                    }
                  });
                },
                label: Text('发送'),
                icon: Icon(Icons.send),
              )
            ],
          )
        ],
      ),
    ));
  }
}


Future<void> chat(String prompt) async {
  OpenAI.apiKey = Env.key;
  OpenAI.baseUrl = "https://api.deepseek.com/v1";
  final completion = await OpenAI.instance.completion.create(
    model: "deepseek-chat",
    prompt: prompt,
  );
  print(completion.choices[0].text);
}