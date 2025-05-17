import 'package:flutter/material.dart';
import 'app_color.dart';

ThemeData appTheme() => ThemeData(
  appBarTheme: AppBarTheme(backgroundColor: AppColors.scaffoldBackgroundColor),
  useMaterial3: true,
  textTheme: const TextTheme(
    titleMedium: TextStyle(
      color: AppColors.themeColor,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(fontSize: 24),
    headlineSmall: TextStyle(fontSize: 20),
    bodyLarge: TextStyle(fontSize: 16),
    labelMedium: TextStyle(color: AppColors.themeColor, fontSize: 20, fontWeight: FontWeight.bold)
  ),
  snackBarTheme: const SnackBarThemeData(showCloseIcon: true),
  cardTheme: CardTheme(
color: AppColors.backgroundColor,
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
  ),
  dividerTheme: const DividerThemeData(color: Colors.black),
  dividerColor: Colors.brown.shade100,
  dialogTheme: const DialogTheme(
    backgroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontSize: 22,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: const TextStyle(fontSize: 14),
    hintStyle: const TextStyle(fontSize: 14),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.circular(5),
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(foregroundColor: AppColors.themeColor),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: Colors.grey),
      foregroundColor: Colors.black,
    ),
  ),
  scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
  colorScheme: ColorScheme.light(
    primary: AppColors.themeColor,
  ),
);

ThemeData darkTheme() => ThemeData(
  cardTheme: CardTheme(
    color: AppColors.darkBackgroundColor,
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
  ),
  textTheme: const TextTheme(
    titleMedium: TextStyle(
      color: AppColors.darkThemeColor,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(fontSize: 24),
    headlineSmall: TextStyle(fontSize: 20),
    bodyLarge: TextStyle(fontSize: 16),
    labelMedium: TextStyle(color: AppColors.darkThemeColor, fontSize: 20, fontWeight: FontWeight.bold),
  ),


  brightness: Brightness.dark, // テーマの明るさをダークに設定。
  colorScheme: ColorScheme.dark(
    primary: const Color.fromARGB(255, 228, 228, 195), 
  ),
);
