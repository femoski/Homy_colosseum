import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class MElevatedButtonTheme {
  MElevatedButtonTheme._();

  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: MColors.white,
      backgroundColor: MColors.primary,
      disabledForegroundColor: MColors.secondary,
      disabledBackgroundColor: MColors.secondary,
      side: BorderSide(color: MColors.primary),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      textStyle: TextStyle(
          fontSize: 16, color: MColors.primary, fontWeight: FontWeight.normal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: MColors.primary,
      backgroundColor: MColors.white,
      disabledForegroundColor: MColors.secondary,
      disabledBackgroundColor: MColors.secondary,
      side: BorderSide(color: MColors.white),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      textStyle: TextStyle(
          fontSize: 16, color: MColors.white, fontWeight: FontWeight.normal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
