import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/media.dart';
import 'package:homy/screens/property_detail_screen/preview_image_screen.dart';

class ImagesScreenController extends GetxController {
  List<dynamic> imagesTab = [
    'All',
    'Overview',
    'Bedrooms',
    'Bathroom',
    'Video',
    'Other',
    '360'
  ];
  int selectedImagesTab = 0;
  ScrollController scrollController = ScrollController();
  ScrollController rowScrollController = ScrollController();
  List<String> images = [];
  List<Media> media = [];
  List<Media> filteredMedia = [];

  ImagesScreenController(this.selectedImagesTab, this.media) {
    filteredMedia = media;
  }

  @override
  void onReady() {
    super.onReady();
    onImagesTabTap(selectedImagesTab);
  }

  void onImagesTabTap(int index) {
    images = [];
    selectedImagesTab = index;
    if (index > 2) {
      rowScrollController.animateTo(rowScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.linear);
    } else {
      rowScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.linear);
    }
    
    // Filter media based on selected tab
    filteredMedia = media.where((item) {
      if (item.content == null) return false;
      
      switch (selectedImagesTab) {
        case 0: // All
          return item.mediaTypeId != 7; // Exclude videos from "All" tab
        case 1: // Bedrooms
          return item.mediaTypeId == 1; // Bedroom images
        case 2: // Bathroom
          return item.mediaTypeId == 2; // Bathroom images
        case 3: // Other
          return item.mediaTypeId == 3; // Other images
        case 4: // Video
          return item.mediaTypeId == 5; // Video images
        case 5: // 360
          return item.mediaTypeId == 6; // 360 images
        default:
          return false;
      }
    }).toList();

    // Update images list with filtered content
    images = filteredMedia.map((item) => item.content ?? '').toList();
    
    if (scrollController.hasClients) {
      scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.linear);
    }
    update();
  }

  void onImageClick(String image) {
    int currentIndex = images.indexOf(image);
    selectedImagesTab == 4
        ? Get.to(() => PreviewImageScreen(
              images: images,
              initialIndex: currentIndex,
              screenType: 1,
            ))
        : Get.to(() => PreviewImageScreen(
              images: images,
              initialIndex: currentIndex,
              screenType: 0,
            ));
  }
}
