import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/category.dart';
import 'package:homy/models/property/property_type_model.dart';
import 'package:homy/screens/search_screen/controllers/search_controller.dart';
import 'package:homy/utils/my_text_style.dart';


class SearchPropertyCategory extends StatelessWidget {
  final SearchScreenController controller;

  const SearchPropertyCategory({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      id: controller.uPropertyCategoryID,
      init: controller,
      builder: (controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Text(
            'Select Type',
            style: MyTextStyle.productLight(
              size: 18,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            height: 40,
            width: Get.width,
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.outline,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: controller.selectPropertyCategory == 0 ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    width: (Get.width / controller.propertyCategory.length) - 15,
                    decoration: BoxDecoration(
                      borderRadius: controller.selectPropertyCategory == 0
                          ? const BorderRadius.only(bottomLeft: Radius.circular(30), topLeft: Radius.circular(30))
                          : const BorderRadius.only(
                              bottomRight: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                        color: Get.theme.colorScheme.primary,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  textDirection: TextDirection.ltr,
                  children: List.generate(
                    controller.propertyCategory.length,
                    (index) {
                      return InkWell(
                        onTap: () => controller.onSelectPropertyCategory(index),
                        child: Container(
                          width: (Get.width / 2.5),
                          alignment: Alignment.center,
                          child: AnimatedDefaultTextStyle(
                            style: MyTextStyle.productMedium(
                                size: 13,
                                color: controller.selectPropertyCategory == index ? Get.theme.colorScheme.onPrimary : Get.theme.colorScheme.primary),
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              controller.propertyCategory[index].toUpperCase(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          controller.selectPropertyCategory == 0
              ? PropertyCategoryType(
                  onTap: controller.onPropertySelected,
                  list: controller.residentialCategory,
                  selected: controller.selectedProperty,
                )
              : PropertyCategoryType(
                  onTap: controller.onPropertySelected,
                  list: controller.commercialCategory,
                  selected: controller.selectedProperty,
                ),
          const SizedBox(
            height: 10,
          ),
           Divider(
            thickness: 0.5,
            color: Get.theme.colorScheme.outline,
          ),
        ],
      ),
    );
  }
}

class PropertyCategoryType extends StatelessWidget {
  final Category? selected;
  final List<Category> list;
  final Function(Category selected) onTap;

  const PropertyCategoryType({super.key, required this.selected, required this.list, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          list.length,
          (index) {
            return InkWell(
              onTap: () => onTap(list[index]),
              child: Container(
                height: 37,
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: selected == list[index] ? Get.theme.colorScheme.primary.withOpacity(0.15) : Get.theme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: selected == list[index] ? Get.theme.colorScheme.primary : Get.theme.colorScheme.outline,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  list[index].title ?? '',
                  style: MyTextStyle.productMedium(
                    size: 16,
                    color: selected == list[index] ? Get.theme.colorScheme.primary : Get.theme.colorScheme.primary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}