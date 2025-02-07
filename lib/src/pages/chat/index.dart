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
    return Padding(
      padding: EdgeInsets.all(10),
      child: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            Positioned(bottom: 0, child: _buildChatInput(context, constraints)),
            SingleChildScrollView(
              child: Column(
                children: items,
              ),
            )
          ],
        );
      }),
    );
  }

  Widget _buildChatBubble(Widget child, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: child,
    );
  }

  Widget _buildChatInput(BuildContext context, BoxConstraints constraints) {
    return IntrinsicHeight(
        child: Container(
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
                    items.add(
                      _buildChatBubble(Text(message), true)
                    );
                    textEditingController.clear();
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
