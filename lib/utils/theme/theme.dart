import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:homy/utils/theme/custom/appbar_theme.dart';
import 'package:homy/utils/theme/custom/bottom_sheet_them.dart';
import 'package:homy/utils/theme/custom/checkbox_theme.dart';
import 'package:homy/utils/theme/custom/chip_theme.dart';
import 'package:homy/utils/theme/custom/elavated_button_theme.dart';
import 'package:homy/utils/theme/custom/input_decoration.dart';
import 'package:homy/utils/theme/custom/outline_button_them.dart';
import 'package:homy/utils/theme/custom/text_theme.dart';
import '../constants/app_colors.dart';

class MAppTheme {
  MAppTheme._();

  static ThemeMode getThemeMode() {
    String? themeMode = GetStorage().read<String>('theme_mode');
    return _handleThemeMode(themeMode);
  }

  static ThemeMode _handleThemeMode(String? themeMode) {
    switch (themeMode) {
      case 'ThemeMode.light':
        setSystemUIOverlayStyle(true);
        return ThemeMode.light;
      case 'ThemeMode.dark':
        setSystemUIOverlayStyle(false);
        return ThemeMode.dark;
      default:
        // For system and null cases
        final isPlatformDark = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
        setSystemUIOverlayStyle(!isPlatformDark);
        return ThemeMode.system;
    }
  }

