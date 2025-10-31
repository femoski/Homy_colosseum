import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/widgets/blur_bg_icon.dart';
import 'package:homy/common/widgets/user_image_custom.dart';
import 'package:homy/models/chat/chat_list.dart';
import 'package:homy/models/chat/conversation.dart';
import 'package:homy/screens/chat_screen/controllers/message_box_controller.dart';
import 'package:homy/utils/my_text_style.dart';

class ChatTopBar extends StatelessWidget {
  final ChatListItem? conversation;
  final Function(int, ChatUser?) onMoreBtnClick;
  final ChatScreenController controller;

  const ChatTopBar({super.key, required this.conversation, required this.onMoreBtnClick, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: controller.deletedChatList.isEmpty ? 1 : 0,
                child: controller.deletedChatList.isNotEmpty
                    ? const SizedBox()
                    : Row(
                        children: [
                          // Back Button
                          _buildBackButton(context),
                          const SizedBox(width: 12),
                          
                          // User Avatar
                          Hero(
                            tag: 'user-${conversation?.user?.name}',
                            child: UserImageCustom(
                              image: conversation?.user?.avatar ?? '',
                              name: conversation?.user?.name ?? '',
                              widthHeight: 45,
                              borderColor: context.theme.colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // User Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  conversation?.user?.name ?? '',
                                  style: MyTextStyle.productBold(
                                    size: 17,
                                    color: context.theme.colorScheme.onPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                _buildOnlineStatus(context),
                              ],
                            ),
                          ),
                          
                          // Actions
                          if(controller.isLoadingMessages)
                            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white,strokeWidth: 3,strokeCap: StrokeCap.round,))
                          else
                            _buildActionButtons(context),

                        ],
                      ),
              ),
              
              // Delete Mode UI
              _buildDeleteModeBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () => Get.back(),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.onPrimary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.theme.colorScheme.onPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineStatus(BuildContext context) {
    if (conversation?.isOnline == 'online') {
      return Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Online',
            style: MyTextStyle.productRegular(
              size: 13,
              color: context.theme.colorScheme.onPrimary.withOpacity(0.7),
            ),
          ),
        ],
      );
    } else {
      
      return Text(
        _getLastSeenText(conversation?.lastSeen.toString()),
        style: MyTextStyle.productRegular(
          size: 13,
          color: context.theme.colorScheme.onPrimary.withOpacity(0.7),
        ),
      );
    }
  }

  String _getLastSeenText(String? lastSeen) {
    if (lastSeen == null || lastSeen == "null") return ' ';
    if (lastSeen == "0") return 'Last Seen Recently';
    try {
      // Convert epoch timestamp string to DateTime
      final lastSeenDate = DateTime.fromMillisecondsSinceEpoch(
        int.parse(lastSeen) * 1000  // Multiply by 1000 if timestamp is in seconds
      );
      final now = DateTime.now();
      final difference = now.difference(lastSeenDate);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        final minutes = difference.inMinutes;
        return 'Last seen ${minutes}m ago';
      } else if (difference.inDays < 1) {
        final hours = difference.inHours;
        return 'Last seen ${hours}h ago';
      } else if (difference.inDays == 1) {
        return 'Last seen yesterday';
      } else if (difference.inDays < 7) {
        final days = difference.inDays;
        return 'Last seen ${days}d ago';
      } else {
        // Format date for older timestamps
        final day = lastSeenDate.day.toString().padLeft(2, '0');
        final month = lastSeenDate.month.toString().padLeft(2, '0');
        return 'Last seen on $day/$month/${lastSeenDate.year}';
      }
    } catch (e) {
      Get.log("Error in _getLastSeenText: $e");
      return 'Offline';
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // IconButton(
        //   icon: Icon(
        //     Icons.video_call_rounded,
        //     color: context.theme.colorScheme.onPrimary,
        //   ),
        //   onPressed: () {
        //     // Implement video call
        //   },
        // ),
        PopupMenuButton<int>(
          icon: Icon(
            Icons.more_vert,
            color: context.theme.colorScheme.onPrimary,
          ),
          color: context.theme.colorScheme.surface,
          elevation: 3,
          position: PopupMenuPosition.under,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // onSelected: (value) => onMoreBtnClick(value, conversation?.user),
          itemBuilder: (context) => [
            _buildPopupMenuItem(0, Icons.flag_outlined, 'Report', context),
            // _buildPopupMenuItem(
            //   1,
            //   Icons.block_outlined,
            //   conversation?.iAmBlocked == true ? 'Unblock' : 'Block',
            //   context,
            // ),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<int> _buildPopupMenuItem(
    int value,
    IconData icon,
    String text,
    BuildContext context,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: context.theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: MyTextStyle.productMedium(
              size: 14,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteModeBar(BuildContext context) {
    if (controller.deletedChatList.isEmpty) return const SizedBox();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: controller.deletedChatList.isEmpty ? 0 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            BlurBGIcon(
              icon: Icons.close_rounded,
              onTap: controller.onDeleteMessageCancel,
              color: context.theme.colorScheme.onPrimary.withOpacity(0.2),
              iconColor: context.theme.colorScheme.onPrimary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '${controller.deletedChatList.length} selected',
                style: MyTextStyle.productMedium(
                  size: 16,
                  color: context.theme.colorScheme.onPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 16),
            BlurBGIcon(
              icon: Icons.delete_rounded,
              onTap: controller.onDeleteMessageCancel,
              color: Colors.red.withOpacity(0.2),
              iconColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
