import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/city_model.dart';
import 'package:homy/repositories/properties_respository.dart';
import 'package:homy/services/location_service.dart';

class AllAreasController extends GetxController {
  final PropertiesRepository propertiesRepository = PropertiesRepository();
  final locationService = Get.find<LocationService>();
  
  List<CityModel> popularAreas = [];
  bool isLoading = false;
  bool hasMoreData = true;
  int currentPage = 1;
  static const int itemsPerPage = 10;
  
  late ScrollController scrollController;

  AllAreasController() {
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }

  @override
  void onInit() {
    super.onInit();
    fetchPopularAreas();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= 
        scrollController.position.maxScrollExtent - 200 &&
        !isLoading && 
        hasMoreData) {
      loadMoreAreas();
    }
  }

  Future<void> fetchPopularAreas() async {
    try {
      isLoading = true;
      update();

      Map<String, dynamic> params = {
        'city': locationService.place.value.city,
        'page': '1',
        'limit': itemsPerPage.toString(),
      };

      final areas = await propertiesRepository.getPopularCity(params: params);
      popularAreas = areas;
      currentPage = 1;
      hasMoreData = areas.length >= itemsPerPage;

    } catch (e) {
      Get.log('Error fetching popular areas: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> loadMoreAreas() async {
    if (!hasMoreData || isLoading) return;

    try {
      isLoading = true;
      update();

      Map<String, dynamic> params = {
        'city': locationService.place.value.city,
        'page': (currentPage + 1).toString(),
        'limit': itemsPerPage.toString(),
      };

      final newAreas = await propertiesRepository.getPopularCity(params: params);
      
      if (newAreas.isEmpty) {
        hasMoreData = false;
      } else {
        popularAreas.addAll(newAreas);
        currentPage++;
      }

    } catch (e) {
      Get.log('Error loading more areas: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> refreshAreas() async {
    hasMoreData = true;
    await fetchPopularAreas();
  }

  void onAreaTap(String areaName) {
    String formattedArea = areaName.replaceAll(' ', '-');
    Get.toNamed('/porpular-area/$formattedArea');
  }
}
