
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/screens/properties/widgets/property_card.dart';
import 'package:homy/screens/saved_screen/controllers/saved_controller.dart';

class PropertyList extends GetView<SavedPropertyScreenController> {
  // final SavedPropertyScreenController controller;

  // const PropertyList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(

      controller: controller.scrollController,
      itemCount: controller.savedPropertyData.length,
      padding: EdgeInsets.symmetric(horizontal: 10),
      itemBuilder: (context, index) {
        // return Container();
        PropertyData data = controller.savedPropertyData[index];
        return InkWell(
          onTap: () {
            // NavigateService.push(
            //   Get.context!,
            //   PropertyDetailScreen(propertyId: data.id ?? -1),
            // ).then(
            //   (value) {
            //     controller.savedPropertyData = [];
            //     controller.fetchSavedPropertyApiCall();
            //   },
            // );
          },
          child: PropertyHorizontalCard(property: data),
        );
      },
    );
  }
}