import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/dashboard/controller/search_box_controller.dart';
  import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/utils/responsiveSize.dart';
 import 'package:hugeicons/hugeicons.dart';


class HomeSearchFieldOld extends StatelessWidget {
  HomeSearchFieldOld({super.key});
  final SearchBoxController controller = Get.put(SearchBoxController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // Navigator.pushNamed(context, Routes.searchScreenRoute,
          //     arguments: {"autoFocus": true, "openFilterScreen": false});
        },
        child: AbsorbPointer(
          absorbing: true,
          child: Container(
            width: double.infinity,
            height: 50.rh(context),
            alignment: Alignment.center,
            child: Obx(() {
              String currentSuggestion =
                  controller.searchSuggestions[controller.currentSuggestionIndex.value];
              return TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Search for $currentSuggestion',
                  hintStyle: TextStyle(
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
                    borderSide:
                        BorderSide(width: 9, color: context.theme.colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder().copyWith(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(width: 1, color: context.theme.colorScheme.outline),
                  ),
                ),
                enableSuggestions: true,
                onEditingComplete: () {
                  FocusScope.of(context).unfocus();
                },
                onTap: () {
                  //change prefix icon color to primary
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}
