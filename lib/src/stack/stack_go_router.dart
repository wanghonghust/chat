import 'dart:io';
import 'dart:ui';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chat/route_new.dart';
import 'package:chat/src/data_provider/index.dart';
import 'package:chat/src/database/models/conversation.dart';
import 'package:chat/src/pages/not_found/index.dart';
import 'package:chat/src/pages/settings/controller.dart';
import 'package:chat/src/stack/blur_container.dart';
import 'package:chat/src/stack/slider_menu.dart';
import 'package:chat/src/stack/window_buttons.dart';
import 'package:chat/widgets/sidebar/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/macos/macos_blur_view_state.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

String initialRoute = "/";

class AppStack extends StatefulWidget {
  const AppStack({super.key});

  @override
  State<AppStack> createState() => _AppStackState();
}

class _AppStackState extends State<AppStack> with RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<NavigatorState> _localNavigatorKey =
      GlobalKey<NavigatorState>();
  MacOSBlurViewState macOSBlurViewState =
      MacOSBlurViewState.followsWindowActiveState;

  final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();
  AppDataProvider? dataProvider;
  ThemeNotifier? themeNotifier;
  bool? canPop = false;
  @override
  void initState() {
    super.initState();
    themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
  }

  void updateUi() {
    setState(() {});
  }

  void _updateCanPop() {
    final bool? _canPop = _localNavigatorKey.currentState?.canPop();
    String? routeName = getCurrentRouteName(_localNavigatorKey);
    setState(() {
      if (routeName != null) {
        dataProvider!.setCurrentRoute(routeName);
      }
    });
    if (_canPop != canPop && mounted) {
      setState(() {
        canPop = _canPop;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    dataProvider = Provider.of<AppDataProvider>(context, listen: true);
    themeNotifier!.init();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {}

  @override
  void didPopNext() {
    _updateCanPop();
  }

  @override
  void didPop() {
    _updateCanPop();
  }

  @override
  void didPushNext() {
    _updateCanPop();
  }

  void _onHistoryDelete(Conversation conversation) async {
    var res = await Conversation.getConversations();
    dataProvider!.setConversations(res);
    String route = "/chat:${conversation.id}:${conversation.title}";
    if (route == dataProvider!.currentRoute) {
      _localNavigatorKey.currentState!.pop();
    }
    final snackBar = SnackBar(
      content: Text('删除对话 ${conversation.title} 成功'),
      action: SnackBarAction(
        label: '撤销',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    List<SidebarItem> items = [];
    routes.forEach((item) {
      items.add(SidebarItem(
        key: ValueKey(item.hashCode),
        title: Text(item.name??""),
        icon: Icon(Icons.home),
        route: item.path,
      ));
    });
    // print(dataProvider!.currentRoute);
    Widget sideMenu = SliderMenu(
      items: items,
      histories: dataProvider!.conversations,
      activeKey: ValueKey(dataProvider!.currentRoute),
      navigatorKey: _localNavigatorKey,
      onHistoryDelete: _onHistoryDelete,
    );
    bool showDrawer = isDesktop && isSmallScreen || !isDesktop;

    return Scaffold(
      key: _scaffoldKey,
      appBar: isDesktop ? null : AppBar(),
      body: Column(children: [
        if (isDesktop)
          WindowTitleBarBox(
            child: Row(
              children: [
                if (canPop != null && canPop!)
                  InkWell(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: const Icon(
                        Icons.arrow_back_outlined,
                      ),
                    ),
                    onTap: () {
                      _localNavigatorKey.currentState!.pop();
                    },
                  ),
                if (showDrawer)
                  InkWell(
                    child: Padding(
                        padding: EdgeInsets.all(5),
                        child: const Icon(Icons.menu_rounded)),
                    onTap: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                if (isDesktop) Expanded(child: MoveWindow()),
                if (isDesktop) const WindowButtons()
              ],
            ),
          ),
        Expanded(
            child: Row(children: [
          AnimatedContainer(
            width: !showDrawer ? 200 : 0,
            duration: Duration(milliseconds: 300),
            child: !showDrawer ? sideMenu : null,
          ),
          Expanded(child: _buildMain(context, _localNavigatorKey))
        ]))
      ]),
      drawer: showDrawer
          ? Drawer(
              backgroundColor: Colors.transparent,
              width: 200,
              shape: RoundedRectangleBorder(),
              child: BlurryContainer(
                padding: EdgeInsets.all(0),
                color: themeNotifier!.isDarkMode
                    ? const Color.fromARGB(255, 29, 31, 45).withAlpha(200)
                    : Colors.white.withAlpha(250),
                child: Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: sideMenu,
                ),
              ))
          : null,
    );
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

  Widget _buildMain(BuildContext context1, Key key) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}
