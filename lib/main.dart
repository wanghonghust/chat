import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chat/src/pages/settings/controller.dart';
import 'package:chat/src/pages/settings/theme.dart';
import 'package:chat/src/stack/stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!Platform.isAndroid && !Platform.isIOS) {
    await Window.initialize();
    Window.enableShadow();
  }

  if (Platform.isWindows) {
    await Window.hideWindowControls();
  }
  runApp(ChangeNotifierProvider(
      create: (context) {
        return ThemeNotifier(lightTheme, context, ThemeMode.system);
      },
      child: MyApp()));
  if (Platform.isWindows) {
    doWhenWindowReady(() {
      appWindow
        ..minSize = Size(250, 360)
        ..size = Size(720, 540)
        ..alignment = Alignment.center
        ..show();
    });
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, themeNotifier, child) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeNotifier.currentTheme,
        darkTheme: darkTheme,
        themeMode: themeNotifier.themeMode,
        home: AppStack(),
      );
    });
  }
}
