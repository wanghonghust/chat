import 'dart:io';
import 'dart:math';
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
import 'package:chat/src/types/chat_param.dart';
import 'package:chat/widgets/sidebar/index.dart';
import 'package:dropdown_search/dropdown_search.dart';
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
    final bool? _canPop = dataProvider!.navigatorKey.currentState?.canPop();
    Route<dynamic>? route = getCurrentRoute(dataProvider!.navigatorKey);
    setState(() {
      if (route != null && route.settings.name != null) {
        ChatParam? param = route.settings.arguments as ChatParam?;
        if (param != null) {
          dataProvider!
              .setCurrentRoute('${route.settings.name!}:${param.conversation.id}');
        } else {
          dataProvider!.setCurrentRoute(route.settings.name!);
        }
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
      dataProvider!.navigatorKey.currentState!.pop();
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
    routes.forEach((key, value) {
      if(key == '/chat'){
        return;
      }
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
      navigatorKey: dataProvider!.navigatorKey,
      onHistoryDelete: _onHistoryDelete,
    );
    bool showDrawer = isDesktop && isSmallScreen || !isDesktop;

    return Scaffold(
      key: _scaffoldKey,
      appBar: isDesktop ? null : AppBar(),
      body: Column(children: [
        if (isDesktop)
          Container(
            alignment: Alignment.topCenter,
            height: 45,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (canPop != null && canPop!)
                  InkWell(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: const Icon(
                        Icons.navigate_before,
                      ),
                    ),
                    onTap: () {
                      dataProvider!.navigatorKey.currentState!.pop();
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
                if (isDesktop)
                  Expanded(
                      child: MoveWindow(
                          child: Center(
                    child: Container(
                      padding: EdgeInsets.all(5),
                      width: 300,
                      child: DropDownSearch(),
                    ),
                  ))),
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
          Expanded(child: _buildMain(context, dataProvider!.navigatorKey))
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

  Route<dynamic>? getCurrentRoute(GlobalKey<NavigatorState> navigatorKey) {
    Route<dynamic>? currentRoute;
    navigatorKey.currentState?.popUntil((route) {
      // 这里会依次遍历所有路由，最终 currentRouteName 为最后一次赋值，也就是栈顶路由的 name
      currentRoute = route;
      return true;
    });
    return currentRoute;
  }

  Widget _buildMain(BuildContext context1, Key key) {
    return Navigator(
      key: key,
      initialRoute: initialRoute,
      observers: [routeObserver],
      onGenerateRoute: (RouteSettings settings) {
        CustomBuilder builder;
        builder = routes[settings.name]?.builder ?? (_, __) => NotFoundPage();
        return PageRouteBuilder(
          maintainState: true,
          pageBuilder: (context, animation, secondaryAnimation) {
            routeObserver.subscribe(this, ModalRoute.of(context)!);
            return builder(context, settings.arguments);
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.0;
            const end = 1.0;
            const curve = Curves.fastOutSlowIn;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var fadeTween = Tween(begin: begin, end: end);

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: ScaleTransition(
                scale: animation.drive(tween),
                child: child,
              ),
            );
          },
          settings: settings,
        );
      },
    );
  }
}

class DropDownSearch extends StatelessWidget {
  const DropDownSearch({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<(String, Color)>(
      clickProps: ClickProps(borderRadius: BorderRadius.circular(20)),
      mode: Mode.custom,
      items: (f, cs) => [
        ("Red", Colors.red),
        ("Black", Colors.black),
        ("Yellow", Colors.yellow),
        ('Blue', Colors.blue),
      ],
      compareFn: (item1, item2) => item1.$1 == item2.$2,
      popupProps: PopupProps.menu(
        menuProps: MenuProps(align: MenuAlign.bottomCenter),
        fit: FlexFit.loose,
        itemBuilder: (context, item, isDisabled, isSelected) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(item.$1, style: TextStyle(color: item.$2, fontSize: 16)),
        ),
      ),
      dropdownBuilder: (ctx, selectedItem) =>
          ElevatedButton(onPressed: null, child: Icon(Icons.search)),
    );
  }
}
