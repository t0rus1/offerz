import 'package:flutter/material.dart';

final ThemeData companyThemeData = new ThemeData(
  brightness: Brightness.light,
  primarySwatch: AppThemeColors.main,
  primaryColor: AppThemeColors.main[600],
  primaryColorBrightness: Brightness.light,
  accentColor: AppThemeColors.main[500],
  accentColorBrightness: Brightness.light,
  fontFamily: 'Poppins',
);

// see this website: http://mcg.mbitson.com/ for palette generation
class AppThemeColors {
  AppThemeColors._(); // this basically makes it so you can instantiate this class

  static const MaterialColor main =
      const MaterialColor(0xffdc5e5e, // this is a REDish palette
          const <int, Color>{
        50: const Color(0xfffbeded), //lightest
        100: const Color(0xfff6d1d1),
        200: const Color(0xfff0b3b3),
        300: const Color(0xffe99494),
        400: const Color(0xffe57d7d),
        500: const Color(0xffe06666), //accent
        600: const Color(0xffdc5e5e), //primary
        700: const Color(0xffd85353),
        800: const Color(0xffd34949),
        900: const Color(0xffcb3838) //darkest
      });

  //semi transparent panels with text
  static const Color textBackground = const Color.fromARGB(50, 71, 150, 236);
  static const Color textBackgroundMoreOpaque =
      const Color.fromARGB(128, 71, 150, 236);

  static const Color textForegroundDark = Colors.black87;
  static const Color textForegroundLight = Colors.white70;
}

class AppThemeText {
  AppThemeText._();

  static const TextStyle norm10 = const TextStyle(
      fontSize: 10.0,
      fontWeight: FontWeight.normal,
      color: AppThemeColors.textForegroundDark);

  static const TextStyle norm12 = const TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: AppThemeColors.textForegroundDark);

  static const TextStyle norm14 = const TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: AppThemeColors.textForegroundDark);

  static const TextStyle light14 = const TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w300,
      color: AppThemeColors.textForegroundDark);

  static const TextStyle informOK14 = const TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle warn14 = const TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: Colors.amber,
  );

  static const TextStyle informOK20 = const TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle itemPrice14 = const TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.w800, color: Colors.redAccent);

  static const TextStyle itemPrice20 = const TextStyle(
      fontSize: 20.0, fontWeight: FontWeight.w800, color: Colors.redAccent);

  static const TextStyle btn20 = const TextStyle(
      fontSize: 20.0, fontWeight: FontWeight.w600, color: Colors.white70);
}
