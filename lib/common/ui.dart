import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/widgets/custom_toast.dart';
import 'package:homy/common/widgets/loader_custom.dart';
import 'package:homy/utils/constants/image_string.dart';
import 'package:homy/utils/my_text_style.dart';

import '../utils/dimensions.dart';

class CommonUI {
  static GetSnackBar SuccessSnackBarold(
      {String title = 'Success', String message = ''}) {
    Get.log("[$title] $message");
    return GetSnackBar(
      titleText: Text(title.tr,
          style: Get.textTheme.titleLarge
              ?.merge(TextStyle(color: Get.theme.primaryColor))),
      messageText: Text(message,
          style: Get.textTheme.bodySmall!
              .merge(TextStyle(color: Get.theme.primaryColor))),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(20),
      backgroundColor: Colors.green,
      icon: Icon(Icons.check_circle_outline,
          size: 32, color: Get.theme.primaryColor),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      borderRadius: 8,
      dismissDirection: DismissDirection.horizontal,
      duration: const Duration(seconds: 5),
    );
  }

  static GetSnackBar SuccessSnackBar(
      {String title = 'Success!!', String message = ''}) {
    Get.log("[$title] $message", isError: true);
    return GetSnackBar(
      // titleText: Text(title.tr,
      //     style: Get.textTheme.titleLarge
      //         ?.merge(TextStyle(color: Get.theme.primaryColor,fontSize: 20))),
      messageText:  Container(
        height: 80,
        child: Stack(children: [
          Positioned(
            top: -16,
            left: -8,
            child: Transform.rotate(
              angle: 10 * pi / 180,
              child: const  SizedBox(
                  height: 95,
                  child: Icon(
                    Icons
                        .check_circle_outline, // You can change this to any icon you want
                    color: Color(0x15000000),
                    size: 120, // Adjust the size as needed
                  )),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('${message.substring(0, min(message.length, 200))}',
                  textAlign: TextAlign.center,
                  // overflow: TextOverflow.ellipsis,

                  textScaleFactor: 1,
                  style: Get.textTheme.titleLarge?.merge(
                  const  TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'roboto',
                    ),
                  )),
            ),
          )
        ]),
      ),

      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(20),
      backgroundColor: Color(0xFF087C7C),

      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      borderRadius: 16,
      duration: const Duration(seconds: 3),
    );
  }

  static GetSnackBar ErrorSnackBarold(
      {String title = 'Oh Snap!!', String message = ''}) {
    Get.log("[$title] $message", isError: true);
    return GetSnackBar(
      titleText: Text(title.tr,
          style: Get.textTheme.titleLarge
              ?.merge(TextStyle(color: Get.theme.primaryColor, fontSize: 20))),
      messageText: Text(message.substring(0, min(message.length, 200)),
          style: TextStyle(
              color: Get.theme.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold)),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(20),
      backgroundColor: Color(0xffc72c41),
      icon: Icon(Icons.remove_circle_outline,
          size: 32, color: Get.theme.primaryColor),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      borderRadius: 16,
      duration: const Duration(seconds: 5),
    );
  }

  static void snackBar({required String? title}) {
    Get.rawSnackbar(
      backgroundColor: Get.theme.colorScheme.surface,
      borderRadius: 10,
      messageText: Text(
        title ?? '',
        style: MyTextStyle.gilroySemiBold(
            size: 15, color: Get.theme.colorScheme.onSurface),
      ),
      forwardAnimationCurve: Curves.fastEaseInToSlowEaseOut,
      reverseAnimationCurve: Curves.fastLinearToSlowEaseIn,
      snackStyle: SnackStyle.FLOATING,
      margin: const EdgeInsets.all(15),
      duration: const Duration(milliseconds: 1500),
    );
  }

  static GetSnackBar ErrorSnackBar(
      {String title = 'Oh Snap!!', String message = ''}) {
    Get.log("[$title] $message", isError: true);
    return GetSnackBar(
      // titleText: Text(title.tr,
      //     style: Get.textTheme.titleLarge
      //         ?.merge(TextStyle(color: Get.theme.primaryColor,fontSize: 20))),
      messageText: Container(
        height: 90,
        child: Stack(children: [
          Positioned(
            top: -10,
            left: -8,
            child: Transform.rotate(
              angle: 32 * pi / 180,
              child: const SizedBox(
                  height: 95,
                  child: Icon(
                    Icons
                        .error_outline, // You can change this to any icon you want
                    color: Color(0x15000000),
                    size: 120, // Adjust the size as needed
                  )),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('${message.substring(0, min(message.length, 200))}',
                  textAlign: TextAlign.center,
                  // overflow: TextOverflow.ellipsis,

                  textScaleFactor: 1,
                  style: Get.textTheme.titleLarge?.merge(
                  const  TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'roboto',
                    ),
                  )),
            ),
          )
        ]),
      ),

      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(20),
      backgroundColor: Color(0xffc72c41),

      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      borderRadius: 16,
      duration: Duration(seconds: 3),
    );
  }

  static GetSnackBar infoSnackBar(
      {String title = 'Information', String message = ''}) {
    Get.log("[$title] $message", isError: false);
    return GetSnackBar(
      messageText: Container(
        height: 70,
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              top: -20,
              right: -20,
              child: Transform.rotate(
                angle: 45 * pi / 180,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            // Main content
            Row(
              children: [
                // Icon container
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(left: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Text content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message.substring(0, min(message.length, 200)),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Close button
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ],
        ),
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFF2B3A55),
      padding: EdgeInsets.zero,
      borderRadius: 16,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 500),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      overlayBlur: 0.5,
      overlayColor: Colors.black.withOpacity(0.1),
    );
  }

  static GetSnackBar infoSnackBarSweet(
      {String title = 'Information', String message = ''}) {
    Get.log("[$title] $message", isError: false);
    return GetSnackBar(
      messageText: Container(
        height: 80,
        child: Stack(
          children: [
            // Decorative elements
            Positioned(
              top: -15,
              right: -15,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              left: -10,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
            // Main content
            Row(
              children: [
                // Left decorative line
                Container(
                  width: 4,
                  height: 40,
                  margin: const EdgeInsets.only(left: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.8),
                        Colors.white.withOpacity(0.4),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 20),
                // Content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message.substring(0, min(message.length, 200)),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Action button
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFF1E3A8A),
      padding: EdgeInsets.zero,
      borderRadius: 20,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 600),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      overlayBlur: 0.8,
      overlayColor: Colors.black.withOpacity(0.2),
    );
  }

  static Widget errorUserPlaceholder(
      {required double width, required double height}) {
    return Container(
      height: height,
      width: width,
      color: Get.theme.colorScheme.primary.withOpacity(0.5),
      child: Image.asset(
        MImages.userPlaceHolder,
        color: Get.theme.colorScheme.primary.withOpacity(0.5),
      ),
    );
  }

  static GetSnackBar defaultSnackBar(
      {String title = 'Alert', String message = ''}) {
    Get.log("[$title] $message", isError: false);
    return GetSnackBar(
      titleText: Text(title.tr,
          style: Get.textTheme.titleLarge
              ?.merge(TextStyle(color: Get.theme.hintColor))),
      messageText: Text(message,
          style: Get.textTheme.bodySmall!
              .merge(TextStyle(color: Get.theme.focusColor))),
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(20),
      backgroundColor: Get.theme.primaryColor,
      borderColor: Get.theme.focusColor.withOpacity(0.1),
      icon: Icon(Icons.warning_amber_rounded,
          size: 32, color: Get.theme.hintColor),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      borderRadius: 8,
      duration: Duration(seconds: 2),
    );
  }

  static Widget loaderWidget() {
    return const LoaderCustom();
  }

  static Widget noDataFound(
      {required double width,
      required double height,
      String? title,
      String? subTitle,
      String? image}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primary.withOpacity(.05),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              image ?? MImages.logo,
              color: Get.theme.colorScheme.primary.withOpacity(.6),
              height: height * 0.6,
              width: width * 0.6,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title ?? 'No Data Found',
            style: MyTextStyle.productLight(
              size: 18,
              color: Get.theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subTitle ?? 'We couldn\'t find what you\'re looking for',
            style: MyTextStyle.productLight(
              size: 14,
              color: Get.theme.colorScheme.primary.withOpacity(.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static void showCustomSnackBar(String? message,
      {bool isError = true, bool getXSnackBar = false}) {
    if (message != null && message.isNotEmpty) {
      if (getXSnackBar) {
        Get.showSnackbar(GetSnackBar(
          backgroundColor: isError ? Colors.red : Colors.green,
          message: message,
          maxWidth: 500,
          duration: const Duration(seconds: 3),
          snackStyle: SnackStyle.FLOATING,
          margin: const EdgeInsets.only(
              left: Dimensions.paddingSizeSmall,
              right: Dimensions.paddingSizeSmall,
              bottom: 100),
          borderRadius: Dimensions.radiusSmall,
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
        ));
      } else {
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          dismissDirection: DismissDirection.endToStart,
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          content: CustomToast(text: message, isError: isError),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  static GetSnackBar notificationSnackBar(
      {String title = 'Notification',
      String message = '',
      OnTap? onTap,
      Widget? mainButton}) {
    Get.log("[$title] $message", isError: false);
    return GetSnackBar(
      onTap: onTap,
      mainButton: mainButton,
      titleText: Text(title.tr,
          style: Get.textTheme.titleLarge
              ?.merge(TextStyle(color: Get.theme.hintColor))),
      messageText: Text(message,
          style: Get.textTheme.bodySmall!
              .merge(TextStyle(color: Get.theme.focusColor))),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(20),
      backgroundColor: Get.theme.primaryColor,
      borderColor: Get.theme.focusColor.withOpacity(0.1),
      icon:
          Icon(Icons.notifications_none, size: 32, color: Get.theme.hintColor),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      borderRadius: 8,
      duration: Duration(seconds: 5),
    );
  }

  static void loader() {
    Get.dialog(const LoaderCustom(), barrierDismissible: true);
  }

  static void loaderClose() {
    Get.back();
  }

  static Color parseColor(String? hexCode, {double? opacity}) {
    try {
      return Color(int.tryParse(hexCode!.replaceAll("#", "0xFF")) ?? 0)
          .withOpacity(opacity ?? 1);
    } catch (e) {
      return Color(0xFFCCCCCC).withOpacity(opacity ?? 1);
    }
  }

  static List<Icon> getStarsList(double? rate, {double size = 18}) {
    var list = <Icon>[];
    if (rate == null) rate = 0;
    list = List.generate(rate.floor(), (index) {
      return Icon(Icons.star, size: size, color: Color(0xFFFFB24D));
    });
    if (rate - rate.floor() > 0) {
      list.add(Icon(Icons.star_half, size: size, color: Color(0xFFFFB24D)));
    }
    list.addAll(
        List.generate(5 - rate.floor() - (rate - rate.floor()).ceil(), (index) {
      return Icon(Icons.star_border, size: size, color: Color(0xFFFFB24D));
    }));
    return list;
  }

  static BoxDecoration getBoxDecoration(
      {Color? color, double? radius, Border? border, Gradient? gradient}) {
    return BoxDecoration(
      color: color ?? Get.theme.primaryColor,
      borderRadius: BorderRadius.all(Radius.circular(radius ?? 10)),
      boxShadow: [
        BoxShadow(
            color: Get.theme.focusColor.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5)),
      ],
      border:
          border ?? Border.all(color: Get.theme.focusColor.withOpacity(0.05)),
      gradient: gradient,
    );
  }

  static InputDecoration getInputDecoration(
      {String? hintText = '',
      String? errorText,
      IconData? iconData,
      Widget? suffixIcon,
      Widget? suffix}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: Get.textTheme.bodySmall,
      prefixIcon: iconData != null
          ? Icon(iconData, color: Get.theme.focusColor).marginOnly(right: 14)
          : SizedBox(),
      prefixIconConstraints: iconData != null
          ? BoxConstraints.expand(width: 38, height: 38)
          : BoxConstraints.expand(width: 0, height: 0),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      contentPadding: EdgeInsets.all(0),
      border: OutlineInputBorder(borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
      suffixIcon: suffixIcon,
      suffix: suffix,
      errorText: errorText,
    );
  }

  static InputDecoration tradeInputDecoration(
      {String? hintText = '',
      String? errorText,
      Widget? suffixIcon,
      Widget? suffix,
      Widget? prefix}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: Get.textTheme.bodySmall,
      prefixIcon: prefix != null ? prefix.marginOnly(right: 14) : SizedBox(),
      prefixIconConstraints: prefix != null
          ? BoxConstraints.expand(width: 42, height: 42)
          : BoxConstraints.expand(width: 0, height: 0),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      contentPadding: EdgeInsets.all(0),
      border: OutlineInputBorder(borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
      suffixIcon: suffixIcon,
      suffix: suffix,
      errorText: errorText,
    );
  }

  static Widget errorPlaceholder(
      {required double width, required double height, double? iconSize}) {
    return Container(
      height: height,
      width: width,
      padding: EdgeInsets.all(iconSize ?? 30),
      color: Get.theme.colorScheme.surface,
      child: Image.asset(
        MImages.logo,
        color: Get.theme.colorScheme.onPrimary.withOpacity(0.5),
      ),
    );
  }

  static InputDecoration getInputDecorations(
      {String? hintText = '',
      String? errorText,
      IconData? iconData,
      Widget? suffixIcon,
      Widget? suffix}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: Get.textTheme.bodySmall,
      prefixIcon: iconData != null
          ? Icon(iconData, color: Get.theme.focusColor).marginOnly(right: 14)
          : SizedBox(),
      prefixIconConstraints: iconData != null
          ? BoxConstraints.expand(width: 38, height: 38)
          : BoxConstraints.expand(width: 0, height: 0),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      contentPadding: EdgeInsets.all(0),
      suffixIcon: suffixIcon,
      suffix: suffix,
      errorText: errorText,
    );
  }

  static BoxFit getBoxFit(String boxFit) {
    switch (boxFit) {
      case 'cover':
        return BoxFit.cover;
      case 'fill':
        return BoxFit.fill;
      case 'contain':
        return BoxFit.contain;
      case 'fit_height':
        return BoxFit.fitHeight;
      case 'fit_width':
        return BoxFit.fitWidth;
      case 'none':
        return BoxFit.none;
      case 'scale_down':
        return BoxFit.scaleDown;
      default:
        return BoxFit.cover;
    }
  }

  static AlignmentDirectional getAlignmentDirectional(
      String alignmentDirectional) {
    switch (alignmentDirectional) {
      case 'top_start':
        return AlignmentDirectional.topStart;
      case 'top_center':
        return AlignmentDirectional.topCenter;
      case 'top_end':
        return AlignmentDirectional.topEnd;
      case 'center_start':
        return AlignmentDirectional.centerStart;
      case 'center':
        return AlignmentDirectional.topCenter;
      case 'center_end':
        return AlignmentDirectional.centerEnd;
      case 'bottom_start':
        return AlignmentDirectional.bottomStart;
      case 'bottom_center':
        return AlignmentDirectional.bottomCenter;
      case 'bottom_end':
        return AlignmentDirectional.bottomEnd;
      default:
        return AlignmentDirectional.bottomEnd;
    }
  }

  static CrossAxisAlignment getCrossAxisAlignment(String textPosition) {
    switch (textPosition) {
      case 'top_start':
        return CrossAxisAlignment.start;
      case 'top_center':
        return CrossAxisAlignment.center;
      case 'top_end':
        return CrossAxisAlignment.end;
      case 'center_start':
        return CrossAxisAlignment.center;
      case 'center':
        return CrossAxisAlignment.center;
      case 'center_end':
        return CrossAxisAlignment.center;
      case 'bottom_start':
        return CrossAxisAlignment.start;
      case 'bottom_center':
        return CrossAxisAlignment.center;
      case 'bottom_end':
        return CrossAxisAlignment.end;
      default:
        return CrossAxisAlignment.start;
    }
  }

  static bool isDesktop(BoxConstraints constraint) {
    return constraint.maxWidth >= 1280;
  }

  static bool isTablet(BoxConstraints constraint) {
    return constraint.maxWidth >= 768 && constraint.maxWidth <= 1280;
  }

  static bool isMobile(BoxConstraints constraint) {
    return constraint.maxWidth < 768;
  }

  static double col12(BoxConstraints constraint,
      {double desktopWidth = 1280,
      double tabletWidth = 768,
      double mobileWidth = 480}) {
    if (isMobile(constraint)) {
      return mobileWidth;
    } else if (isTablet(constraint)) {
      return tabletWidth;
    } else {
      return desktopWidth;
    }
  }

  static double col9(BoxConstraints constraint,
      {double desktopWidth = 1280,
      double tabletWidth = 768,
      double mobileWidth = 480}) {
    if (isMobile(constraint)) {
      return mobileWidth * 3 / 4;
    } else if (isTablet(constraint)) {
      return tabletWidth * 3 / 4;
    } else {
      return desktopWidth * 3 / 4;
    }
  }

  static double col8(BoxConstraints constraint,
      {double desktopWidth = 1280,
      double tabletWidth = 768,
      double mobileWidth = 480}) {
    if (isMobile(constraint)) {
      return mobileWidth * 2 / 3;
    } else if (isTablet(constraint)) {
      return tabletWidth * 2 / 3;
    } else {
      return desktopWidth * 2 / 3;
    }
  }

  static double col6(BoxConstraints constraint,
      {double desktopWidth = 1280,
      double tabletWidth = 768,
      double mobileWidth = 480}) {
    if (isMobile(constraint)) {
      return mobileWidth / 2;
    } else if (isTablet(constraint)) {
      return tabletWidth / 2;
    } else {
      return desktopWidth / 2;
    }
  }

  static double col4(BoxConstraints constraint,
      {double desktopWidth = 1280,
      double tabletWidth = 768,
      double mobileWidth = 480}) {
    if (isMobile(constraint)) {
      return mobileWidth * 1 / 3;
    } else if (isTablet(constraint)) {
      return tabletWidth * 1 / 3;
    } else {
      return desktopWidth * 1 / 3;
    }
  }

  static double col3(BoxConstraints constraint,
      {double desktopWidth = 1280,
      double tabletWidth = 768,
      double mobileWidth = 480}) {
    if (isMobile(constraint)) {
      return mobileWidth * 1 / 4;
    } else if (isTablet(constraint)) {
      return tabletWidth * 1 / 4;
    } else {
      return desktopWidth * 1 / 4;
    }
  }

  static GetSnackBar InfoSnackBar(
      {String title = 'Information', String message = ''}) {
    Get.log("[$title] $message");
    return GetSnackBar(
      titleText: Text(title.tr,
          style: Get.textTheme.titleLarge
              ?.merge(TextStyle(color: Get.theme.primaryColor))),
      messageText: Text(message,
          style: Get.textTheme.bodySmall!
              .merge(TextStyle(color: Get.theme.primaryColor))),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(20),
      backgroundColor: Colors.blue.shade100,
      icon: Icon(Icons.info_outline, size: 32, color: Get.theme.primaryColor),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      borderRadius: 8,
      dismissDirection: DismissDirection.horizontal,
      duration: const Duration(seconds: 5),
    );
  }

  Widget buildTimeStamp(String status, int time, bool isMe, bool onImage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      // decoration: BoxDecoration(
      //   color: onImage
      //       ? Colors.black.withOpacity(0.5)
      //       : (isMe
      //           ? context.theme.colorScheme.primary.withOpacity(0.15)
      //           : context.theme.colorScheme.background.withOpacity(0.8)),
      //   borderRadius: BorderRadius.circular(8),
      //   border: Border.all(
      //     color: onImage
      //         ? Colors.transparent
      //         : (isMe
      //             ? context.theme.colorScheme.primary.withOpacity(0.15)
      //             : context.theme.dividerColor.withOpacity(0.1)),
      //     width: 0.5,
      //   ),
      // ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatMessageTime(time.toInt() * 1000),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: onImage
                  ? Colors.white
                  : (isMe
                      ? Get.theme.colorScheme.primary.withOpacity(0.8)
                      : Get.theme.hintColor.withOpacity(0.8)),
            ),
          ),
          const SizedBox(width: 4),
          _buildMessageStatus(status, isMe, onImage),
        ],
      ),
    );
  }

  Widget _buildMessageStatus(String status, bool isMe, bool onImage) {
    if (!isMe) return const SizedBox.shrink();

    IconData? icon;
    Color? color;

    switch (status.toLowerCase()) {
      case 'sent':
        icon = Icons.check;
        color = onImage ? Colors.white : Colors.grey;
        break;
      case 'delivered':
        icon = Icons.done_all;
        color = onImage ? Colors.white : Colors.grey;
        break;
      case 'read':
        icon = Icons.done_all;
        color = onImage ? Colors.white : Colors.blue;
        break;
      case 'pending':
        icon = Icons.access_time;
        color = onImage ? Colors.white : Colors.grey;
        break;
      default:
        icon = Icons.access_time;
        color = onImage ? Colors.white : Colors.grey;
        break;
    }

    return icon != null
        ? Icon(
            icon,
            size: 16,
            color: color,
          )
        : const SizedBox.shrink();
  }

  String _formatMessageTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    // final now = DateTime.now();
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString()}:${date.minute.toString().padLeft(2, '0')} $amPm';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  static void showErrorSnackBar({required String message}) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
