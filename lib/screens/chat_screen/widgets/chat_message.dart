import 'package:flutter/material.dart';
import '../../../models/chat/chat_message.dart';
import '../controllers/message_box_controller.dart';

class ChatMessage extends StatelessWidget {
  final ChatMessages message;
  final ChatScreenController controller;
  
  const ChatMessage({
    Key? key,
    required this.message,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) { // Swipe left to right
          controller.onSwipeToReply(message);
        }
      },
      child: Dismissible(
        key: Key(message.time.toString()),
        direction: DismissDirection.startToEnd,
        confirmDismiss: (direction) async {
          controller.onSwipeToReply(message);
          return false;
        },
        child: Container(
          // Add your chat message UI here
          child: Text(message.text ?? ''),
        ),
      ),
    );
  }
} 