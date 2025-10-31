import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class MOutlinedButtonTheme {
  MOutlinedButtonTheme._();

  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: MColors.primary,
      side: BorderSide(color: MColors.primary),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      textStyle: TextStyle(
          fontSize: 16, color: MColors.primary, fontWeight: FontWeight.normal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: MColors.white,
      side: BorderSide(color: MColors.white),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      textStyle: TextStyle(
          fontSize: 16, color: MColors.white, fontWeight: FontWeight.normal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
