import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chat/route.dart';
import 'package:chat/src/pages/not_found/index.dart';
import 'package:chat/src/pages/settings/controller.dart';
import 'package:chat/src/pages/settings/settings_view.dart';
import 'package:chat/src/stack/slider_menu.dart';
import 'package:chat/src/stack/window_buttons.dart';
import 'package:chat/widgets/sidebar/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/macos/macos_blur_view_state.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:provider/provider.dart';

const String initialRoute = '/';

class AppStack extends StatefulWidget {
  const AppStack({super.key});

  @override
  State<AppStack> createState() => _AppStackState();
}

class _AppStackState extends State<AppStack> with RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<NavigatorState> _localNavigatorKey =
      GlobalKey<NavigatorState>();
  WindowEffect effect = WindowEffect.mica;
  Color color = Colors.transparent;
  InterfaceBrightness brightness = InterfaceBrightness.dark;
  MacOSBlurViewState macOSBlurViewState =
      MacOSBlurViewState.followsWindowActiveState;

  final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();
  bool? canPop = false;
  Key? activeKey;
  @override
  void initState() {
    super.initState();
    setWindowEffect(effect, false);
    activeKey = ValueKey(initialRoute);
  }

  void updateUi() {
    setState(() {});
  }

  void setWindowEffect(WindowEffect? value, bool dark) {
    Window.setEffect(
      effect: value!,
      color: color,
      dark: dark,
    );
    setState(() => effect = value);
  }

  void _updateCanPop() {
    final bool? _canPop = _localNavigatorKey.currentState?.canPop();
    String? routeName = getCurrentRouteName(_localNavigatorKey);
    setState(() {
      activeKey = ValueKey(routeName!);
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
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    print('MyPage was pushed');
    // _updateCanPop();
  }

  @override
  void didPopNext() {
    print('MyPage was popped next');
    _updateCanPop();
  }

  @override
  void didPop() {
    print('MyPage was popped');
    _updateCanPop();
  }

  @override
  void didPushNext() {
    print('MyPage pushed next');
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
    Widget sideMenu = SliderMenu(
      items: items,
      activeKey: activeKey,
      navigatorKey: _localNavigatorKey,
    );
    bool showDrawer = isDesktop && isSmallScreen || !isDesktop;
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      key: _scaffoldKey,
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
              backgroundColor: themeNotifier.isDarkMode
                  ? const Color.fromARGB(61, 0, 0, 0)
                  : const Color.fromARGB(61, 255, 255, 255),
              width: 200,
              shape: RoundedRectangleBorder(),
              child: sideMenu,
            )
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
        WidgetBuilder builder;
        builder = routes[settings.name]?.builder ?? (_) => NotFoundPage();
        return MaterialPageRoute(
          maintainState: true,
          builder: (context) {
            routeObserver.subscribe(this, ModalRoute.of(context)!);
            return builder(context);
          },
          settings: settings,
        );
      },
    );
  }
}
