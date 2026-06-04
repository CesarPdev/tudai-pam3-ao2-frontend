import 'package:flutter/material.dart';

class AppTheme {
  static const Color whatsappGreen = Color(0xFF25D366);
  static const Color whatsappDarkGreen = Color(0xFF075E54);
  static const Color whatsappTeal = Color(0xFF128C7E);
  static const Color whatsappBackground = Color(0xFFECE5DD);
  static const Color whatsappBubbleSent = Color(0xFFDCF8C6);

  static ThemeData theme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: whatsappBackground,
    colorScheme: const ColorScheme.light(
      primary: whatsappGreen,
      secondary: whatsappTeal,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: whatsappDarkGreen,
      centerTitle: true,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: whatsappGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: whatsappGreen, width: 1.4),
        borderRadius: BorderRadius.circular(6),
      ),
      labelStyle: const TextStyle(color: Colors.black54, fontSize: 13),
      hintStyle: const TextStyle(color: Colors.black38),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
  );
}
