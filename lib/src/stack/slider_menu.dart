import 'package:chat/src/data_provider/index.dart';
import 'package:chat/src/database/models/conversation.dart';
import 'package:chat/src/pages/chat/index.dart';
import 'package:chat/src/types/chat_param.dart';
import 'package:chat/widgets/sidebar/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SliderMenu extends StatefulWidget {
  final Function(SidebarItem)? onItemClick;
  final GlobalKey<NavigatorState>? navigatorKey;
  final List<SidebarItem> items;
  final List<Conversation>? histories;
  final Key? activeKey;
  final Function(Conversation)? onHistoryDelete;
  const SliderMenu({
    super.key,
    this.activeKey,
    required this.items,
    this.histories,
    this.onItemClick,
    this.navigatorKey,
    this.onHistoryDelete,
  });

  @override
  State<SliderMenu> createState() => _SliderMenuState();
}

class _SliderMenuState extends State<SliderMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.transparent,
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          _buildNewChat(context),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: widget.histories!.isNotEmpty
                  ? _buildHistory(context)
                  : SizedBox.shrink()),
          Divider(
            thickness: 1,
            height: 1,
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  return buildItem(context, widget.items[index],
                      widget.activeKey == widget.items[index].key);
                },
                itemCount: widget.items.length),
          ),
          Divider(
            thickness: 1,
          ),
          _buildBottom(context)
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, SidebarItem item, bool active) {
    return Builder(builder: (context) {
      final bgColor = Theme.of(context).hoverColor;
      return Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: active ? bgColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(5)),
                height: 36,
                child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () {
                    if (widget.navigatorKey != null) {
                      Route<dynamic>? currentRoute =
                          getCurrentRoute(widget.navigatorKey!);

                      if (currentRoute!.settings.name! != item.route ||
                          (currentRoute.settings.name! == item.route &&
                              currentRoute.settings.arguments != null)) {
                        widget.navigatorKey!.currentState
                            ?.pushNamed(item.route!);
                      }
                    }
                    if (widget.onItemClick != null) {
                      widget.onItemClick!(item);
                    }
                    if (item.onTap != null) {
                      item.onTap!();
                    }
                  },
                  child: Row(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: item.icon),
                      Expanded(
                        child: Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: DefaultTextStyle(
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              softWrap: false,
                              style: Theme.of(context).textTheme.bodyMedium!,
                              child: item.title,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeIn,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(1.5),
                ),
                width: 3,
                height: active ? 24 : 0,
              ),
            ],
          ));
    });
  }

  Route<dynamic>? getCurrentRoute(GlobalKey<NavigatorState> navigatorKey) {
    Route<dynamic>? currentRoute;
    navigatorKey.currentState?.popUntil((route) {
      // 这里会依次遍历所有路由，最终 currentRouteName 为最后一次赋值，也就是栈顶路由的 name
      currentRoute = route;
      return true;
    });
    return currentRoute;
  }

  Widget _buildBottom(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.black26,
            child: CircleAvatar(
              radius: 16,
              backgroundImage: Image.network(
                      'https://thirdwx.qlogo.cn/mmopen/vi_32/PiajxSqBRaEILA3sib6LqDfgoibD3KQ2wvBAkNfoIR8xRicppSH4JQp0WvNbdRp0e0BeqtQBced3Pge5b3BNAIibAA0dZ1FgJI6887RoQGZfnhksIR7TgQt9icUQ/132')
                  .image,
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Text(
            '智能助手',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNewChat(BuildContext context) {
    return FilledButton.tonal(
        onPressed: () {
          widget.navigatorKey!.currentState?.pushNamed("/start");
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("新建聊天"),
            SizedBox(
              width: 10,
            ),
            Icon(Icons.add)
          ],
        ));
  }

  Widget _buildHistory(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemBuilder: (context, index) {
        return Padding(
            padding: EdgeInsets.only(bottom: 2),
            child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                onTap: () {
                  Route<dynamic>? currentRoute =
                      getCurrentRoute(widget.navigatorKey!);
                  ChatParam? param = currentRoute!.settings.arguments == null
                      ? null
                      : currentRoute.settings.arguments as ChatParam;
                  if (param == null ||
                      param.conversation != widget.histories![index]) {
                    ChatParam chatParam = ChatParam(
                        conversation: widget.histories![index], isNew: false);
                    widget.navigatorKey!.currentState
                        ?.pushNamed('/chat', arguments: chatParam);
                  }
                },
                child: Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: widget.activeKey ==
                                  ValueKey(
                                      '/chat:${widget.histories![index].id}')
                              ? Theme.of(context).hoverColor
                              : null,
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                              widget.histories![index].title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapDown: (details) {
                                _showMenu(context, details.globalPosition,
                                    widget.histories![index]);
                              },
                              child: Icon(
                                Icons.more_horiz,
                                size: 16,
                              ),
                            )
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                        width: 3,
                        height: widget.activeKey ==
                                ValueKey('/chat:${widget.histories![index].id}')
                            ? 20
                            : 0,
                      ),
                    ])));
      },
      itemCount: widget.histories!.length,
    );
  }

  void _showMenu(
      BuildContext context, Offset position, Conversation conversation) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color.fromARGB(255, 32, 32, 32)
          : const Color.fromARGB(255, 247, 247, 247),
      menuPadding: EdgeInsets.all(5),
      context: context,
      constraints: BoxConstraints(maxWidth: 110),
      position: RelativeRect.fromRect(
        Rect.fromPoints(position, position), // 鼠标点击的位置
        Offset.zero & overlay.size, // 确保菜单正确显示
      ),
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          height: 32,
          value: "share",
          child: Row(
            children: [
              Icon(
                Icons.share,
                size: 24,
              ),
              SizedBox(width: 10),
              Expanded(child: Text("分享"))
            ],
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          height: 32,
          value: "delete",
          child: Row(
            children: [
              Icon(
                Icons.delete,
                size: 24,
              ),
              SizedBox(width: 10),
              Expanded(child: Text("删除对话"))
            ],
          ),
          onTap: () {
            if (conversation.id != null) {
              Conversation.deleteConversation(conversation.id!).then((v) {
                if (widget.onHistoryDelete != null) {
                  widget.onHistoryDelete!(conversation);
                }
              });
            }
          },
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          height: 32,
          value: "edit",
          child: Row(
            children: [
              Icon(
                Icons.edit_note,
                size: 24,
              ),
              SizedBox(width: 10),
              Expanded(child: Text("重命名"))
            ],
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          height: 32,
          value: "tune",
          child: SizedBox(
            child: Row(
              children: [
                Icon(
                  Icons.tune,
                  size: 24,
                ),
                SizedBox(width: 10),
                Expanded(child: Text("批量管理"))
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 62,
          backgroundColor: Colors.black26,
          child: CircleAvatar(
            radius: 60,
            backgroundImage: Image.network(
                    'https://thirdwx.qlogo.cn/mmopen/vi_32/PiajxSqBRaEILA3sib6LqDfgoibD3KQ2wvBAkNfoIR8xRicppSH4JQp0WvNbdRp0e0BeqtQBced3Pge5b3BNAIibAA0dZ1FgJI6887RoQGZfnhksIR7TgQt9icUQ/132')
                .image,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'DeepSeek',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ],
    );
  }
}
