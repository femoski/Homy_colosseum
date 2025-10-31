import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/screens/properties/widgets/like_button_widget.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:homy/utils/extentions/extentions.dart';
import 'package:homy/utils/extentions/lib/string_extenstion.dart';
import 'package:homy/utils/helpers/helper_utils.dart';
import 'package:homy/utils/responsiveSize.dart';
import 'package:homy/utils/ui.dart';
import 'package:homy/utils/my_text_style.dart';

class MatchedPropertyCard extends StatelessWidget {
  final PropertyData property;
  final Function(FavoriteType type)? onLikeChange;
  final bool? showLikeButton;

  const MatchedPropertyCard({
    super.key,
    required this.property,
    this.onLikeChange,
    this.showLikeButton,
  });

  @override
  Widget build(BuildContext context) {
    String rentPrice = (property.firstPrice.toString()
        .priceFormate(
          disabled: Constant.isNumberWithSuffix == false,
        )
        .toString()
        .formatAmount(prefix: true));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: GestureDetector(
        onLongPress: () {
          HelperUtils.share(context, property.id!);
        },
        onTap: () {
          Get.toNamed('/property-details/${property.id}');
        },
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1.5, 
              color: context.theme.colorScheme.outline,
            ),
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Get.isDarkMode 
                    ? Colors.transparent 
                    : context.theme.colorScheme.outline.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Stack(
                                children: [
                                  Ui.getImage(
                                    property.media?.first.content ?? "",
                                    height: 120,
                                    width: 120,
                                    fit: BoxFit.cover,
                                  ),
                                  // "Matched to Your Search" badge
                                  PositionedDirectional(
                                    top: 5,
                                    start: 5,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF4CAF50),
                                            Color(0xFF2E7D32),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Matched',
                        style: MyTextStyle.productRegular(
                          size: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Property type badge
                                  PositionedDirectional(
                                    bottom: 6,
                                    start: 6,
                                    child: Container(
                                      height: 19,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        color: context.theme.colorScheme.background
                                            .withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 3),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: Center(
                                            child: Text(
                                              property.propertyType ?? '',
                                            )
                                                .bold()
                                                .size(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 5,
                              left: 12,
                              bottom: 5,
                              right: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    Ui.imageType(
                                      property.category?.image ?? "",
                                      width: 18,
                                      height: 18,
                                      color: context.theme.colorScheme.tertiary,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(property.category?.category ?? "")
                                          .setMaxLines(lines: 1)
                                          .size(
                                            context.theme.textTheme.titleSmall!
                                                .fontSize!
                                                .rf(context),
                                          )
                                          .bold(weight: FontWeight.w400),
                                    ),
                                    if (showLikeButton ?? true)
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: context.theme.colorScheme.background,
                                          shape: BoxShape.circle,
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color.fromARGB(12, 0, 0, 0),
                                              offset: Offset(0, 2),
                                              blurRadius: 15,
                                              spreadRadius: 0,
                                            )
                                          ],
                                        ),
                                        child: LikeButtonWidget(
                                          property: property,
                                          onLikeChanged: onLikeChange,
                                        ),
                                      ),
                                  ],
                                ),
                                // Price
                                if (property.propertyAvailableFor
                                        .toString()
                                        .toLowerCase() ==
                                    "1") ...[
                                  Text(rentPrice)
                                      .size(context.theme.textTheme.titleLarge!.fontSize!)
                                      .color(context.theme.colorScheme.tertiary)
                                      .bold(weight: FontWeight.w700)
                                      .fontFamily("roboto"),
                                ] else ...[
                                  Text(
                                    property.firstPrice.toString()
                                        .priceFormate(
                                          disabled: Constant.isNumberWithSuffix == false,
                                        )
                                        .toString()
                                        .formatAmount(prefix: true),
                                  )
                                      .size(context.theme.textTheme.titleMedium!.fontSize!)
                                      .color(context.theme.colorScheme.tertiary)
                                      .bold(weight: FontWeight.w700)
                                      .fontFamily("roboto"),
                                ],
                                // Title
                                Text(
                                  property.title!.firstUpperCase(),
                                )
                                    .setMaxLines(lines: 1)
                                    .size(context.theme.textTheme.titleMedium!.fontSize!),
                                // Location
                                if (property.city != "")
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: context.theme.colorScheme.onTertiary,
                                      ),
                                      Expanded(
                                        child: Text(property.city?.trim() ?? "")
                                            .setMaxLines(lines: 1)
                                            .color(context.theme.colorScheme.tertiary),
                                      ),
                                      if (property.distance != null) ...[
                                        Text(
                                          " • ${property.distance!}",
                                          style: TextStyle(
                                            color: context.theme.colorScheme.tertiary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                // Contact Agent Button
                                const SizedBox(height: 4),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // TODO: Implement contact agent functionality
                                      Get.snackbar(
                                        'Contact Agent',
                                        'Contact agent functionality will be implemented',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Get.theme.colorScheme.primary,
                                      foregroundColor: Get.theme.colorScheme.onPrimary,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 8,
                                          backgroundColor: Get.theme.colorScheme.onPrimary,
                                          child: property.user?.avatar != null
                                              ? ClipOval(
                                                  child: Ui.getImage(
                                                    property.user!.avatar!,
                                                    width: 16,
                                                    height: 16,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.person,
                                                  size: 10,
                                                  color: Get.theme.colorScheme.primary,
                                                ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Contact Agent',
                        style: MyTextStyle.productRegular(
                          size: 12,
                          color: Get.theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
}
