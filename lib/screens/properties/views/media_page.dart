import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/media.dart';
import 'package:homy/screens/properties/controllers/add_edit_property_controller.dart';

class MediaPage extends StatelessWidget {
  final AddEditPropertyScreenController controller;

  const MediaPage({super.key, required this.controller});

  bool _isExpanded(AddEditPropertyScreenController controller, int sectionIndex) {
    return controller.expandedSections[sectionIndex];
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMediaSection(
                title: 'Overview Images',
                subtitle: 'Required',
                isRequired: true,
                list: controller.overviewMedia,
                onTap: () => controller.pickMultipleImage(0),
                onDeleteTap: (index) => controller.onImageDeleteTap(index, 0),
                threeSixtyIndex: 0,
              ),
              _buildExpandableMediaSection(
                title: 'Bedroom Images',
                subtitle: 'Optional',
                list: controller.bedRoomMedia,
                onTap: () => controller.pickMultipleImage(1),
                onDeleteTap: (index) => controller.onImageDeleteTap(index, 1),
                threeSixtyIndex: 1,
                sectionIndex: 1,
                controller: controller,
              ),
              _buildExpandableMediaSection(
                title: 'Bathroom Images',
                subtitle: 'Optional',
                list: controller.bathRoomMedia,
                onTap: () => controller.pickMultipleImage(2),
                onDeleteTap: (index) => controller.onImageDeleteTap(index, 2),
                threeSixtyIndex: 2,
                sectionIndex: 2,
                controller: controller,
              ),
              _buildExpandableMediaSection(
                title: 'Floor Plan',
                subtitle: 'Optional',
                list: controller.floorPlanMedia,
                onTap: () => controller.pickMultipleImage(3),
                onDeleteTap: (index) => controller.onImageDeleteTap(index, 3),
                threeSixtyIndex: 3,
                sectionIndex: 3,
                controller: controller,
              ),
              _buildExpandableMediaSection(
                title: 'Other Images',
                subtitle: 'Optional',
                list: controller.otherMedia,
                onTap: () => controller.pickMultipleImage(4),
                onDeleteTap: (index) => controller.onImageDeleteTap(index, 4),
                threeSixtyIndex: 4,
                sectionIndex: 4,
                controller: controller,
              ),
              _buildExpandableMediaSection(
                title: '360° Views',
                subtitle: 'Optional',
                list: controller.threeSixtyMedia,
                onTap: () => controller.pickMultipleImage(5),
                onDeleteTap: (index) => controller.onImageDeleteTap(index, 5),
                threeSixtyIndex: 5,
                sectionIndex: 5,
                controller: controller,
                is360: true,
              ),
              // const SizedBox(height: 16),
              _buildExpandableVideoSection(controller),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMediaSection({
    required String title,
    required String subtitle,
    required List<Media> list,
    required VoidCallback onTap,
    required Function(int) onDeleteTap,
    required int threeSixtyIndex,
    bool isRequired = false,
    bool is360 = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isRequired && list.isEmpty && controller.showErrorsMedia)
              ? Get.theme.colorScheme.error
              : Get.theme.colorScheme.primary.withOpacity(0.1),
          width: (isRequired && list.isEmpty && controller.showErrorsMedia) ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Get.theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  is360 ? Icons.view_in_ar : Icons.photo_library_outlined,
                  size: 20,
                  color: Get.theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Get.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isRequired
                        ? Get.theme.colorScheme.primary.withOpacity(0.1)
                        : Get.theme.colorScheme.outline.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    subtitle,
                    style: Get.textTheme.labelSmall!.copyWith(
                      color: isRequired
                          ? Get.theme.colorScheme.primary
                          : Get.theme.colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _buildAddImageButton(
                  onTap,
                  hasError: isRequired && list.isEmpty && controller.showErrorsMedia,
                ),
                ...list.map((media) => _buildImageTile(
                      media,
                      () => onDeleteTap(list.indexOf(media)),
                      is360: is360,
                    )),
              ],
            ),
          ),
          if (isRequired && list.isEmpty && controller.showErrorsMedia)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                'Please add at least one overview image',
                style: Get.textTheme.labelSmall!.copyWith(
                  color: Get.theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton(VoidCallback onTap, {bool hasError = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasError
                ? Get.theme.colorScheme.error
                : Get.theme.colorScheme.primary.withOpacity(0.2),
            width: hasError ? 2 : 1,
          ),
        ),
        child: Icon(
          Icons.add_rounded,
          color: hasError
              ? Get.theme.colorScheme.error
              : Get.theme.colorScheme.primary,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildImageTile(Media media, VoidCallback onDelete, {bool is360 = false}) {
    return Container(
      margin: const EdgeInsets.only(left: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(media, is360),
                  if (is360)
                    Container(
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.primary.withOpacity(0.3),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.view_in_ar,
                            color: Get.theme.colorScheme.surface,
                            size: 24,
                          ),
                          Text(
                            '360°',
                            style: Get.textTheme.labelSmall!.copyWith(
                              color: Get.theme.colorScheme.surface,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: Get.theme.colorScheme.surface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(Media media, bool is360) {
    Widget imageWidget;
    if (media.id != -1) {
      imageWidget = Image.network(
        media.content ?? '',
        fit: BoxFit.cover,
      );
    } else {
      if (kIsWeb) {
        // For web, use network image
        imageWidget = Image.network(
          media.content!,
          fit: BoxFit.cover,
        );
      } else {
        // For mobile, use file
        imageWidget = Image.file(
          File(media.content!),
          fit: BoxFit.cover,
        );
      }
    }

    return is360
        ? ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: imageWidget,
          )
        : imageWidget;
  }

  Widget _buildVideoPreview(AddEditPropertyScreenController controller) {
    if (controller.propertyVideoThumbnail == null &&
        controller.networkPropertyVideoThumbnail == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.upload_file,
            size: 48,
            color: Get.theme.colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload Video',
            style: Get.textTheme.bodyMedium!.copyWith(
              color: Get.theme.colorScheme.primary,
            ),
          ),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: controller.networkPropertyVideoThumbnail != null
              ? Image.network(
                  controller.networkPropertyVideoThumbnail!,
                  fit: BoxFit.cover,
                )
              : kIsWeb
                  ? Image.network(
                      controller.propertyVideoThumbnail!.path,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(controller.propertyVideoThumbnail!.path),
                      fit: BoxFit.cover,
                    ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.play_circle_outline,
            size: 48,
            color: Get.theme.colorScheme.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableMediaSection({
    required String title,
    required String subtitle,
    required List<Media> list,
    required VoidCallback onTap,
    required Function(int) onDeleteTap,
    required int threeSixtyIndex,
    required int sectionIndex,
    required AddEditPropertyScreenController controller,
    bool is360 = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Get.theme.colorScheme.primary.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Get.theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => controller.toggleSection(sectionIndex),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    is360 ? Icons.view_in_ar : Icons.photo_library_outlined,
                    size: 20,
                    color: Get.theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Get.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.outline.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      subtitle,
                      style: Get.textTheme.labelSmall!.copyWith(
                        color: Get.theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded(controller, sectionIndex)
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: Get.theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded(controller, sectionIndex))
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  _buildAddImageButton(onTap),
                  ...list.map((media) => _buildImageTile(
                        media,
                        () => onDeleteTap(list.indexOf(media)),
                        is360: is360,
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandableVideoSection(AddEditPropertyScreenController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Get.theme.colorScheme.primary.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Get.theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => controller.toggleSection(6),
            child: Row(
              children: [
                Icon(
                  Icons.videocam_outlined,
                  size: 20,
                  color: Get.theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Property Video',
                  style: Get.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.outline.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Optional',
                    style: Get.textTheme.labelSmall!.copyWith(
                      color: Get.theme.colorScheme.outline,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  _isExpanded(controller, 6)
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: Get.theme.colorScheme.primary,
                ),
              ],
            ),
          ),
          if (_isExpanded(controller, 6)) ...[
            const SizedBox(height: 16),
            InkWell(
              onTap: controller.pickPropertyVideo,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Get.theme.colorScheme.primary.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: _buildVideoPreview(controller),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
