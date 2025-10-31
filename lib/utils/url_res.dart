
import 'package:homy/utils/app_constant.dart';

class UrlRes {
  // static const String fetchFAQs = '${ConstRes.baseUrl}fetchFAQs';
  // static const String addUser = '${ConstRes.baseUrl}addUser';
  // static const String fetchProfileDetail = '${ConstRes.baseUrl}fetchProfileDetail';
  // static const String fetchPropertyDetail = '${ConstRes.baseUrl}fetchPropertyDetail';
  // static const String editProfile = '${ConstRes.baseUrl}editProfile';
  // static const String addProperty = '${ConstRes.baseUrl}addProperty';
  // static const String fetchPropertyType = '${ConstRes.baseUrl}fetchPropertyType';
  // static const String logout = '${ConstRes.baseUrl}logout';
  // static const String deleteMyAccount = '${ConstRes.baseUrl}deleteMyAccount';
  // static const String addSupport = '${ConstRes.baseUrl}addSupport';
  // static const String fetchSavedProperties = '${ConstRes.baseUrl}fetchSavedProperties';
  // static const String fetchHomePageData = '${ConstRes.baseUrl}fetchHomePageData';
  // static const String fetchMyProperties = '${ConstRes.baseUrl}fetchMyProperties';
  // static const String editProperty = '${ConstRes.baseUrl}editProperty';
  // static const String fetchPropertiesByType = '${ConstRes.baseUrl}fetchPropertiesByType';
  // static const String createScheduleTour = '${ConstRes.baseUrl}createScheduleTour';
  // static const String fetchPropertyReceiveTourList = '${ConstRes.baseUrl}fetchPropertyReceiveTourList';
  // static const String fetchPropertyTourSubmittedList = '${ConstRes.baseUrl}fetchPropertyTourSubmittedList';
  // static const String fetchSettings = '${ConstRes.baseUrl}fetchSettings';
  // static const String confirmPropertyTour = '${ConstRes.baseUrl}confirmPropertyTour';
  // static const String declinePropertyTour = '${ConstRes.baseUrl}declinePropertyTour';
  // static const String completedPropertyTour = '${ConstRes.baseUrl}completedPropertyTour';
  // static const String searchProperty = '${ConstRes.baseUrl}searchProperty';
  // static const String deleteMyProperty = '${ConstRes.baseUrl}deleteMyProperty';
  // static const String reportUser = '${ConstRes.baseUrl}reportUser';
  // static const String fetchBlockUserList = '${ConstRes.baseUrl}fetchBlockUserList';
  // static const String uploadFileGivePath = '${ConstRes.baseUrl}uploadFileGivePath';
  // static const String fetchPlatformNotification = '${ConstRes.baseUrl}fetchPlatformNotification';
  // static const String pushNotificationToSingleUser = '${ConstRes.baseUrl}pushNotificationToSingleUser';
  // static const String oneSignalNotification = 'https://onesignal.com/api/v1/notifications';
  // static const String termsOfUse = '${ConstRes.base}privacyPolicy';
  // static const String privacyPolicy = '${ConstRes.base}termsOfUse';

  static String getLatLong({required String description, required String apiKey}) =>
      'https://maps.googleapis.com/maps/api/geocode/json?address=$description&key=$apiKey';

  static String searchPlace({required String description, required String apiKey}) =>
      'https://maps.googleapis.com/maps/api/place/queryautocomplete/json?input=$description&key=$apiKey';

  static String googleMapUrl(double latitude, double longitude) {
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  }

  static String appleMapUrl(double latitude, double longitude) {
    return 'https://maps.apple.com/?q=$latitude,$longitude';
  }

  // static const String uploadReel = '${ConstRes.baseUrl}uploadReel';
  static const String fetchReelsByUser = '${Constant.baseUrl}fetchReelsByUser';
  static const String generateReel = 'reels';
  static const String nearByReels = 'reels/nearby';
  static const String followingReels = 'reels/following';
  static const String forYouReels = 'reels/for-you';

