import 'package:get/get.dart';
import 'package:homy/models/category.dart';
import 'package:homy/services/categories_service.dart';

class CategoriesController extends GetxController {
  final categories = <Category>[].obs;
  final _allCategories = <Category>[].obs;
  final isLoading = false.obs;
  final isSearchMode = false.obs;
  final searchQuery = ''.obs;
  
  CategoriesService categoriesService = Get.find<CategoriesService>();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      update();
      
      final List<Category> fetchedCategories = await categoriesService.getAllCategories();
      categories.value = fetchedCategories;
      _allCategories.value = fetchedCategories;
      
      isLoading.value = false;
      update();
    } catch (e) {
      isLoading.value = false;
      update();
      print('Error fetching categories: $e');
    }
  }

  void toggleSearchMode() {
    isSearchMode.value = !isSearchMode.value;
    if (!isSearchMode.value) {
      clearSearch();
    }
    update();
  }

  void clearSearch() {
    searchQuery.value = '';
    categories.value = _allCategories;
    update();
  }

  void searchCategories(String query) {
    if (query.isEmpty) {
      categories.value = _allCategories;
    } else {
      categories.value = _allCategories
          .where((category) => category.title!
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    }
    update();
  }
}
