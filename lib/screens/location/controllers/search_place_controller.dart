import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/models/place_model.dart';
import 'package:homy/repositories/location_repository.dart';

class SearchPlaceController extends GetxController {
  final searchController = TextEditingController();
  final recentSearches = <PlaceModel>[].obs;
  final isLoading = false.obs;
  final searchResults = <PlaceModel>[].obs;
  final selectedPlace = Rxn<PlaceModel>();
  final isProcessing = false.obs;
  
  final _locationRepository = LocationRepository();
  final _storage = GetStorage();
  Timer? _debounce;

  @override
  void onInit() {
    _loadRecentSearches();
    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  void _loadRecentSearches() async {
    try {
      final recentPlacesJson = _storage.read<List<dynamic>>('recent_places') ?? [];
      recentSearches.value = recentPlacesJson
          .map((json) => PlaceModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error loading recent places: $e');
    }
  }

  void onChanged(String value) {
    if (searchController.text.isNotEmpty) {
      update();
    }
  }

  void onTap(PlaceModel? data) {
    if (data?.description != null) {
      CommonUI.loader();
    } else {
      CommonUI.snackBar(title: 'Something went wrong, try again');
    }
  }

  void initPref() async {
    // await prefService.init();
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchPlaces(query);
    });
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      update();
      return;
    }
    
    isLoading.value = true;
    update();
    
    try {
      final results = await _locationRepository.searchCities(query);
      searchResults.value = results;
      update();
    } catch (e) {
      debugPrint('Error searching places: $e');
      searchResults.clear();
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> _saveToRecent(PlaceModel place) async {
    try {
      // Remove if already exists to avoid duplicates
      recentSearches.removeWhere((p) => p.placeId == place.placeId);
      
      // Add to start of list and limit to 5 recent places
      final updatedRecent = [place, ...recentSearches.take(4)];
      recentSearches.value = updatedRecent;

      // Save to local storage
      final recentPlacesJson = updatedRecent.map((p) => p.toJson()).toList();
      await _storage.write('recent_places', recentPlacesJson);
    } catch (e) {
      debugPrint('Error saving recent places: $e');
    }
  }

  void onMapClick() {
    // Get.to<LatLng>(() => MapScreen(latLng: latLng))?.then((value) {
    //   if (value != null) {
    //     Get.back(result: {
    //       uUserLatitude: value.latitude,
    //       uUserLongitude: value.longitude,
    //     });
    //   }
    // });
  }

  void selectPlace(PlaceModel place) {
    if (selectedPlace.value?.placeId == place.placeId) {
      selectedPlace.value = null;
    } else {
      selectedPlace.value = place;
    }
    update();
  }

  void confirmSelectedPlace() async {
    if (selectedPlace.value != null) {
      isProcessing.value = true;
      update();
      
      try {
        final placeDetails = await _locationRepository.getPlaceDetailsFromPlaceId(selectedPlace.value!.placeId);
        final updatedPlace = selectedPlace.value!.copyWith(
          latitude: placeDetails['lat'].toString(),
          longitude: placeDetails['lng'].toString(),
          state: placeDetails['state'].toString(),
        );
        
        // Save to recent searches before returning
        await _saveToRecent(updatedPlace);
        
        Get.back(result: updatedPlace);
      } finally {
        isProcessing.value = false;
        update();
      }
    }
  }
}
