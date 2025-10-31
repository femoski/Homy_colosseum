import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:homy/utils/constants/app_icons.dart';
import 'package:homy/utils/extentions/extentions.dart';
import 'package:homy/utils/extentions/lib/string_extenstion.dart';
import 'package:homy/utils/helpers/helper_utils.dart';
import 'package:homy/utils/ui.dart';



class PropertyGridCard extends StatelessWidget {
  final PropertyData property;
  final bool? isFirst;
  final bool? showEndPadding;
  // final Function(FavoriteType type)? onLikeChange;
  const PropertyGridCard(
      {super.key,
      // this.onLikeChange,
      required this.property,
      this.isFirst,
      this.showEndPadding});

  @override
  Widget build(BuildContext context) {
    String rentPrice = (property.firstPrice!
        .toString()
        .priceFormate(
          disabled: Constant.isNumberWithSuffix == false,
        )
        .toString()
        .formatAmount(prefix: true));
    // if (property.rentduration != "" && property.rentduration != null) {
    //   rentPrice =
    //       ("$rentPrice / ") + (rentDurationMap[property.rentduration] ?? "");
    // }

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: (isFirst ?? false) ? 0 : 5.0,
        end: (showEndPadding ?? true) ? 5.0 : 0,
      ),
      child: GestureDetector(
        onLongPress: () {
          HelperUtils.share(context, property.id!);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: context.theme.colorScheme.surface,
            border: Border.all(
              width: 1.5,
              color: context.theme.colorScheme.outline,
            ),
          ),
          height: 272,
          width: 250,
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 147,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Ui.getImage(
                            property.media?.first.content ?? '',
                            height: 147,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            // blurHash: property.titleimagehash,
                          ),
                        ),
                     

                        PositionedDirectional(
                          start: 10,
                          bottom: 10,
                          child: Container(
                            height: 24,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: context.theme.colorScheme.background.withOpacity(
                                0.5,
                              ),
                              borderRadius: BorderRadius.circular(
                                4,
                              ),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 3),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Center(
                                  child: Text(
                                    property.propertyTypeId.toString()
                                        .toLowerCase()
                                        .tr,
                                  )
                                      
                                      .bold()
                                      .size(context.theme.textTheme.titleSmall!.fontSize!),
                                ),
                              ),
                            ),
                          ),
                        )

                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 5, bottom: 5, left: 12, right: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Ui.imageType(property.category?.image ?? '',
                                  width: 18,
                                  height: 18,
                                  color: context.theme.colorScheme.tertiary),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(property.category?.category ?? "")
                                  .size(
                                      context.theme.textTheme.titleSmall!.fontSize!)
                                  .bold(
                                    weight: FontWeight.w400,
                                  )
                                  .color(
                                      context.theme.colorScheme.onSurface,
                                  )
                            ],
                          ),
                          const SizedBox(
                            height: 7,
                          ),
                          if (property.propertyAvailableFor.toString().toLowerCase() ==
                              "rent") ...[
                            Text(rentPrice)
                                .size(
                                  context.theme.textTheme.titleMedium!.fontSize!,
                                )
                                .color(
                                  context.theme.colorScheme.tertiary,
                                )
                                .bold(
                                  weight: FontWeight.w700,
                                ),
                          ] else ...[
                            Text(property.firstPrice!.toString()
                                    .priceFormate(
                                      disabled:
                                          Constant.isNumberWithSuffix == false,
                                    )
                                    .toString()
                                    .formatAmount(prefix: true))
                                .size(
                                  context.theme.textTheme.titleMedium!.fontSize!,
                                )
                                .color(context.theme.colorScheme.tertiary)
                                .bold(
                                  weight: FontWeight.w700,
                                ),
                          ],
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            property.title ?? "",
                          )
                              .setMaxLines(lines: 1)
                              .size(context.theme.textTheme.titleMedium!.fontSize!)
                              .color(context.theme.colorScheme.onSurface),
                          if (property.city != "") ...[
                            const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Ui.getSvg(AppIcons.location,
                                    color: context.theme.colorScheme.onSurface),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Text(property.city ?? "")
                                      .color(context.theme.colorScheme.onSurface)
                                      .setMaxLines(lines: 1),
                                )
                              ],
                            )
                          ]
                        ],
                      ),
                    ),
                  )
                ],
              ),
              PositionedDirectional(
                end: 25,
                top: 128,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.background,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                          color: Color.fromARGB(33, 0, 0, 0),
                          offset: Offset(0, 2),
                          blurRadius: 15,
                          spreadRadius: 0)
                    ],
                  ),
                  child: Icon(
                    Icons.share,
                    color: context.theme.colorScheme.primary,
                  ),
                ),
              ),
              PositionedDirectional(
                start: 10,
                top: 10,
                child: Row(
                  children: [
                    // Visibility(
                    //     visible: property.promoted ?? false,
                    //     child: const PromotedCard(type: PromoteCardType.text)),
                    // const SizedBox(
                    //   width: 2,
                    // ),
                    // Container(
                    //   height: 24,
                    //   decoration: BoxDecoration(
                    //       color: context.color.secondaryColor.withOpacity(0.9),
                    //       borderRadius: BorderRadius.circular(4)),
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    //     child: Center(
                    //       child: Text(
                    //         UiUtils.getTranslatedLabel(context, "sell"),
                    //       )
                    //           .color(
                    //             context.color.textColorDark,
                    //           )
                    //           .bold()
                    //           .size(context.font.smaller),
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
