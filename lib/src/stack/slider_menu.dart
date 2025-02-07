import 'package:chat/widgets/sidebar/index.dart';
import 'package:flutter/material.dart';

class SliderMenu extends StatefulWidget {
  final Function(SidebarItem)? onItemClick;
  final GlobalKey<NavigatorState>? navigatorKey;
  final List<SidebarItem> items;
  final Key? activeKey;
  const SliderMenu({
    super.key,
    this.activeKey,
    required this.items,
    this.onItemClick,
    this.navigatorKey,
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
          _Profile(),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  return buildItem(context, widget.items[index],
                      widget.activeKey == widget.items[index].key);
                },
                itemCount: widget.items.length),
          ),
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, SidebarItem item, bool active) {
    return Builder(builder: (context) {
      final primaryColor = Theme.of(context).primaryColor;
      return AnimatedContainer(
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: active ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(5)),
        duration: Duration(milliseconds: 300),
        height: 42,
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: () {
            if (widget.navigatorKey != null) {
              String? currentRoute = getCurrentRouteName(widget.navigatorKey!);
              if (currentRoute != item.route) {
                widget.navigatorKey!.currentState?.pushNamed(item.route!);
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
      );
    });
  }

  String? getCurrentRouteName(GlobalKey<NavigatorState> navigatorKey) {
    String? currentRouteName;
    navigatorKey.currentState?.popUntil((route) {
      // 这里会依次遍历所有路由，最终 currentRouteName 为最后一次赋值，也就是栈顶路由的 name
      currentRouteName = route.settings.name;
      return true;
    });
    return currentRouteName;
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
