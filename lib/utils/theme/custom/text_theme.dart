import 'package:flutter/material.dart';

class MTextTheme {
  MTextTheme._();

  static TextTheme lightTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    headlineMedium: const TextStyle().copyWith(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    headlineSmall: const TextStyle().copyWith(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    
    titleLarge: const TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    titleMedium: const TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
    
    titleSmall: const TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      color: Colors.black.withOpacity(0.7),
    ),
    
    bodyLarge: const TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
    bodyMedium: const TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    bodySmall: const TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      color: Colors.black.withOpacity(0.7),
    ),
    
    labelLarge: const TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    labelMedium: const TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: Colors.black.withOpacity(0.7),
    ),
  );

  static TextTheme darkTheme = TextTheme(
    headlineLarge: lightTheme.headlineLarge!.copyWith(color: Colors.white),
    headlineMedium: lightTheme.headlineMedium!.copyWith(color: Colors.white),
    headlineSmall: lightTheme.headlineSmall!.copyWith(color: Colors.white),
    
    titleLarge: lightTheme.titleLarge!.copyWith(color: Colors.white),
    titleMedium: lightTheme.titleMedium!.copyWith(color: Colors.white),
    titleSmall: lightTheme.titleSmall!.copyWith(color: Colors.white70),
    
    bodyLarge: lightTheme.bodyLarge!.copyWith(color: Colors.white),
    bodyMedium: lightTheme.bodyMedium!.copyWith(color: Colors.white),
    bodySmall: lightTheme.bodySmall!.copyWith(color: Colors.white70),
    
    labelLarge: lightTheme.labelLarge!.copyWith(color: Colors.white),
    labelMedium: lightTheme.labelMedium!.copyWith(color: Colors.white70),
  );
}