  static void setSystemUIOverlayStyle(bool isLight) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
        statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isLight ? Colors.white : Colors.black,
        systemNavigationBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      ),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'NeueMontreal',
    brightness: Brightness.light,
    primaryColor: MColors.primary,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: MColors.backgroundLight,
    ),
    scaffoldBackgroundColor: MColors.backgroundLight,
    textTheme: MTextTheme.lightTheme,
    elevatedButtonTheme: MElevatedButtonTheme.lightElevatedButtonTheme,
    appBarTheme: MAppBarTheme.lightAppBarTheme.copyWith(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    bottomSheetTheme: MBottomSheetTheme.lightAppBarTheme,
    checkboxTheme: MCheckBoxTheme.lightAppBarTheme,
    chipTheme: MChipTheme.lightChipTheme,
    outlinedButtonTheme: MOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      contentPadding: const EdgeInsets.all(15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: MColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: MColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: MColors.primary,
          width: 2,
        ),
      ),
      labelStyle: TextStyle(
        color: MColors.primary.withOpacity(0.8),
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: MColors.primary.withOpacity(0.5),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      prefixIconColor: MColors.primary.withOpacity(0.7),
      suffixIconColor: MColors.primary.withOpacity(0.7),
    ),
    colorScheme: ColorScheme.light(
      primary: MColors.primary,
      secondary: MColors.teritoryColor,
      surface: MColors.surfaceLight,
      background: MColors.backgroundLight,
      error: MColors.error,
      onPrimary: MColors.white,
      onSecondary: MColors.white,
      onSurface: MColors.textPrimary,
      onBackground: MColors.textPrimary,
      onError: MColors.white,
      brightness: Brightness.light,
      tertiary: MColors.teritoryColor,
      onTertiary: MColors.lightTextColor,
      outline: MColors.borderPrimary,
      outlineVariant: MColors.borderSecondary,
    ),
    dividerColor: MColors.borderSecondary,
    dividerTheme: DividerThemeData(
      color: MColors.borderSecondary,
      thickness: 1,
    ),
  );





  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'NeueMontreal',
    // scaffoldBackgroundColor: const Color(0xFF15202B), // Deep blue-gray
    primaryColor: MColors.darkprimary,
  
    scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0), // Full black
    // Card & Dialog Colors
    cardColor: const Color(0xFF1E1E1E), // Slightly lighter than background
        // dialogTheme: DialogThemeData(
        //   backgroundColor: const Color(0xFF1E1E1E),
        // ),
    dialogBackgroundColor: const Color(0xFF1E1E1E),
    bottomSheetTheme: MBottomSheetTheme.darkAppBarTheme,
    appBarTheme: MAppBarTheme.darkAppBarTheme.copyWith(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    // AppBar Theme
    // appBarTheme: const AppBarTheme(
    //   // backgroundColor: Color(0xFF15202B),
    //   backgroundColor: Colors.transparent,
    //   elevation: 0,
    //   systemOverlayStyle: SystemUiOverlayStyle.light,
    // ),
    
    // Color Scheme
    colorScheme: ColorScheme.dark(
      background: const Color.fromARGB(255, 0, 0, 0),
      surface: const Color(0xFF4D5454).withOpacity(0.3),
      primary: MColors.darkprimary.withOpacity(0.9),
      secondary: MColors.secondary.withOpacity(0.9),
      onBackground: Colors.white.withOpacity(0.87),
      onSurface: Colors.white.withOpacity(0.87),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      error: const Color(0xFFFF5252),
      tertiary: MColors.darkprimary.withOpacity(0.7),
      onTertiary: MColors.secondary.withOpacity(0.9),
      outline: Colors.white.withOpacity(0.1),
    ),

    // Text Theme
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white.withOpacity(0.95),
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Colors.white.withOpacity(0.95),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: Colors.white.withOpacity(0.95),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: Colors.white.withOpacity(0.87),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: Colors.white.withOpacity(0.87),
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: Colors.white.withOpacity(0.87),
        fontSize: 14,
      ),
      labelLarge: TextStyle(
        color: Colors.white.withOpacity(0.87),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    inputDecorationTheme: MInputDecorationTheme.darkInputDecorationTheme,

    // Input Decoration Theme
    // inputDecorationTheme: InputDecorationTheme(
    //   filled: true,
    //   fillColor: const Color(0xFF253341),
    //   contentPadding: const EdgeInsets.all(15),
    //   border: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(12),
    //     borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
    //   ),
    //   enabledBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(12),
    //     borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
    //   ),
    //   focusedBorder: OutlineInputBorder(
    //     borderRadius: BorderRadius.circular(12),
    //     borderSide: BorderSide(color: MColors.primary.withOpacity(0.7), width: 2),
    //   ),
    //   labelStyle: TextStyle(
    //     color: Colors.white.withOpacity(0.6),
    //   ),
    //   hintStyle: TextStyle(
    //     color: Colors.white.withOpacity(0.4),
    //   ),
    //   floatingLabelBehavior: FloatingLabelBehavior.never,
    //   prefixIconColor: Colors.white.withOpacity(0.7),
    //   suffixIconColor: Colors.white.withOpacity(0.7),
    // ),
    
    dividerColor: MColors.borderSecondary,
    dividerTheme: DividerThemeData(
      color: MColors.borderSecondary,
      thickness: 1,
    ),

    // Card Theme
    cardTheme: CardTheme(
      color: const Color(0xFF1E2C3A),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
    ),

    // Icon Theme
    iconTheme: IconThemeData(
      color: Colors.white.withOpacity(0.87),
    ),

  
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E2C3A),
      selectedItemColor: MColors.primary.withOpacity(0.9),
      unselectedItemColor: Colors.white.withOpacity(0.5),
    ),
  );


  static ThemeData darkTheme1 = ThemeData(
    useMaterial3: true,
    fontFamily: 'NeueMontreal',
    brightness: Brightness.dark,
    primaryColor: MColors.light,
    scaffoldBackgroundColor: MColors.backgroundDark,
    textTheme: MTextTheme.darkTheme,
    elevatedButtonTheme: MElevatedButtonTheme.darkElevatedButtonTheme,
    appBarTheme: MAppBarTheme.darkAppBarTheme,
    bottomSheetTheme: MBottomSheetTheme.darkAppBarTheme,
    checkboxTheme: MCheckBoxTheme.darkAppBarTheme,
    chipTheme: MChipTheme.darkChipTheme,
    outlinedButtonTheme: MOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: MInputDecorationTheme.darkInputDecorationTheme,
    colorScheme: ColorScheme.dark(
      primary: MColors.light,
      secondary: MColors.teritoryColor,
      surface: MColors.surfaceDark,
      background: MColors.backgroundDark,
      error: MColors.error,
      onPrimary: MColors.dark,
      onSecondary: MColors.dark,
      onSurface: MColors.textLight,
      onBackground: MColors.textLight,
      onError: MColors.white,
      brightness: Brightness.dark,
      tertiary: MColors.teritoryColor,
      onTertiary: MColors.lightTextColor,
      outline: MColors.borderDark,
      outlineVariant: MColors.borderDarkSecondary,
    ),
    dividerColor: MColors.borderDark,
    dividerTheme: DividerThemeData(
      color: MColors.borderDark,
      thickness: 1,
    ),
  );
}
