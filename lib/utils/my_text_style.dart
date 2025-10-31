import 'package:flutter/material.dart';
import 'package:homy/utils/constants.dart';
import 'package:homy/utils/dimensions.dart';

class MyTextStyle {
  static TextStyle productBlack({double? size, Color? color}) {
    return TextStyle(
        fontFamily: 'Roboto',
        fontSize: size ?? 14,
        color: color
        );
  }

  static TextStyle productBold({double? size, Color? color}) {
    return TextStyle(
        fontFamily: 'Roboto',
        fontSize: size ?? 14,
        color: color
        );
  }

  static TextStyle productLight({double? size, Color? color, FontWeight? fontWeight, double? height}) {
    return TextStyle(
        fontFamily: 'Roboto',
        fontSize: size ?? 14,
        color: color,
        fontWeight: fontWeight,
        height: height
        );
  }

  static TextStyle productMedium({double? size, Color? color, FontWeight? fontWeight, double? height}) {
    return TextStyle(
        fontFamily: 'Roboto',
        fontSize: size ?? 14,
        color: color,
        fontWeight: fontWeight,
        height: height
        );
  }

  static TextStyle productRegular({double? size, Color? color, FontWeight? fontWeight}) {
    return TextStyle(
        fontFamily: 'Roboto',
        fontSize: size ?? 14,
        color: color,
        fontWeight: fontWeight
        );
  }

  static TextStyle productThin({double? size, Color? color}) {
    return TextStyle(
      fontFamily: 'thin',
      fontSize: size ?? 14,
      color: color
    );
  }

  static TextStyle gilroySemiBold({double? size, Color? color}) {
    return TextStyle(
      fontFamily: 'semiBoldGilroy',
      fontSize: size ?? 14,
      color: color
    );
  }

  static TextStyle montserratRegular({double? size, Color? color}) {
    return TextStyle(
      fontFamily: 'regular',
      fontSize: size ?? 14,
      color: color
    );
  }


  static TextStyle robotoRegular = TextStyle(
  fontFamily: Constants.fontFamily,
  fontWeight: FontWeight.w400,
  fontSize: Dimensions.fontSizeDefault,
);

  static TextStyle robotoMedium = TextStyle(
    fontFamily: Constants.fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: Dimensions.fontSizeDefault,
  );

  static TextStyle robotoBold = TextStyle(
    fontFamily: Constants.fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: Dimensions.fontSizeDefault,
  );

final robotoBlack = TextStyle(
  fontFamily: Constants.fontFamily,
  fontWeight: FontWeight.w900,
  fontSize: Dimensions.fontSizeDefault,
);

}
