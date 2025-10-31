import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
 import 'package:get/get.dart';
import 'package:homy/models/media.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:image_picker/image_picker.dart';
 import 'package:intl/intl.dart';
 
class CommonFun {
  static String getMediaold({required List<Media> m, required int mediaId}) {
    for (int i = 0; i < m.length; i++) {
      if (m[i].mediaTypeId == mediaId) {
        return (m[i].content ?? '');
      }
      else{
        return (m[i].content ?? '');
      }
    }
    return '';
  }

  static String getMedia({required List<Media> m, required int mediaId}) {
    for (int i = 0; i < m.length; i++) {
      if (m[i].mediaTypeId == mediaId) {
        return (m[i].content ?? '');
      }
      
    }
    return '';
  }

  static int mediaLength(List<Media> m) {
    int count = 0;
    for (int i = 0; i < m.length; i++) {
      if (m[i].mediaTypeId != 7) {
        count++;
      }
    }
    return count;
  }

  static double getSizeInMb(XFile file) {
    int sizeInBytes = File(file.path).lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    return sizeInMb;
  }

  static String dateFormat(String timeZone) {
    DateTime time = DateFormat('dd/MM/yyyy hh:mm a', 'en').parse(timeZone);
    return DateFormat('dd MMM, yyyy : EEE : hh:mm a', 'en').format(time);
  }

  static List<String> getBedRoomList() {
    List<String> add = [];
    for (int i = 1; i <= Constant.maxBedRooms; i++) {
      add.add(i.toString());
    }
    return add;
  }

  static List<String> getBathRoomList() {
    List<String> add = [];
    for (int i = 1; i <= Constant.maxBathRooms; i++) {
      add.add(i.toString());
    }
    return add;
  }

  static List<String> getTotalFloorsList() {
    List<String> add = [];
    for (int i = 1; i <= Constant.maxTotalFloor; i++) {
      add.add(i.toString());
    }
    return add;
  }

  static List<String> getFloorsList() {
    List<String> add = [];
    for (int i = 0; i < Constant.maxTotalFloor; i++) {
      add.add(i.toString());
    }
    return add;
  }

  static List<String> getCarParkingList() {
    List<String> add = [];
    for (int i = 0; i < Constant.maxCarParking; i++) {
      add.add(i.toString());
    }
    return add;
  }

  static String timeAgo(int time) {
    // Check if timestamp is in milliseconds (13 digits) or seconds (10 digits)
    if (time.toString().length == 10) {
      time = time * 1000; // Convert seconds to milliseconds
    }
    
    print(time.toString());
    
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

  static String getChatTime(time) {
    return DateFormat('dd MMM, yyyy h:mm a', 'en').format(
      DateTime.fromMillisecondsSinceEpoch(time),
    );
  }

  static List<String> facingList = [
    'North-West',
    'North',
    'North-East',
    'West',
    'East',
    'South-West',
    'South',
    'South-East',
  ];

  static List<String> furnitureList = [
    'Furnished',
    'Not Furnished',
  ];

  static List<String> propertyCategoryList = [
    'Residential',
    'Commercial',
  ];
  static List<String> locationTypeList = ['City', 'Location'];
  static List<String> propertyTypeList = ['All', 'For Rent', 'For Sale'];
  // static List<String> userTypeList = [
  //   S.current.toBuyProperty,
  //   S.current.toSellProperty,
  //   S.current.iAmABroker,
  //   S.current.weAreAgency,
  // ];

  static getRadius({
    required double radius,
    required bool isRTL,
  }) {
    return isRTL
        ? BorderRadius.only(
            topRight: Radius.circular(radius),
            bottomRight: Radius.circular(radius),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(radius),
            bottomLeft: Radius.circular(radius),
          );
  }

  static String formatHHMMSS(int second) {
    int seconds = second;

    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if (hours == 0) {
      return "$minutesStr:$secondsStr";
    }

    return "$hoursStr:$minutesStr:$secondsStr";
  }



  // static void shareBranch(
  //     {required String? title,
  //     required String? image,
  //     required String? description,
  //     required String key,
  //     required int? id}) async {
  //   CommonUI.loader();
  //   BranchUniversalObject buo = BranchUniversalObject(
  //       canonicalIdentifier: 'flutter/branch',
  //       title: title ?? '',
  //       imageUrl: image ?? '',
  //       contentDescription: description ?? '',
  //       publiclyIndex: true,
  //       locallyIndex: true);
  //   BranchLinkProperties lp = BranchLinkProperties();
  //   lp.addControlParam(key, id);
  //   if (Platform.isIOS) {
  //     if (buo.imageUrl != '') {
  //       await FlutterBranchSdk.showShareSheet(buo: buo, linkProperties: lp, messageText: '');
  //     } else {
  //       await rootBundle.load(AssetRes.appIcon).then((data) {
  //         FlutterBranchSdk.shareWithLPLinkMetadata(
  //             buo: buo, linkProperties: lp, icon: data.buffer.asUint8List(), title: title ?? '');
  //       });
  //     }
  //   } else {
  //     await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp).then((value) {
  //       Share.share(value.result ?? '', subject: title ?? '');
  //     });
  //   }
  //   Get.back();
  // }

  static String getConversationId(int? myId, int? otherUserId) {
    String convId = '${myId ?? -1}_${otherUserId ?? -1}';
    List<String> id = convId.split('_');
    id.sort((a, b) {
      return int.parse(a).compareTo(int.parse(b));
    });
    return id.join('_');
  }



}
