import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/agent_model.dart';
import 'package:homy/models/city_model.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/repositories/notifications_repository.dart';
import 'package:homy/repositories/properties_respository.dart';
import 'package:homy/services/deep_link_service.dart';
import 'package:homy/services/location_service.dart';
import 'package:homy/services/notifications/shared_notification_service.dart';


class HomeScreenController extends GetxController {
  PageController pageController = PageController(viewportFraction: 0.90);
  final propertyRepository = PropertiesRepository();
  final notificationsRepository = NotificationsRepository();
  late final SharedNotificationService _sharedNotificationService;

  // Separate scroll controllers for different scroll views
  late ScrollController allPropertiesScrollController;
  late ScrollController recentPropertiesScrollController;
  late ScrollController featuredPropertiesScrollController;
  late ScrollController nearbyPropertiesScrollController;
  late ScrollController mostlikePropertiesScrollController;
  late ScrollController popularCityScrollController;
  late ScrollController featuredAgentsScrollController;
  late ScrollController personalizedPropertiesScrollController;
  late ScrollController personalizedPropertiesAllScrollController;
  List<PropertyData> nearByProperties = [];
  List<PropertyData> nearByPropertiesAll = [];

  List<PropertyData> filteredNearByProperties = [];


  List<PropertyData> featuredProperties = [];
  List<PropertyData> filteredFeaturedProperties = [];

  List<PropertyData> mostLikedProperties = [];
  List<PropertyData> mostLikedPropertiesAll = []; 
  List<PropertyData> filteredMostLikedProperties = [];

  List<PropertyData> recentlyAddedProperties = [];
  List<PropertyData> filteredRecentlyAddedProperties = [];

  List<PropertyData> personalizedProperties = [];
  List<PropertyData> personalizedPropertiesAll = [];
  List<PropertyData> allProperties = [];
  List<PropertyData> filteredAllProperties = [];

  List<PropertyData> recentProperties = [];
  List<PropertyData> filteredRecentProperties = [];

  List<CityModel> popularCityProperties = [];

  List<AgentModel> featuredAgents = [];
  List<PropertyData> popularAreaProperties = [];  
  bool isLoading = false;


 // Filter related variables
  String? selectedPropertyType;
  final minPriceController = TextEditingController();
  final maxPriceController = TextEditingController();
  int? selectedBedrooms;
  int? selectedBathrooms;
  String sortBy = 'newest';


  bool isLoadingAllProperties = false;
  int currentPage = 1;
  int currentRecentPage = 1;
  int currentNearbyPage = 1;
  int currentMostLikePage = 1;
  int currentPopularCityPage = 1; 
  int currentPopularAreaPage = 1;
  int currentFeaturedAgentsPage = 1;
  int currentPersonalizedPage = 1;
  int currentPersonalizedAllPage = 1;

  bool isFilterMostLikeActive = false;
  bool isFilterFeaturedActive = false;
  bool isFilterRecentlyAddedActive = false;
  bool isFilterNearByActive = false;
  bool isFilterAllActive = false;
  bool isFilterPopularCityActive = false;
  bool isFilterPopularAreaActive = false;

  static const int itemsPerPage = 10;

  double lat = 0;
  double lng = 0;

  bool isResetBtnVisible = false;
  bool isLoadingNearbyProperties = false;
    bool isLoadingNearbyPropertiesAll = false;

  bool isLoadingMostLikePropertiesAll = false;
  bool isLoadingMostlikeProperties = false;


  bool isLoadingRecentProperties = false;
  bool isLoadingPopularCity = false;
  bool isLoadingMostLikeProperties = false;
  bool isLoadingFeaturedProperties = false;
  bool isLoadingFeaturedAgents = false;
  bool hasMoreCityData = true;
  bool isLoadingPopularArea = false;
  bool isLoadingPersonalizedProperties = false;
  bool isLoadingPersonalizedPropertiesAll = false;

  final locationService = Get.find<LocationService>();

