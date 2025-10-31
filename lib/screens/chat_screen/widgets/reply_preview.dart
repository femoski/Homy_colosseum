import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/chat/chat_message.dart';

class ReplyPreview extends StatelessWidget {
  final ChatMessages replyToMessage;
  final VoidCallback onCancelReply;

  const ReplyPreview({
    Key? key,
    required this.replyToMessage,
    required this.onCancelReply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        // border: Border(
        //   top: BorderSide(
        //     color: context.theme.dividerColor,
        //     width: 0.5,
        //   ),
        // ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  context.theme.colorScheme.primary,
                  context.theme.colorScheme.primary.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Reply to message',
                  style: TextStyle(
                    color: context.theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                if (replyToMessage.type == 'image')...[
                  const Row(
                    children: [
                      Icon(Icons.image), 
                      SizedBox(width: 6),
                      Text('Image'),
                    ],
                  ),
                ],

                 if (replyToMessage.type == 'audio')...[
                  const Row(
                    children: [
                      Icon(Icons.music_note), 
                      SizedBox(width: 6),
                      Text('Audio'),
                    ],
                  ),
                ],

                if (replyToMessage.type == 'text')...[
                  Text(
                    replyToMessage.text ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.theme.textTheme.bodySmall?.color,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onCancelReply,
            icon: Icon(
              Icons.close,
              size: 20,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
} 