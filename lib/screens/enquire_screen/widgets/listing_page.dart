import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/screens/enquire_screen/controllers/enquire_screen_controller.dart';
import 'package:homy/screens/properties/widgets/property_card.dart';
import 'package:homy/screens/enquire_screen/widgets/property_shimmer_loader.dart';

class ListingPage extends GetView<EnquireInfoScreenController> {
  @override
  Widget build(BuildContext context) {
    return controller.isPropertyLoading && controller.propertyList.isEmpty
        ? const PropertyShimmerLoader()
        : controller.propertyList.isEmpty
            ? Center(child: CommonUI.noDataFound(width: 50, height: 50, title: 'No Proper1ty Found'))
            : ListView.builder(
                primary: false,
                shrinkWrap: true,
                itemCount: controller.propertyList.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  PropertyData? data = controller.propertyList[index];
                  return InkWell(
                    onTap: () => controller.onNavigatePropertyDetail(context, data),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      child: PropertyHorizontalCard(property: data),
                    ),
                  );
                },
              );
  }
}
