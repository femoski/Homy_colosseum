import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/common_funtions.dart';
import 'package:homy/screens/auth/login/login_screen.dart';
import 'package:homy/screens/search_screen/controllers/search_controller.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:homy/utils/extentions/lib/adaptive_type.dart';
import 'package:homy/utils/my_text_style.dart';

class RangeSelectedCard extends StatelessWidget {
  final SearchScreenController controller;
  final String title;
  final String? textIcon;
  final double startingRange;
  final double endingRange;
  final double minPrice;
  final double maxPrice;
  final Function(RangeValues)? onChanged;

  const RangeSelectedCard(
      {super.key,
      required this.controller,
      required this.title,
      required this.startingRange,
      required this.endingRange,
      required this.minPrice,
      required this.maxPrice,
      this.onChanged,
      this.textIcon});

  void _handleStartRangeChange(String value) {
    final newStart = double.parse(value);
    if (onChanged != null) {
      onChanged!(RangeValues(newStart, endingRange));
    }
  }

  void _handleEndRangeChange(String value) {
    final newEnd = double.parse(value);
    if (onChanged != null) {
      onChanged!(RangeValues(startingRange, newEnd));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        Text(
          title,
          style: MyTextStyle.productLight(
            size: 18,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: RangeCard(
                range: startingRange,
                title: textIcon,
                onChanged: _handleStartRangeChange,
                minValue: minPrice,
                maxValue: endingRange,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              'To',
              style: MyTextStyle.productLight(size: 17),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: RangeCard(
                range: endingRange,
                title: textIcon,
                onChanged: _handleEndRangeChange,
                minValue: startingRange,
                maxValue: maxPrice,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
          child: RangeSlider(
            values: RangeValues(startingRange, endingRange),
            labels: RangeLabels(
              startingRange.toString(),
              endingRange.toString(),
            ),
            onChanged: onChanged,
            min: minPrice,
            max: maxPrice,
            activeColor: Get.theme.colorScheme.primary,
            inactiveColor: Get.theme.colorScheme.primary.withOpacity(0.15),
          ),
        ),
        //  Divider(
        //   thickness: 0.5,
        //   color: Get.theme.colorScheme.outline,
        // ),
      ],
    );
  }
}

class RangeCard extends StatelessWidget {
  final double range;
  final String? title;
  final Function(String)? onChanged;
  final double minValue;
  final double maxValue;

  const RangeCard({
    super.key, 
    required this.range,
    this.title,
    this.onChanged,
    required this.minValue,
    required this.maxValue,
  });

  void _showEditDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: title == null ? range.toInt().numberFormat.toString() : range.toInt().toString()
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter ${title ?? 'Price'}',
                style: MyTextStyle.productBold(size: 18),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: MyTextStyle.productMedium(size: 18),
                decoration: InputDecoration(
                  hintText: 'Enter value',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: MyTextStyle.productMedium(
                          color: Get.theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final value = controller.text.replaceAll(',', '');
                        if (double.tryParse(value) != null) {
                          final numValue = double.parse(value);
                          if (numValue >= minValue && numValue <= maxValue) {
                            onChanged?.call(value);
                            Get.back();
                          } else {
                            Get.snackbar(
                              'Invalid Value',
                              'Please enter a value between ${minValue.toInt()} and ${maxValue.toInt()}',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Get.theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Apply',
                        style: MyTextStyle.productMedium(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged != null ? () => _showEditDialog(context) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.outline,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: Get.width / 8.5,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary,
                borderRadius: CommonFun.getRadius(
                  radius: 8,
                  isRTL: Directionality.of(context) == TextDirection.rtl,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                title ?? configService.config.value?.currencySymbol ?? Constant.currencySymbol,
                style: title == null
                    ? MyTextStyle.productMedium(size: 22, color: Get.theme.colorScheme.onPrimary)
                    : MyTextStyle.productLight(color: Get.theme.colorScheme.onPrimary, size: 15),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title == null ? range.toInt().numberFormat.toString() : range.toInt().toString(),
                    style: MyTextStyle.productMedium(color: Get.theme.colorScheme.primary, size: 17),
                  ),
                  if (onChanged != null) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: Get.theme.colorScheme.primary.withOpacity(0.5),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
