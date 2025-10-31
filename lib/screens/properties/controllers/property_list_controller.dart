import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/filter_apply.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/repositories/properties_respository.dart';
import 'package:homy/services/categories_service.dart';

class PropertyListController extends GetxController {
  var isLoading = false.obs;
  var propertyList = <PropertyData>[].obs;
  var hasMoreData = true.obs;
  var error = Rx<String?>(null);
  // var selectedFilter = Rx<FilterApply?>(null);
  var selectedCategoryId = ''.obs;
  var selectedCategoryName = ''.obs;
  var searchBody = {}.obs;
  bool hasMoreProperty = true;
  RxBool isLoadingMore = false.obs;
final PropertiesRepository propertiesRepository = PropertiesRepository();
final CategoriesService categories = Get.find<CategoriesService>();
var selectedFilter = 'newest';
int currentPage = 1;

@override
void onInit() {
  super.onInit();  
  fetchPropertyFromCategory(int.parse(Get.parameters['catID'].toString()));
}




 // Filter related variables
  String? selectedPropertyType;
  final minPriceController = TextEditingController();
  final maxPriceController = TextEditingController();
  int? selectedBedrooms;
  int? selectedBathrooms;
  String sortBy = 'newest';

  
Future<void> fetchCategoryDetails(String categoryId) async {
  try {
   
   final filterOptions =  categories.getCategorybyIds(categoryId);
   selectedCategoryName.value = filterOptions?.title ?? '';
// Get.log('filterOptions: ${filterOptions?.toJson()}');

    }catch(e){
      isLoading.value = false;
      error.value = e.toString();
    }
  }

  Future<void> fetchPropertyFromCategory(int categoryId, {bool showPropertyType = false,}) async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      error.value = null;
      Map<String, dynamic> params = {
        'category': categoryId.toString(),
        'page': currentPage.toString(),
        'per_page': 10.toString(),
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


      final properties = await propertiesRepository.getProperties(params: params);

      //  propertyList.value = properties;

      if (properties.isNotEmpty) {
        propertyList.addAll(properties);
        currentPage++;
      }

      // TODO: Implement your API call here
      // Example:
      // final response = await apiService.getProperties(categoryId, filter);
      // await Future.delayed(const Duration(seconds: 2));
      //  propertyList.value = MockPropertyData.properties.values.map((e) => PropertyData.fromJson(e.toJson())).toList();
      
       isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
    }
  }

  Future<void> fetchPropertyFromCategoryMore() async {
    if (!hasMoreProperty) return;
    isLoadingMore.value = true;
    
    try {
           Map<String, dynamic> params = {
        'category': selectedCategoryId.value.toString(),
        'after_id': propertyList.last.id.toString(),
        'sort_by': selectedFilter,
      };

      final properties = await propertiesRepository.getProperties(params: params);
      
      if (properties.isEmpty) {
        hasMoreProperty = false;
      }
      propertyList.addAll(properties);
      // TODO: Implement pagination logic here
      // Example:
      // final response = await apiService.getMoreProperties();
      // propertyList.addAll(response.properties);
      // hasMoreData.value = response.hasMore;
        // hasMoreData.value = false;

    } catch (e) {
      error.value = e.toString();
    }
    finally{
      isLoadingMore.value = false;
    }
  }

  // void setFilter(FilterApply filter) {
  //   selectedFilter.value = filter;
  // }

  void setFilter(String filter) {
    selectedFilter = filter;
    update();
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
    currentPage = 1;
    propertyList.clear();
    fetchPropertyFromCategory(int.parse(Get.parameters['catID'].toString()));
  }

} 
