import 'package:get/get.dart';
import 'device_info_utils.dart';

/// Example usage of DeviceInfoUtils
/// This file demonstrates how to use the DeviceInfo map in your Flutter app
class DeviceInfoExample {
  
  /// Example function showing how to get device information
  static Future<void> showDeviceInfo() async {
    try {
      // Get device information
      final Map<String, dynamic> deviceInfo = await DeviceInfoUtils.getDeviceInfo();
      
      // Log the device information
      Get.log('=== Device Information ===');
      Get.log('Device Name: ${deviceInfo['device_name']}');
      Get.log('Device Type: ${deviceInfo['device_type']}');
      Get.log('App Version: ${deviceInfo['app_version']}');
      Get.log('Platform: ${deviceInfo['platform']}');
      Get.log('========================');
      
      // Example of how the data looks:
      // Device Name: iPhone 14 Pro
      // Device Type: ios
      // App Version: 1.2.0
      // Platform: iOS 17.0
      
    } catch (e) {
      Get.log('Error getting device info: $e');
    }
  }
  
  /// Example function showing how to use device info in API calls
  static Future<Map<String, dynamic>> prepareApiData({
    required String username,
    required String email,
    required String password,
  }) async {
    // Get device information
    final Map<String, dynamic> deviceInfo = await DeviceInfoUtils.getDeviceInfo();
    
    // Prepare API data with device information
    return {
      'username': username,
      'email': email,
      'password': password,
      'device_info': deviceInfo, // This contains device_name, device_type, app_version, platform
    };
  }
  
  /// Example function showing how to check device type
  static Future<bool> isMobileDevice() async {
    final Map<String, dynamic> deviceInfo = await DeviceInfoUtils.getDeviceInfo();
    final String deviceType = deviceInfo['device_type'];
    
    return deviceType == 'android' || deviceType == 'ios';
  }
  
  /// Example function showing how to get app version for update checks
  static Future<String> getAppVersion() async {
    final Map<String, dynamic> deviceInfo = await DeviceInfoUtils.getDeviceInfo();
    return deviceInfo['app_version'];
  }
} 