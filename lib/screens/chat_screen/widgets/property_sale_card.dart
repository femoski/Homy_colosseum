import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/models/chat/chat_message.dart';
import 'package:homy/services/auth_service.dart';
import 'package:homy/utils/constants/image_string.dart';


class PropertySaleCard extends StatelessWidget {
  final int index;
  final ChatMessages? chat;
  final bool isDeletedMsg;
  const PropertySaleCard(
      {super.key, required this.index, required this.chat,required this.isDeletedMsg});




  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final isMe = chat?.fromId == int.parse(authService.id.toString());
        final isAvailable = chat?.propertyId == chat?.property?.propertyId? true : false;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          left: isMe ? 64 : 8,
          right: isMe ? 8 : 64,
          top: 4,
          bottom: 4,
        ),
        decoration: BoxDecoration(
          color: isMe 
              ? context.theme.colorScheme.primary.withOpacity(0.1)
              : context.theme.colorScheme.surface.withOpacity(0.8),
          gradient: isMe ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.theme.colorScheme.primary.withOpacity(0.15),
              context.theme.colorScheme.primary.withOpacity(0.05),
            ],
          ) : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 6),
            bottomRight: Radius.circular(isMe ? 6 : 20),
          ),
          border: Border.all(
            color: isMe 
                ? context.theme.colorScheme.primary.withOpacity(0.2)
                : context.theme.colorScheme.outline.withOpacity(0.1),
            width: 0.5,
          ),
          boxShadow: [
            if (!context.isDarkMode)
              BoxShadow(
                color: isMe 
                    ? context.theme.colorScheme.primary.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
                spreadRadius: -2,
              ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                           _buildPropertyCard(isMe, isAvailable),
                                       _buildMessageContainer(isMe),

              Align(
              alignment: Alignment.bottomRight,
              child: CommonUI().buildTimeStamp(chat?.status ?? '', chat?.time?.toInt() ?? 0, isMe, false),
            ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }


  @override
  Widget buildol(BuildContext context) {
    final authService = Get.find<AuthService>();
    final isMe = chat?.fromId == int.parse(authService.id.toString());
    final isAvailable = true;

    return InkWell(
      onTap: isDeletedMsg ? null : () {
        // Navigation logic commented out
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            _buildPropertyCard(isMe, isAvailable),
            _buildMessageContainer(isMe),
            const SizedBox(height: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard(bool isMe, bool isAvailable) {
    return GestureDetector(
      onTap: isAvailable && !isDeletedMsg ? () {

         Get.toNamed('/property-details/${chat?.property?.propertyId}', arguments: {
          'propertyId': chat?.property?.propertyId,
          'propertiesList': [],
          'fromMyProperty': false,
        });
      } : null,
      child: Stack(
        children: [
          Container(
            width: Get.width / 1.32,
            padding: const EdgeInsets.all(0),
            margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Get.theme.colorScheme.outline.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 4),
                _buildImageGallery(isAvailable),
                const SizedBox(height: 4),
                _buildPropertyInfo(isMe),
                // const SizedBox(height: 5),
              ],
            ),
          ),
          if (!isAvailable)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    'Unavailable',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Get.theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          _getImageCount(),
          (index) => _buildImageItem(index, isAvailable),
        ),
      ),
    );
  }

  int _getImageCount() {
    if (chat?.property?.image == null || chat!.property!.image!.isEmpty) {
      return 0;
    }
    return (chat?.property?.image?.length ?? 0) > 2
        ? 2
        : (chat?.property?.image?.length ?? 0);
  }

  Widget _buildImageItem(int index, bool isAvailable) {
    return Expanded(
      child: Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: isAvailable
              ? _buildNetworkImage(index)
              : const SizedBox(height: 130, width: 130),
        ),
      ),
    );
  }

  Widget _buildNetworkImage(int index) {
    print('buildNetworkImage ${chat?.property?.image?[index]}');
    return Image.network(
      (chat?.property?.image?[index] ?? ''),
      height: 130,
      width: 130,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 130,
      width: 130,
      padding: const EdgeInsets.all(15),
      child: Center(
        child: Image.asset(
          MImages.warningImage,
          color: Get.context!.theme.colorScheme.surface,
        ),
      ),
    );
  }

  Widget _buildPropertyInfo(bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat?.property?.title ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Get.theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  chat?.property?.address ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _buildPropertyTypeTag(),
        ],
      ),
    );
  }

  Widget _buildPropertyTypeTag() {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(50),
      ),
      alignment: Alignment.center,
      child: Text(
        chat?.property?.propertyType == 0 ? 'For Sale' : 'For Rent',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Get.theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildMessageContainer(bool isMe) {
    // if (chat?.property?.message == null || chat!.property!.message!.isEmpty) {
    //   return const SizedBox();
    // }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
      constraints: BoxConstraints(
        maxWidth: Get.width / 1.32,
      ),
      // decoration: BoxDecoration(
      //   color: Get.theme.colorScheme.surface.withOpacity(0.7),
      //   borderRadius: const BorderRadius.vertical(
      //     bottom: Radius.circular(15),
      //   ),
      //   border: Border.all(
      //     color: Get.theme.colorScheme.outline.withOpacity(0.1),
      //     width: 0.5,
      //   ),
      // ),
      child: Text(
        chat?.property?.message ?? chat?.text ?? '',
        style: TextStyle(
          fontSize: 15,
          // color: Get.theme.colorScheme.onSurface,
          height: 1.4,
        ),
      ),
    );
  }
}