  // Getters
  int get notificationCount => _sharedNotificationService.unreadCount;






  @override
  void onReady() {
    super.onReady();
    DeepLinkService.to.handlePendingDeepLink();
  }

  HomeScreenController() {
    // Initialize all scroll controllers
    allPropertiesScrollController = ScrollController();
    recentPropertiesScrollController = ScrollController();
    featuredPropertiesScrollController = ScrollController();
    nearbyPropertiesScrollController = ScrollController();
    mostlikePropertiesScrollController = ScrollController();
    popularCityScrollController = ScrollController();
    featuredAgentsScrollController = ScrollController();
    personalizedPropertiesScrollController = ScrollController();
    personalizedPropertiesAllScrollController = ScrollController();
    // Add listeners to each controller
    allPropertiesScrollController.addListener(_onAllPropertiesScroll);
    recentPropertiesScrollController.addListener(_onRecentPropertiesScroll);
    featuredPropertiesScrollController.addListener(_onFeaturedPropertiesScroll);
    nearbyPropertiesScrollController.addListener(_onNearbyPropertiesScroll);
    mostlikePropertiesScrollController.addListener(_onMostLikePropertiesScroll);
    popularCityScrollController.addListener(_onPopularCityScroll);
    featuredAgentsScrollController.addListener(_onFeaturedAgentsScroll);
    personalizedPropertiesScrollController.addListener(_onPersonalizedPropertiesScroll);
    personalizedPropertiesAllScrollController.addListener(_onPersonalizedPropertiesAllScroll);
    refreshHome();
  }

  void _onAllPropertiesScroll() {
    if (allPropertiesScrollController.position.pixels >=
        allPropertiesScrollController.position.maxScrollExtent - 200) {
      fetchAllProperties();
    }
  }

  void _onRecentPropertiesScroll() {
    if (recentPropertiesScrollController.position.pixels >=
        recentPropertiesScrollController.position.maxScrollExtent - 200) {
      // loadMoreRecentData();
      fetchRecentlyAddedProperties();
    }
  }

  void _onFeaturedPropertiesScroll() {
    if (featuredPropertiesScrollController.position.pixels >=
        featuredPropertiesScrollController.position.maxScrollExtent - 200) {
      // loadMoreFeaturedData();
    }
  }

  void _onNearbyPropertiesScroll() {
    if (nearbyPropertiesScrollController.position.pixels >=
        nearbyPropertiesScrollController.position.maxScrollExtent - 200) {
      fetchNearByPropertiesAll();
    }
  }

  void _onMostLikePropertiesScroll() {
    if (mostlikePropertiesScrollController.position.pixels >=
        mostlikePropertiesScrollController.position.maxScrollExtent - 200) {
      fetchMostLikedPropertiesAll();
    }
  }

  void _onPopularCityScroll() {

    if (popularCityScrollController.position.pixels >=
        popularCityScrollController.position.maxScrollExtent - 200) {
      fetchPopularCity();
    }
  }

  void _onFeaturedAgentsScroll() {

    if (featuredAgentsScrollController.position.pixels >=
        featuredAgentsScrollController.position.maxScrollExtent - 200) {
      fetchFeaturedAgents();
    }
  }

  void _onPersonalizedPropertiesScroll() {
    if (personalizedPropertiesScrollController.position.pixels >=
        personalizedPropertiesScrollController.position.maxScrollExtent - 200) {
      fetchPersonalizedProperties();
    }
  }

  void _onPersonalizedPropertiesAllScroll() {
    if (personalizedPropertiesAllScrollController.position.pixels >=
        personalizedPropertiesAllScrollController.position.maxScrollExtent - 200) {
      fetchPersonalizedPropertiesAll();
    }
  }

  bool _isLoadingMore = false;

