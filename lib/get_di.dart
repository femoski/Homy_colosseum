import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:homy/services/audio_manager_service.dart';
import 'package:homy/services/auth_service.dart';
import 'package:homy/services/categories_service.dart';
import 'package:homy/services/deep_link_service.dart';
import 'package:homy/services/fcm_service.dart';
import 'package:homy/services/location_service.dart';
import 'package:homy/services/websocket_service.dart';
import 'package:homy/services/solana_wallet_service.dart';
import 'package:homy/services/nft_marketplace_service.dart';

Future<Map<String, Map<String, String>>> init() async {
  await GetStorage.init();
  Get.put(AuthService());

    await Get.putAsync(() => AuthService().init());
   Get.putAsync(() => WebSocketService().init());
   Get.putAsync(() => DeepLinkService().init());

  Get.put(CategoriesService());
  // Get.put(SettingsService());

  Get.put(LocationService());
  // Get.put(SavedRequirementService());


  // Initialize AudioManagerService
  Get.put(AudioManagerService());
  MobileAds.instance.initialize();

  // // Initialize FCM Service
   Get.putAsync(() => FCMService().init());
   
  // // Initialize FCM Notification Service
  // Get.put(FCMNotificationService());

  // Initialize Web3/NFT services
  Get.put(SolanaWalletService());
  Get.put(NFTMarketplaceService());

 return {};
}
