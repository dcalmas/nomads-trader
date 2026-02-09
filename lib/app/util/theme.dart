import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const typeTheme = Typography.whiteMountainView;

class ThemeProvider {
  static const appColor = Color.fromRGBO(255, 194, 36, 1);
  static const secondaryAppColor = Color.fromARGB(255, 35, 74, 214);
  static const whiteColor = Colors.white;
  static const blackColor = Color(0xFF000000);
  static const greyColor = Colors.grey;
  static const backgroundColor = Color(0xFFF3F3F3);
  static const orangeColor = Color(0xFFFF9900);
  static const greenColor = Color(0xFF32CD32);
  static const redColor = Color(0xFFFF0000);
  static const transparent = Color.fromARGB(0, 0, 0, 0);
  static final titleStyle = GoogleFonts.montserrat(
      fontWeight: FontWeight.bold, fontSize: 14, color: ThemeProvider.whiteColor);
}

TextTheme txtTheme = GoogleFonts.montserratTextTheme(Typography.whiteMountainView).copyWith(
  bodyLarge: GoogleFonts.montserrat(fontSize: 16),
  bodyMedium: GoogleFonts.montserrat(fontSize: 14),
  displayLarge: GoogleFonts.montserrat(fontSize: 32),
  displayMedium: GoogleFonts.montserrat(fontSize: 28),
  displaySmall: GoogleFonts.montserrat(fontSize: 24),
  headlineMedium: GoogleFonts.montserrat(fontSize: 21),
  headlineSmall: GoogleFonts.montserrat(fontSize: 18),
  titleLarge: GoogleFonts.montserrat(fontSize: 16),
  titleMedium: GoogleFonts.montserrat(fontSize: 24),
  titleSmall: GoogleFonts.montserrat(fontSize: 21),
);

ThemeData light = ThemeData(
    fontFamily: GoogleFonts.montserrat().fontFamily,
    primaryColor: ThemeProvider.appColor,
    secondaryHeaderColor: ThemeProvider.secondaryAppColor,
    disabledColor: const Color(0xFFBABFC4),
    brightness: Brightness.light,
    hintColor: const Color(0xFF9F9F9F),
    cardColor: ThemeProvider.appColor,
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: ThemeProvider.appColor)),
    textTheme: txtTheme, colorScheme: const ColorScheme.light(
        primary: ThemeProvider.appColor,
        secondary: ThemeProvider.secondaryAppColor).copyWith(surface: const Color(0xFFF3F3F3)).copyWith(error: const Color(0xFFE84D4F)));

ThemeData dark = ThemeData(
    fontFamily: GoogleFonts.montserrat().fontFamily,
    primaryColor: ThemeProvider.blackColor,
    secondaryHeaderColor: const Color(0xFF009f67),
    disabledColor: const Color(0xffa2a7ad),
    brightness: Brightness.dark,
    hintColor: const Color(0xFFbebebe),
    cardColor: Colors.black,
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: ThemeProvider.blackColor)),
    textTheme: txtTheme, colorScheme: const ColorScheme.dark(
        primary: ThemeProvider.blackColor, secondary: Color(0xFFffbd5c)).copyWith(surface: const Color(0xFF343636)).copyWith(error: const Color(0xFFdd3135)));
