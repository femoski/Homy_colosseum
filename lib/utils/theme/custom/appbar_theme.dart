import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class MAppBarTheme {
  MAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: MColors.primary, size: 24),
      actionsIconTheme: IconThemeData(color: MColors.primary, size: 24),
      titleTextStyle: TextStyle(fontSize: 18, color: MColors.primary, fontWeight: FontWeight.w600),
  );


  static const darkAppBarTheme = AppBarTheme(
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: MColors.white, size: 24),
      actionsIconTheme: IconThemeData(color: MColors.white, size: 24),
      titleTextStyle: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
  );
}
