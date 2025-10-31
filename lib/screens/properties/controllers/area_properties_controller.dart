import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/repositories/properties_respository.dart';

class AreaPropertiesController extends GetxController {
  final String areaName;
  final PropertiesRepository propertiesRepository = PropertiesRepository();
  
  final properties = <PropertyData>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;
  final error = Rx<String?>(null);
  int currentPage = 1;
  late ScrollController scrollController;

  // Filter related variables
  String? selectedPropertyType;
  final minPriceController = TextEditingController();
  final maxPriceController = TextEditingController();
  int? selectedBedrooms;
  int? selectedBathrooms;
  String sortBy = 'newest';
  
  AreaPropertiesController(this.areaName);

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_onScroll);
    fetchProperties();
  }

  @override
  void onClose() {
    scrollController.dispose();
    minPriceController.dispose();
    maxPriceController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      fetchProperties();
    }
  }

  Future<void> fetchProperties() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      error.value = null;

      String area = areaName.replaceAll('-', ' ');

      Map<String, dynamic> params = {
        'area-place': area,
        'page': currentPage.toString(),
        'per_page': '10',
      };

      // Add filter parameters
      if (selectedPropertyType != null) {
        params['type'] = selectedPropertyType.toString();
      }
      if (minPriceController.text.isNotEmpty) {
        params['price_from'] = minPriceController.text;
      }
      if (maxPriceController.text.isNotEmpty) {
        params['price_to'] = maxPriceController.text;
      }
      if (selectedBedrooms != null) {
        params['bedrooms'] = selectedBedrooms.toString();
      }
      if (selectedBathrooms != null) {
        params['bathrooms'] = selectedBathrooms.toString();
      }

      // Handle sorting
      switch (sortBy) {
        case 'newest':
          params['sort_by'] = 'created_at';
          params['sort_order'] = 'desc';
          break; 
        case 'oldest':
          params['sort_by'] = 'created_at';
          params['sort_order'] = 'asc';
          break;
        case 'price_desc':
          params['sort_by'] = 'price';
          params['sort_order'] = 'desc';
          break;
        case 'price_asc':
          params['sort_by'] = 'price';
          params['sort_order'] = 'asc';
          break;
        default:
          params['sort_by'] = 'created_at';
          params['sort_order'] = 'desc';
      }

      final fetchedProperties = await propertiesRepository.getProperties(params: params);
      if (fetchedProperties.isNotEmpty) {
        properties.addAll(fetchedProperties);
        hasMoreData.value = fetchedProperties.isNotEmpty;
        currentPage++;
      } else {
        hasMoreData.value = false;
      }
      update(['area_properties']);

    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
      update(['area_properties']);
    }
  }

  Future<void> loadMoreProperties() async {
    if (!hasMoreData.value || isLoadingMore.value) return;
    
    try {
      isLoadingMore.value = true;

      Get.log('areaName: $areaName');
      Map<String, dynamic> params = {
        'area': areaName,
        'after_id': properties.last.id.toString(),
        'per_page': '10',
      };

      // Add filter parameters
      if (selectedPropertyType != null) {
        params['type'] = selectedPropertyType.toString();
      }
      if (minPriceController.text.isNotEmpty) {
        params['min_price'] = minPriceController.text;
      }
      if (maxPriceController.text.isNotEmpty) {
        params['max_price'] = maxPriceController.text;
      }
      if (selectedBedrooms != null) {
        params['bedrooms'] = selectedBedrooms.toString();
      }
      if (selectedBathrooms != null) {
        params['bathrooms'] = selectedBathrooms.toString();
      }

      // Handle sorting
      switch (sortBy) {
        case 'newest':
          params['sort_by'] = 'created_at';
          params['sort_order'] = 'desc';
          break;
        case 'oldest':
          params['sort_by'] = 'created_at';
          params['sort_order'] = 'asc';
          break;
        case 'price_desc':
          params['sort_by'] = 'price';
          params['sort_order'] = 'desc';
          break;
        case 'price_asc':
          params['sort_by'] = 'price';
          params['sort_order'] = 'asc';
          break;
        default:
          params['sort_by'] = 'created_at';
          params['sort_order'] = 'desc';
      }

      final newProperties = await propertiesRepository.getProperties(params: params);
      
      if (newProperties.isEmpty) {
        hasMoreData.value = false;
      } else {
        properties.addAll(newProperties);
      }
    } catch (e) {
      Get.log('Error loading more properties: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshProperties() async {
    currentPage = 1;
    properties.clear();
    hasMoreData.value = true;
    await fetchProperties();
  }

  // Filter methods
  void updatePropertyType(String? type) {
    selectedPropertyType = type;
    update();
  }

  void updateBedrooms(int? bedrooms) {
    selectedBedrooms = bedrooms;
    update();
  }

  void updateBathrooms(int? bathrooms) {
    selectedBathrooms = bathrooms;
    update();
  }

  void updateSortBy(String value) {
    sortBy = value;
    update();
  }

  void resetFilters() {
    selectedPropertyType = null;
    minPriceController.clear();
    maxPriceController.clear();
    selectedBedrooms = null;
    selectedBathrooms = null;
    sortBy = 'newest';
    update();
  }

  void applyFilters() {
    refreshProperties();
  }
} 