import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/category.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/repositories/properties_respository.dart';

class PropertiesController extends GetxController {
  List<PropertyData> propertyData = [];
  bool isLoading = false;
  Category? type;
  Map<String, dynamic> map = {};
  bool isDialog = false;
  int screenType;
  final isGridView = false.obs;
  Map<String, dynamic> currentFilters = {};
  bool isLoadingMore = false;

  final sortBy = 'newest'.obs;
  final propertyStatus = 'all'.obs;
  var selectedFilter = 'newest';

  int currentPage = 1;
  PropertiesController(this.type, this.map, this.screenType);

  ScrollController scrollController = ScrollController();

final PropertiesRepository propertiesRepository = PropertiesRepository();

  @override
  void onInit() {
    super.onInit();
    fetchProperties();
  }

  @override
  void onReady() {
      fetchProperties();
    fetchScrollData();
    super.onReady();
  }

  Future<void> fetchProperties() async {
    if (isLoading) return;

    isLoading = true;
    update();

    try {
      if (propertyData.isEmpty) {
        isDialog = true;
      }
      Map<String, dynamic> params = Map<String, dynamic>.from(map);
      params['page'] = currentPage.toString();
      params['per_page'] = 10.toString();

       switch (selectedFilter) {
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
              Get.log('fetchProperties: $params');

      final properties = await propertiesRepository.getProperties(params: params);


      if (properties.isNotEmpty) {
        propertyData.addAll(properties);
        currentPage++;
        isLoading = false;
        update();
        return;
      }

      // propertyData.addAll(properties);
      // currentPage++;
      // update();
    } catch (e) {
      Get.log('fetchProperties error: $e');
      // Error handling
    } finally {
      isLoading = false;
      update();
    }
  }

  void fetchPropertiesByCategoryApiCall() async {
    // if (isLoading) return;

      Map<String, dynamic> params = Map<String, dynamic>.from(map);
    final type = await propertiesRepository.getProperties(params: params);
        propertyData.addAll(type);
    isLoading = false;
    update();

  }


void fetchMoreProperties() async {
     if (isLoadingMore) return;
try{
  isLoadingMore = true;
  update();
      Map<String, dynamic> params = Map<String, dynamic>.from(map);
      params['after_id'] = propertyData.last.id.toString();
    final type = await propertiesRepository.getProperties(params: params);
    if(type.isEmpty){
      isLoadingMore = true;
    }else{
      isLoadingMore = false;
      propertyData.addAll(type);
    }
    update();
}catch(e){
  isLoadingMore = false;
  update();
}

  }

  void getResponseData(Object response) {
    if (Get.isDialogOpen == true) {
      isDialog = false;
      Get.back();
    }
    // FetchSavedProperty data = FetchSavedProperty.fromJson(response);
    // propertyData.addAll(data.data ?? []);
    // isLoading = false;
    // if (data.data?.isEmpty == true) {
    //   isLoading = true;
    // }
    update();
  }

  void fetchScrollData() {
    scrollController.addListener(() {
      if (scrollController.offset >= scrollController.position.maxScrollExtent) {
        if (!isLoading) {
          fetchProperties();
          // fetchMoreProperties();
        }
      }
    });
  }

  void updateSortBy(String value) {
    sortBy.value = value;
  }

  void updatePropertyStatus(String value) {
    propertyStatus.value = value;
  }

  void resetFilters() {
    sortBy.value = 'newest';
    propertyStatus.value = 'all';
    update();
  }

  void applyFilters() {
    List<PropertyData> filteredProperties = List.from(propertyData);

    // Filter by property status
    // if (propertyStatus.value != 'all') {
    //   filteredProperties = filteredProperties.where((property) {
    //     return property.status == propertyStatus.value;
    //   }).toList();
    // }

    // Sort properties
    switch (sortBy.value) {
      // case 'most_viewed':
      //   filteredProperties.sort((a, b) => 
      //     (b.viewCount ?? 0).compareTo(a.viewCount ?? 0));
      //   break;
      // case 'featured':
      //   filteredProperties = filteredProperties.where((p) => p.isFeatured).toList();
      //   break;
      case 'newest':
        filteredProperties.sort((a, b) => 
          b.createdAt!.compareTo(a.createdAt!));
        break;
      case 'oldest':
        filteredProperties.sort((a, b) => 
          a.createdAt!.compareTo(b.createdAt!));
        break;
    }

    propertyData = filteredProperties;
    update();
  }

  Future<void> refreshProperties() async {
    // Implement your refresh logic here
    // This should reload the properties with current filters
    update();
  }

  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }

  void setFilter(filter) {
    Get.log('filtersssssssss: $filter');
    selectedFilter = filter;
    propertyData.clear();
    update();
    currentPage = 1;
    fetchProperties();
  }
}

