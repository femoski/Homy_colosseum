import 'package:get/get.dart';
import 'package:homy/models/settings/settings_model.dart';
import 'package:homy/models/settings/module_model.dart';

class SettingsService extends GetxService {
  final RxList<SettingsModel> settings = <SettingsModel>[].obs;
  
  Future<SettingsService> init() async {
    // Load settings from API or local storage
    await loadSettings();
    return this;
  }

  Future<void> loadSettings() async {
    try {
      // Example of creating settings
      final paymentModule = ModuleModel(
        id: '1',
        name: 'Payment',
        description: 'Payment settings',
        enabled: true,
        options: {
          'wallet_enabled': true,
          'card_enabled': true,
          'minimum_balance': 50.0,
          'service_fee': 10.0,
        },
      );

      final walletSetting = SettingsModel(
        id: '1',
        key: 'wallet_payment',
        value: 'true',
        enabled: true,
        module: paymentModule,
      );

      settings.add(walletSetting);
      
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  // Get setting by key
  SettingsModel? getSetting(String key) {
    try {
      return settings.firstWhere((setting) => setting.key == key);
    } catch (e) {
      return null;
    }
  }

  // Get module setting
  T? getModuleOption<T>(String moduleName, String optionKey) {
    try {
      final setting = settings.firstWhere(
        (setting) => setting.module?.name == moduleName,
      );
      return setting.module?.getOption<T>(optionKey);
    } catch (e) {
      return null;
    }
  }

  // Check if a module is enabled
  bool isModuleEnabled(String moduleName) {
    try {
      final setting = settings.firstWhere(
        (setting) => setting.module?.name == moduleName,
      );
      return setting.module?.isEnabled ?? false;
    } catch (e) {
      return false;
    }
  }
} 