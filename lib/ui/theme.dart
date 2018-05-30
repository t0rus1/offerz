import 'package:flutter/material.dart';

final ThemeData companyThemeData = new ThemeData(
  brightness: Brightness.light,
  primarySwatch: AppThemeColors.main,
  primaryColor: AppThemeColors.main[500],
  primaryColorBrightness: Brightness.light,
  accentColor: AppThemeColors.main[600],
  accentColorBrightness: Brightness.light,
  fontFamily: 'Poppins',
);


// see this website: http://mcg.mbitson.com/ for palette generation
class AppThemeColors {

  AppThemeColors._(); // this basically makes it so you can instantiate this class

  static const MaterialColor main = const MaterialColor(
    0xffdc5e5e,  // this is a REDish palette
    const <int,Color>{  
      50: const Color(0xfffbeded),
      100: const Color(0xfff6d1d1),
      200: const Color(0xfff0b3b3),
      300: const Color(0xffe99494),
      400: const Color(0xffe57d7d),
      500: const Color(0xffe06666),
      600: const Color(0xffdc5e5e),
      700: const Color(0xffd85353),
      800: const Color(0xffd34949),
      900: const Color(0xffcb3838)
    }
  );


}