// ignore_for_file: file_names

import 'package:flutter/material.dart';

const String svgPath = 'assets/svg/';

class Constant {

  static const double appVersion = 2.12; ///Flutter Version: 3.24.5

  static const String base = '------- Base Url -----';
  static const String apiKey = '123';

  //backend url  
  static const String baseUrl = '';
  
  static const String itemBase = '';

  /// Google Search Place Api Key
  static const String searchKey = '------ Paid Key ------';

  /// RevenueCat config
  static const String revenueCatAppleApiKey = '----- Apple Key ----';
  static const String revenueCatAndroidApiKey = '---- Android Key ----';

  /// FCM
  static const String subscribeTopic = 'homely';
  
  static const String appName = "Property App";
  static const String androidPackageName = "com.property.app";
  static const String iOSAppId = "123456789";
 


  //Do not add anything here
  static String googlePlaceAPIkey = "YOUR_GOOGLE_PLACES_API_KEY";

  ////Payment gateway API keys
  static String razorpayKey = "rzp_test_1234567890";

  //paystack
  static String paystackKey = "pk_test_1234567890";
  // public key
  static String paystackCurrency = "NGN";

  ///Paypal
  static String paypalClientId = "YOUR_PAYPAL_CLIENT_ID";
  static String paypalServerKey = "YOUR_PAYPAL_SECRET_KEY"; //secret

  static bool isSandBoxMode = true; //testing mode
  static String paypalCancelURL = "https://propertyapp.com/cancel";
  static String paypalReturnURL = "https://propertyapp.com/success";

  /////////////////////////////////

  // static late Session session;
  static String currencySymbol = "\u{20A6}";
  //
  static int otpTimeOutSecond = 60; //otp time out
  static int otpResendSecond = 30; // resend otp timer
  //

  static String logintypeMobile = "1"; //always 1
  //
  static String maintenanceMode = "0"; //OFF
  static bool isUserDeactivated = false;
  //
  static String valSellBuy = "0";
  static String valRent = "1";
  //
  static int loadLimit = 20;

  static const String defaultCountryCode = "91";

  ///This maxCategoryLength is for show limited number of categories and show "More" button,
  ///You have to set less than [loadLimit] constant

  static const int maxCategoryLength = 10;

  //

  ///Lottie animation
  static const String progressLottieFile = "assets/lottie/loading.json";
  static const String progressLottieFileWhite = "assets/lottie/loading_white.json"; //When there is dark background and you want to show progress so it will be used

  static const String maintenanceModeLottieFile = "assets/lottie/maintenance.json";

  ///

  ///Put your loading json file in assets/lottie/ folder
  static const bool useLottieProgress = true; //if you don't want to use lottie progress then set it to false'

  static const String notificationChannel = "property_app_channel";
  static int uploadImageQuality = 80; //0 to 100

  static String? subscriptionPackageId;
  // static PropertyFilterModel? propertyFilter;
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static String typeRent = "rent";
  static String generalNotification = "0";
  static String enquiryNotification = "1";
  static String notificationPropertyEnquiry = "property_inquiry";
  static String notificationDefault = "default";
  //0: last_week   1: yesterday
  static String filterLastWeek = "0";
  static String filterYesterday = "1";
  static String filterAll = "";



  static bool showExperimentals = false;
  //Don't touch this settings
  static bool isUpdateAvailable = false;
  static String newVersionNumber = "";
  static bool isNumberWithSuffix = false;

  static List<Type> hydratedCubits = [];

  //Demo mode settings
  static bool isDemoModeOn = false;
  static String demoCountryCode = "91";
  static String demoMobileNumber = "9876543210";
  static String demoModeOTP = "123456";
  /// email Login
  static const String cDollar = '\$';
  static const String cPaginationLimit = '15';
  static const int cFirebaseDocumentLimit = 20;

/// documents to be fetched per request
  static const int maximumVideoSizeInMb = 50;

/// Maximum Video Mb Size
  static const int maxBedRooms = 10;
  static const int maxBathRooms = 10;
  static const int maxTotalFloor = 21;
  static const int maxCarParking = 3;
  static const double minPriceRange = 0;
  static const double maxPriceRange = 10000000000;
  static const double minAreaRange = 0;
  static const double maxAreaRange = 900000;
  static const double minRadius = 0;
  static const double maxRadius = 100;

  static const int cMaxWidthVideo = 720;
  static const int cMaxHeightVideo = 720;
  static const int cQualityVideo = 100;
  static const double cMaxWidthImage = 1280;
  static const double cMaxHeightImage = 720;
  static const int cQualityImage = 90;

  // Capture story video duration in second
  static const int storyVideoDuration = 30;

  static String get apiToken => 'YOUR_API_TOKEN'; // Replace with actual token or get from storage
}

const String cPaginationLimit = '15';


const int maximumVideoSizeInMb = 50;
