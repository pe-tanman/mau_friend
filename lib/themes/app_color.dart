import 'package:flutter/material.dart';

class AppColors {
  static final accentColor = Color.fromARGB(255, 221, 168, 83);
  static const themeColor = Color.fromARGB(255, 24, 59, 78);
  static const backgroundColor = Color.fromARGB(255, 243, 243, 224);
  static const scaffoldBackgroundColor = Colors.white;

  //dark theme
  static final darkAccentColor = Color.fromARGB(255, 255, 193, 94);

  static const darkThemeColor = Color(0xFFF3F3E0);
  static const darkBackgroundColor = Color.fromARGB(255, 35, 35, 35);
  static const darkScaffoldBackgroundColor = Color.fromARGB(255, 30, 30, 30);
  //text color
  static const darkText1 = Colors.black;
  static const lightText1 = Colors.white;
  static const lightText2 = darkThemeColor;
  static final linkTextColor = Colors.blue.shade900;
  static MaterialColor primarySwatch =
      const MaterialColor(0xFF183B4E, <int, Color>{
        50: Color(0xFFE6EBEF),
        100: Color(0xFFBFCFD9),
        200: Color(0xFF94B0C1),
        300: Color(0xFF678FA7),
        400: Color(0xFF457493),
        500: Color(0xFF183B4E),
        600: Color(0xFF153546),
        700: Color(0xFF112C3B),
        800: Color(0xFF0E2331),
        900: Color(0xFF081622),
        950: Color(0xFF050F19),
      });
  //
}
