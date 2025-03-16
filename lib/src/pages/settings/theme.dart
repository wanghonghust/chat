import 'dart:io';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
var lightTheme = FlexThemeData.light(
        scheme: FlexScheme.orangeM3,
        scaffoldBackground: isDesktop ? Colors.transparent : null,
        subThemesData: const FlexSubThemesData(
            popupMenuRadius: 10,
            drawerBackgroundSchemeColor: SchemeColor.transparent,
            interactionEffects: true,
            tintedDisabledControls: true,
            useM2StyleDividerInM3: true,
            inputDecoratorIsFilled: true,
            inputDecoratorBorderType: FlexInputBorderType.outline,
            alignedDropdown: true,
            appBarCenterTitle: false,
            bottomNavigationBarMutedUnselectedLabel: true,
            bottomNavigationBarMutedUnselectedIcon: true,
            navigationBarMutedUnselectedLabel: true,
            navigationBarMutedUnselectedIcon: true,
            navigationBarIndicatorOpacity: 0.03,
            navigationBarIndicatorRadius: 8.0,
            navigationBarBackgroundSchemeColor: SchemeColor.transparent,
            navigationBarHeight: 60.0,
            adaptiveRemoveNavigationBarTint: FlexAdaptive.all(),
            navigationRailUseIndicator: true,
            navigationRailLabelType: NavigationRailLabelType.all,
            cardElevation: 0,
            searchBarElevation: 0.0,
            searchViewElevation: 0.0,
            searchBarRadius: 9.0,
            searchViewRadius: 9.0,
            bottomNavigationBarElevation: 10),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true))
    .copyWith(
  scrollbarTheme: ScrollbarThemeData(
    radius: Radius.circular(3),
    thickness: WidgetStateProperty.all(6),
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.dragged)) {
        return Colors.orange.shade700;
      }
      return Colors.black.withAlpha(100);
    }),
  ),
);
var darkTheme = FlexThemeData.dark(
        scaffoldBackground: isDesktop ? Colors.transparent : null,
        scheme: FlexScheme.orangeM3,
        subThemesData: const FlexSubThemesData(
            popupMenuRadius: 10,
            drawerBackgroundSchemeColor: SchemeColor.transparent,
            interactionEffects: true,
            tintedDisabledControls: true,
            blendOnColors: true,
            useM2StyleDividerInM3: true,
            inputDecoratorIsFilled: true,
            inputDecoratorBorderType: FlexInputBorderType.outline,
            alignedDropdown: true,
            appBarCenterTitle: false,
            bottomNavigationBarMutedUnselectedLabel: true,
            bottomNavigationBarMutedUnselectedIcon: true,
            navigationBarMutedUnselectedLabel: true,
            navigationBarMutedUnselectedIcon: true,
            navigationBarIndicatorOpacity: 0.03,
            navigationBarIndicatorRadius: 8.0,
            navigationBarBackgroundSchemeColor: SchemeColor.transparent,
            navigationBarHeight: 60.0,
            navigationRailUseIndicator: true,
            navigationRailLabelType: NavigationRailLabelType.all,
            cardElevation: 0,
            searchBarElevation: 0.0,
            searchViewElevation: 0.0,
            searchBarRadius: 9.0,
            searchViewRadius: 9.0,
            bottomNavigationBarElevation: 10),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true))
    .copyWith(
  scrollbarTheme: ScrollbarThemeData(
    radius: Radius.circular(3),
    thickness: WidgetStateProperty.all(6),
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.dragged)) {
        return Colors.orange.shade700;
      }
      return Colors.white.withAlpha(100);
    }),
  ),
);
