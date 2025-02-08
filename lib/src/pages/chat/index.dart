import 'package:chat/env/env.dart';
import 'package:chat/src/pages/chat/markodwn_widget.dart';
import 'package:chat/src/pages/chat/toggle_button.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Widget> items = [];
  bool done = true;
  List<OpenAIChatCompletionChoiceMessageModel> messages = [];
  String userMessage = "";
  TextEditingController textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool think = false;
  bool network = false;
  bool autoScroll = true;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: messages.isNotEmpty
                  ? ListView.builder(
                      controller: _scrollController,
                      itemBuilder: (context, index) {
                        final String content =
                            messages[index].content![0].text!;
                        final bool isMe =
                            messages[index].role == OpenAIChatMessageRole.user;
                        return Padding(
                            padding: EdgeInsets.all(10),
                            child: _buildChatBubble(
                                isMe
                                    ? Text(content.trim())
                                    : MarkdownWidget(
                                        text: content,
                                      ),
                                isMe));
                      },
                      itemCount: messages.length,
                    )
                  : SizedBox.shrink(),
            ),
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
            color: Theme.of(context).hoverColor,
            borderRadius: BorderRadius.circular(5)),
        child: child,
      ),
    );
  }

  Widget _buildChatInput(BuildContext context, BoxConstraints constraints) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    return IntrinsicHeight(
        child: Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      width: constraints.maxWidth,
      constraints: BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withAlpha(80),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50), // 阴影的颜色
              offset: Offset(0.8, 0.8), // 阴影与容器的距离
              blurRadius: 0.5, // 高斯的标准偏差与盒子的形状卷积。
              spreadRadius: 0.0, // 在应用模糊之前，框应该膨胀的量。
            )
          ]),
      child: Column(
        children: [
          Expanded(
              child: TextField(
            controller: textEditingController,
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
                  ToggleButton(
                      icon: Icon(
                        Icons.emoji_objects,
                        size: 16,
                      ),
                      isSelected: think,
                      label: isSmallScreen ? null : Text("深度思考"),
                      onSelected: (value) {
                        setState(() {
                          think = value;
                        });
                      }),
                  SizedBox(width: 10),
                  ToggleButton(
                      icon: Icon(
                        Icons.wifi,
                        size: 16,
                      ),
                      isSelected: network,
                      label: isSmallScreen ? null : Text("联网搜索"),
                      onSelected: (value) {
                        setState(() {
                          network = value;
                        });
                      }),
                  SizedBox(width: 10),
                  ToggleButton(
                      icon: Icon(
                        Icons.import_export,
                        size: 16,
                      ),
                      isSelected: autoScroll,
                      label: isSmallScreen ? null : Text("自动滚动"),
                      onSelected: (value) {
                        setState(() {
                          autoScroll = value;
                        });
                      }),
                ],
              ),
              ElevatedButton.icon(
                onPressed: done ? sendMessage : null,
                label: Text('发送'),
                icon: Icon(Icons.send),
              )
            ],
          )
        ],
      ),
    ));
  }

  void sendMessage() {
    setState(() {
      userMessage = textEditingController.text;
      textEditingController.clear();
      if (userMessage.trim().isNotEmpty) {
        items.add(_buildChatBubble(Text(userMessage), true));
        chat(userMessage);
      }
    });
  }

  Future<void> chat(String message) async {
    setState(() {
      done = false;
    });
    StringBuffer responseBuffer = StringBuffer();
    OpenAI.apiKey = Env.key;
    OpenAI.baseUrl = "https://dashscope.aliyuncs.com/compatible-mode";
    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          message,
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );
    setState(() {
      messages.add(userMessage);
    });
    final chatStream = await OpenAI.instance.chat.createStream(
      model: "qwen-plus",
      messages: messages,
    );
    messages.add(OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "",
        )
      ],
      role: OpenAIChatMessageRole.assistant,
    ));
    chatStream.listen(
      (streamChatCompletion) {
        final content = streamChatCompletion.choices.first.delta.content;
        content?.forEach((item) {
          if (item != null) {
            setState(() {
              responseBuffer.write(item.text);
              messages[messages.length - 1] =
                  OpenAIChatCompletionChoiceMessageModel(
                content: [
                  OpenAIChatCompletionChoiceMessageContentItemModel.text(
                    responseBuffer.toString(),
                  )
                ],
                role: OpenAIChatMessageRole.assistant,
              );
            });
            if (autoScroll) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            }
          }
        });
      },
      onDone: () {
        setState(() {
          done = true;
        });
        responseBuffer.clear();
      },
    );
  }
}
