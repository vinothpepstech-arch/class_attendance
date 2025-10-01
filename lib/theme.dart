import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primarySeedColor = Color(0xFF6750A4);

class AppTheme {
  static final TextTheme _appTextTheme = TextTheme(
    displayLarge: GoogleFonts.robotoFlex(fontSize: 57, fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.robotoFlex(fontSize: 45, fontWeight: FontWeight.bold),
    displaySmall: GoogleFonts.robotoFlex(fontSize: 36, fontWeight: FontWeight.bold),
    headlineLarge: GoogleFonts.robotoFlex(fontSize: 32, fontWeight: FontWeight.w600),
    headlineMedium: GoogleFonts.robotoFlex(fontSize: 28, fontWeight: FontWeight.w600),
    headlineSmall: GoogleFonts.robotoFlex(fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
    titleSmall: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.normal),
    bodyMedium: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.normal),
    bodySmall: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.normal),
    labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
    labelSmall: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: Brightness.light,
    ),
    textTheme: _appTextTheme,
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: primarySeedColor,
      unselectedItemColor: Colors.grey[600],
      showUnselectedLabels: true,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: Brightness.dark,
    ),
    textTheme: _appTextTheme,
    cardTheme: CardTheme(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: Colors.deepPurple.shade200,
      unselectedItemColor: Colors.grey[400],
      showUnselectedLabels: true,
    ),
  );
}
