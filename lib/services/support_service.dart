import 'package:get/get.dart';
import 'package:homy/utils/device_info_utils.dart';
import 'package:homy/services/auth_service.dart';
import 'package:homy/providers/api_client.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/utils/constants.dart';

class SupportService extends GetxService {
  final ApiClient _apiClient = ApiClient(appBaseUrl: Constants.baseUrl);
  
  // Singleton pattern
  static SupportService? _instance;
  static SupportService get instance => _instance ??= SupportService._();
  SupportService._();
  
  /// Creates a support ticket with device information
  /// This method sends device info to server without exposing sensitive data to user
  Future<Map<String, dynamic>> createSupportTicket({
    required String subject,
    required String description,
    String? category,
    String? priority,
  }) async {
    try {
      // Get comprehensive device info for server
      final deviceInfo = await DeviceInfoUtils.getSupportDeviceInfo();
      final userFriendlyId = deviceInfo['user_friendly_id'];
      
      // Prepare ticket data
      final ticketData = {
        'subject': subject,
        'description': description,
        'category': category ?? 'general',
        'priority': priority ?? 'medium',
        'device_info': deviceInfo, // Full device info for server
        'user_friendly_device_id': userFriendlyId, // Show this to user
        'user_id': Get.find<AuthService>().user.value?.id,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Send to server
      final response = await _apiClient.postData('support/tickets', ticketData);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final ticketId = response.body['ticket_id'];
        
        return {
          'success': true,
          'ticket_id': ticketId,
          'user_friendly_device_id': userFriendlyId,
          'message': 'Support ticket created successfully',
        };
      } else {
        throw Exception('Failed to create support ticket');
      }
    } catch (e) {
      Get.log('Error creating support ticket: $e');
      return {
        'success': false,
        'message': 'Failed to create support ticket: $e',
      };
    }
  }
  
  /// Gets device information for user to share with support
  /// This only shows non-sensitive information to the user
  Future<Map<String, dynamic>> getUserFriendlyDeviceInfo() async {
    try {
      Get.log('Getting user-friendly device info...');
      final deviceInfo = await DeviceInfoUtils.getDeviceInfo();
      final userFriendlyId = await DeviceInfoUtils.generateUserFriendlyDeviceId();
      
      final result = {
        'device_name': deviceInfo['device_name'],
        'device_type': deviceInfo['device_type'],
        'platform': deviceInfo['platform'],
        'app_version': deviceInfo['app_version'],
        'user_friendly_id': userFriendlyId,
        'support_code': userFriendlyId, // For easy reference
      };
      
      Get.log('User-friendly device info result: $result');
      return result;
    } catch (e) {
      Get.log('Error getting user-friendly device info: $e');
      return {
        'device_name': 'Unknown Device',
        'device_type': 'unknown',
        'platform': 'Unknown Platform',
        'app_version': '1.0.0',
        'user_friendly_id': 'DEV-UNK-000',
        'support_code': 'DEV-UNK-000',
      };
    }
  }
  
  /// Validates a support device ID (for support staff)
  /// This allows support to verify device information using the user-friendly ID
  Future<Map<String, dynamic>> validateSupportDeviceId(String userFriendlyId) async {
    try {
      final response = await _apiClient.getData('support/validate-device/$userFriendlyId');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'device_info': response.body['device_info'],
          'ticket_history': response.body['ticket_history'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': 'Device ID not found',
        };
      }
    } catch (e) {
      Get.log('Error validating support device ID: $e');
      return {
        'success': false,
        'message': 'Error validating device ID',
      };
    }
  }
  
  /// Logs a support interaction for tracking
  Future<void> logSupportInteraction({
    required String interactionType,
    required String description,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final deviceInfo = await DeviceInfoUtils.getSupportDeviceInfo();
      
      final logData = {
        'interaction_type': interactionType,
        'description': description,
        'device_info': deviceInfo,
        'user_id': Get.find<AuthService>().user.value?.id,
        'timestamp': DateTime.now().toIso8601String(),
        'additional_data': additionalData ?? {},
      };
      
      await _apiClient.postData('support/logs', logData);
    } catch (e) {
      Get.log('Error logging support interaction: $e');
    }
  }
  
  /// Generates a support report with device information
  Future<String> generateSupportReport() async {
    try {
      final deviceInfo = await DeviceInfoUtils.getSupportDeviceInfo();
      final userFriendlyInfo = await getUserFriendlyDeviceInfo();
      
      final report = '''
Support Report
=============

Device Information:
- Device: ${userFriendlyInfo['device_name']}
- Type: ${userFriendlyInfo['device_type']}
- Platform: ${userFriendlyInfo['platform']}
- App Version: ${userFriendlyInfo['app_version']}
- Support Code: ${userFriendlyInfo['support_code']}

User Information:
- User ID: ${Get.find<AuthService>().user.value?.id ?? 'Not logged in'}
- Email: ${Get.find<AuthService>().user.value?.email ?? 'Not available'}

Technical Details (for support staff):
- Device Fingerprint: ${deviceInfo['support_fingerprint']}
- Session ID: ${deviceInfo['session_id']}
- Timestamp: ${deviceInfo['timestamp']}

Please provide this support code to our support team: ${userFriendlyInfo['support_code']}
''';
      
      return report;
    } catch (e) {
      Get.log('Error generating support report: $e');
      return 'Error generating support report';
    }
  }
} 