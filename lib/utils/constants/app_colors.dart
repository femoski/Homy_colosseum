import 'package:flutter/material.dart';

class MColors {
  MColors._();

  static const Color primary = Color(0xFF674422);
  static const Color darkprimary = Color(0xFFC3915F);
  static const Color secondary = Color(0xFF8D99AE);
  static const Color accent = Color(0xFFEF233C);

  static const Color light = Color(0xFFEDF2F4);
  static const Color dark = Color(0xFF674422);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color daveGrey = Color(0xFF575757);
  static const Color balticSea = Color(0xFF282828);
  static const Color snowDrift = Color(0xFFF9F9F9);

  static const Color luxury = Color(0xFFAF9F7E);
  static const Color apartment = Color(0xFF4A90E2);
  static const Color villa = Color(0xFF98B4AA);
  static const Color vacation = Color(0xFFF4A261);
  static const Color penthouse = Color(0xFF845EC2);
  static const Color commercial = Color(0xFF2D4059);

  static const Color available = Color(0xFF4CAF50);
  static const Color rented = Color(0xFFE63946);
  static const Color pending = Color(0xFFFFA726);
  static const Color featured = Color(0xFFFFD700);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE63946);
  static const Color info = Color(0xFF2196F3);

  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF1A1B1E);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2D2E32);

  static const Color textPrimary = Color(0xFF674422);
  static const Color textSecondary = Color(0xFF8D99AE);
  static const Color textLight = Color(0xFFEDF2F4);
  static const Color textDark = Color(0xFF674422);

  static const Color budget = Color(0xFF81B29A);
  static const Color moderate = Color(0xFF3D405B);
  static const Color premium = Color(0xFFAF9F7E);
  static const Color ultra = Color(0xFF845EC2);

  static const Color wellness = Color(0xFF95A5A6);
  static const Color outdoor = Color(0xFF7CB342);
  static const Color security = Color(0xFF34495E);
  static const Color convenience = Color(0xFF00ACC1);
  static const Color faintcolor = Color.fromARGB(255, 148, 148, 148);

  static const Color teritoryColor = Color(0xFF674422);
  static final Color lightTextColor = Color(0xFF4D5454).withOpacity(0.5);

  static const List<Color> primaryGradient = [
    Color(0xFF674422),
    Color(0xFF8D99AE),
  ];

  static const List<Color> luxuryGradient = [
    Color(0xFFAF9F7E),
    Color(0xFFD4C5A9),
  ];

  // Dark Theme Specific Colors
  static const Color darkPrimary = Color(0xFFEDF2F4);    // Inverted for dark theme
  static const Color darkSecondary = Color(0xFFB8C1CF);  // Lighter version for dark theme
  
  // Dark Theme Property Colors (slightly adjusted for dark backgrounds)
  static const Color luxuryDark = Color(0xFFCFBF9E);     // Lighter gold
  static const Color apartmentDark = Color(0xFF6BAAF0);  // Lighter blue
  static const Color villaDark = Color(0xFFB8D4CA);      // Lighter sage
  static const Color vacationDark = Color(0xFFF6B481);   // Lighter coral
  static const Color penthouseDark = Color(0xFFA47EE2);  // Lighter purple
  static const Color commercialDark = Color(0xFF4D6079); // Lighter navy

  // Dark Theme Gradients
  static const List<Color> primaryGradientDark = [
    Color(0xFFEDF2F4),
    Color(0xFFB8C1CF),
  ];

  static const List<Color> luxuryGradientDark = [
    Color(0xFFCFBF9E),
    Color(0xFFE4D5B9),
  ];

  // Dark Theme Status Colors (slightly adjusted for visibility)
  static const Color availableDark = Color(0xFF66BB6A);
  static const Color rentedDark = Color(0xFFEF5350);
  static const Color pendingDark = Color(0xFFFFB74D);
  static const Color featuredDark = Color(0xFFFFE57F);

  static const Color textColor = Color(0xFF4D5454);

  // Border Colors
  static  Color borderPrimary = Color(0xffEEEEEE).withOpacity(0.6);  // Light mode default border
  static const Color borderSecondary = Color(0xFFEEEEEE);   // Light mode subtle border
  static const Color borderDark = Color(0xFF424242);        // Dark mode default border
  static const Color borderDarkSecondary = Color(0xFF303030); // Dark mode subtle border
  
  // Input Border Colors
  static const Color inputBorderLight = Color(0xFFBDBDBD);  // Light mode input border
  static const Color inputBorderDark = Color(0xFF616161);   // Dark mode input border
  static const Color inputBorderFocus = Color(0xFF674422);  // Focused input border
  static const Color inputBorderError = Color(0xFFE63946);  // Error input border

  static const Color loginGradientStart = Color(0xFF674422);
  static const Color loginGradientEnd = Color(0xFF8D99AE);

  static const Color shimmerBaseColor = Color.fromARGB(255, 40, 40, 40);
  static const Color shimmerHighlightColor = Color.fromARGB(255, 202, 202, 202);
}
