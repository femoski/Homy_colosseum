import 'package:get/get.dart';
import 'package:homy/models/category.dart';
import 'package:homy/models/property/property_type_model.dart';
import 'package:homy/repositories/properties_respository.dart';

class CategoriesService extends GetxService {
  // final LaravelApiClient _laravelApiClient = Get.find<LaravelApiClient>();
  final categories = <PropertyType>[].obs;
  final categoriesList = <Category>[].obs;
  final propertiesRepository = PropertiesRepository();
  // final commercialCategories = <PropertyType>[].obs;
  // final residentialCategories = <PropertyType>[].obs;


  @override
  void onInit() {
    super.onInit();
    initCategories();
  }

  Future<void> initCategories() async {

    
    // try {
    //   await getCategories();
    //   await getSubCategories();
    // } catch (e) {
    //   print('Error initializing categories: $e');
    // }
  }

  Future<dynamic> getCategories() async {
    try {
      // Simulating network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      final List<PropertyType> dummyCategories = [
        PropertyType(
          id: 1,
          title: 'Apartment',
          propertyCategory: 1,
          icon: 'assets/icons/apartment.png',
        ),
        PropertyType(
          id: 2,
          title: 'House',
          propertyCategory: 1,
          icon: 'assets/icons/house.png',
        ),
        PropertyType(
          id: 3,
          title: 'Villa',
          propertyCategory: 1,
          icon: 'assets/icons/villa.png',
        ),
        PropertyType(
          id: 4,
          title: 'Office Space',
          propertyCategory: 2,
          icon: 'assets/icons/office.png',
        ),
        PropertyType(
          id: 5,
          title: 'Retail Shop',
          propertyCategory: 2,
          icon: 'assets/icons/shop.png',
        ),
        PropertyType(
          id: 6,
          title: 'Warehouse',
          propertyCategory: 2,
          icon: 'assets/icons/warehouse.png',
        ),
        PropertyType(
          id: 7,
          title: 'Land',
          propertyCategory: 3,
          icon: 'assets/icons/land.png',
        ),
        PropertyType(
          id: 8,
          title: 'Farm',
          propertyCategory: 3,
          icon: 'assets/icons/farm.png',
        ),


        
      ];
      
      categories.assignAll(dummyCategories);
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }



  Future<dynamic> getCategoriesList() async {

try {
    final list = await propertiesRepository.getCategories();
    categoriesList.assignAll(list);
    // print('categories111: $categories');
    // try {
    //   // Simulating network delay
    //   await Future.delayed(const Duration(milliseconds: 800));
      
    //   final List<Category> dummyCategories = [
    //        Category(
    //     // parameterTypes: 'Apartments',
    //     image: 'https://api.getpeid.com/uploads/coin/binance-bundle/usdt.svg',
    //     id: '1',
    //     title: 'Apartments',
    //     propertyType: 1,
    // ),
    // Category(
    //   image: 'assets/svg/villa.svg',
    //   id: '2',
    //   title: 'Villas',
    //   propertyType: 1,
    // ),
    // Category(
    //   image: 'assets/svg/penthouse.svg', 
    //   id: '3',
    //   title: 'Penthouses',
    //   propertyType: 1,
    // ),
    // Category(
    //   image: 'assets/svg/townhouse.svg',
    //   id: '4', 
    //   title: 'Townhouses',
    //   propertyType: 1,
    // ),
    // Category(
    //   image: 'assets/svg/studio.svg',
    //   id: '5',
    //   title: 'Studios',
    //   propertyType: 1,
    // ),
    // // Commercial Properties
    // Category(
    //   image: 'assets/svg/office.svg',
    //   id: '6',
    //   title: 'Offices',
    //   propertyType: 2,
    // ),
    // Category(
    //   image: 'assets/svg/retail.svg',
    //   id: '7', 
    //   title: 'Retail Shops',
    //   propertyType: 2,
    // ),
    // Category(
    //   image: 'assets/svg/warehouse.svg',
    //   id: '8',
    //   title: 'Warehouses',
    //   propertyType: 2,
    // ),
    // Category(
    //   image: 'assets/svg/showroom.svg',
    //   id: '9',
    //   title: 'Showrooms', 
    //   propertyType: 2,
    // ),
    // ];
      
    //   categoriesList.assignAll(dummyCategories);
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }


  // Future<void> getSubCategories() async {
  //   try {
  //     final List<Category> fetchedSubCategories = await _laravelApiClient.getSubCategories();
  //     subCategories.assignAll(fetchedSubCategories);
  //   } catch (e) {
  //     print('Error fetching subcategories: $e');
  //   }
  // }

  PropertyType? getCategoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  Category? getCategorybyIds(String id) {
    try {
      final category = categoriesList.firstWhere((category) => category.id == id);
      Get.log('FEMLAAA: ${category?.toJson()}');
      return category;
    } catch (e) {
      return null;
    }
  }
  // Future<List<PropertyType>> getAllCategories() async {
  //   if (categories.isEmpty) {
  //     await getCategories();
  //   }
  //   return categories;
  // }


  Future<List<Category>> getAllCategories() async {
    if (categoriesList.isEmpty) {
      await getCategoriesList();
    }
    return categoriesList;
  }

  // Future<List<Category>> getAllSubCategories() async {
  //   if (subCategories.isEmpty) {
  //     await getSubCategories();
  //   }
  //   return subCategories;
  // }

  // Future<List<Category>> getSubCategoriesByCategory(String category) async {
  //   if (subCategories.isEmpty) {
  //     await getSubCategories();
  //   }

  //   return subCategories.where((subCat) => subCat.category == category).toList();
  // }

  List<PropertyType> getCategoriesByCategory(String category) {
    return categories.where((cat) => cat.propertyCategory == category).toList();
  }
} 
