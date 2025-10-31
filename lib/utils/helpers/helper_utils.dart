import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:math' show Random, min;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';





class HelperUtils {


  static String checkHost(String url) {
    if (url.endsWith("/")) {
      return url;
    } else {
      return "$url/";
    }
  }

  static Future<void> push(BuildContext context, Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return screen;
        },
      ),
    );
  }

  static int comparableVersion(String version) {
    //removing dot from version and parsing it into int
    String plain = version.replaceAll(".", "");

    return int.parse(plain);
  }

  static void share(BuildContext context, int propertyId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.onBackground.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Share Property',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Get.theme.colorScheme.onBackground,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.copy_rounded,
                      color: Get.theme.colorScheme.onPrimary,
                    ),
                  ),
                  title: Text(
                    "Copy Link".tr,
                    style: TextStyle(
                      color: Get.theme.colorScheme.onBackground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    "Copy property link to clipboard",
                    style: TextStyle(
                      color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: 'https://urlink.com/app/property-details?id=$propertyId')
                    );
                    Get.back();
                    Get.showSnackbar(
                      CommonUI.SuccessSnackBar(
                        message: "Link copied to clipboard".tr,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.share_rounded,
                      color: Get.theme.colorScheme.onPrimary,
                    ),
                  ),
                  title: Text(
                    "Share".tr,
                    style: TextStyle(
                      color: Get.theme.colorScheme.onBackground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    "Share property with others",
                    style: TextStyle(
                      color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  onTap: () async {
                    await Share.share(
                      'Check out this amazing property on Homy! https://urlink.com/app/property-details?id=$propertyId',
                      subject: 'Check out this incredible property listing on Homy!',
                    );
                    Get.back();
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }




  static void shareAll(BuildContext context, {required String title, required String description, required String url}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.onBackground.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Get.theme.colorScheme.onBackground,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.copy_rounded,
                      color: Get.theme.colorScheme.onPrimary,
                    ),
                  ),
                  title: Text(
                    "Copy Link".tr,
                    style: TextStyle(
                      color: Get.theme.colorScheme.onBackground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    "Copy property link to clipboard",
                    style: TextStyle(
                      color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: url)
                    );
                    Get.back();
                    Get.showSnackbar(
                      CommonUI.SuccessSnackBar(
                        message: "Link copied to clipboard".tr,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.share_rounded,
                      color: Get.theme.colorScheme.onPrimary,
                    ),
                  ),
                  title: Text(
                    "Share".tr,
                    style: TextStyle(
                      color: Get.theme.colorScheme.onBackground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    "Share property with others",
                    style: TextStyle(
                      color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  onTap: () async {
                    await Share.share(
                      '$title\n$description\n$url',
                      subject: description,
                    );
                    Get.back();
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }



  static void unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static checkIsUserInfoFilled({String name = "", String email = ""}) {
    String chkname = name;
    if (name.trim().isEmpty) {
      // chkname = Constant.session.getStringData(Session.keyUserName);
    }
    return chkname.trim().isNotEmpty;
  }

  static String getFileSizeString({required int bytes, int decimals = 0}) {
    const suffixes = ["b", "kb", "mb", "gb", "tb"];
    if (bytes == 0) return '0${suffixes[0]}';
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
  }

  static killPreviousPages(BuildContext context, var nextpage, var args) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(nextpage, (route) => false, arguments: args);
  }

  static goToNextPage(var nextpage, BuildContext bcontext, bool isreplace,
      {Map? args}) {
    if (isreplace) {
      Navigator.of(bcontext).pushReplacementNamed(nextpage, arguments: args);
    } else {
      Navigator.of(bcontext).pushNamed(nextpage, arguments: args);
    }
  }

  static String setFirstLetterUppercase(String value) {
    if (value.isNotEmpty) value = value.replaceAll("_", ' ');
    return value.toTitleCase();
  }

  static Widget checkVideoType(String url,
      {required Widget Function() onYoutubeVideo,
      required Widget Function() onOtherVideo}) {
    List youtubeDomains = ["youtu.be", "youtube.com"];

    Uri uri = Uri.parse(url);
    var host = uri.host.toString().replaceAll("www.", "");
    if (youtubeDomains.contains(host)) {
      return onYoutubeVideo.call();
    } else {
      return onOtherVideo.call();
    }
  }

  static bool isYoutubeVideo(String url) {
    List youtubeDomains = ["youtu.be", "youtube.com"];

    Uri uri = Uri.parse(url);
    var host = uri.host.toString().replaceAll("www.", "");
    if (youtubeDomains.contains(host)) {
      return true;
    } else {
      return false;
    }
  }

    static String timeAgo(int time) {
    var d = DateTime.fromMillisecondsSinceEpoch(time).toLocal();
    Duration diff = DateTime.now().toLocal().difference(d);
    if (diff.inDays > 30) {
      return DateFormat('dd MMM, yyyy', 'en').format(d);
    }
    if (diff.inDays > 7) {
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "Week" : "Weeks"} ago";
    }
    if (diff.inDays > 0) {
      return "${diff.inDays} ${diff.inDays == 1 ? "Day" : "Days"} ago";
    }
    if (diff.inHours > 0) {
      return "${diff.inHours} ${diff.inHours == 1 ? "Hour" : "Hours"} ago";
    }
    if (diff.inMinutes > 0) {
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "Minute" : "Minutes"} ago";
    }
    return "Just now";
  }

  static String formatCurrency(double amount) {
    return '${Constant.currencySymbol} ${NumberFormat('#,##0').format(amount)}';
  }

  static String maskSensitiveInfo(String? input, {bool isEmail = false}) {
    if (input == null || input.isEmpty) return '';

    if (isEmail) {
      final parts = input.split('@');
      if (parts.length != 2) return input;
      
      String username = parts[0];
      String domain = parts[1];
      
      if (username.length <= 2) return input;
      
      String maskedUsername = '${username[0]}${'*' * (username.length - 2)}${username[username.length - 1]}';
      return '$maskedUsername@$domain';
    } else {
      // For phone numbers
      if (input.length <= 4) return input;
      return '${'*' * (input.length - 4)}${input.substring(input.length - 4)}';
    }
  }

  static String encryptReelId(int? id) {
    if (id == null) return '';
    // Convert to base36 (alphanumeric)
    String encoded = id.toRadixString(36).toLowerCase();
    if (encoded.length < 8) {
      // Add deterministic padding based on the ID
      final seed = id % 100000; // Use ID as seed for deterministic padding
      final random = Random(seed);
      const urlSafeChars = 'abcdefghijklmnopqrstuvwxyz0123456789';
      // Add a separator to distinguish padding
      encoded += '-';
      while (encoded.length < 9) { // 8 chars + separator
        encoded += urlSafeChars[random.nextInt(urlSafeChars.length)];
      }
    }
    // Truncate if longer than 10 chars
    return encoded.substring(0, min(encoded.length, 10));
  }

  static int? decryptReelId(String encrypted) {
    try {
      if (encrypted.isEmpty) return null;
      
      // Handle full URLs by extracting the ID portion
      if (encrypted.contains('/')) {
        encrypted = encrypted.split('/').last;
      }
      
      // Take the part before the padding separator
      String cleanId = encrypted.split('-').first;
      // Parse as base36
      return int.parse(cleanId, radix: 36);
    } catch (e) {
      return null;
    }
  }

}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}
