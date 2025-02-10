import 'dart:ffi';

import 'package:chat/env/env.dart';
import 'package:chat/src/database/models/Conversation.dart';
import 'package:chat/src/database/models/message.dart';
import 'package:chat/src/pages/chat/markodwn_widget.dart';
import 'package:chat/src/pages/chat/select_widget.dart';
import 'package:chat/src/pages/chat/toggle_button.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ChatPage extends StatefulWidget {
  dynamic arguments;
  ChatPage({super.key, this.arguments});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Conversation? conversation;
  String model = "qwen-plus";
  List<PopupMenuItem<String>> models = [
    PopupMenuItem(
      value: "qwen-plus",
      child: Text("通义千问 Plus"),
    ),
    PopupMenuItem(
      value: "deepseek-r1",
      child: Text("DeepSeek R1"),
    ),
    PopupMenuItem(
      value: "deepseek-v3",
      child: Text("DeepSeek V3"),
    )
  ];

  List<Widget> items = [];
  bool done = true;
  Map<String, List<OpenAIChatCompletionChoiceMessageModel>> messages = {};
  List<OpenAIChatCompletionChoiceMessageModel> orderedMessages = [];
  String userMessage = "";
  TextEditingController textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool think = false;
  bool network = false;
  bool autoScroll = true;
  bool selectModel = false;
  final MaterialTextSelectionControls materialTextControls =
      MaterialTextSelectionControls();

  @override
  void initState() {
    super.initState();
    if (widget.arguments != null) {
      conversation = widget.arguments as Conversation;
      fetchData();
    }
  }

  void fetchData() async {
    List<Message> mes = await Message.getConversationMessage(conversation!.id!);
    mes.forEach((item) {
      OpenAIChatMessageRole role = item.role == 0
          ? OpenAIChatMessageRole.user
          : OpenAIChatMessageRole.assistant;

      setState(() {
        OpenAIChatCompletionChoiceMessageModel chatModel =
            OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              item.content,
            ),
          ],
          role: role,
          name: item.model,
        );
        orderedMessages.add(chatModel);
        if (messages.containsKey(item.model)) {
          messages[item.model]!.add(chatModel);
        } else {
          messages[item.model] = [chatModel];
        }
      });
    });
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
                  conversation?.title ?? "Chat",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )),
            Expanded(
              child: messages.isNotEmpty
                  ? ListView.builder(
                      controller: _scrollController,
                      itemBuilder: (context, index) {
                        final String content =
                            orderedMessages[index].content![0].text!;
                        final bool isMe = orderedMessages[index].role ==
                            OpenAIChatMessageRole.user;
                        return Padding(
                            padding: EdgeInsets.all(10),
                            child: _buildChatBubble(
                                isMe
                                    ? SelectableRegion(
                                        focusNode: FocusNode(),
                                        selectionControls: materialTextControls,
                                        child: Text(content.trim()))
                                    : MarkdownWidget(
                                        text: content,
                                      ),
                                isMe));
                      },
                      itemCount: orderedMessages.length,
                    )
                  : SizedBox.shrink(),
            ),
            _buildChatInput(context, constraints),
          ],
        );
      },
    );
  }

  List<OpenAIChatCompletionChoiceMessageModel> getMessages() {
    List<OpenAIChatCompletionChoiceMessageModel> res = [];
    messages.forEach((key, value) {
      res.addAll(value);
    });
    return res;
  }

  List<OpenAIChatCompletionChoiceMessageModel> getCurrentModelMessages(
      String model) {
    List<OpenAIChatCompletionChoiceMessageModel> res = [];
    orderedMessages.forEach((item) {
      if (item.name == model) {
        res.add(item);
      }
    });
    return res;
  }

  Future<void> getModelMessages(String model) async {
    if (conversation != null) {
      List<Message> res =
          await Message.getModelConversationMessage(conversation!.id!, model);
      List<OpenAIChatCompletionChoiceMessageModel> res1 = [];
      res.forEach((item) {
        OpenAIChatMessageRole role = item.role == 0
            ? OpenAIChatMessageRole.user
            : OpenAIChatMessageRole.assistant;
        res1.add(OpenAIChatCompletionChoiceMessageModel(content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            item.content,
          ),
        ], role: role, name: model));
      });
      orderedMessages = res1;
    }
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
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(10),
      width: constraints.maxWidth,
      constraints: BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
          color: Theme.of(context).hoverColor,
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
                  SelectWidget(
                      value: model,
                      items: models,
                      onSelected: (value) {
                        setState(() {
                          model = value;
                        });
                      }),
                  SizedBox(width: 10),
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

  void sendMessage() async {
    String message = textEditingController.text;
    if (conversation == null) {
      Conversation con = Conversation(title: message);
      int id = await Conversation.insertConversation(con);
      setState(() {
        conversation = Conversation(title: message, id: id);
      });
    }
    setState(() {
      userMessage = message;
      textEditingController.clear();
      if (userMessage.trim().isNotEmpty) {
        items.add(_buildChatBubble(Text(userMessage), true));
        chat(userMessage);
      }
    });
  }

  Future<void> chat(String message) async {
    String chatModel = model;
    setState(() {
      done = false;
    });

    StringBuffer responseBuffer = StringBuffer();
    OpenAI.apiKey = Env.key;
    OpenAI.baseUrl = "https://dashscope.aliyuncs.com/compatible-mode";
    final userMessage = OpenAIChatCompletionChoiceMessageModel(content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        message,
      ),
    ], role: OpenAIChatMessageRole.user, name: chatModel);

    setState(() {
      orderedMessages.add(userMessage);
      if (messages[chatModel] != null) {
        messages[chatModel]!.add(userMessage);
      } else {
        messages[chatModel] = [userMessage];
      }
    });

    List<OpenAIChatCompletionChoiceMessageModel> modelMessages =
        getCurrentModelMessages(chatModel);
    final chatStream = OpenAI.instance.chat.createStream(
      model: chatModel,
      messages: modelMessages,
    );
    var resModel = OpenAIChatCompletionChoiceMessageModel(content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "",
      )
    ], role: OpenAIChatMessageRole.assistant, name: chatModel);
    setState(() {
      if (messages[chatModel] != null) {
        messages[chatModel]!.add(resModel);
      }
      orderedMessages.add(resModel);
    });
    chatStream.listen(
      (streamChatCompletion) {
        final content = streamChatCompletion.choices.first.delta.content;
        content?.forEach((item) {
          if (item != null) {
            modelMessages = getCurrentModelMessages(chatModel);

            responseBuffer.write(item.text);
            var mm = messages[chatModel]![modelMessages.length - 1] =
                OpenAIChatCompletionChoiceMessageModel(content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                responseBuffer.toString(),
              )
            ], role: OpenAIChatMessageRole.assistant, name: chatModel);
            setState(() {
              orderedMessages[orderedMessages.length - 1] = mm;
              if (messages[chatModel] != null) {
                messages[chatModel]![modelMessages.length - 1] = mm;
              }
            });
            if (autoScroll) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            }
          }
        });
      },
      onDone: () async {
        setState(() {
          done = true;
        });
        if (conversation != null) {
          Message userMsg = Message(
              content: message,
              conversationId: conversation!.id!,
              role: 0,
              model: model);
          await Message.insertMessage(userMsg);

          Message assistantMsg = Message(
              content: responseBuffer.toString(),
              conversationId: conversation!.id!,
              role: 1,
              model: chatModel);
          await Message.insertMessage(assistantMsg);
        }
        responseBuffer.clear();
      },
    );
  }
}
