import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/Helper/AuthHelper.dart';
import 'package:homy/common/common_funtions.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/common/widgets/image_widget.dart';
import 'package:homy/common/widgets/not_logged_in_screen.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/screens/properties/controllers/my_properties_controller.dart';
import 'package:homy/screens/search_screen/widgets/search_tab.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:homy/utils/constants/image_string.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:homy/screens/properties/widgets/my_properties_shimmer.dart';

class MyPropertiesScreen extends GetView<MyPropertiesScreenController> {
  final int type;

  const MyPropertiesScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'My Properties',
          style: MyTextStyle.productBold(size: 20),
        ),
        elevation: 0,
        backgroundColor: Get.theme.colorScheme.background,
      ),
      body: GetBuilder(
            init: controller,
            builder: (controller) =>  AuthHelper.isLoggedIn() ? Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            child: SearchPropertyTab(
              controller: controller,
            ),
          ),
         Expanded(
              child: Stack(
                children: [
                  controller.isLoading&&controller.propertyList.isEmpty
                      ? const MyPropertiesShimmer()
                      : ListView.builder(
                          controller: controller.scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: controller.propertyList.length,
                          itemBuilder: (context, index) {
                            PropertyData? propertyData = controller.propertyList[index];
                            return Card(
                              color: Get.theme.colorScheme.surface,
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Property Image Section
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                        child: ImageWidget(
                                          image: CommonFun.getMedia(m: propertyData.media ?? [], mediaId: 1),
                                          width: double.infinity,
                                          borderRadius: 16,
                                          height: 200,
                                          // fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 12,
                                        left: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Get.theme.colorScheme.primary,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            (propertyData.propertyType == 'Sales' ? 'FOR SALE' : 'FOR RENT'),
                                            style: MyTextStyle.productBold(
                                              size: 12,
                                              color: Get.theme.colorScheme.onPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Row(
                                          children: [
                                            _buildIconButton(
                                              onTap: () => controller.onDeleteProperty(propertyData.id ?? -1),
                                              icon: MImages.imageDeleteIcon,
                                              backgroundColor: Get.theme.colorScheme.error.withOpacity(0.9),
                                            ),
                                            const SizedBox(width: 8),
                                            _buildToggleVisibilityButton(propertyData, controller),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Property Details Section
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          propertyData.title ?? '',
                                          style: MyTextStyle.productBold(size: 18),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 16,
                                              color: Get.theme.colorScheme.primary,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                propertyData.address ?? '',
                                                style: MyTextStyle.productLight(
                                                  size: 14,
                                                  color: Get.theme.colorScheme.primary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Text(
                                              propertyData.propertyAvailableFor == 0
                                                  ? '${Constant.currencySymbol}${(propertyData?.firstPrice ?? 0).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ${propertyData.period != '' ? '/${propertyData.period}' : ''}'
                                                  : '${Constant.currencySymbol}${(propertyData?.firstPrice ?? 0).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ${propertyData.period != '' ? '/${propertyData.period}' : ''}',
                                              style: MyTextStyle.productBold(
                                                size: 20,
                                                color: Get.theme.colorScheme.primary,
                                              ),
                                            ),
                                            const Spacer(),
                                            ElevatedButton.icon(
                                              onPressed: () => controller.onEditBtnClick(propertyData),
                                              icon: const Icon(Icons.edit_outlined, size: 18),
                                              label: const Text('Edit'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Get.theme.colorScheme.primary,
                                                foregroundColor: Get.theme.colorScheme.onPrimary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(25),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                  if (controller.isHideProperty) CommonUI.loaderWidget(),
                ],
              ),
            ),
          ],
        ) : NotLoggedInScreen(callBack: (success) {
          
        if (success) {
          controller.fetchMyProperties();
        }
      }),
    ));
  }

  Widget _buildIconButton({
    required VoidCallback onTap,
    required String icon,
    required Color backgroundColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 32,
        width: 32,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Image.asset(
          icon,
          color: Get.theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildToggleVisibilityButton(PropertyData propertyData, MyPropertiesScreenController controller) {
    return InkWell(
      onTap: () => controller.onPropertyEnable(propertyData),
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: propertyData.isHidden == 0
              ? Get.theme.colorScheme.primary.withOpacity(0.9)
              : Get.theme.colorScheme.primary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          propertyData.isHidden == 1 ? Icons.visibility : Icons.visibility_off,
          size: 18,
          color: Get.theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}
