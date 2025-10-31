import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class MBottomSheetTheme {
  MBottomSheetTheme._();

  static BottomSheetThemeData lightAppBarTheme = BottomSheetThemeData(
      // showDragHandle: true,
      modalBackgroundColor: MColors.white,
      backgroundColor: MColors.white,
      constraints: BoxConstraints(minWidth: double.infinity),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  );


  static BottomSheetThemeData darkAppBarTheme = BottomSheetThemeData(
      // showDragHandle: true,
      modalBackgroundColor: const Color(0xFF1E1E1E),
      backgroundColor: const Color(0xFF1E1E1E),
      constraints: BoxConstraints(minWidth: double.infinity),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  );
}
