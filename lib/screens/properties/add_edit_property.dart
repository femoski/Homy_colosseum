import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/properties/controllers/add_edit_property_controller.dart';
import 'package:homy/screens/properties/views/attributes_page.dart';
import 'package:homy/screens/properties/views/location_page.dart';
import 'package:homy/screens/properties/views/media_page.dart';
import 'package:homy/screens/properties/views/overview_page.dart';
import 'package:homy/screens/properties/views/pricing_page.dart';
import 'package:homy/utils/my_text_style.dart';

class AddEditPropertyScreen extends StatelessWidget {
  final int screenType;

  const AddEditPropertyScreen({super.key, required this.screenType});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddEditPropertyScreenController(screenType));

    return Scaffold(
      backgroundColor: Get.theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Get.theme.colorScheme.background,
        title: Text('Upload Property'),
      ),
      body: Column(
        children: [
          // TopBarArea(title: 'Upload Property', bottomSize: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              // color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              // border: Border.all(
              //   color: Get.theme.colorScheme.primary.withOpacity(0.1),
              //   width: 1,
              // ),
              boxShadow: [
                BoxShadow(
                  color: Get.theme.colorScheme.primary.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: GetBuilder(
              init: controller,
              builder: (controller) {
                return SizedBox(
                  height: 50,
                  child: ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.propertyTab.length,
                    itemBuilder: (context, index) {
                      final isSelected = controller.selectedTabIndex == index;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => controller.onTabClick(index),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              width: 110,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Get.theme.colorScheme.primary
                                    : Get.isDarkMode ? Get.theme.colorScheme.outline : Get.theme.colorScheme.onPrimary,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Get.theme.colorScheme.primary
                                      : Get.theme.colorScheme.outline.withOpacity(0.15),
                                  width: 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Get.theme.colorScheme.primary.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getTabIcon(index),
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : Get.theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    controller.propertyTab[index],
                                    style: MyTextStyle.productLight(
                                      size: 13,
                                      color: isSelected
                                          ? Colors.white
                                          : Get.theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ), 
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              controller: controller.pageScrollController,
              child: GetBuilder(
                init: controller,
                builder: (controller) {
                  return controller.selectedTabIndex == 0
                      ? OverviewPage(controller: controller)
                      : controller.selectedTabIndex == 1
                          ? LocationPage(controller: controller)
                          : controller.selectedTabIndex == 2
                              ? AttributesPage(controller: controller)
                              : controller.selectedTabIndex == 3
                                  ? MediaPage(controller: controller)
                                  : PricingPage(controller: controller);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: GetBuilder(
        init: controller,
        builder: (controller) => FloatingActionButton.extended(
          onPressed: controller.isLoading ? null : controller.onSubmitClick,
          backgroundColor: Get.theme.colorScheme.primary,
          icon: controller.isLoading 
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  controller.selectedTabIndex < 4 
                      ? Icons.arrow_forward 
                      : Icons.check,
                  color: Colors.white,
                ),
          label: Text(
            controller.selectedTabIndex < 4 ? 'Next' : 'Submit',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  IconData _getTabIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home_outlined;
      case 1:
        return Icons.location_on_outlined;
      case 2:
        return Icons.format_list_bulleted;
      case 3:
        return Icons.photo_library_outlined;
      case 4:
        return Icons.attach_money;
      default:
        return Icons.circle_outlined;
    }
  }
}
