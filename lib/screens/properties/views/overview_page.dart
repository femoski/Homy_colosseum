import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/common_funtions.dart';
import 'package:homy/screens/properties/controllers/add_edit_property_controller.dart';
import 'package:homy/screens/properties/widgets/modern_select_field.dart';
import 'package:homy/screens/properties/widgets/modern_text_field.dart';
import 'package:homy/utils/my_text_style.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;


class OverviewPage extends StatelessWidget {
  final AddEditPropertyScreenController controller;

  const OverviewPage({super.key, required this.controller});

  void _focusOnError(BuildContext context) {
    // Check each field in order and request focus for the first error found
    if (controller.showErrorsOverview) {
      if (controller.propertyTitleController.text.isEmpty) {
        FocusScope.of(context).requestFocus(controller.titleFocus);
        return;
      }
      // if (controller.selectPropertyCategory == null) {
      //   _showCategoryBottomSheet(context, controller);
      //   return;
      // }
      // if (controller.selectedPropertyType == null) {
      //   _showTypeBottomSheet(context, controller);
      //   return;
      // }
      // if (controller.selectPropertyCategoryIndex == 0 && controller.selectedBedrooms == null) {
      //   _showOptionsBottomSheet(
      //     context,
      //     'Select Bedrooms',
      //     CommonFun.getBedRoomList(),
      //     controller.selectedBedrooms,
      //     controller.onBedroomsClick,
      //   );
      //   return;
      // }
      // if (controller.selectedBathrooms == null) {
      //   _showOptionsBottomSheet(
      //     context,
      //     'Select Bathrooms',
      //     CommonFun.getBathRoomList(),
      //     controller.selectedBathrooms,
      //     controller.onBathroomsClick,
      //   );
      //   return;
      // }
      if (controller.aboutPropertyController.text.isEmpty) {
        FocusScope.of(context).requestFocus(controller.aboutFocus);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        // Call _focusOnError when showErrorsOverview changes to true
        if (controller.showErrorsOverview) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _focusOnError(context);
          });
        }
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModernTextField(
                controller: controller.propertyTitleController,
                focusNode: controller.titleFocus,
                labelText: 'Property Title',
                hintText: 'Enter property title',
                prefixIcon: Icons.title,
                textCapitalization: TextCapitalization.sentences,
                errorText: controller.showErrorsOverview && controller.propertyTitleController.text.isEmpty 
                    ? 'Please enter property title'
                    : null,
              ),
              const SizedBox(height: 24),
              
