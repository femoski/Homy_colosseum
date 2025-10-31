import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class MCheckBoxTheme {
  MCheckBoxTheme._();


  static CheckboxThemeData lightAppBarTheme = CheckboxThemeData(
    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return MColors.white;
      } else {
        return Colors.transparent;
      }
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return MColors.primary;
      } else {
        return Colors.transparent;
      }
    }),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), side: BorderSide(color: MColors.primary)),
  );

  static CheckboxThemeData darkAppBarTheme = CheckboxThemeData(
    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return MColors.primary;
      } else {
        return Colors.transparent;
      }
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return MColors.white;
      } else {
        return Colors.transparent;
      }
    }),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), side: BorderSide(color: MColors.white)),
  );
}
