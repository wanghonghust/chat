import 'dart:async';

import 'package:chat/src/pages/chat/icon_button.dart';
import 'package:chat/src/pages/chat/toggle_button.dart';
import 'package:chat/src/pages/settings/controller.dart';
import 'package:chat/src/pages/test/index.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ChatInput extends StatefulWidget {
  String? model;
  Map<String, String>? supportModels;
  final double maxWidth;
  void Function(String)? onSend;
  void Function(String?)? onModelChange;
  ChatInput({
    super.key,
    required this.maxWidth,
    this.onSend,
    this.onModelChange,
    this.model,
    this.supportModels,
  });
  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool think = false;
  bool network = false;
  bool autoScroll = true;
  bool selectModel = false;
  StreamSubscription? subscription;
  bool expand = false;
  List<DropdownMenuItem<String>> models = [];
  @override
  void initState() {
    super.initState();
    textEditingController.addListener(_updateUi);
    widget.supportModels!.forEach((k, v) {
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
  }

  @override
  void dispose() {
    textEditingController.removeListener(_updateUi);
    textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateUi() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
                width: widget.maxWidth,
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
                                  SubmitActionIndent:CallbackAction(onInvoke: (intent) {
                                    if(textEditingController.text.trim().isNotEmpty){
                                      sendMessage();
                                    }
                                    return true;
                                  },),
                                  InsertNewLineIntent:
                                      CallbackAction(onInvoke: (intent) {
                                    textEditingController.text += "\n";
                                    return true;
                                  }),
                                },
                                child: Focus(
                                    autofocus: true,
                                    child: TextField(
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
                                    ))))),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(child: _buildStarMenu(context)),
                        SizedBox(width: 10),
                        CusIconButton(
                          onPressed:
                              textEditingController.text.trim().isEmpty &&
                                      subscription == null
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
            value: widget.model,
            onChanged: (value) {
              if (widget.onModelChange != null) {
                widget.onModelChange!(value!);
              }
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

  void sendMessage() {
    if (widget.onSend != null) {
      widget.onSend!(textEditingController.text);
    }
    textEditingController.clear();
    print("send message: '${textEditingController.text}'");
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
}

class SubmitActionIndent extends Intent {}

class InsertNewLineIntent extends Intent {}
