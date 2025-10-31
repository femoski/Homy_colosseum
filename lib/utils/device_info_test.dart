import 'package:get/get.dart';
import 'device_info_utils.dart';

/// Simple test to verify device info generation
class DeviceInfoTest {
  static Future<void> testDeviceInfo() async {
    try {
      Get.log('=== Testing Device Info Generation ===');
      
      // Test basic device info
      final deviceInfo = await DeviceInfoUtils.getDeviceInfo();
      Get.log('Basic device info: $deviceInfo');
      
      // Test user-friendly ID generation
      final userFriendlyId = await DeviceInfoUtils.generateUserFriendlyDeviceId();
      Get.log('User-friendly ID: $userFriendlyId');
      
      // Test support fingerprint
      final supportFingerprint = await DeviceInfoUtils.generateSupportDeviceFingerprint();
      Get.log('Support fingerprint: $supportFingerprint');
      
      // Test comprehensive support info
      final supportInfo = await DeviceInfoUtils.getSupportDeviceInfo();
      Get.log('Support device info: $supportInfo');
      
      Get.log('=== Device Info Test Complete ===');
    } catch (e) {
      Get.log('Error in device info test: $e');
    }
  }
} 