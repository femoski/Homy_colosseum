import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/common_funtions.dart';
import 'package:homy/common/widgets/image_widget.dart';
import 'package:homy/models/tour/fetch_property_tour.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:intl/intl.dart';

class TourRequestCard extends StatelessWidget {
  final FetchPropertyTourData data;

  const TourRequestCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Row(
              children: [
                _buildImage(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.property?.title ?? '',
                          style: MyTextStyle.productBold(size: 16),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Get.theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                data.property?.address ?? '',
                                style: MyTextStyle.productRegular(
                                  size: 14,
                                  color: Get.theme.colorScheme.onBackground
                                      .withOpacity(0.6),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Get.theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(data.createdAt),
                        style: MyTextStyle.productRegular(
                          color: Get.theme.colorScheme.primary,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Get.theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        data.tourTime ?? '',
                        style: MyTextStyle.productRegular(
                          color: Get.theme.colorScheme.primary,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(data.tourStatus ?? 0 , data.completionStatus ?? ''),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      data.tourStatusText ?? '',
                      style: MyTextStyle.productRegular(
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      width: 100,
      height: 100,
      child: ImageWidget(
        image: CommonFun.getMedia(m: data.property?.media ?? [], mediaId: 1),
        width: 100,
        height: 100,
        borderRadius: 16,
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return '';
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Color _getStatusColor(int status, String completionStatus) {
    switch (status) {
      case 1: // waiting
        return Colors.amber;
      case 2: // confirmed
        if(completionStatus == 'disputed'){
          return Colors.orange;
        }
        if(completionStatus == 'refunded'){
          return const Color(0xFF17c964);
        }
        if(completionStatus == 'to_user' || completionStatus == 'to_agent'){
          return const Color(0xFF1abc9c);
        }
        if(completionStatus == 'agent_marked'){
          return Colors.blue;
        }
        return Colors.green;
      case 3: // disputed
        return Colors.grey;
      case 4: // declined
        return Colors.red;
      case 5: // refunded
        return Colors.blue;
      case 7:
        if(completionStatus == 'disputed'){
          return Colors.orange;
        }
        if(completionStatus == 'refunded'){
          return const Color(0xFF17c964);
        }
        if(completionStatus == 'to_user' || completionStatus == 'to_agent'){
          return const Color(0xFF1abc9c);
        }
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
