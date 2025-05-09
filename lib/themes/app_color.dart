import 'package:flutter/material.dart';

class AppColors {
  static MaterialColor congressBlueSwatch = const MaterialColor(
    0xFF3174C6,
    <int, Color>{
      50: Color(0xFFF2F6FD),
      100: Color(0xFFE5ECF9),
      200: Color(0xFFC5D8F2),
      300: Color(0xFF92B8E7),
      400: Color(0xFF5792D9),
      500: Color(0xFF3174C6),
      600: Color(0xFF225AA7),
      700: Color(0xFF1F4E93),
      800: Color(0xFF1B3E71),
      900: Color(0xFF1C365E),
      950: Color(0xFF13233E),
    },
  );
  static MaterialColor orangeSwatch = const MaterialColor(
    0xFFF26A26,
    <int, Color>{
      50: Color(0xFFFEF6EE),
      100: Color(0xFFFEEAD6),
      200: Color(0xFFFBD1AD),
      300: Color(0xFFF8B079),
      400: Color(0xFFF58542),
      500: Color(0xFFF26A26),
      600: Color(0xFFE34A13),
      700: Color(0xFFBC3712),
      800: Color(0xFF962C16),
      900: Color(0xFF782816),
      950: Color(0xFF411109),
    },
  );
  static final themeColor = congressBlueSwatch.shade700;
  static final secondaryColor = congressBlueSwatch.shade500;
  static final themeColorPrimary = congressBlueSwatch;
  static const accentTextColor = Color.fromARGB(255, 237, 107, 90);
  static const accentColor = Color.fromRGBO(242, 106, 38, 1);
  static const scaffoldBackgroundColor = Colors.white;
  //text color
  static const darkText1 = Colors.black;
  static const lightText1 = Colors.white;
  static final indicatorColorHigh = orangeSwatch.shade400;
  static final indicatorColorMedium = orangeSwatch.shade300;
  static final indicatorColorLow = orangeSwatch.shade200;
  //
}
