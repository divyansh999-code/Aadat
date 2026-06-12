import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InkTheme {
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color lightGray = Color(0xFFE8E8E8);
  static const Color midGray = Color(0xFF888888);
  static const Color darkGray = Color(0xFF333333);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: black,
        onPrimary: white,
        secondary: black,
        onSecondary: white,
        surface: white,
        onSurface: black,
        error: black,
        onError: white,
        outline: black,
      ),
      scaffoldBackgroundColor: white,
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: black,
          letterSpacing: 1.5,
        ),
      ),
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.dmSans(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: black,
        ),
        displayMedium: GoogleFonts.dmSans(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: black,
        ),
        headlineLarge: GoogleFonts.dmSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: black,
        ),
        headlineMedium: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: black,
        ),
        titleLarge: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: black,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: black,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: black,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: darkGray,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: midGray,
          letterSpacing: 0.5,
        ),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: black,
          letterSpacing: 1.0,
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: midGray,
          letterSpacing: 0.8,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: lightGray,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: lightGray, width: 1),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: lightGray, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: black, width: 1.5),
        ),
        hintStyle: GoogleFonts.dmSans(
          color: midGray,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: black,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: black,
          textStyle: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return white;
          return midGray;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return black;
          return lightGray;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: white,
        onPrimary: black,
        secondary: white,
        onSecondary: black,
        surface: black,
        onSurface: white,
        error: white,
        onError: black,
        outline: white,
      ),
      scaffoldBackgroundColor: black,
      appBarTheme: AppBarTheme(
        backgroundColor: black,
        foregroundColor: white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: white,
          letterSpacing: 1.5,
        ),
      ),
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.dmSans(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: white,
        ),
        displayMedium: GoogleFonts.dmSans(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: white,
        ),
        headlineLarge: GoogleFonts.dmSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: white,
        ),
        headlineMedium: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: white,
        ),
        titleLarge: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: white,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: white,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: white,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: lightGray,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: midGray,
          letterSpacing: 0.5,
        ),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: white,
          letterSpacing: 1.0,
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: midGray,
          letterSpacing: 0.8,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkGray,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: darkGray, width: 1),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: darkGray, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: white, width: 1.5),
        ),
        hintStyle: GoogleFonts.dmSans(
          color: midGray,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: white,
          foregroundColor: black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: white,
          textStyle: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return black;
          return midGray;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return white;
          return darkGray;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
