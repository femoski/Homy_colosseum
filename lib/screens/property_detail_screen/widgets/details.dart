import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/property_detail_screen/controllers/property_detail_controller.dart';
import 'package:homy/screens/property_detail_screen/widgets/property_header.dart';
import 'package:homy/utils/helpers/helper_utils.dart';
import 'package:homy/utils/my_text_style.dart';

import '../../../models/property/property_data.dart';
import '../../../utils/app_constant.dart';

class Details extends GetView<PropertyDetailScreenController> {
  @override
  Widget build(BuildContext context) {
    PropertyData? data = controller.propertyData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PropertyHeading(title: 'Details'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                _buildDetailSection(
                  context,
                  'Basic Information',
                  [
                    // DetailItem('Property ID', data?.id.toString() ?? '', icon: Icons.numbers),
                    if(data?.builtYear != null && data?.builtYear != 0)
                    DetailItem('Built Year', data?.builtYear.toString() ?? '', icon: Icons.calendar_today),
                    if(data?.area != null)
                    DetailItem('Area', '${data?.area.toString()} Sqft', icon: Icons.square_foot),
                  ],
                  backgroundColor: context.theme.colorScheme.primary.withOpacity(0.05),
                ),
                _buildDetailSection(
                  context,
                  'Pricing',
                  [
                    if(data?.firstPrice != null)
                    DetailItem('First Price', HelperUtils.formatCurrency(double.parse(data?.firstPrice?.toString() ?? '0')), icon: Icons.monetization_on_outlined),
                    if (data?.propertyAvailableFor == 0 && data?.secondPrice != null)
                      DetailItem('Second Price', '${Constant.currencySymbol} ${data?.secondPrice}/Sqft', icon: Icons.price_change),
                    if(data?.tourBookingFee != null)
                    
                    DetailItem('Inspection Fee', HelperUtils.formatCurrency(double.parse(data?.tourBookingFee ?? '0')), icon: Icons.monetization_on_outlined),

                  ],
                  backgroundColor: Colors.transparent,
                ),
                _buildDetailSection(
                  context,
                  'Property Features',
                  [
                    DetailItem('Furniture', data?.furniture == 1 ? 'Furnished' : 'Not Furnished', 
                        icon: Icons.chair),
                    if(data?.facing != null && data?.facing != '0')
                    DetailItem('Facing', data?.facing.toString() ?? '', icon: Icons.compass_calibration),
                    if(data?.totalFloors != null)
                    DetailItem('Total Floors', data?.totalFloors.toString() ?? '', 
                        icon: Icons.apartment),
                    if(data?.floorNumber != null)
                    DetailItem('Floor Number', data?.floorNumber.toString() ?? '', 
                        icon: Icons.layers),
                    if(data?.carParkings != null)
                    DetailItem('Car Parking', data?.carParkings.toString() ?? '', 
                        icon: Icons.local_parking),
                  ],
                  backgroundColor: context.theme.colorScheme.primary.withOpacity(0.05),
                ),
                _buildDetailSection(
                  context,
                  'Additional Details',
                  [
                    DetailItem('Maintenance/Month', '${data?.maintenanceMonth}', 
                        icon: Icons.build),
                    if(data?.societyName != null)
                    DetailItem('Society Name', data?.societyName.toString() ?? '', 
                        icon: Icons.location_city),
                  ],
                  backgroundColor: Colors.transparent,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(
    BuildContext context, 
    String sectionTitle, 
    List<DetailItem> items, 
    {Color? backgroundColor}
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionTitle,
            style: Get.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: context.theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 15),
          ...items.map((item) => _buildDetailRow(context, item)).toList(),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, DetailItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            item.icon,
            size: 20,
            color: context.theme.primaryColor.withOpacity(0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              item.title.capitalize ?? '',
              style: MyTextStyle.productMedium(
                size: 15,
                color: context.theme.textTheme.bodyMedium!.color!.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.value,
              style: MyTextStyle.productBold(
                size: 15,
                color: context.theme.textTheme.bodyMedium!.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailItem {
  final String title;
  final String value;
  final IconData icon;

  DetailItem(this.title, this.value, {required this.icon});
}
