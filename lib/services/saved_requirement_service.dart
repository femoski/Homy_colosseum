import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:homy/models/saved_requirement_model.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/services/auth_service.dart';
import 'package:homy/services/fcm_service.dart';
import 'package:homy/providers/api_client.dart';
import 'package:homy/utils/constants.dart';

class SavedRequirementService extends GetxService {
  static const String _requirementKey = 'saved_property_requirement';
  static const String _lastSyncKey = 'requirement_last_sync';
    final ApiClient _apiClient = ApiClient(appBaseUrl: Constants.baseUrl);

  final _storage = GetStorage();
  // final _authService = AuthService.getAuth();
    final AuthService _authService = Get.find<AuthService>();

  // Observable for current requirement
  final Rx<SavedRequirement?> currentRequirement = Rx<SavedRequirement?>(null);
  
  // Observable for matched properties
  final RxList<PropertyData> matchedProperties = <PropertyData>[].obs;
  
  // Observable for loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedRequirement();
    
    // Listen to authentication state changes
    ever(_authService.isAuth.obs, (bool isLoggedIn) {
      if (isLoggedIn) {
        // User logged in, sync with backend
        // _loadFromBackend();
        forceBidirectionalSync();
        Get.log('User logged in, syncing with backend');
      }
    });
  }

  // Load saved requirement from local storage and backend
  Future<void> _loadSavedRequirement() async {
    try {
      // First load from local storage for immediate access
      final localRequirementJson = _storage.read(_requirementKey);
      if (localRequirementJson != null) {
        currentRequirement.value = SavedRequirement.fromJson(localRequirementJson);
      }
      
      // Then try to load from backend if user is authenticated

      Get.log('isAuth: ${_authService.isAuth}');
      if (_authService.isAuth) {
          // await _loadFromBackend();
          await forceBidirectionalSync();
        Get.log('User logged in, syncing with backend');
      }
    } catch (e) {
      Get.log('Error loading saved requirement: $e');
    }
  }

  // Load requirement from backend
  Future<void> _loadFromBackend() async {
    try {
      final response = await _apiClient.getData('property-requirements');
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;
        if (data['status'] == 200 && data['data'] != null) {
          // Handle nested requirements structure
          final requirementsData = data['data']['requirements'] ?? data['data'];
          final backendRequirement = SavedRequirement.fromJson(requirementsData);
          Get.log('backend data: ${backendRequirement.toJson()}');
          // Compare with local version and use the most recent one
          final localRequirement = currentRequirement.value;
          if (localRequirement == null || 
              backendRequirement.updatedAt.isAfter(localRequirement.updatedAt)) {
            // Backend version is newer, use it
            currentRequirement.value = backendRequirement;
            await _storage.write(_requirementKey, backendRequirement.toJson());
            Get.log('Requirement loaded from backend (newer version)');
          } else if (localRequirement.updatedAt.isAfter(backendRequirement.updatedAt)) {
            // Local version is newer, sync to backend
            await _syncWithBackend(localRequirement);
            Get.log('Local requirement synced to backend');
          }
        }
      } else if (response.statusCode == 404) {
        // No requirements found for this user
        Get.log('No requirements found for user on backend');
        // Keep local requirement if exists, or leave as null
        // Don't clear local data as user might have local requirements
      }
    } catch (e) {
      Get.log('Error loading from backend: $e');
      // Continue with local version if backend fails
    }
  }

  // Save requirement to local storage
  Future<void> saveRequirement(SavedRequirement requirement) async {

    Get.log('saveRequirement: ${_authService.isAuth}');
    try {
      isLoading.value = true;
      
      // Update timestamps
      final updatedRequirement = requirement.copyWith(
        updatedAt: DateTime.now(),
      );
      
      // Save to local storage
      await _storage.write(_requirementKey, updatedRequirement.toJson());
      currentRequirement.value = updatedRequirement;
      
      // Sync with backend if user is logged in
      if (_authService.isAuth) {
        await _syncWithBackend(updatedRequirement);
      }
      
      Get.log('Requirement saved successfully');
    } catch (e) {
      Get.log('Error saving requirement: $e');
      Get.snackbar('Error', 'Failed to save requirement');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete saved requirement
  Future<void> deleteRequirement() async {
    try {
      isLoading.value = true;
      
      // Remove from local storage
      await _storage.remove(_requirementKey);
      currentRequirement.value = null;
      matchedProperties.clear();
      
      // Remove from backend if user is logged in
      if (_authService.isAuth) {
        await _deleteFromBackend();
      }
      
      Get.log('Requirement deleted successfully');
    } catch (e) {
      Get.log('Error deleting requirement: $e');
      Get.snackbar('Error', 'Failed to delete requirement');
    } finally {
      isLoading.value = false;
    }
  }

  // Sync requirement with backend
  Future<void> _syncWithBackend(SavedRequirement requirement) async {
    try {
      final response = await _apiClient.postData('property-requirements', requirement.toJson());
      if (response.statusCode == 200) {
        await _storage.write(_lastSyncKey, DateTime.now().toIso8601String());
        Get.log('Requirement synced with backend successfully');
      } else {
        Get.log('Failed to sync with backend: ${response.statusCode}');
      }
    } catch (e) {
      Get.log('Error syncing with backend: $e');
      // Don't show error to user as local save was successful
    }
  }

  // Delete requirement from backend
  Future<void> _deleteFromBackend() async {
    try {
      final response = await _apiClient.deleteData('property-requirements');
      if (response.statusCode == 200) {
        Get.log('Requirement deleted from backend successfully');
      } else {
        Get.log('Failed to delete from backend: ${response.statusCode}');
      }
    } catch (e) {
      Get.log('Error deleting from backend: $e');
    }
  }

  // Check if property matches user requirements
  bool doesPropertyMatch(PropertyData property) {
    final requirement = currentRequirement.value;
    if (requirement == null || requirement.isEmpty) return false;

    // Check location match
    if (requirement.locations.isNotEmpty) {
      final propertyLocation = property.city?.toLowerCase() ?? '';
      final matchesLocation = requirement.locations.any(
        (location) => propertyLocation.contains(location.toLowerCase())
      );
      if (!matchesLocation) return false;
    }

    // Check price range match
    if (requirement.minPrice != null || requirement.maxPrice != null) {
      final propertyPrice = property.firstPrice ?? 0;
      
      if (requirement.minPrice != null && propertyPrice < requirement.minPrice!) {
        return false;
      }
      
      if (requirement.maxPrice != null && propertyPrice > requirement.maxPrice!) {
        return false;
      }
    }

    // Check property type match
    if (requirement.propertyTypes.isNotEmpty) {
      final propertyType = property.propertyType?.toLowerCase() ?? '';
      final matchesType = requirement.propertyTypes.any(
        (type) => propertyType.contains(type.toLowerCase())
      );
      if (!matchesType) return false;
    }

    // Check bedrooms match
    if (requirement.minBedrooms != null) {
      final propertyBedrooms = property.bedrooms ?? 0;
      if (propertyBedrooms < requirement.minBedrooms!) {
        return false;
      }
    }

    // Check bathrooms match
    if (requirement.minBathrooms != null) {
      final propertyBathrooms = property.bathrooms ?? 0;
      if (propertyBathrooms < requirement.minBathrooms!) {
        return false;
      }
    }

    return true;
  }

  // Find matching properties from a list
  List<PropertyData> findMatchingProperties(List<PropertyData> properties) {
    return properties.where((property) => doesPropertyMatch(property)).toList();
  }

  // Update matched properties list
  void updateMatchedProperties(List<PropertyData> allProperties) {
    final previousMatches = Set<int>.from(matchedProperties.map((p) => p.id!));
    final newMatches = findMatchingProperties(allProperties);
    
    // Check for new matches
    final newProperties = newMatches.where((property) => 
        !previousMatches.contains(property.id!)).toList();
    
    // Update the matched properties list
    matchedProperties.value = newMatches;
    
    // Send notifications for new matches
    if (newProperties.isNotEmpty) {
      _sendNotificationsForNewMatches(newProperties);
    }
  }

  // Send notifications for newly matched properties
  void _sendNotificationsForNewMatches(List<PropertyData> newProperties) async {
    try {
      final fcmService = Get.find<FCMService>();
      
      for (final property in newProperties) {
        await fcmService.showPropertyMatchNotification(
          propertyTitle: property.title ?? 'Property',
          propertyType: property.propertyType ?? 'Property',
          location: property.city ?? 'Location',
          propertyId: property.id!,
        );
      }
    } catch (e) {
      Get.log('Error sending property match notifications: $e');
    }
  }

  // Get requirement summary for display
  String getRequirementSummary() {
    final requirement = currentRequirement.value;
    if (requirement == null || requirement.isEmpty) {
      return 'No requirements set';
    }

    final parts = <String>[];
    
    if (requirement.locations.isNotEmpty) {
      parts.add('Location: ${requirement.locationsString}');
    }
    
    if (requirement.minPrice != null || requirement.maxPrice != null) {
      parts.add('Price: ${requirement.priceRangeString}');
    }
    
    if (requirement.propertyTypes.isNotEmpty) {
      parts.add('Type: ${requirement.propertyTypesString}');
    }
    
    if (requirement.minBedrooms != null) {
      parts.add('Bedrooms: ${requirement.bedroomsString}');
    }
    
    if (requirement.minBathrooms != null) {
      parts.add('Bathrooms: ${requirement.bathroomsString}');
    }

    return parts.join(' • ');
  }

  // Check if user has any requirements set
  bool get hasRequirements => currentRequirement.value?.hasCriteria ?? false;

  // Get current requirement
  SavedRequirement? get current => currentRequirement.value;

  // Force refresh from backend
  Future<void> refreshFromBackend() async {
    if (!_authService.isAuth) return;
    
    try {
      isLoading.value = true;
      // await _loadFromBackend();
      await forceBidirectionalSync();
      Get.log('Requirement refreshed from backend');
    } catch (e) {
      Get.log('Error refreshing from backend: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Check if sync is needed
  bool shouldSyncWithBackend() {
    if (!_authService.isAuth) return false;
    
    final lastSync = _storage.read(_lastSyncKey);
    if (lastSync == null) return true;
    
    final lastSyncTime = DateTime.parse(lastSync);
    final now = DateTime.now();
    
    // Sync if more than 1 hour has passed
    return now.difference(lastSyncTime).inHours >= 1;
  }

  // Auto-sync if needed
  Future<void> autoSyncIfNeeded() async {
    if (shouldSyncWithBackend()) {
      await refreshFromBackend();
    }
  }

  // Handle device switching - load from backend when user logs in on new device
  Future<void> handleDeviceSwitch() async {
    if (!_authService.isAuth) return;
    
    try {
      isLoading.value = true;
      
      // Always try to load from backend when handling device switch
      // await _loadFromBackend();
      await forceBidirectionalSync();
      Get.log('Device switch handled - requirements synced');
    } catch (e) {
      Get.log('Error handling device switch: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Check if local and backend versions are in sync
  Future<bool> isInSync() async {
    if (!_authService.isAuth) return true;
    
    try {
      final response = await _apiClient.getData('property-requirements');
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;
        if (data['status'] == 200 && data['data'] != null) {
          // Handle nested requirements structure
          final requirementsData = data['data']['requirements'] ?? data['data'];
          final backendRequirement = SavedRequirement.fromJson(requirementsData);
          final localRequirement = currentRequirement.value;
          
          if (localRequirement == null) return false;
          
          // Check if timestamps are the same (within 1 second tolerance)
          final timeDiff = backendRequirement.updatedAt.difference(localRequirement.updatedAt).abs();
          return timeDiff.inSeconds <= 1;
        }
      } else if (response.statusCode == 404) {
        // No requirements found for this user
        return currentRequirement.value == null;
      }
      return false;
    } catch (e) {
      Get.log('Error checking sync status: $e');
      return false;
    }
  }

  // Force sync both ways - upload local if newer, download backend if newer
  Future<void> forceBidirectionalSync() async {
    if (!_authService.isAuth) return;
    
    try {
      isLoading.value = true;
      final response = await _apiClient.getData('property-requirements');
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;
        if (data['status'] == 200 && data['data'] != null) {
          // Handle nested requirements structure
          final requirementsData = data['data']['requirements'] ?? data['data'];
          final backendRequirement = SavedRequirement.fromJson(requirementsData);
          final localRequirement = currentRequirement.value;
          
          if (localRequirement == null) {
            // No local requirement, use backend
            currentRequirement.value = backendRequirement;
            await _storage.write(_requirementKey, backendRequirement.toJson());
            Get.log('No local requirement - loaded from backend');
          } else if (backendRequirement.updatedAt.isAfter(localRequirement.updatedAt)) {
            // Backend is newer, use it
            currentRequirement.value = backendRequirement;
            await _storage.write(_requirementKey, backendRequirement.toJson());
            Get.log('Backend is newer - updated local');
          } else if (localRequirement.updatedAt.isAfter(backendRequirement.updatedAt)) {
            // Local is newer, sync to backend
            await _syncWithBackend(localRequirement);
            Get.log('Local is newer - synced to backend');
          } else {
            // They're the same, no action needed
            Get.log('Local and backend are in sync');
          }
        }
      } else if (response.statusCode == 404) {
        // No requirements found for this user on backend
        final localRequirement = currentRequirement.value;
        if (localRequirement != null) {
          // User has local requirements but none on backend, sync to backend
          await _syncWithBackend(localRequirement);
          Get.log('No backend requirements - synced local to backend');
        } else {
          Get.log('No requirements found on backend or locally');
        }
      }
    } catch (e) {
      Get.log('Error in bidirectional sync: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
