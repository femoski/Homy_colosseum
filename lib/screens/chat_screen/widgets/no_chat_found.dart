import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/my_text_style.dart';

class NoChatFound extends StatelessWidget {
  const NoChatFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: context.theme.colorScheme.tertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Chats Found',
            style: MyTextStyle.productBold(
              size: 18,
              color: context.theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with someone',
            style: MyTextStyle.productRegular(
              size: 14,
              color: context.theme.colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
} 