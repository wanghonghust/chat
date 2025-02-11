import 'package:chat/src/pages/chat/index.dart';
import 'package:chat/src/pages/home/index.dart';
import 'package:chat/src/pages/settings/settings_view.dart';
import 'package:flutter/material.dart';

typedef CustomBuilder = Widget Function(BuildContext context,dynamic arguments);

class RouteItem {
  final String title;
  final String route;
  final IconData icon;
  final CustomBuilder builder;
  final Function(BuildContext context)? onTap;

  RouteItem({
    required this.route,
    required this.builder,
    required this.title,
    required this.icon,
    this.onTap,
  });
}

Map<String, RouteItem> routes = {
  '/': RouteItem(
    route: '/',
    title: 'Home',
    icon: Icons.home,
    builder: (context,arguments) => HomePage(),
    onTap: (context) => {
      Navigator.pushNamed(context, '/'),
    },
  ),
  '/chat': RouteItem(
    route: '/chat',
    title: 'Chat',
    icon: Icons.architecture,
    builder: (context,arguments) => ChatPage(arguments: arguments,),
    onTap: (context) => {
      Navigator.pushNamed(context, '/chat'),
    },
  ),
  '/settings': RouteItem(
    route: '/settings',
    title: 'Settings',
    icon: Icons.settings,
    builder: (context,arguments) => SettingsPage(),
    onTap: (context) => {
      Navigator.pushNamed(context, '/settings'),
    },
  ),
};
