import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/chat/chat_list.dart';
import 'package:homy/screens/chat_screen/controllers/message_box_controller.dart';
import 'package:homy/screens/chat_screen/widgets/chat_area.dart';
import 'package:homy/screens/chat_screen/widgets/chat_bottom.dart';
import 'package:homy/screens/chat_screen/widgets/chat_top_bar.dart';

class MessageBox extends StatelessWidget {
  final ChatListItem conversation;
  // final PropertyMessage? propertyMessage;
  final int screen;
  final Function(int blockUnBlock)? onUpdateUser;

  const MessageBox(
      {super.key,
      required this.conversation,
      required this.screen,
      this.onUpdateUser});

  @override
  Widget build(BuildContext context) {
    final controller = ChatScreenController(conversation, screen, onUpdateUser);
    return Scaffold(
      // backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/chat_background/doodle.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: GetBuilder(
          init: controller,
          builder: (controller) {
            return Column(
              children: [
                ChatTopBar(
                  conversation: controller.conversation,
                  onMoreBtnClick: (int, ChatUser) => {},
                  controller: controller,
                ),
                ChatArea(
                    chatId: controller.conversation.user.userId.toString(),
                    chatList: controller.chatMessages,
                    scrollController: controller.scrollController,
                    deletedChatList: controller.deletedChatList,
                    onLongPressToDeleteChat: controller.onLongPressToDeleteChat,
                    isDeletedMsg: controller.isDeletedMsg,
                    isTyping: controller.isTyping,
                    onReplyTap: controller.onSwipeToReply),

                ChatBottomArea(
                  controller: controller.textMessageController,
                  onTextFieldTap: controller.onTextFieldTap,
                  onTap: controller.onTextMsgSend,
                  onPlusButtonClick: controller.onPlusButtonClick,
                  conversation: controller.conversation,
                  onTextFieldChanged: controller.onTextFieldChanged,
                  onImageSelected: controller.handleImageSelection,
                  onDocumentSelected: (file) => {},
                  onVideoSelected: controller.handleVideoSelection,
                  onAudioSelected: controller.handleAudioSelection,
                  isReplying: controller.isReplying,
                  replyToMessage: controller.replyToMessage,
                  onCancelReply: controller.cancelReply,
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