  // Add new methods for loading more data for other sections
  Future<void> loadMoreRecentData() async {
    Get.log(
        'Recent properties scroll: ${recentPropertiesScrollController.position.pixels}');
    if (isLoadingRecentProperties ||
        !recentPropertiesScrollController.hasClients) return;

    try {
      isLoadingRecentProperties = true;
      // isLoadingRecentProperties = true;
      update(['recentlyAddedProperties']);

      Map<String, dynamic> params = {
        // 'after_id': recentProperties.last.id?.toString() ?? '',
        'page': currentRecentPage.toString(),
        'per_page': itemsPerPage.toString(),
      };

      final newProperties =
          await propertyRepository.getProperties(params: params);

      if (newProperties.isNotEmpty) {
        recentlyAddedProperties.addAll(newProperties);
        currentRecentPage++;
        isLoadingRecentProperties = false;
      }
    } catch (e) {
      Get.log('Error loading more recent properties: $e');
      isLoadingRecentProperties = false;
    } finally {
      isLoadingRecentProperties = false;
      update(['recentlyAddedProperties']);
    }
  }

  Future<void> loadMoreData() async {
    if (_isLoadingMore || !allPropertiesScrollController.hasClients) return;

    try {
      _isLoadingMore = true;
      isLoadingAllProperties = true;
      update(['allProperties']);

      Map<String, dynamic> params = {
        'after_id': allProperties.last.id?.toString() ?? '',
      };

      final newProperties =
          await propertyRepository.getProperties(params: params);

      if (newProperties.isNotEmpty) {
        allProperties.addAll(newProperties);
        _isLoadingMore = false;
      }
    } catch (e) {
      Get.log('Error loading more properties: $e');
      _isLoadingMore = false;
    } finally {
      isLoadingAllProperties = false;
      update(['allProperties']);
    }
  }

  @override
  void onClose() {
    // Dispose all scroll controllers
    allPropertiesScrollController.dispose();
    recentPropertiesScrollController.dispose();
    featuredPropertiesScrollController.dispose();
    nearbyPropertiesScrollController.dispose();
    personalizedPropertiesScrollController.dispose();
    personalizedPropertiesAllScrollController.dispose();
    super.onClose();
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    _sharedNotificationService = Get.find<SharedNotificationService>();
    init();
  }

  init() {
    // Notification count is now automatically loaded by SharedNotificationService
    // No need to call loadUnreadCount() here as it's handled by the service
  }


    Future<void> fetchNearByProperties({bool refresh = false}) async {
      if (refresh) {
        nearByProperties.clear();
        currentNearbyPage = 1;
      }
      if (isLoadingNearbyProperties) return;
      isLoadingNearbyProperties = true;
      update(['nearByProperties']);
      try {
        Map<String, dynamic> params = {
          'page': currentNearbyPage.toString(),
          'per_page': itemsPerPage.toString(),
          'city': locationService.place.value.city,
        };

        final newProperties =
            await propertyRepository.getProperties(params: params);

        if (newProperties.isNotEmpty) {
          nearByProperties.addAll(newProperties);
          // currentNearbyPage++;
        }
      } catch (e) {
        Get.log('Error fetching nearby properties: $e');
      } finally {
        isLoadingNearbyProperties = false;
        update(['nearByProperties']);
      }
    }







