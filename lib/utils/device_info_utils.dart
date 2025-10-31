import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

class DeviceInfoUtils {
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String? firebaseId = '1234567890';
      String deviceName = '';
      String deviceType = '';
      String platform = '';
      String deviceId = '';
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        deviceName = '${androidInfo.brand} ${androidInfo.model}';
        deviceType = 'android';
        platform = 'Android ${androidInfo.version.release}';
        deviceId = androidInfo.id ?? '';
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        deviceName = '${iosInfo.name} ${iosInfo.modelName}';
        deviceType = 'ios';
        platform = 'iOS ${iosInfo.systemVersion}';
        deviceId = iosInfo.identifierForVendor ?? '';
      } else if (Platform.isWindows) {
        final WindowsDeviceInfo windowsInfo = await deviceInfoPlugin.windowsInfo;
        deviceName = '${windowsInfo.computerName}';
        deviceType = 'windows';
        platform = 'Windows ${windowsInfo.buildNumber}';
        deviceId = '';
      } else if (Platform.isMacOS) {
        final MacOsDeviceInfo macOsInfo = await deviceInfoPlugin.macOsInfo;
        deviceName = '${macOsInfo.computerName}';
        deviceType = 'macos';
        platform = 'macOS ${macOsInfo.osRelease}';
        deviceId = '';
      } else if (Platform.isLinux) {
        final LinuxDeviceInfo linuxInfo = await deviceInfoPlugin.linuxInfo;
        deviceName = '${linuxInfo.name}';
        deviceType = 'linux';
        platform = 'Linux ${linuxInfo.version}';
        deviceId = '';
      } else {
        deviceName = 'Unknown Device';
        deviceType = 'unknown';
        platform = 'Unknown Platform';
        deviceId = '';
      }
      
      return {
        'device_name': deviceName,
        'device_type': deviceType,
        'app_version': packageInfo.version,
        'platform': platform,
        'device_id': firebaseId ?? deviceId,
        // 'firebase_id': firebaseId,
      };
    } catch (e) {
      Get.log('Error getting device info: $e');
      String deviceId = '';
      String firebaseId = '1234567890';
      return {
        'device_name': 'Unknown Device',
        'device_type': 'unknown',
        'app_version': '1.0.0',
        'platform': 'Unknown Platform',
        'device_id': deviceId,
        'firebase_id': firebaseId,
      };
    }
  }

  /// Generates a secure device fingerprint for support purposes
  /// This creates a unique identifier without exposing raw device IDs to users
  static Future<String> generateSupportDeviceFingerprint() async {
    try {
      final deviceInfo = await getDeviceInfo();
      
      // Create a fingerprint from non-sensitive device characteristics
      final fingerprintData = {
        'device_name': deviceInfo['device_name'],
        'device_type': deviceInfo['device_type'],
        'platform': deviceInfo['platform'],
        'app_version': deviceInfo['app_version'],
        // Include a timestamp to make it more unique
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Convert to JSON and hash it
      final jsonString = jsonEncode(fingerprintData);
      final bytes = utf8.encode(jsonString);
      
      // Simple hash function (in production, use a proper cryptographic hash)
      int hash = 0;
      for (int byte in bytes) {
        hash = ((hash << 5) - hash + byte) & 0xFFFFFFFF;
      }
      
      // Convert to a readable format (8 characters)
      return hash.toRadixString(36).toUpperCase().padLeft(8, '0');
    } catch (e) {
      Get.log('Error generating device fingerprint: $e');
      return 'UNKNOWN';
    }
  }

  /// Generates a user-friendly device identifier for support
  /// This shows users a simple code they can share with support
  static Future<String> generateUserFriendlyDeviceId() async {
    try {
      final deviceInfo = await getDeviceInfo();
      
      Get.log('Generating user-friendly device ID from: $deviceInfo');
      
      // Create a simple, memorable identifier
      final deviceType = deviceInfo['device_type'].toString().toUpperCase();
      final deviceName = deviceInfo['device_name'].toString();
      
      // Extract first letter of each word in device name
      final nameInitials = deviceName
          .split(' ')
          .where((word) => word.isNotEmpty)
          .map((word) => word[0].toUpperCase())
          .take(3)
          .join('');
      
      // Generate a random 3-digit number
      final random = Random();
      final randomNumber = random.nextInt(900) + 100; // 100-999
      
      final result = '$deviceType-$nameInitials-$randomNumber';
      Get.log('Generated user-friendly device ID: $result');
      
      return result;
    } catch (e) {
      Get.log('Error generating user-friendly device ID: $e');
      return 'DEV-UNK-000';
    }
  }

  /// Gets comprehensive device info for server-side support
  /// This includes all necessary information for debugging without exposing to user
  static Future<Map<String, dynamic>> getSupportDeviceInfo() async {
    try {
      final deviceInfo = await getDeviceInfo();
      final supportFingerprint = await generateSupportDeviceFingerprint();
      final userFriendlyId = await generateUserFriendlyDeviceId();
      
      return {
        ...deviceInfo,
        'support_fingerprint': supportFingerprint,
        'user_friendly_id': userFriendlyId,
        'timestamp': DateTime.now().toIso8601String(),
        'session_id': DateTime.now().millisecondsSinceEpoch.toString(),
      };
    } catch (e) {
      Get.log('Error getting support device info: $e');
      return {
        'device_name': 'Unknown Device',
        'device_type': 'unknown',
        'app_version': '1.0.0',
        'platform': 'Unknown Platform',
        'support_fingerprint': 'UNKNOWN',
        'user_friendly_id': 'DEV-UNK-000',
        'timestamp': DateTime.now().toIso8601String(),
        'session_id': DateTime.now().millisecondsSinceEpoch.toString(),
      };
    }
  }
} 