              // Category and Type Section
              Row(
                children: [
                  Expanded(
                    child: ModernSelectField(
                      title: 'Category',
                      value: controller.selectPropertyCategory ?? 'Select Category',
                      icon: Icons.category_outlined,
                      isSelected: controller.selectPropertyCategory != null,
                      onTap: () => _showCategoryBottomSheet(context, controller),
                      errorText: controller.showErrorsOverview && controller.selectPropertyCategory == null
                          ? 'Please select category'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ModernSelectField(
                      title: 'Type',
                      value: controller.selectedPropertyType?.title ?? 'Select Type',
                      icon: Icons.home_work_outlined,
                      isSelected: controller.selectedPropertyType != null,
                      onTap: () => _showTypeBottomSheet(context, controller),
                      errorText: controller.showErrorsOverview && controller.selectedPropertyType == null
                          ? 'Please select type'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Bedrooms and Bathrooms
              Row(
                children: [
                  Expanded(
                    child: ModernSelectField(
                      title: 'Bedrooms',
                      value: controller.selectedBedrooms ?? 'Select',
                      icon: Icons.bed_outlined,
                      isSelected: controller.selectedBedrooms != null,
                      color: controller.selectPropertyCategoryIndex == 0 
                          ? Get.theme.colorScheme.surface
                          : Get.theme.colorScheme.outline.withOpacity(0.3),
                      onTap: () {
                        if (controller.selectPropertyCategoryIndex == 0) {
                          _showOptionsBottomSheet(
                            context,
                            'Select Bedrooms',
                            CommonFun.getBedRoomList(),
                            controller.selectedBedrooms,
                            controller.onBedroomsClick,
                          );
                        }
                      },
                      errorText: controller.showErrorsOverview && 
                               controller.selectPropertyCategoryIndex == 0 && 
                               controller.selectedBedrooms == null
                          ? 'Please select bedrooms'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ModernSelectField(
                      title: 'Bathrooms',
                      value: controller.selectedBathrooms ?? 'Select',
                      icon: Icons.bathroom_outlined,
                      isSelected: controller.selectedBathrooms != null,
                      onTap: () => _showOptionsBottomSheet(
                        context,
                        'Select Bathrooms',
                        CommonFun.getBathRoomList(),
                        controller.selectedBathrooms,
                        controller.onBathroomsClick,
                      ),
                      errorText: controller.showErrorsOverview && controller.selectedBathrooms == null
                          ? 'Please select bathrooms'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Area
              ModernTextField(
                controller: controller.areaController,
                labelText: 'Area (sqft)',
                hintText: 'Enter property area',
                prefixIcon: Icons.square_foot,
                keyboardType: TextInputType.number,
                // errorText: controller.showErrorsOverview && controller.areaController.text.isEmpty
                //     ? 'Please enter area'
                //     : null,
              ),
              const SizedBox(height: 24),
              
              // About Property
              ModernTextField(
                controller: controller.aboutPropertyController,
                focusNode: controller.aboutFocus,
                labelText: 'About Property',
                hintText: 'Describe your property',
                prefixIcon: Icons.description_outlined,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                errorText: controller.showErrorsOverview && controller.aboutPropertyController.text.isEmpty
                    ? 'Please enter about property'
                    : null,
              ),
              const SizedBox(height: 60),


              // RichTextField(
              //   controller: controller.aboutPropertyController,
              //   focusNode: controller.aboutFocus,
              //   labelText: 'About Property',
              //   hintText: 'Describe your property (use *text* for bold)',
              //   prefixIcon: Icons.description_outlined,
              //   maxLines: 4,
              //   textCapitalization: TextCapitalization.sentences,
              //   errorText: controller.showErrorsOverview && controller.aboutPropertyController.text.isEmpty
              //       ? 'Please enter about property'
              //       : null,
              //   onChanged: (text) {
              //     // Process the text to handle bold formatting
              //     final spans = <TextSpan>[];
              //     final parts = text.split(RegExp(r'(\*.*?\*)'));
                  
              //     for (var i = 0; i < parts.length; i++) {
              //       if (parts[i].isEmpty) continue;
                    
              //       if (i % 2 == 0) {
              //         // Regular text
              //         spans.add(TextSpan(
              //           text: parts[i],
              //           style: Get.theme.textTheme.bodyMedium!.copyWith(
              //             fontSize: 15,
              //           ),
              //         ));
              //       } else {
              //         // Bold text (remove asterisks)
              //         final boldText = parts[i].length > 2 ? parts[i].substring(1, parts[i].length - 1) : parts[i];
              //         spans.add(TextSpan(
              //           text: boldText,
              //           style: Get.theme.textTheme.bodyMedium!.copyWith(
              //             fontSize: 15,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ));
              //       }
              //     }
                  
              //     // Update the controller with the formatted text
              //     controller.aboutPropertyController.value = TextEditingValue(
              //       text: text,
              //       selection: controller.aboutPropertyController.selection,
              //     );
              //   },
              // ),

            ],
          ),
        );
      },
    );
  }

  void _showCategoryBottomSheet(BuildContext context, AddEditPropertyScreenController controller) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Get.theme.shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modern handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Title with icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    color: Get.theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select Category',
                    style: MyTextStyle.productRegular(
                      size: 20,
                      color: Get.theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(
                color: Get.theme.colorScheme.outline.withOpacity(0.2),
                thickness: 1,
              ),
            ),
            // List of options
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: controller.propertyCategoryList.length,
                itemBuilder: (context, index) {
                  final category = controller.propertyCategoryList[index];
                  final isSelected = category == controller.selectPropertyCategory;
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Get.theme.colorScheme.primary.withOpacity(0.1)
                          : Get.theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Get.theme.colorScheme.primary
                            : Get.theme.colorScheme.outline.withOpacity(0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          controller.onPropertyCategoryClick(category);
                          Get.back();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  category,
                                  style: MyTextStyle.productRegular(
                                    size: 16,
                                    color: isSelected
                                        ? Get.theme.colorScheme.primary
                                        : Get.theme.colorScheme.onSurface,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: Get.theme.colorScheme.primary,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Bottom padding
            const SizedBox(height: 24),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showTypeBottomSheet(BuildContext context, AddEditPropertyScreenController controller) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Get.theme.shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.home_work_outlined,
                    color: Get.theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select Type',
                    style: MyTextStyle.productRegular(
                      size: 20,
                      color: Get.theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(
                color: Get.theme.colorScheme.outline.withOpacity(0.2),
                thickness: 1,
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: controller.propertyType.length,
                itemBuilder: (context, index) {
                  final propertyType = controller.propertyType[index];
                  final isSelected = propertyType == controller.selectedPropertyType;
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Get.theme.colorScheme.primary.withOpacity(0.1)
                          : Get.theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Get.theme.colorScheme.primary
                            : Get.theme.colorScheme.outline.withOpacity(0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          controller.onPropertyTypeClick(propertyType);
                          Get.back();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  propertyType.title ?? '',
                                  style: MyTextStyle.productRegular(
                                    size: 16,
                                    color: isSelected
                                        ? Get.theme.colorScheme.primary
                                        : Get.theme.colorScheme.onSurface,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: Get.theme.colorScheme.primary,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Get.theme.shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    title.contains('Bedrooms') ? Icons.bed_outlined : Icons.bathroom_outlined,
                    color: Get.theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: MyTextStyle.productRegular(
                      size: 20,
                      color: Get.theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(
                color: Get.theme.colorScheme.outline.withOpacity(0.2),
                thickness: 1,
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option == selectedValue;
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Get.theme.colorScheme.primary.withOpacity(0.1)
                          : Get.theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Get.theme.colorScheme.primary
                            : Get.theme.colorScheme.outline.withOpacity(0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          onSelect(option);
                          Get.back();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: MyTextStyle.productRegular(
                                    size: 16,
                                    color: isSelected
                                        ? Get.theme.colorScheme.primary
                                        : Get.theme.colorScheme.onSurface,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: Get.theme.colorScheme.primary,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget buildImage(String imagePath) {
    if (kIsWeb) {
      // For web platform
      if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
        // If it's a network image
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Text('Failed to load image'));
          },
        );
      } else {
        // For local files on web
        return Image.memory(
          File(imagePath).readAsBytesSync(),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Text('Failed to load image'));
          },
        );
      }
    } else {
      // For mobile platforms
      if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
        // If it's a network image
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Text('Failed to load image'));
          },
        );
      } else {
        // For local files
        return Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Text('Failed to load image'));
          },
        );
      }
    }
  }
}