    Future<void> fetchNearByPropertiesAll({bool refresh = false}) async {
      if (refresh) {
        nearByPropertiesAll.clear();
        currentNearbyPage = 1;
      }
      if (isLoadingNearbyPropertiesAll) return;
      isLoadingNearbyPropertiesAll = true;
      update(['allNearByProperties']);
      try {
        Map<String, dynamic> params = {
          'page': currentNearbyPage.toString(),
          'per_page': itemsPerPage.toString(),
          'city': locationService.place.value.city,
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




        final newProperties =
            await propertyRepository.getProperties(params: params);

        if (newProperties.isNotEmpty) {
          nearByPropertiesAll.addAll(newProperties);
          currentNearbyPage++;
        }
      } catch (e) {
        Get.log('Error fetching nearby properties: $e');
      } finally {
        isLoadingNearbyPropertiesAll = false;
        update(['allNearByProperties']);
      }
    }

 

  Future<void> fetchFeaturedProperties() async {
    try {
      isLoadingFeaturedProperties = true;
      update(['featuredProperties']);

      Map<String, dynamic> params = {
        'is_featured': 'true',
      };
      featuredProperties =
          await propertyRepository.getProperties(params: params);
    } finally {
      isLoadingFeaturedProperties = false;
      update(['featuredProperties']);
    }
  }

  Future<void> fetchRecentlyAddedProperties() async {
    if (isLoadingRecentProperties) return;
    try {
      // _isLoadingMore = true;
      isLoadingRecentProperties = true;
      update(['recentlyAddedProperties']);

      Map<String, dynamic> params = {
        // 'after_id': recentProperties.last.id?.toString() ?? '',
        'page': currentRecentPage.toString(),
        'per_page': itemsPerPage.toString(),
      };

      final newProperties =
          await propertyRepository.getProperties(params: params);

      if (newProperties.isNotEmpty) {
        recentlyAddedProperties.addAll(newProperties);
        currentRecentPage++;
        isLoadingRecentProperties = false;
      }
    } catch (e) {
      Get.log('Error loading more recent properties: $e');
      isLoadingRecentProperties = false;
    } finally {
      // isLoadingRecentProperties = false;
      update(['recentlyAddedProperties']);
    }

    // try {
    //   isLoadingRecentProperties = true;
    //   update(['recentlyAddedProperties']);

    //   Map<String, dynamic> params = {
    //     'recently_added': 'true',
    //   };
    //   recentlyAddedProperties =
    //       await propertyRepository.getProperties(params: params);
    // } finally {
    //   isLoadingRecentProperties = false;
    //   update(['recentlyAddedProperties']);
    // }
  }

  Future<void> fetchMostLikedProperties() async {
    if (isLoadingMostLikeProperties) return;
    isLoadingMostLikeProperties = true;
    
    update(['mostLikedProperties']);
    try {
      Map<String, dynamic> params = {
        'page': currentMostLikePage.toString(),
        'per_page': itemsPerPage.toString(),
        'most_liked': 'true',
      };



      final newProperties =
          await propertyRepository.getProperties(params: params);

      if (newProperties.isNotEmpty) {
        mostLikedProperties.addAll(newProperties);
        isLoadingMostLikeProperties = false;
      }

      // mostLikedProperties =
      //     await propertyRepository.getProperties(params: params);
      // update(['mostLikedProperties']);
    } catch (e) {
      Get.log('Error loading more recent properties: $e');
      isLoadingMostLikeProperties = false;
    } finally {
      // isLoadingRecentProperties = false;
      update(['mostLikedProperties']);
    }
  }





  Future<void> fetchMostLikedPropertiesAll({bool refresh = false}) async {
    Get.log('fetchMostLikedPropertiesAll: $refresh');
    if (isLoadingMostLikePropertiesAll) return;
    isLoadingMostLikePropertiesAll = true;

    if (refresh) {
      mostLikedPropertiesAll.clear();
      currentMostLikePage = 1;
    } 

    update(['mostLikedPropertiesAll']);
    try {
      Map<String, dynamic> params = {
        'page': currentMostLikePage.toString(),
        'per_page': itemsPerPage.toString(),
        'most_liked': 'true',
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


      final newProperties =
          await propertyRepository.getProperties(params: params);

      if (newProperties.isNotEmpty) {
        mostLikedPropertiesAll.addAll(newProperties);
        currentMostLikePage++;
        isLoadingMostLikePropertiesAll = false;
      }

      // mostLikedProperties =
      //     await propertyRepository.getProperties(params: params);
      // update(['mostLikedProperties']);
    } catch (e) {
      Get.log('Error loading more recent properties: $e');
      isLoadingMostLikePropertiesAll = false;
    } finally {
      // isLoadingRecentProperties = false;
      update(['mostLikedPropertiesAll']);
    }
  }



  Future<void> fetchAllProperties() async {
    if (isLoadingAllProperties) return;

    try {
      isLoadingAllProperties = true;
      update(['allProperties']);

      Map<String, dynamic> params = {
        'page': currentPage.toString(),
        'per_page': itemsPerPage.toString(),
      };

      final newProperties =
          await propertyRepository.getProperties(params: params);

      if (newProperties.isNotEmpty) {
        allProperties.addAll(newProperties);
        currentPage++;
        isLoadingAllProperties = false;
      }
    } catch (e) {
      Get.log('Error fetching properties: $e');
      isLoadingAllProperties = false;
    } finally {
      isLoadingAllProperties = false;
      update(['allProperties']);
    }
  }

  Future<void> fetchPopularCity() async {
    Get.log('Fetching popular city');
    if (isLoadingPopularCity) return;   
    try {
    isLoadingPopularCity = true;
    update(['popular_city_properties']);
    Map<String, dynamic> params = {
      'page': currentPopularCityPage.toString(),
      'per_page': itemsPerPage.toString(),
      'city': locationService.place.value.city,
    };

    Get.log('Puopular city: $params');
    final newProperties =
        await propertyRepository.getPopularCity(params: params);

    if (newProperties.isNotEmpty) {
      popularCityProperties.addAll(newProperties);
      currentPopularCityPage++;
      isLoadingPopularCity = false;
    }
    print('popular_city_properties: ${popularCityProperties}');
      update(['popular_city_properties']);
    } catch (e) {
      Get.log('Error fetching popular city: $e');
      isLoadingPopularCity = false;
    } finally {
      isLoadingPopularCity = false;
      update(['popular_city_properties']);
    }
  }

  Future<void> fetchPopularArea() async {
    if (isLoadingPopularArea) return;
    try {
      isLoadingPopularArea = true;
      update(['popular_area_properties']);
      Map<String, dynamic> params = {
        'page': currentPopularAreaPage.toString(),
        'per_page': itemsPerPage.toString(),
        'city': locationService.place.value.city,
      };
      
      final newProperties =
          await propertyRepository.getProperties(params: params);

      if (newProperties.isNotEmpty) {
        popularAreaProperties.addAll(newProperties);
        currentPopularAreaPage++;
        isLoadingPopularArea = false;
      }
      update(['popular_area_properties']);
      }
    catch (e) {
      Get.log('Error fetching popular area: $e');
      isLoadingPopularArea = false;
    } finally {
      isLoadingPopularArea = false;
      update(['popular_area_properties']);
    }
  }


  Future<void> fetchFeaturedAgents() async {
    if (isLoadingFeaturedAgents) return;
    try {
      isLoadingFeaturedAgents = true;
      update(['featured_agents']);
      Map<String, dynamic> params = {
        'page': currentFeaturedAgentsPage.toString(),
        'per_page': itemsPerPage.toString(),
      };
      final newAgents = await propertyRepository.getFeaturedAgents(params: params);
      Get.log('newAgents: $newAgents');
      if (newAgents.isNotEmpty) {
        featuredAgents.addAll(newAgents);
        currentFeaturedAgentsPage++;
        isLoadingFeaturedAgents = false;
      }
      update(['featured_agents']);
    }
    catch (e) {
      Get.log('Error fetching featured agents: $e');
      isLoadingFeaturedAgents = false;
    } finally {
      isLoadingFeaturedAgents = false;
      update(['featured_agents']);
    }
  }

  Future<void> fetchPersonalizedProperties() async {
    if (isLoadingPersonalizedProperties) return;
    try {
      isLoadingPersonalizedProperties = true;
      update(['personalizedProperties']);
      Map<String, dynamic> params = {
        'page': currentPersonalizedPage.toString(),
        'per_page': itemsPerPage.toString(),
        'personalized': 'true',
      };
      final newProperties = await propertyRepository.getProperties(params: params);

      Get.log('newProperties: $newProperties');
      Get.log('personalizedProperties: $personalizedProperties');
      if (newProperties.isNotEmpty) {
        personalizedProperties.addAll(newProperties);
        currentPersonalizedPage++;
        isLoadingPersonalizedProperties = false;
      }
      update(['personalizedProperties']);
    } catch (e) {
      Get.log('Error fetching personalized properties: $e');
      isLoadingPersonalizedProperties = false;
    } finally {
      isLoadingPersonalizedProperties = false;
      update(['personalizedProperties']);
    }
  }

  Future<void> fetchPersonalizedPropertiesAll({bool refresh = false}) async {
    if (refresh) {
      personalizedPropertiesAll.clear();
      currentPersonalizedAllPage = 1;
    }
    if (isLoadingPersonalizedPropertiesAll) return;
    isLoadingPersonalizedPropertiesAll = true;
    update(['allPersonalizedProperties']);
    try {
      Map<String, dynamic> params = {
        'page': currentPersonalizedAllPage.toString(),
        'per_page': itemsPerPage.toString(),
        'personalized': 'true',
      };

      final newProperties = await propertyRepository.getProperties(params: params);
      Get.log('newProperties: $newProperties');
      Get.log('personalizedPropertiesAll: $personalizedPropertiesAll');
      if (newProperties.isNotEmpty) {
        personalizedPropertiesAll.addAll(newProperties);
        currentPersonalizedAllPage++;
      }
      update(['allPersonalizedProperties']);
    } catch (e) {
      Get.log('Error fetching personalized properties all: $e');
    } finally {
      isLoadingPersonalizedPropertiesAll = false;
      update(['allPersonalizedProperties']);
    }
  }

  void onAreaTap(String areaName) {
    String formattedArea = areaName.replaceAll(' ', '-');
    Get.toNamed('/porpular-area/$formattedArea');
  }

  Future<void> refreshAreas() async {
    hasMoreCityData = true;
    await fetchPopularCity();
  }

  void onLikeChange(String type, int id) async {
    await propertyRepository.likeProperty(id, type);

    Get.log('type: $type');
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
    // Get.log('applyFilters');
    // currentMostLikePage = 1;
    // mostLikedProperties.clear();
    fetchMostLikedPropertiesAll(refresh: true);
    fetchNearByPropertiesAll(refresh: true);
  }


  void refreshHome() async {
    fetchMostLikedProperties();

    fetchFeaturedProperties();
    fetchRecentlyAddedProperties();
    fetchPopularCity();
    fetchFeaturedAgents();
    fetchAllProperties();
    fetchNearByProperties();
    fetchPersonalizedProperties();

    //  fetchNearByProperties();
    //  fetchFeaturedProperties();
    //  fetchNearByProperties();
    //  fetchFeaturedProperties();
    // fetchRecentlyAddedProperties();
  }

  // void fetchHomePageData() {
  //   Map<String, dynamic> map = {};
  //   map[uUserId] = PrefService.id.toString();
  //   if (lat != 0 && lng != 0) {
  //     map[uUserLatitude] = lat.toStringAsFixed(4);
  //     map[uUserLongitude] = lng.toStringAsFixed(4);
  //     isResetBtnVisible = true;
  //   }

  //   ApiService().call(
  //     completion: (response) {
  //       homeData = FetchHomePageData.fromJson(response);
  //       isLoading = false;
  //       update();
  //     },
  //     url: UrlRes.fetchHomePageData,
  //     param: map,
  //   );
  // }

  void getCityName() {
    // Get.to(() => SearchPlaceScreen(
    //       screenType: 0,
    //       latLng: LatLng(lat, lng),
    //     ))?.then((value) async {
    //   if (value != null) {
    //     lat = value[uUserLatitude];
    //     lng = value[uUserLongitude];
    //     selectedCity = value[pSelectCity] ?? '${lat.toStringAsFixed(4)}N , ${lng.toStringAsFixed(4)}E';
    //     update();
    //     await prefService.saveString(key: uUserLatitude, value: lat.toStringAsFixed(4));
    //     await prefService.saveString(key: uUserLongitude, value: lng.toStringAsFixed(4));
    //     if (value[pSelectCity] != null) {
    //       await prefService.saveString(key: pSelectCity, value: value[pSelectCity]);
    //     } else {
    //       await prefService.preferences?.remove(pSelectCity);
    //     }
    //     fetchHomePageData();
    //   }
    // });
  }

  void onPropertySaved() {
    // String? savedPropertyId = savedUser?.savedPropertyIds;
    // List<String> savedId = [];
    // if (savedPropertyId == null || savedPropertyId.isEmpty) {
    //   savedPropertyId = data?.id.toString();
    // } else {
    //   savedId = savedPropertyId.split(',');
    //   if (savedId.contains(data?.id.toString() ?? '')) {
    //     savedId.remove(data?.id.toString() ?? '');
    //   } else {
    //     savedId.add(data?.id.toString() ?? '');
    //   }
    //   savedPropertyId = savedId.join(',');
    // }

    // PropertyData? propertyData = data;
    // if (data?.savedProperty == true) {
    //   propertyData?.savedProperty = false;
    // } else {
    //   propertyData?.savedProperty = true;
    // }
    // homeData?.featured?[homeData!.featured!.indexWhere((element) {
    //   return element.id == data?.id;
    // })] = propertyData!;
    // update();

    // ApiService().call(
    //   url: UrlRes.editProfile,
    //   param: {uUserId: PrefService.id.toString(), uSavedPropertyIds: savedPropertyId},
    //   completion: (response) async {
    //     FetchUser editProfile = FetchUser.fromJson(response);
    //     await prefService.saveUser(editProfile.data);
    //     fetchHomePageData();
    //   },
    // );
  }

  void onResetCityBtn() async {
    //   prefService.preferences?.remove(uUserLatitude);
    //   prefService.preferences?.remove(uUserLongitude);
    //   prefService.preferences?.remove(pSelectCity);
    //   isResetBtnVisible = false;
    //   selectedCity = '- - - - - -';
    //   lat = 0;
    //   lng = 0;
    //   update();
    //   fetchHomePageData();
    // }

    void loadFeaturedProperties() {
      isLoadingFeaturedProperties = true;
      update(['featuredProperties']);

      // Your loading logic here...

      isLoadingFeaturedProperties = false;
      update(['featuredProperties']);
    }

    void fetchRecentProperties() {
      isLoadingRecentProperties = true;
      update(['recentlyAddedProperties']);

      // Your API call or data fetching logic here

      // When done loading
      isLoadingRecentProperties = false;
      update(['recentlyAddedProperties']);
    }

    Future<void> loadMoreFeaturedData() async {
      // Implement loading more featured properties
    }

    Future<void> loadMoreNearbyData() async {
      // Implement loading more nearby properties
    }
  }

  void applyMostLikedFilters(String sortBy) {
    List<PropertyData> filteredProperties = List.from(mostLikedProperties);

    switch (sortBy) {
      case 'price_high_low':
        filteredProperties.sort((a, b) => 
          (b.firstPrice ?? 0).compareTo(a.firstPrice ?? 0));
        break;
      case 'price_low_high':
        filteredProperties.sort((a, b) => 
          (a.firstPrice ?? 0).compareTo(b.firstPrice ?? 0));
        break;
      case 'newest':
        filteredProperties.sort((a, b) => 
          b.createdAt!.compareTo(a.createdAt!));
        break;
      case 'oldest':
        filteredProperties.sort((a, b) => 
          a.createdAt!.compareTo(b.createdAt!));
        break;
    }

    mostLikedProperties = filteredProperties;
    update(['mostLikedProperties']);
  }
} // End of HomeScreenController class
