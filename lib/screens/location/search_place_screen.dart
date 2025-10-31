import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/widgets/custom_button.dart';
import 'package:homy/screens/location/controllers/search_place_controller.dart';
import 'package:homy/models/place_model.dart';

class SearchPlaceScreen extends GetView<SearchPlaceController> {
  const SearchPlaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Location'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => Get.toNamed('/pick-location'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: GetBuilder<SearchPlaceController>(
              builder: (controller) {
                if (controller.searchController.text.isEmpty) {
                  return _buildRecentSearches();
                }
                return _buildSearchResults();
              },
            ),
          ),
          _buildPickCityButton(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: 'Search city or area'.tr,
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: controller.onSearchChanged,
      ),
    );
  }

  Widget _buildRecentSearches() {
    return GetBuilder<SearchPlaceController>(
      builder: (controller) {
        if (controller.recentSearches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 48,
                  color: Get.theme.disabledColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No recent searches'.tr,
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: Get.theme.disabledColor,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Recent Searches'.tr,
                style: Get.textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: controller.recentSearches.length,
                itemBuilder: (context, index) {
                  final place = controller.recentSearches[index];
                  return _buildPlaceTile(place, isRecent: true);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return GetBuilder<SearchPlaceController>(
      builder: (controller) {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: Get.theme.disabledColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No results found'.tr,
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: Get.theme.disabledColor,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.searchResults.length,
          itemBuilder: (context, index) {
            final place = controller.searchResults[index];
            return _buildPlaceTile(place, isRecent: false);
          },
        );
      },
    );
  }

  Widget _buildPlaceTile(PlaceModel place, {required bool isRecent}) {
    return GetBuilder<SearchPlaceController>(
      builder: (controller) {
        final isSelected = controller.selectedPlace.value?.placeId == place.placeId;
        return ListTile(
          leading: Icon(isRecent ? Icons.history : Icons.location_on),
          title: Text(place.description),
          subtitle: Text(place.formattedAddress ?? ''),
          trailing: Radio<String>(
            value: place.placeId,
            groupValue: controller.selectedPlace.value?.placeId,
            activeColor: Get.theme.primaryColor,
            onChanged: (_) => controller.selectPlace(place),
          ),
          selected: isSelected,
          onTap: () => controller.selectPlace(place),
        );
      },
    );
  }

  Widget _buildPickCityButton() {
    return GetBuilder<SearchPlaceController>(
      builder: (controller) {
        final hasResults = controller.searchResults.isNotEmpty || 
                          (controller.recentSearches.isNotEmpty && controller.searchController.text.isEmpty);
        
        if (!hasResults) return const SizedBox();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            buttonText: 'Pick City'.tr,
            onPressed: controller.selectedPlace.value == null || controller.isProcessing.value
              ? null 
              : () => controller.confirmSelectedPlace(),
            isLoading: controller.isProcessing.value,
            fontSize: 16,
          ),
        );
      },
    );
  }
}
