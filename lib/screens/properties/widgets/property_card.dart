import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/screens/dashboard/widgets/promoted_card.dart';
import 'package:homy/screens/properties/widgets/like_button_widget.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:homy/utils/constants/app_icons.dart';
import 'package:homy/utils/extentions/extentions.dart';
import 'package:homy/utils/extentions/lib/string_extenstion.dart';
import 'package:homy/utils/helpers/helper_utils.dart';
import 'package:homy/utils/responsiveSize.dart';
import 'package:homy/utils/ui.dart';



class PropertyHorizontalCard extends StatelessWidget {
  final PropertyData property;
  final List<Widget>? addBottom;
  final double? additionalHeight;
  final StatusButton? statusButton;
  final Function(FavoriteType type)? onLikeChange;
  final bool? useRow;
  final bool? showDeleteButton;
  final VoidCallback? onDeleteTap;
  final double? additionalImageWidth;
  final bool? showLikeButton;
  const PropertyHorizontalCard(
      {super.key,
      required this.property,
      this.useRow,
      this.addBottom,
      this.additionalHeight,
      this.onLikeChange,
      this.statusButton,
      this.showDeleteButton,
      this.onDeleteTap,
      this.showLikeButton,
      this.additionalImageWidth});

  @override
  Widget build(BuildContext context) {
    String rentPrice = (property.firstPrice.toString()
        .priceFormate(
          disabled: Constant.isNumberWithSuffix == false,
        )
        .toString()
        .formatAmount(prefix: true));

    // if (property.rentduration != "" && property.rentduration != null) {
    //   rentPrice =
    //       ("$rentPrice / ") + (rentDurationMap[property.rentduration] ?? "");
    // }

    return  Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.5),
        child: GestureDetector(
          onLongPress: () {
            HelperUtils.share(context, property.id!);
          },
          onTap: () {
            Get.toNamed('/property-details/${property.id}');
            // Get.to(() => PropertyDetailsScreen(property: property));
          },
          child: Container(
            height: addBottom == null ? 124 : (124 + (additionalHeight ?? 0)),
            decoration: BoxDecoration(
                border:
                    Border.all(width: 1.5, color: context.theme.colorScheme.outline),
                color: context.theme.colorScheme.surface ,
                borderRadius: BorderRadius.circular(18)),
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
                                      height: statusButton != null ? 90 : 120,
                                      width: 120 + (additionalImageWidth ?? 0),
                                      fit: BoxFit.cover,
                                    ),
                                    // Text(property.promoted.toString()),
                                    if (property.isFeatured ?? false)
                                      const PositionedDirectional(
                                          start: 5,
                                          top: 5,
                                          child: PromotedCard(
                                              type: PromoteCardType.icon)),
                                    PositionedDirectional(
                                      bottom: 6,
                                      start: 6,
                                      child: Container(
                                        height: 19,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                            color: context.theme.colorScheme.background
                                                .withOpacity(0.4),
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 2, sigmaY: 3),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Center(
                                              child: Text(
                                                property.propertyType ?? '',
                                              )
                                                  // .color(
                                                  //   context.theme.colorScheme.tertiary,
                                                  // )
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
                              if (statusButton != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 3.0, horizontal: 3.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: statusButton!.color,
                                        borderRadius: BorderRadius.circular(4)),
                                    width: 80,
                                    height: 120 - 90 - 8,
                                    child: Center(
                                        child: Text(statusButton!.lable)
                                            .size(context.theme.textTheme.titleSmall!.fontSize!)
                                            .bold()
                                            .color(statusButton?.textColor ??
                                                Colors.black)),
                                  ),
                                )
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    children: [
                                      Ui.imageType(
                                          property.category?.image ?? "",
                                          width: 18,
                                          height: 18,
                                          color: context.theme.colorScheme.tertiary),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child:
                                            Text(property.category?.category ?? "")
                                                .setMaxLines(lines: 1)
                                                .size(
                                                  context.theme.textTheme.titleSmall!.fontSize!
                                                      .rf(context),
                                                )
                                                .bold(
                                                  weight: FontWeight.w400,
                                                )
                                                // .color(
                                                //   context.theme.colorScheme.tertiary,
                                                // ),
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
                                                color:
                                                    Color.fromARGB(12, 0, 0, 0),
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
                                  if (property.propertyAvailableFor
                                          .toString()
                                          .toLowerCase() ==
                                      "1") ...[
                                    Text( 
                                      rentPrice,
                                    )
                                        .size(context.theme.textTheme.titleLarge!.fontSize!)
                                        .color(context.theme.colorScheme.tertiary)
                                        .bold(weight: FontWeight.w700)
                                        .fontFamily("roboto"),
                                        
                                  ] else ...[
                                    Text(
                                      property.firstPrice.toString()
                                          .priceFormate(
                                              disabled:
                                                  Constant.isNumberWithSuffix ==
                                                      false)
                                          .toString()
                                          .formatAmount(
                                            prefix: true,
                                          ),
                                    )
                                        .size(context.theme.textTheme.titleMedium!.fontSize!)
                                        .color(context.theme.colorScheme.tertiary)
                                        .bold(weight: FontWeight.w700)
                                        .fontFamily("roboto"),
                                  ],
                                  Text(
                                    property.title!.firstUpperCase(),
                                  )
                                      .setMaxLines(lines: 1)
                                      .size(context.theme.textTheme.titleMedium!.fontSize!),
                                      // .color(context.theme.colorScheme.outlineVariant),
                                  if (property.city != "")
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: context.theme.colorScheme.onTertiary,
                                        ),
                                        Expanded(
                                          child: Text(
                                                  property.city?.trim() ?? "")
                                              .setMaxLines(lines: 1)
                                              .color(
                                                  context.theme.colorScheme.tertiary),
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
                                    )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (useRow == false || useRow == null) ...addBottom ?? [],

                    if (useRow == true) ...{Row(children: addBottom ?? [])}

                    // ...addBottom ?? []
                  ],
                ),
                if (showDeleteButton ?? false)
                  PositionedDirectional(
                    top: 32 * 2,
                    end: 12,
                    child: InkWell(
                      onTap: () {
                        onDeleteTap?.call();
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.secondary,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                                color: Color.fromARGB(33, 0, 0, 0),
                                offset: Offset(0, 2),
                                blurRadius: 15,
                                spreadRadius: 0)
                          ],
                        ),
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: FittedBox(
                            fit: BoxFit.none,
                            child: SvgPicture.asset(
                              AppIcons.bin,
                              color: context.theme.colorScheme.onTertiary,
                              width: 18,
                              height: 18,
                            ),
                          ),
                        ),
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

class StatusButton {
  final String lable;
  final Color color;
  final Color? textColor;
  StatusButton({
    required this.lable,
    required this.color,
    this.textColor,
  });
}
