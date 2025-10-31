import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class MInputDecorationTheme {
  MInputDecorationTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: MColors.primary,
    suffixIconColor: MColors.primary,

    labelStyle: TextStyle().copyWith(fontSize: 14, color: MColors.primary),
    hintStyle: TextStyle().copyWith(fontSize: 14, color: MColors.primary),
    errorStyle: TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle: TextStyle().copyWith(color: MColors.primary.withOpacity(0.8)),
    border: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(width: 1, color: MColors.primary),
    ),
    enabledBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(width: 1, color: MColors.primary),
    ),
    focusedBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(width: 1, color: MColors.primary),
    ),
    errorBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(width: 1, color: MColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(width: 1, color: MColors.warning),
    ),
  );


   static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: MColors.white,
    suffixIconColor: MColors.white,

    labelStyle: TextStyle().copyWith(fontSize: 14, color: MColors.white),
    hintStyle: TextStyle().copyWith(fontSize: 14, color: const Color.fromARGB(255, 115, 115, 115)),
    errorStyle: TextStyle().copyWith(fontStyle: FontStyle.normal),
    // floatingLabelStyle: TextStyle().copyWith(color: MColors.white.withOpacity(0.8)),
          floatingLabelBehavior: FloatingLabelBehavior.never,

    border: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(width: 1, color: MColors.white),
    ),
    enabledBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(width: 1, color: MColors.white),
    ),
    focusedBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(width: 1, color: MColors.white),
    ),
    errorBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(width: 1, color: MColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(width: 1, color: MColors.warning),
    ),
  );

}