import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/common_funtions.dart';
import 'package:homy/screens/search_screen/controllers/search_controller.dart';
import 'package:homy/utils/my_text_style.dart';


class SearchBathAndBed extends StatelessWidget {
  final SearchScreenController controller;

  const SearchBathAndBed({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: const EdgeInsets.only(bottom: 16),
        //   child: Row(
        //     children: [
        //       Container(
        //         padding: const EdgeInsets.all(8),
        //         decoration: BoxDecoration(
        //           color: Get.theme.colorScheme.primary.withOpacity(0.1),
        //           borderRadius: BorderRadius.circular(10),
        //         ),
        //         child: Icon(
        //           Icons.home_work_rounded,
        //           color: Get.theme.colorScheme.primary,
        //           size: 20,
        //         ),
        //       ),
        //       const SizedBox(width: 12),
        //       Text(
        //         'Property Details',
        //         style: MyTextStyle.productBold(
        //           size: 20,
        //           color: Get.theme.colorScheme.onBackground,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
         Text(
                'Bedrooms & Bathrooms',
                style: MyTextStyle.productBold(
                  size: 18,
                ),
              ),
        SizedBox(height: 16),
  
        Row(
          children: [
            GetBuilder(
              id: controller.uBedroomID,
              init: controller,
              builder: (controller) => BathBedCard(
                title: 'Bedrooms',
                list: CommonFun.getBedRoomList(),
                selectedValue: controller.selectBedroom,
                onChange: controller.selectPropertyCategory == 0 ? controller.onBedRoomChange : null,
                isResident: controller.selectPropertyCategory == 0,
              ),
            ),
            const SizedBox(width: 16),
            GetBuilder(
              id: controller.uBathroomID,
              init: controller,
              builder: (controller) => BathBedCard(
                title: 'Bathrooms',
                list: CommonFun.getBathRoomList(),
                selectedValue: controller.selectBathRoom,
                onChange: controller.onBathRoomChange,
                isResident: true,
              ),
            )
          ],
        )
      ],
    );
  }
}

class BathBedCard extends StatelessWidget {
  final String title;
  final List<dynamic> list;
  final dynamic selectedValue;
  final Function(String? value)? onChange;
  final bool isResident;

  const BathBedCard({
    super.key,
    required this.title,
    required this.list,
    this.selectedValue,
    this.onChange,
    required this.isResident,
  });

  void _showBottomSheet(BuildContext context) {
    if (!isResident) return;
    
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 4,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Enhanced Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        title == 'Bedrooms' ? Icons.king_bed_rounded : Icons.shower_rounded,
                        color: Get.theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select $title',
                          style: MyTextStyle.productBold(size: 20),
                        ),
                        Text(
                          title == 'Bedrooms' ? 'How many bedrooms?' : 'Number of bathrooms',
                          style: MyTextStyle.productLight(
                            size: 14,
                            color: Get.theme.colorScheme.onBackground.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      style: IconButton.styleFrom(
                        backgroundColor: Get.theme.colorScheme.background,
                        padding: const EdgeInsets.all(8),
                      ),
                      icon: Icon(
                        Icons.close_rounded,
                        color: Get.theme.colorScheme.onBackground.withOpacity(0.5),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Divider with gradient
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Get.theme.colorScheme.primary.withOpacity(0.1),
                      Get.theme.colorScheme.primary.withOpacity(0.05),
                      Get.theme.colorScheme.outline.withOpacity(0.05),
                    ],
                  ),
                ),
              ),

              // Enhanced Options List
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: list.map((value) {
                      final isSelected = value.toString() == selectedValue?.toString();
                      
                      return InkWell(
                        onTap: () {
                          onChange?.call(value.toString());
                          Get.back();
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Get.theme.colorScheme.primary
                                : Get.theme.colorScheme.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Get.theme.colorScheme.primary
                                  : Get.theme.colorScheme.outline.withOpacity(0.1),
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: Get.theme.colorScheme.primary.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Enhanced number indicator
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.2)
                                        : Get.theme.colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Number
                                      Text(
                                        value.toString(),
                                        style: MyTextStyle.productBold(
                                          size: 18,
                                          color: isSelected
                                              ? Colors.white
                                              : Get.theme.colorScheme.primary,
                                        ),
                                      ),
                                      // Icon overlay
                                      if (isSelected)
                                        Positioned(
                                          right: 4,
                                          bottom: 4,
                                          child: Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.white.withOpacity(0.9),
                                            size: 14,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Enhanced content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            title == 'Bedrooms'
                                                ? Icons.bed_rounded
                                                : Icons.bathroom_rounded,
                                            size: 16,
                                            color: isSelected
                                                ? Colors.white.withOpacity(0.7)
                                                : Get.theme.colorScheme.onBackground.withOpacity(0.4),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            title == 'Bedrooms'
                                                ? '${value == "1" ? "Single Bedroom" : "$value Bedrooms"}'
                                                : '${value == "1" ? "Single Bathroom" : "$value Bathrooms"}',
                                            style: MyTextStyle.productMedium(
                                              size: 16,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Get.theme.colorScheme.onBackground,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline_rounded,
                                            size: 14,
                                            color: isSelected
                                                ? Colors.white.withOpacity(0.5)
                                                : Get.theme.colorScheme.onBackground.withOpacity(0.3),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _getDescription(title, value.toString()),
                                            style: MyTextStyle.productLight(
                                              size: 13,
                                              color: isSelected
                                                  ? Colors.white.withOpacity(0.7)
                                                  : Get.theme.colorScheme.onBackground.withOpacity(0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  String _getDescription(String type, String value) {
    if (type == 'Bedrooms') {
      switch (value) {
        case '1':
          return 'Studio or single bedroom setup';
        case '2':
          return 'Suitable for couples or small families';
        case '3':
          return 'Comfortable for families';
        case '4':
          return 'Spacious family home';
        default:
          return 'Large family residence';
      }
    } else {
      switch (value) {
        case '1':
          return 'Single bathroom unit';
        case '2':
          return 'Master and guest bathrooms';
        case '3':
          return 'Multiple bathroom setup';
        default:
          return 'Luxury configuration';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => _showBottomSheet(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isResident 
                  ? Get.theme.colorScheme.primary.withOpacity(0.2)
                  : Get.theme.colorScheme.outline.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Get.theme.colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          foregroundDecoration: BoxDecoration(
            color: isResident ? null : Get.theme.colorScheme.background.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Main Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon and Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Get.theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            title == 'Bedrooms' 
                                ? Icons.king_bed_rounded 
                                : Icons.shower_rounded,
                            color: Get.theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: MyTextStyle.productMedium(
                            size: 14,
                            color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    
                    // Selected Value
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedValue?.toString() ?? 'Select',
                          style: selectedValue != null
                              ? MyTextStyle.productBold(
                                  size: 24,
                                  color: Get.theme.colorScheme.primary,
                                )
                              : MyTextStyle.productLight(
                                  size: 16,
                                  color: Get.theme.colorScheme.onBackground.withOpacity(0.5),
                                ),
                        ),
                        if (selectedValue != null)
                          Text(
                            title == 'Bedrooms'
                                ? '${selectedValue == "1" ? "Bedroom" : "Bedrooms"}'
                                : '${selectedValue == "1" ? "Bathroom" : "Bathrooms"}',
                            style: MyTextStyle.productLight(
                              size: 14,
                              color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Tap indicator
              if (isResident)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
