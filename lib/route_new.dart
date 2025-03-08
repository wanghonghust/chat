import 'package:chat/src/pages/chat/index.dart';
import 'package:chat/src/pages/home/index.dart';
import 'package:chat/src/pages/settings/settings_view.dart';
import 'package:chat/src/pages/test/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GoRouter router = GoRouter(
  routes: routes,
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
);

List<GoRoute> routes = [
  GoRoute(
    path: '/',
    builder: (context, state) => HomePage(),
  ),
  GoRoute(
    path: '/chat',
    builder: (context, state) => ChatPage(
      arguments: state.extra,
    ),
  ),
  GoRoute(
    path: '/settings',
    builder: (context, state) => SettingsPage(),
  ),
  GoRoute(
    path: '/test',
    builder: (context, state) => TesPage(),
  ),
];
