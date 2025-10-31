import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class MChipTheme {
  MChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
      disabledColor: Colors.grey.withOpacity(0.4),
      labelStyle: TextStyle(color: MColors.primary),
      selectedColor: MColors.accent,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      checkmarkColor: MColors.white
  );


  static ChipThemeData darkChipTheme = ChipThemeData(
      disabledColor: Colors.grey,
      labelStyle: TextStyle(color: MColors.white),
      selectedColor: MColors.accent,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      checkmarkColor: MColors.white

  );
}
