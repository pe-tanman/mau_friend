import 'package:flutter/material.dart';
import 'app_color.dart';

ThemeData appTheme() => ThemeData(
  cardColor: AppColors.darkThemeColor,
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
    style: ElevatedButton.styleFrom(backgroundColor: AppColors.themeColor, foregroundColor: Colors.white,
  ),),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: AppColors.themeColor),
      foregroundColor: Colors.black,
    ),

  ),
  dividerTheme: DividerThemeData(
    color: AppColors.themeColor,
    thickness: 1,
  ),
  scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
  colorScheme: ColorScheme.light(
    primary: AppColors.themeColor,
  ),

);

ThemeData darkTheme() => ThemeData(
  cardColor: AppColors.darkBackgroundColor,
  textTheme: const TextTheme(
    titleMedium: TextStyle(
      color: AppColors.darkThemeColor,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(fontSize: 24, ),
    headlineSmall: TextStyle(fontSize: 20),
    bodyLarge: TextStyle(fontSize: 16),
    labelMedium: TextStyle(color: AppColors.darkThemeColor, fontSize: 20, fontWeight: FontWeight.bold),
  ),
  dividerTheme: DividerThemeData(
    color: AppColors.darkThemeColor,
    thickness: 1,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkThemeColor, foregroundColor: Colors.black),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: AppColors.darkThemeColor),
      foregroundColor: AppColors.darkThemeColor,

    ),
  ),

  brightness: Brightness.dark, // テーマの明るさをダークに設定。
  colorScheme: ColorScheme.dark(
    primary: const Color.fromARGB(255, 228, 228, 195), 

  ),
);
