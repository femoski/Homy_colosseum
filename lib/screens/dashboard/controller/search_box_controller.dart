import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchBoxController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final List<String> searchSuggestions = [
    'Luxury Apartments',
    'Beach Houses',
    'City Condos',
    'Mountain Villas',
    'Studio Apartments',
    'Penthouses',
    'Family Homes',
    'Office Spaces',
    'Vacation Rentals',
    'Commercial Properties',
  ];

  var currentSuggestionIndex = 0.obs;
  Timer? timer;

  @override
  void onInit() {
    super.onInit();
    startTextRotation();
  }

  void startTextRotation() {
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      currentSuggestionIndex.value =
          (currentSuggestionIndex.value + 1) % searchSuggestions.length;
    });
  }

  void stopTextRotation() {
    timer?.cancel();
  }

  void restartTextRotation() {
    stopTextRotation();
    startTextRotation();
  }

  @override
  void onClose() {
    stopTextRotation();
    super.onClose();
  }

  void onSearch() {
    print(searchController.text);
  }
}
