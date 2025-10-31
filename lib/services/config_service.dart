import 'package:get/get.dart';
import 'package:homy/models/config/config_model.dart';
import 'package:homy/providers/api_client.dart';
import 'package:homy/utils/constants.dart';

class ConfigService extends GetxService {
  final Rx<ConfigModel?> config = Rx<ConfigModel?>(null);
    final apiClient = ApiClient(appBaseUrl: Constants.baseUrl);

  // Initialize with default configuration
  Future<ConfigService> init() async {
    try {
      await fetchConfig();
      return this;
    } catch (e) {
      print('Error initializing config service: $e');
      rethrow;
    }
  }

  // Fetch configuration from API
  Future<void> fetchConfig() async {
    try {
      if (config.value == null) {
        final response = await apiClient.getData('config');
        Get.log('Config fetched: ${response.body['data']}');
        config.value = ConfigModel.fromJson(response.body['data']);
      }
    } catch (e) {
      Get.log('Error fetching config: $e');
      rethrow;
    }
  }

  // Update configuration
  Future<void> updateConfig(ConfigModel newConfig) async {
    try {
      // TODO: Implement API call to update configuration
      // await _apiClient.updateConfig(newConfig.toJson());
      config.value = newConfig;
    } catch (e) {
      print('Error updating config: $e');
      rethrow;
    }
  }

  // Helper methods to access specific configurations
  String? get name => config.value?.name;
  
  String? get keywords => config.value?.keywords;
  
  String? get email => config.value?.email;
  
  String? get description => config.value?.description;
  
  String? get timezone => config.value?.timezone;
  
  bool? get maintenance => config.value?.maintenance;
  
  String? get message => config.value?.message;
  
  String? get address => config.value?.address;
  
  String? get phone => config.value?.phone;
  
  CentralizeLogin get centralizeLogin => 
      config.value?.centralizeLogin ?? CentralizeLogin();
      
  UploadConfig get uploadConfig =>
      config.value?.uploadConfig ?? UploadConfig();
      
  SocialMedia get socialMedia =>
      config.value?.socialMedia ?? SocialMedia();

    
  ChatConfig get chatConfig =>
      config.value?.chatConfig ?? ChatConfig();

  SupportConfig get supportConfig =>
      config.value?.supportConfig ?? SupportConfig();


  AdsModel get adsModel =>
      config.value?.adsModel ?? AdsModel();

  AppVersion get appVersion =>
      config.value?.appVersion ?? AppVersion();

  AppConfig get appConfig =>
      config.value?.appConfig ?? AppConfig();

  // // Helper methods to access specific configurations
  // RegistrationConfig get registrationConfig => 
  //     config.value?.registrationConfig ?? RegistrationConfig();

  // PropertyConfig get propertyConfig => 
  //     config.value?.propertyConfig ?? PropertyConfig();

  // AppearanceConfig get appearanceConfig => 
  //     config.value?.appearanceConfig ?? AppearanceConfig();

  // NotificationConfig get notificationConfig => 
  //     config.value?.notificationConfig ?? NotificationConfig();

  bool get isMaintenanceMode => config.value?.maintenance ?? false;

  
  // Static helper method to get config service and ensure it's initialized
  static Future<ConfigService> getConfig() async {
    if (!Get.isRegistered<ConfigService>()) {
      await Get.putAsync(() => ConfigService().init());
    } else {
      final configService = Get.find<ConfigService>();
      if (configService.config.value == null) {
        await configService.fetchConfig();
      }
    }
    return Get.find<ConfigService>();
  }
} 