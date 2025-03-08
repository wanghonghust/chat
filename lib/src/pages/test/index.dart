import 'dart:io';
import 'dart:ui';

import 'package:chat/src/pages/chat/expandable_panel.dart';
import 'package:chat/src/pages/chat/highlight_view.dart';
import 'package:chat/src/pages/chat/icon_button.dart';
import 'package:chat/src/pages/chat/toggle_button.dart';
import 'package:chat/src/pages/settings/settings_view.dart';
import 'package:chat/widgets/custom_tab/controller.dart';
import 'package:chat/widgets/custom_tab/index.dart' as csTab;
import 'package:chat/widgets/glass_widget/index.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/github.dart';

class TesPage extends StatefulWidget {
  @override
  _TesPageState createState() => _TesPageState();
}

class _TesPageState extends State<TesPage> {
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
  void initState() {
    super.initState();
    controller.addListener(_updateUi);
  }

  void _updateUi() {
    setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_updateUi);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: csTab.CustomTab(
      controller: controller,
      child: IndexedStack(
        index: controller.selectedIndex,
        children: [
          MyWidget(title: "Home"),
          MyWidget(title: "Add"),
          MyWidget(title: "Home"),
          MyWidget(title: "FaceRecognition"),
        ],
      ),
    ));
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

class MyWidget extends StatefulWidget {
  final String title;
  MyWidget({super.key, required this.title});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    var code = '''import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}
''';

    return Scaffold(
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: EdgeInsets.all(5),
        child: TextField(
          maxLines: 1,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CusIconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.refresh,
                      size: 20,
                    ),
                    backgroundColor: Colors.transparent,
                    shadow: false,
                  ),
                  CusIconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.home,
                      size: 20,
                    ),
                    backgroundColor: Colors.transparent,
                    shadow: false,
                  )
                ],
              ),
              prefixIcon: Icon(
                Icons.search,
                size: 20,
              ),
              suffixIcon: CusIconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.star,
                  size: 20,
                ),
                backgroundColor: Colors.transparent,
                shadow: false,
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide:
                      BorderSide(color: Theme.of(context).primaryColor)),
              isDense: true,
              constraints: BoxConstraints(maxHeight: 30),
              contentPadding: EdgeInsets.all(0)),
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      Stack(
        children: [
          const _AcrylicChildren(),
          Positioned.fill(
              child: Padding(
                  padding: const EdgeInsets.all(12.0), child: Acrylic(
                    elevation: 10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  )))
        ],
      )
    ]));
  }
}

class _AcrylicChildren extends StatelessWidget {
  const _AcrylicChildren();

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        height: 200,
        width: 100,
        color: Colors.blue,
      ),
      Align(
        alignment: AlignmentDirectional.center,
        child: Container(
          height: 152,
          width: 152,
          color: Colors.deepPurple,
        ),
      ),
      Align(
        alignment: AlignmentDirectional.bottomEnd,
        child: Container(
          height: 100,
          width: 80,
          color: Colors.yellow,
        ),
      ),
    ]);
  }
}
