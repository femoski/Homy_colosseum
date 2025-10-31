import 'dart:developer';

 
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:homy/utils/constants/app_icons.dart';
import 'package:homy/utils/extentions/extentions.dart';
import 'package:homy/utils/ui.dart';

import 'promoted_card.dart';

 

class PropertyGradiendCard extends StatefulWidget {
  final PropertyData model;
  final bool? isFirst;
  final bool? showEndPadding;
  const PropertyGradiendCard(
      {super.key, required this.model, this.isFirst, this.showEndPadding});

  @override
  State<PropertyGradiendCard> createState() => _PropertyGradiendCardState();
}

class _PropertyGradiendCardState extends State<PropertyGradiendCard> {
  // List<Widget> paramterList(PropertyData propertie) {
  //   List<Parameter>? parameters = propertie.parameters;

  //   List<Widget>? icons = parameters?.map((e) {
  //     return Padding(
  //       padding: const EdgeInsets.all(2.0),
  //       child: SizedBox(
  //         width: 15,
  //         height: 15,
  //         child: SvgPicture.network(
  //           e.image!,
  //           color: context.theme.colorScheme.tertiary,
  //         ),
  //       ),
  //     );
  //   }).toList();

  //   Iterable<Widget>? filterd = icons?.take(4);

  //   return filterd?.toList() ?? [];
  // }

  @override
  Widget build(BuildContext context) {
    // log("AAASDSD ${widget.model.toMap()['promoted']}");
    return GestureDetector(
      onTap: () {
        Get.toNamed('/property-details/${widget.model.id}', arguments: {
          'propertyId': widget.model.id,
          'propertiesList': [],
          'fromMyProperty': false,
        });
        // Navigator.pushNamed(context, Routes.propertyDetails, arguments: {
        //   'propertyData': widget.model,
        //   'propertiesList': [],
        //   'fromMyProperty': false,
        // });
      },
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: (widget.isFirst ?? false) ? 0 : 5.0,
          end: (widget.showEndPadding ?? true) ? 5.0 : 0,
        ),
        child: Container(
          height: 200,
          width: 300,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: LayoutBuilder(builder: (context, c) {
            PropertyData propertie = widget.model;
            return Stack(
              children: [
                Ui.getImage(
                  propertie.media?.first.content ?? "https://picsum.photos/300/200",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Container(
                  width: c.maxWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.72),
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        stops: const [
                          0.2,
                          0.4,
                          0.7
                        ]),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: c.maxHeight,
                    width: c.maxWidth,
                    child: Stack(
                      children: [
                        PositionedDirectional(
                          top: 0,
                          start: 0,
                          child: Row(
                            children: [
                              Container(
                                height: 19,
                                decoration: BoxDecoration(
                                    color: context.theme.colorScheme.secondary.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(4)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Center(
                                    child: Text(
                                      propertie.propertyType.toString(),
                                    )
                                        .color(
                                          context.theme.colorScheme.onPrimary.withOpacity(0.8),
                                        )
                                        .bold()
                                        .size(context.theme.textTheme.bodySmall!.fontSize!),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              if (propertie.isFeatured ?? false)
                                Container(
                                  height: 19,
                                  decoration: BoxDecoration(
                                      color: context.theme.colorScheme.tertiary,
                                      borderRadius: BorderRadius.circular(4)),
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Center(
                                      child: PromotedCard(
                                          color: Colors.transparent,
                                          type: PromoteCardType.icon),
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                        PositionedDirectional(
                            bottom: 0,
                            start: 0,
                            child: SizedBox(
                              height: c.maxHeight * 0.35,
                              width: c.maxWidth - 20,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Spacer(),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Ui.imageType(
                                                propertie.category?.image ?? "",
                                                color: context.theme.colorScheme.tertiary,
                                                width: 20,
                                                height: 20),
                                            const SizedBox(
                                              width: 3,
                                            ),
                                            Expanded(
                                              child: Text((propertie.category!
                                                          .category) ??
                                                      "")
                                                  .setMaxLines(lines: 1)
                                                  .color(context.theme.colorScheme.onPrimary.withOpacity(0.8)),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Text(((propertie.title) ?? ""))
                                            .setMaxLines(lines: 1)
                                            .size(context.theme.textTheme.titleLarge!.fontSize!)
                                            .color(context.theme.colorScheme.onPrimary),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              AppIcons.location,
                                              color: context.theme.colorScheme.onPrimary
                                                  .withOpacity(0.8),
                                              width: 12,
                                              height: 12,
                                            ),
                                            Expanded(
                                              child: SizedBox(
                                                child: Text(
                                                       '${propertie.address}, ${propertie.city}')
                                                    .setMaxLines(lines: 1)
                                                    .size(context.theme.textTheme.bodySmall!.fontSize!)
                                                    .color(context.theme.colorScheme.onPrimary.withOpacity(0.8)),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Spacer(),
                                        FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Text('${propertie.firstPrice}'
                                                  .priceFormate(
                                                      disabled: Constant
                                                              .isNumberWithSuffix ==
                                                          false)
                                                  .formatAmount(
                                                    prefix: true,
                                                  ))
                                              .bold()
                                              .setMaxLines(lines: 1)
                                              .size(context.theme.textTheme.titleLarge!.fontSize!)
                                              .color(context.theme.colorScheme.onPrimary)
                                              .fontFamily("roboto"),
                                        ),
                                        // Row(
                                        //   mainAxisSize: MainAxisSize.min,
                                        //   children: paramterList(propertie),
                                        // )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ))
                      ],
                    ),
                  ),
                ),

                // const PositionedDirectional(
                //     child: PromotedCard(type: PromoteCardType.icon))
              ],
            );
          }),
        ),
      ),
    );
  }
}
