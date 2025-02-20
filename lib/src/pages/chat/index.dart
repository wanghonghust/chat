import 'dart:async';

import 'package:chat/env/env.dart';
import 'package:chat/src/data_provider/index.dart';
import 'package:chat/src/database/models/conversation.dart';
import 'package:chat/src/database/models/message.dart';
import 'package:chat/src/pages/chat/expandable_panel.dart';
import 'package:chat/src/pages/chat/icon_button.dart';
import 'package:chat/src/pages/chat/markodwn_widget.dart';
import 'package:chat/src/pages/chat/toggle_button.dart';
import 'package:chat/src/pages/home/index.dart';
import 'package:chat/src/pages/settings/controller.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

const Map<String, String> supportModels = {
  "qwen-plus": "通义千问 Plus",
  "deepseek-r1": "DeepSeek R1",
  "deepseek-v3": "DeepSeek V3",
};

class ChatPage extends StatefulWidget {
  dynamic arguments;
  ChatPage({super.key, this.arguments});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Conversation? conversation;
  String? model = "qwen-plus";
  List<DropdownMenuItem<String>> models = [];
  List<Widget> items = [];
  bool done = true;
  List<OpenAIChatCompletionChoiceMessageModel> orderedMessages = [];
  String userMessage = "";
  TextEditingController textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _msgScrollController = ScrollController();
  bool think = false;
  bool network = false;
  bool autoScroll = true;
  bool selectModel = false;
  StreamSubscription? subscription;
  final FocusNode _focusNode = FocusNode();
  final MaterialTextSelectionControls materialTextControls =
      MaterialTextSelectionControls();
  final sliderValue = ValueNotifier<double>(0.5);
  bool expand = false;
  @override
  void initState() {
    super.initState();
    supportModels.forEach((k, v) {
      models.add(DropdownMenuItem(
        value: k,
        child: Text(
          v,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12),
        ),
      ));
    });
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
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _buildChat(context);
  }

  Widget _buildStarMenu(BuildContext context) {
    return ExpandableContainer(
      expand: true,
      expandedIcon: Icon(
        Icons.grid_view,
        size: 24,
      ),
      collapsedIcon: Icon(
        Icons.keyboard_arrow_left,
        size: 24,
      ),
      children: [
        ToggleButton(
            icon: Icon(
              Icons.emoji_objects,
              size: 12,
            ),
            isSelected: think,
            label: Text(
              "推理",
              style: TextStyle(fontSize: 12),
            ),
            onSelected: (value) {
              setState(() {
                think = value;
              });
            }),
        SizedBox(
          width: 5,
        ),
        ToggleButton(
            icon: Icon(
              Icons.wifi,
              size: 8,
            ),
            isSelected: network,
            label: Text(
              "搜索",
              style: TextStyle(fontSize: 12),
            ),
            onSelected: (value) {
              setState(() {
                network = value;
              });
            }),
        SizedBox(
          width: 5,
        ),
        ToggleButton(
            icon: Icon(
              Icons.import_export,
              size: 12,
            ),
            isSelected: autoScroll,
            label: Text(
              "滚动",
              style: TextStyle(fontSize: 12),
            ),
            onSelected: (value) {
              setState(() {
                autoScroll = value;
              });
            }),
        GestureDetector(
          child: Icon(Icons.add),
          onTap: () {
            setState(() {
              expand = !expand;
            });
          },
        )
      ],
    );
  }

  Widget _buildChat(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  conversation?.title ?? "Chat",
                  maxLines: 1,
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )),
            Expanded(
              child: orderedMessages.isNotEmpty
                  ? ListView.builder(
                      controller: _msgScrollController,
                      itemBuilder: (context, index) {
                        final String content =
                            orderedMessages[index].content![0].text!;
                        final String? bubleModel =
                            orderedMessages[index].role ==
                                    OpenAIChatMessageRole.user
                                ? null
                                : orderedMessages[index].name;
                        return Padding(
                            padding: EdgeInsets.all(10),
                            child: _buildChatBubble(
                                bubleModel == null
                                    ? SelectableRegion(
                                        focusNode: FocusNode(),
                                        selectionControls: materialTextControls,
                                        child: Text(content.trim()))
                                    : MarkdownWidget(
                                        text: content,
                                      ),
                                bubleModel));
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

  Widget _buildChatBubble(Widget child, String? model) {
    Widget mesageWidget = Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Theme.of(context).hoverColor,
          borderRadius: BorderRadius.circular(5)),
      child: child,
    );
    return Align(
      alignment: model == null ? Alignment.centerRight : Alignment.centerLeft,
      child: model == null
          ? mesageWidget
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).hoverColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      supportModels[model] ?? model,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                mesageWidget
              ],
            ),
    );
  }

  Widget _buildChatInput(BuildContext context, BoxConstraints constraints) {
    ThemeNotifier themeNotifier =
        Provider.of<ThemeNotifier>(context, listen: false);
    return Stack(children: [
      IntrinsicHeight(
          child: AnimatedSize(
              duration: Duration(milliseconds: 200),
              child: Container(
                margin: EdgeInsets.all(10),
                padding:
                    EdgeInsets.only(left: 10, right: 10, top: 25, bottom: 5),
                width: constraints.maxWidth,
                constraints: BoxConstraints(maxHeight: 250),
                decoration: BoxDecoration(
                  color: themeNotifier.isDarkMode
                      ? Theme.of(context).hoverColor
                      : Colors.white.withAlpha(216),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50), // 阴影的颜色
                      offset: Offset(0.8, 0.8), // 阴影与容器的距离
                      blurRadius: 0.5, // 高斯的标准偏差与盒子的形状卷积。
                      spreadRadius: 0.0, // 在应用模糊之前，框应该膨胀的量。
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                        child: KeyboardListener(
                            onKeyEvent: (event) {
                              if (event is KeyDownEvent &&
                                  event.logicalKey ==
                                      LogicalKeyboardKey.enter) {
                                sendMessage();
                              }
                            },
                            focusNode: _focusNode,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  userMessage = value.trim();
                                });
                              },
                              controller: textEditingController,
                              style: TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                  fillColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  hintText: "给智能助手发送消息",
                                  border: InputBorder.none),
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                            ))),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(child: _buildStarMenu(context)),
                        SizedBox(width: 10),
                        CusIconButton(
                          onPressed: sendMessage,
                          icon: Icon(
                            subscription == null
                                ? Icons.send_rounded
                                : Icons.stop,
                            size: 16,
                          ),
                        )
                      ],
                    ),
                    ExpandablePanel(
                      expand: expand,
                      child:
                          SelectableText.rich(TextSpan(text: "asdasdasdasd")),
                    )
                  ],
                ),
              ))),
      Positioned(
        left: 15,
        top: 15,
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            items: models,
            value: model,
            onChanged: (value) {
              setState(() {
                model = value;
              });
            },
            buttonStyleData: ButtonStyleData(
              height: 26,
              width: 110,
              padding: const EdgeInsets.only(left: 5, right: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).hoverColor,
              ),
              // elevation: 2,
            ),
            iconStyleData: const IconStyleData(
                icon: Icon(
                  Icons.expand_more,
                ),
                iconSize: 14,
                openMenuIcon: Icon(Icons.expand_less)),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              width: 110,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: themeNotifier.isDarkMode
                      ? Colors.black.withAlpha(200)
                      : null),
              offset: const Offset(0, 0),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: WidgetStateProperty.all(6),
                thumbVisibility: WidgetStateProperty.all(true),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 30,
              padding: EdgeInsets.only(left: 10, right: 10),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildMenu() {
    ScrollController _scrollController = ScrollController();
    return Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(
                builder: (context) {
                  return IconButton.filledTonal(
                    onPressed: () {
                      final RenderBox button =
                          context.findRenderObject() as RenderBox;
                      final RenderBox overlay = Overlay.of(context)
                          .context
                          .findRenderObject() as RenderBox;
                      final RelativeRect position = RelativeRect.fromRect(
                        Rect.fromPoints(
                          button.localToGlobal(Offset(0, -130),
                              ancestor: overlay),
                          button.localToGlobal(Offset.zero, ancestor: overlay),
                        ),
                        Offset.zero & overlay.size,
                      );
                      showMenu(
                          context: context,
                          position: position,
                          items: <PopupMenuEntry>[
                            PopupMenuItem(child: _buildStarMenu(context))
                          ]);
                    },
                    icon: const Icon(Icons.grid_view),
                  );
                },
              ),
            ],
          ),
        ));
  }

  void sendMessage() async {
    if (subscription != null) {
      subscription!.cancel();
      setState(() {
        subscription = null;
      });
      return;
    }

    AppDataProvider dataProvider =
        Provider.of<AppDataProvider>(context, listen: false);
    if (conversation == null && userMessage.trim().isNotEmpty) {
      Conversation con = Conversation(title: userMessage);
      int id = await Conversation.insertConversation(con);
      conversation = Conversation(title: userMessage, id: id);
      dataProvider.addConversation(conversation!);
      dataProvider.setCurrentRoute("/chat:$id:${con.title}");
      setState(() {});
    }
    setState(() {
      textEditingController.clear();
      if (userMessage.trim().isNotEmpty) {
        items.add(_buildChatBubble(Text(userMessage), null));
        chat(userMessage);
      }
    });
  }

  Future<void> chat(String message) async {
    String chatModel = model!;
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
      orderedMessages.add(resModel);
    });

    subscription = chatStream.listen(
      (streamChatCompletion) {
        final content = streamChatCompletion.choices.first.delta.content;
        content?.forEach((item) {
          if (item != null) {
            modelMessages = getCurrentModelMessages(chatModel);

            responseBuffer.write(item.text);
            var mm = OpenAIChatCompletionChoiceMessageModel(content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                responseBuffer.toString(),
              )
            ], role: OpenAIChatMessageRole.assistant, name: chatModel);
            setState(() {
              orderedMessages[orderedMessages.length - 1] = mm;
            });
            if (autoScroll) {
              _msgScrollController
                  .jumpTo(_msgScrollController.position.maxScrollExtent);
            }
          }
        });
      },
      onDone: () async {
        setState(() {
          done = true;
          subscription = null;
        });
        if (conversation != null) {
          Message userMsg = Message(
              content: message,
              conversationId: conversation!.id!,
              role: 0,
              model: model!);
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

class IconMenu extends StatelessWidget {
  const IconMenu({
    required this.icon,
    required this.text,
    super.key,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 6),
        Text(text),
      ],
    );
  }
}
