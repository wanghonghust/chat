import 'dart:async';

import 'package:chat/conf.dart';
import 'package:chat/env/env.dart';
import 'package:chat/src/database/models/message.dart';
import 'package:chat/src/pages/chat/chat_input.dart';
import 'package:chat/src/pages/chat/expandable_panel.dart';
import 'package:chat/src/pages/chat/icon_button.dart';
import 'package:chat/src/pages/chat/markodwn_widget.dart';
import 'package:chat/src/pages/chat/toggle_button.dart';
import 'package:chat/src/pages/settings/controller.dart';
import 'package:chat/src/pages/test/index.dart';
import 'package:chat/src/types/chat_param.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  dynamic arguments;
  ChatPage({super.key, this.arguments});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatParam? param;
  String? model;
  List<DropdownMenuItem<String>> models = [];
  List<Widget> items = [];
  bool done = true;
  List<Message> orderedMessages = [];
  String userMessage = "";
  TextEditingController textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _msgScrollController = ScrollController();
  bool think = false;
  bool network = false;
  bool autoScroll = true;
  bool selectModel = false;
  bool isThinking = false;
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
      param = widget.arguments as ChatParam;
      model = param!.model ?? 'qwq-plus';
      if (param!.isNew) {
        textEditingController.text = param!.conversation.title;
        assert(param!.message != null);
        userMessage = param!.message!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          sendMessage();
        });
      } else {
        fetchData();
      }
    }
  }

  void fetchData() async {
    List<Message> mes =
        await Message.getConversationMessage(param!.conversation.id!);
    setState(() {
      orderedMessages = mes;
    });
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
                  param!.conversation.title,
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
                        var item = orderedMessages[index];

                        final String content = item.content;
                        final String? bubleModel =
                            item.role == 0 ? null : item.model;
                        return Padding(
                            padding: EdgeInsets.all(10),
                            child: _buildChatBubble(
                                Column(children: [
                                  if (item.thinkContent != null)
                                    ExpandablePanel(
                                      expand: true,
                                      title: Text(
                                        "思考过程",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            border: Border(
                                          left: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 3,
                                          ),
                                        )),
                                        child: MarkdownWidget(
                                          text: item.thinkContent!.trim(),
                                        ),
                                      ),
                                    ),
                                  if (item.thinkContent != null) Divider(),
                                  if (bubleModel == null)
                                    SelectableRegion(
                                        focusNode: FocusNode(),
                                        selectionControls: materialTextControls,
                                        child: Text(content.trim()))
                                  else
                                    MarkdownWidget(
                                      text: content,
                                    )
                                ]),
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

  List<Message> getCurrentModelMessages(String model) {
    List<Message> res = [];
    orderedMessages.forEach((item) {
      if (item.model == model) {
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
                      child: Shortcuts(
                        shortcuts: <LogicalKeySet, Intent>{
                          LogicalKeySet(LogicalKeyboardKey.enter):
                              SubmitActionIndent(),
                          LogicalKeySet(LogicalKeyboardKey.shift,
                              LogicalKeyboardKey.enter): InsertNewLineIntent()
                        },
                        child: Actions(
                          actions: <Type, Action<Intent>>{
                            SubmitActionIndent: CallbackAction(
                              onInvoke: (intent) {
                                if (textEditingController.text
                                    .trim()
                                    .isNotEmpty) {
                                  sendMessage();
                                }
                                return true;
                              },
                            ),
                            InsertNewLineIntent:
                                CallbackAction(onInvoke: (intent) {
                              textEditingController.text += "\n";
                              return true;
                            }),
                          },
                          child: Focus(
                            autofocus: true,
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
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(child: _buildStarMenu(context)),
                        SizedBox(width: 10),
                        CusIconButton(
                          onPressed:
                              userMessage.trim().isEmpty && subscription != null
                                  ? null
                                  : sendMessage,
                          icon: Icon(
                            subscription == null
                                ? Icons.send_rounded
                                : Icons.stop,
                            size: 16,
                          ),
                        )
                      ],
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

    // AppDataProvider dataProvider =
    //     Provider.of<AppDataProvider>(context, listen: false);
    // if (userMessage.trim().isNotEmpty) {
    //   Conversation con = Conversation(title: userMessage);
    //   int id = await Conversation.insertConversation(con);
    //   Conversation conversation = Conversation(title: userMessage, id: id);
    //   dataProvider.addConversation(conversation);
    // }
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
    StringBuffer thinkBuffer = StringBuffer();
    OpenAI.apiKey = Env.key;
    OpenAI.baseUrl = "https://dashscope.aliyuncs.com/compatible-mode";
    final userMessage = OpenAIChatCompletionChoiceMessageModel(content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        message,
      ),
    ], role: OpenAIChatMessageRole.user, name: chatModel);
    Message userMsg = Message(
        content: message,
        conversationId: param!.conversation.id!,
        role: 0,
        model: model!);
    setState(() {
      orderedMessages.add(userMsg);
    });

    List<Message> messages = getCurrentModelMessages(chatModel);
    List<OpenAIChatCompletionChoiceMessageModel> modelMessages = [];
    messages.forEach((element) {
      modelMessages.add(OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              element.content,
            )
          ],
          role: element.role == 0
              ? OpenAIChatMessageRole.user
              : OpenAIChatMessageRole.assistant,
          name: chatModel));
    });
    final chatStream = OpenAI.instance.chat.createStream(
      model: chatModel,
      messages: modelMessages,
    );
    setState(() {
      orderedMessages.add(Message(
          content: "",
          conversationId: param!.conversation.id!,
          role: 1,
          model: chatModel));
    });
    subscription = chatStream.listen(
      (streamChatCompletion) {
        final content = streamChatCompletion.choices.first.delta.content;
        content?.forEach((item) {
          if (item != null) {
            messages = getCurrentModelMessages(chatModel);
            var text = item.text;
            if (text!.contains(RegExp("<think>"))) {
              setState(() {
                isThinking = true;
              });
              text = text.replaceFirst(RegExp("<think>"), "");
              thinkBuffer.write(text);
            } else if (text.contains("</think>")) {
              setState(() {
                isThinking = false;
              });
              var parts = text.split("</think>");
              if (parts.length == 2) {
                if (parts[1].trim().isNotEmpty) {
                  thinkBuffer.write(parts[0]);
                } else {
                  thinkBuffer.write(parts[0]);
                  responseBuffer.write(parts[1]);
                }
              }
            } else {
              if (isThinking) {
                thinkBuffer.write(text);
              } else {
                responseBuffer.write(text);
              }
              Message assistantMsg = Message(
                  content: responseBuffer.toString(),
                  thinkContent: thinkBuffer.toString().trim().isEmpty
                      ? null
                      : thinkBuffer.toString(),
                  conversationId: param!.conversation.id!,
                  role: 1,
                  model: chatModel);
              setState(() {
                orderedMessages[orderedMessages.length - 1] = assistantMsg;
              });
              if (autoScroll) {
                _msgScrollController
                    .jumpTo(_msgScrollController.position.maxScrollExtent);
              }
            }
          }
        });
      },
      onDone: () async {
        setState(() {
          done = true;
          subscription = null;
        });
        await Message.insertMessage(userMsg);

        Message assistantMsg = Message(
            content: responseBuffer.toString(),
            thinkContent: thinkBuffer.toString(),
            conversationId: param!.conversation.id!,
            role: 1,
            model: chatModel);
        await Message.insertMessage(assistantMsg);
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
