import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:chat/src/pages/chat/expandable_panel.dart';
import 'package:chat/src/pages/chat/toggle_button.dart';
import 'package:chat/widgets/custom_tab/chrome_tab.dart';
import 'package:chat/widgets/custom_tab/controller.dart';
import 'package:chat/widgets/custom_tab/index.dart' as csTab;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:envied/envied.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int count = 0;
  bool expand = false;
  String? selectedValue;
  CustomTabController controller =
      CustomTabController(selectedIndex: 0, items: [
    csTab.TabItem(label: "Home", icon: Icons.home),
    csTab.TabItem(label: "Add", icon: Icons.add),
    csTab.TabItem(label: "Home", icon: Icons.home),
    csTab.TabItem(label: "FaceRecognition", icon: Icons.face),
  ]);
  final MaterialTextSelectionControls materialTextControls =
      MaterialTextSelectionControls();
  bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(children: [
          ExpandableContainer(
            children: [
              ToggleButton(
                onSelected: (v) {},
                icon: Icon(Icons.menu),
                label: Text("搜索"),
              ),
              IconButton.filled(onPressed: () {}, icon: Icon(Icons.home)),
              IconButton.filled(onPressed: () {}, icon: Icon(Icons.add)),
              IconButton.filled(onPressed: () {}, icon: Icon(Icons.menu)),
              IconButton.filled(onPressed: () {}, icon: Icon(Icons.menu))
            ],
          ),
          IconButton.filled(
              onPressed: () {
                setState(() {
                  expand = !expand;
                });
              },
              icon: Icon(Icons.arrow_drop_down)),
          ExpandablePanel(
            child: Text("hello world"),
            expand: expand,
          ),
          _buildSelectMenu(context),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.menu),
            padding: EdgeInsets.zero,
            // iconSize: 12,
            constraints: BoxConstraints.tight(Size(24, 24)),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.only(left: 8, right: 8),
              minimumSize: Size(65, 30), // 设置按钮的宽度和高度
            ),
            icon: Icon(Icons.send),
            label: Text('发送'),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text("千问"),
          ),
          Expanded(
              child: csTab.CustomTab(
            controller: controller,
          ))
        ]),
      ),
    );
  }

  Widget _buildSelectMenu(BuildContext context) {
    final List<String> items = [
      'Item1',
      'Item2',
      'Item3',
      'Item4',
      'Item5',
      'Item6',
      'Item7',
      'Item8',
    ];
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        items: items
            .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        value: selectedValue,
        onChanged: (value) {
          setState(() {
            selectedValue = value;
          });
        },
        buttonStyleData: ButtonStyleData(
          height: 26,
          width: 100,
          padding: const EdgeInsets.only(left: 5, right: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: Colors.white.withAlpha(216),
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
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: const Color.fromARGB(0, 255, 255, 255),
          ),
          offset: const Offset(0, 0),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: WidgetStateProperty.all(6),
            thumbVisibility: WidgetStateProperty.all(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.only(left: 14, right: 14),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: TabBar(
        labelColor: Colors.redAccent,
        unselectedLabelColor: Colors.white,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.zero,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        tabs: [
          Tab(
            child: Align(
              alignment: Alignment.center,
              child: Text("APPS"),
            ),
          ),
          Tab(
            child: Align(
              alignment: Alignment.center,
              child: Text("MOVIES"),
            ),
          ),
          Tab(
            child: Align(
              alignment: Alignment.center,
              child: Text("GASMES"),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandableContainer extends StatefulWidget {
  bool expand;
  Widget? collapsedIcon;
  Widget? expandedIcon;
  final EdgeInsetsGeometry? padding;
  final List<Widget> children;
  ExpandableContainer({
    super.key,
    this.padding,
    required this.children,
    this.collapsedIcon,
    this.expandedIcon,
    this.expand = false,
  });
  @override
  _ExpandContainerState createState() => _ExpandContainerState();
}

class _ExpandContainerState extends State<ExpandableContainer> {
  late bool _expand;
  @override
  void initState() {
    super.initState();
    _expand = widget.expand;
  }

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
        alignment: Alignment.centerLeft,
        child: Container(
            padding: widget.padding,
            decoration: ShapeDecoration(
              shape: StadiumBorder(),
              color: Theme.of(context).hoverColor,
            ),
            child: AnimatedSize(
              alignment: Alignment.centerLeft,
              duration: Duration(milliseconds: 200),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: _expand
                          ? widget.collapsedIcon ??
                              Icon(Icons.keyboard_arrow_left)
                          : widget.expandedIcon ?? Icon(Icons.grid_view),
                    ),
                    onTap: () {
                      setState(() {
                        _expand = !_expand;
                      });
                    },
                  ),
                  if (_expand)
                    Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: widget.children,
                        )),
                ],
              ),
            )));
  }
}
