import 'package:flutter/material.dart';
import 'app_color.dart';

ThemeData appTheme() => ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.scaffoldBackgroundColor
      ),
      useMaterial3: true,
      textTheme: const TextTheme(
        titleMedium: TextStyle(
          color: AppColors.themeColor,
          fontSize: 32,
          fontWeight: FontWeight.bold
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
        )
      ),
      snackBarTheme: const SnackBarThemeData(showCloseIcon: true),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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
        labelStyle: const TextStyle(
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          fontSize: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style:
              ElevatedButton.styleFrom(foregroundColor: AppColors.themeColor)),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey),
          foregroundColor: Colors.black,
        ),
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
      colorScheme:
          ColorScheme.fromSwatch(primarySwatch: AppColors.primarySwatch)
              .copyWith(secondary: AppColors.accentColor),
    );

Widget primaryButton(String text, Function onPressed) {
  return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.themeColor),
      onPressed: () {
        onPressed();
      },
      child:  SizedBox(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 13, horizontal: 60),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      )));
}Widget secondaryButton(String text, Function onPressed) {
  return OutlinedButton(
      style: OutlinedButton.styleFrom(foregroundColor: AppColors.themeColor),
      onPressed: () {
        onPressed();
      },
      child:  SizedBox(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 13, horizontal: 60),
        child: Text(
          text,
          style: TextStyle(color: AppColors.themeColor, fontSize: 20),
        ),
      )));
}

