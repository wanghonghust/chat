import 'dart:io';
import 'dart:ui';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chat/route.dart';
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

  @override
  Widget build(BuildContext context) {
    bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    List<SidebarItem> items = [];
    routes.forEach((key, value) {
      items.add(SidebarItem(
        key: ValueKey(key),
        title: Text(value.title),
        icon: Icon(value.icon),
        route: value.route,
      ));
    });
    // print(dataProvider!.currentRoute);
    Widget sideMenu = SliderMenu(
      items: items,
      histories: dataProvider!.conversations,
      activeKey: ValueKey(dataProvider!.currentRoute),
      navigatorKey: _localNavigatorKey,
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
    return Navigator(
      key: key,
      initialRoute: initialRoute,
      observers: [routeObserver],
      onGenerateRoute: (RouteSettings settings) {
        CustomBuilder builder;
        List<String> res = settings.name!.split(":");
        String? route = res.first;
        dynamic arguments = res.length == 3
            ? Conversation(
                id: int.parse(res[1]),
                title: res[2],
              )
            : null;
        // route = route == "/" ? "/chat" : route;
        builder = routes[route]?.builder ?? (_, __) => NotFoundPage();

        return PageRouteBuilder(
          maintainState: true,
          pageBuilder: (context, animation, secondaryAnimation) {
            routeObserver.subscribe(this, ModalRoute.of(context)!);
            return builder(context, arguments);
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          settings: settings,
        );
      },
    );
  }
}
