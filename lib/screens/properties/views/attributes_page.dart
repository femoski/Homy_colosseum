import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/common_funtions.dart';
import 'package:homy/screens/properties/controllers/add_edit_property_controller.dart';
import 'package:homy/screens/properties/widgets/modern_select_field.dart';
import 'package:homy/screens/properties/widgets/modern_text_field.dart';

class AttributesPage extends StatelessWidget {
  final AddEditPropertyScreenController controller;

  const AttributesPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // Property Details Card
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Property Details',
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Get.theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ModernTextField(
                        controller: controller.societyNameController,
                        labelText: 'Society Name',
                        hintText: 'Enter society name',
                        prefixIcon: Icons.location_city,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 20),
                      ModernTextField(
                        controller: controller.builtYearController,
                        labelText: 'Built Year',
                        hintText: 'Enter built year',
                        prefixIcon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Features Card
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Features',
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Get.theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ModernSelectField(
                        title: 'Furniture',
                        value: controller.selectedFurniture ?? 'Select furniture type',
                        icon: Icons.chair_outlined,
                        isSelected: controller.selectedFurniture != null,
                        onTap: () => _showOptionsBottomSheet(
                          context,
                          'Select Furniture Type',
                          CommonFun.furnitureList,
                          controller.selectedFurniture,
                          controller.onFurnitureClick,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ModernSelectField(
                        title: 'Facing',
                        value: controller.selectedFacing ?? 'Select facing direction',
                        icon: Icons.compass_calibration_outlined,
                        isSelected: controller.selectedFacing != null,
                        onTap: () => _showOptionsBottomSheet(
                          context,
                          'Select Facing Direction',
                          CommonFun.facingList,
                          controller.selectedFacing,
                          controller.onFacingClick,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Floor Details Card
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Floor Details',
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Get.theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ModernSelectField(
                              title: 'Total Floors',
                              value: controller.selectedTotalFloor ?? 'Select',
                              icon: Icons.apartment,
                              isSelected: controller.selectedTotalFloor != null,
                              onTap: () => _showOptionsBottomSheet(
                                context,
                                'Select Total Floors',
                                CommonFun.getTotalFloorsList(),
                                controller.selectedTotalFloor,
                                controller.onTotalFloorClick,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ModernSelectField(
                              title: 'Floor Number',
                              value: controller.selectedFloorNumber ?? 'Select',
                              icon: Icons.layers_outlined,
                              isSelected: controller.selectedFloorNumber != null,
                              onTap: () => _showOptionsBottomSheet(
                                context,
                                'Select Floor Number',
                                CommonFun.getFloorsList(),
                                controller.selectedFloorNumber,
                                controller.onFloorNumberClick,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Additional Information Card
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Information',
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Get.theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ModernSelectField(
                        title: 'Car Parking',
                        value: controller.selectedCarParking ?? 'Select parking spots',
                        icon: Icons.local_parking_outlined,
                        isSelected: controller.selectedCarParking != null,
                        onTap: () => _showOptionsBottomSheet(
                          context,
                          'Select Parking Spots',
                          CommonFun.getCarParkingList(),
                          controller.selectedCarParking,
                          controller.onCarParkingClick,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ModernTextField(
                        controller: controller.maintenanceMonthController,
                        labelText: 'Monthly Maintenance',
                        hintText: 'Enter maintenance amount',
                        prefixIcon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Get.theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Get.theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  void _showOptionsBottomSheet(
    BuildContext context,
    String title,
    List<String> options,
    String? selectedValue,
    Function(String) onSelect,
  ) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.outline.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Get.theme.colorScheme.onSurface,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  return _buildOptionItem(option, selectedValue, onSelect);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildOptionItem(String option, String? selectedValue, Function(String) onSelect) {
    return InkWell(
      onTap: () {
        onSelect(option);
        Get.back();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: option == selectedValue
              ? Get.theme.colorScheme.primary.withOpacity(0.1)
              : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: option == selectedValue
                ? Get.theme.colorScheme.primary
                : Get.theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Text(
          option,
          style: TextStyle(
            fontSize: 16,
            color: option == selectedValue
                ? Get.theme.colorScheme.primary
                : Get.theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