  // static const String deleteReel = '${ConstRes.baseUrl}deleteReel';
  static const String fetchReelsByHashtag = '${Constant.baseUrl}fetchReelsByHashtag';
  // static const String increaseReelViewCount = '${ConstRes.baseUrl}increaseReelViewCount';
  // static const String likeReel = '${ConstRes.baseUrl}likeReel';
  // static const String dislikeReel = '${ConstRes.baseUrl}dislikeReel';
  // static const String followUser = '${ConstRes.baseUrl}followUser';
  // static const String unfollowUser = '${ConstRes.baseUrl}unfollowUser';
  // static const String addComment = '${ConstRes.baseUrl}addComment';
  // static const String fetchComments = '${ConstRes.baseUrl}fetchComments';
  // static const String fetchFollowingList = '${ConstRes.baseUrl}fetchFollowingList';
  // static const String fetchFollowersList = '${ConstRes.baseUrl}fetchFollowersList';
  // static const String addReport = '${ConstRes.baseUrl}addReport';
  static const String fetchSavedReels = '${Constant.baseUrl}fetchSavedReels';
  // static const String fetchReelById = '${ConstRes.baseUrl}fetchReelById';
  // static const String fetchUserNotifications = '${ConstRes.baseUrl}fetchUserNotifications';
}

const String uApiKey = 'apikey';
const String uPost = 'POST';
const String uFullName = 'fullname';
const String uEmail = 'email';
const String uUserType = 'user_type';
const String uLoginType = 'login_type';
const String uDeviceType = 'device_type';
const String uDeviceToken = 'device_token';
const String uVerificationStatus = 'verification_status';
const String uUserId = 'user_id';
const String uMyUserId = 'my_user_id';
const String uPropertyId = 'property_id';
const String uSavedPropertyIds = 'saved_property_ids';
const String uFax = 'fax';
const String uMobileNo = 'mobile_no';
const String uPhoneOffice = 'phone_office';
const String uProfile = 'profile';
const String uSubject = 'subject';
const String uDescription = 'description';
const String uStart = 'start';
const String uLimit = 'limit';
const String uUserLatitude = 'user_latitude';
const String uUserLongitude = 'user_longitude';
const String uType = 'type';
const String uCity = 'city';
const String uIsNotification = 'is_notification';

/// Overview
const String uTitle = 'title';
const String uPropertyCategory = 'property_category';
const String uPropertyTypeId = 'property_type_id';
const String uBedrooms = 'bedrooms';
const String uBathrooms = 'bathrooms';
const String uArea = 'area';
const String uAbout = 'about';

/// Location
const String uAddress = 'address';
const String uLatitude = 'latitude';
const String uLongitude = 'longitude';
const String uFarFromHospital = 'far_from_hospital';
const String uFarFromSchool = 'far_from_school';
const String uFarFromGym = 'far_from_gym';
const String uFarFromMarket = 'far_from_market';
const String uFarFromGasoline = 'far_from_gasoline';
const String uFarFromAirport = 'far_from_airport';

///Attributes

const String uSocietyName = 'society_name';
const String uBuiltYear = 'built_year';
const String uFurniture = 'furniture';
const String uFacing = 'facing';
const String uTotalFloors = 'total_floors';
const String uFloorNumber = 'floor_number';
const String uCarParkings = 'car_parkings';
const String uMaintenanceMonth = 'maintenance_month';

/// Media
const String uOverviewsImage = 'overview[]';
const String uBedroomImage = 'bedroom[]';
const String uBathroomImage = 'bathroom[]';
const String uFloorPlanImage = 'floor_plan[]';
const String uPropertyVideo = 'property_video[]';
const String uOtherImageImage = 'other_image[]';
const String uThreeSixtyImage = 'three_sixty[]';
const String uThumbnail = 'thumbnail';

/// Pricing
const String uPropertyAvailableFor = 'property_available_for';
const String uFirstPrice = 'first_price';
const String uSecondPrice = 'second_price';

const String uIsHidden = 'is_hidden';
const String uTimeZone = 'time_zone';
const String uRemoveMediaId = 'remove_media_id[]';
const String uTourStatus = 'tour_status';

const String uPropertyTourId = 'property_tour_id';
const String uRadius = 'radius';
const String uPriceFrom = 'price_from';
const String uPriceTo = 'price_to';
const String uAreaFrom = 'area_from';
const String uAreaTo = 'area_to';
const String uReason = 'reason';
const String uDesc = 'desc';
const String uBlockUserIds = 'block_user_ids';
const String uUploadFile = 'uploadFile';

const String uAppId = 'app_id';
const String uIncludePlayerIds = 'include_player_ids';
const String uSmallIcon = 'small_icon';
const String uData = 'data';
const String uHeadings = 'headings';
const String uContents = 'contents';
const String uAndroidChannelId = 'android_channel_id';

// Notification
const String uConversationId = 'conversation_id';

// Reel
const String uContent = 'content';
const String uHashtags = 'hashtags';
const String uReelId = 'reel_id';
const String uHashtag = 'hashtag';
const String uSavedReelIds = 'saved_reel_ids';
