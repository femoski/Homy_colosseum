import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/common_funtions.dart';
import 'package:homy/common/widgets/image_widget.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:homy/utils/my_text_style.dart';


class PropertyCard extends StatelessWidget {
  final PropertyData? property;
  final EdgeInsets? margin;

  const PropertyCard({super.key, this.property, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Row(
        children: [
          Stack(
            children: [
              ImageWidget(
                  image: CommonFun.getMedia(m: property?.media ?? [], mediaId: 1),
                  width: Get.width / 2.7,
                  height: 118,
                  borderRadius: 13),
              // FeaturedCard(
              //     title: (property?.propertyAvailableFor == 0 ? S.of(context).forSale : S.of(context).forRent),
              //     fontColor: ColorRes.royalBlue,
              //     cardColor: ColorRes.white,
              //     margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
            ],
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 5,
                ),
                Text(
                  '${property?.title}'.capitalize ?? '',
                  style: MyTextStyle.productBold(size: 17),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(
                  height: 4,
                ),
                // Text(
                //   (property?.propertyType?.title ?? '').toUpperCase(),
                //   style: MyTextStyle.productMedium(size: 12, color: Get.theme.colorScheme.primary),
                // ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  (property?.address ?? '').capitalize ?? '',
                  style: MyTextStyle.productLight(size: 15, color: Get.theme.colorScheme.primary),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // HomeRowIconText(
                    //   image: MImages.bedroomIcon,
                    //   title: property?.bedrooms.toString() ?? '0',
                    //   isVisible: property?.bedrooms != 0,
                    // ),
                    // HomeRowIconText(
                    //   image: MImages.bathIcon,
                    //   title: property?.bathrooms.toString() ?? '0',
                    //   isVisible: property?.bathrooms != null,
                    // ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                        decoration: BoxDecoration(
                          color: Get.theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          property?.propertyAvailableFor == 0
                              ? '${Constant.currencySymbol}${(property?.firstPrice ?? 0)}'
                              : '${Constant.currencySymbol}${(property?.firstPrice ?? 0).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ${property?.period != '' ? '/${property?.period}' : ''}',
                          style: MyTextStyle.productMedium(size: 13, color: Get.theme.colorScheme.onPrimary),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
