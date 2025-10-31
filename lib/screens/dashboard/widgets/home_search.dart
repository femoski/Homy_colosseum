import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/dashboard/controller/search_box_controller.dart';
import 'package:homy/utils/constants/app_icons.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/utils/responsiveSize.dart';
import 'package:homy/utils/ui.dart';
import 'package:hugeicons/hugeicons.dart';

class HomeSearchField extends StatelessWidget {
  HomeSearchField({super.key});
  final SearchBoxController controller = Get.put(SearchBoxController());

  @override
  Widget build(BuildContext context) {
    Widget buildSearchIcon() {
      return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Ui.getSvg(AppIcons.search,
              color: context.theme.colorScheme.tertiary));
    }

    String currentSuggestion =
        controller.searchSuggestions[controller.currentSuggestionIndex.value];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Get.toNamed('/search');

              // Navigator.pushNamed(context, Routes.searchScreenRoute,
              //     arguments: {"autoFocus": true, "openFilterScreen": false});
            },
            child: AbsorbPointer(
              absorbing: true,
              child: Container(
                  width: 285.rw(
                    context,
                  ),
                  height: 50.rh(
                    context,
                  ),
                  alignment: Alignment.center,
                  // decoration: BoxDecoration(
                  //     border: Border.all(
                  //         width: 1.5, color: context.theme.colorScheme.outline),
                  //     borderRadius: const BorderRadius.all(Radius.circular(10)),
                  //     color: Get.isDarkMode? context.theme.colorScheme.surface : context.theme.colorScheme.onSecondary),
                  child: Obx(() {
                    String currentSuggestion = controller.searchSuggestions[
                        controller.currentSuggestionIndex.value];
                    return TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Search for $currentSuggestion',
                          hintStyle: TextStyle(
                            // color: context.theme.textTheme.bodyMedium!.color,
                            fontSize: 14,
                          ),
                          filled: true,
                          prefixIcon: Icon(
                            HugeIcons.strokeRoundedSearchArea,
                            size: 20,
                            color: context.theme.colorScheme.tertiary,
                          ),
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder().copyWith(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                width: 9,
                                color: context.theme.colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder().copyWith(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                width: 1,
                                color: context.theme.colorScheme.outline),
                          ),
                        ),
                        enableSuggestions: true,
                        onEditingComplete: () {
                          FocusScope.of(context).unfocus();
                        },
                        onTap: () {
                          //change prefix icon color to primary
                        });
                  })),
            ),
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Get.toNamed('/search');

              // Navigator.pushNamed(context, Routes.searchScreenRoute,
              //     arguments: {"autoFocus": true, "openFilterScreen": false});
            },
            child: Container(
              width: 50.rw(context),
              height: 50.rh(context),
              decoration: BoxDecoration(
                border: Border.all(
                    width: 1.5, color: context.theme.colorScheme.outline),
                color: Get.isDarkMode
                    ? context.theme.colorScheme.surface
                    : context.theme.colorScheme.onSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  HugeIcons.strokeRoundedMapsSearch,
                  size: 30,
                  color: context.theme.colorScheme.tertiary,
                ),

                // Ui.getSvg(AppIcons.propertyMap,
                //     color: context.theme.colorScheme.tertiary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
