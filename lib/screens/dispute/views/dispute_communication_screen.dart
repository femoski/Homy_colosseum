import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/dispute/dispute_model.dart';
import 'package:homy/models/dispute/dispute_message.dart';
import 'package:homy/screens/dispute/controllers/dispute_communication_controller.dart';
import 'package:intl/intl.dart';

class DisputeCommunicationScreen extends GetView<DisputeCommunicationController> {
  const DisputeCommunicationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dispute #${controller.dispute.value?.id ?? ''}',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              controller.dispute.value?.property?.name ?? '',
              style: Get.textTheme.bodySmall?.copyWith(
                color: Get.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        )),
        actions: [
          IconButton(
            onPressed: () {
              Get.bottomSheet(
                _buildDisputeDetailsSheet(),
                isScrollControlled: true,
                backgroundColor: Get.theme.colorScheme.background,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
              );
            },
            icon: Icon(
              Icons.info_outline,
              color: Get.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.error.value != null) {
                return Center(
                  child: Text(
                    controller.error.value ?? 'An error occurred',
                    style: TextStyle(color: Get.theme.colorScheme.error),
                  ),
                );
              }

              if (controller.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Get.theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: Get.textTheme.bodyLarge?.copyWith(
                          color: Get.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                reverse: true,
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  return _buildMessageItem(message);
                },
              );
            }),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Get.theme.colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(
                        color: Get.theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Get.theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => controller.sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: controller.sendMessage,
                  style: IconButton.styleFrom(
                    backgroundColor: Get.theme.colorScheme.primary,
                    foregroundColor: Get.theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(DisputeMessage message) {
    if (message.isMessage) {
      return _buildChatMessage(message);
    } else if (message.isTransfer) {
      return _buildTransferMessage(message);
    } else if (message.isStatusChange) {
      return _buildStatusMessage(message);
    }
    return const SizedBox();
  }

  Widget _buildChatMessage(DisputeMessage message) {
    final isFromCurrentUser = (message.senderType == 'user' || message.senderType == 'agent') && 
        message.senderName == controller.currentUsername;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: isFromCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isFromCurrentUser) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Row(
                children: [
                  _buildAvatar(message),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                            '${message.senderName ?? 'Unknown'} (${message.senderType?.toUpperCase() ?? ''})',
                            style: Get.textTheme.bodyMedium?.copyWith(
                          color: Get.theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Text(
                      //   message.senderType?.toUpperCase() ?? '',
                      //   style: Get.textTheme.bodySmall?.copyWith(
                      //     color: Get.theme.colorScheme.onSurfaceVariant,
                      //     fontSize: 10,
                      //     letterSpacing: 0.5,
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          _buildMessageContent(message, isFromCurrentUser),
          _buildTimestamp(message, isFromCurrentUser),
        ],
      ),
    );
  }

  Widget _buildMessageContent(DisputeMessage message, bool isFromCurrentUser) {
    return Row(
      mainAxisAlignment: isFromCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isFromCurrentUser) ...[
          const SizedBox(width: 40), // Space for avatar
        ],
        Flexible(
          child: Container(
            margin: EdgeInsets.only(
              left: isFromCurrentUser ? 64 : 0,
              right: isFromCurrentUser ? 16 : 64,
            ),
            child: _buildMessageBubble(message, isFromCurrentUser),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(DisputeMessage message) {
    return CircleAvatar(
      backgroundColor: Get.theme.colorScheme.primaryContainer,
      radius: 16,
      child: Text(
        message.senderName?.substring(0, 1).toUpperCase() ?? 'U',
        style: TextStyle(
          color: Get.theme.colorScheme.onPrimaryContainer,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(DisputeMessage message, bool isFromCurrentUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isFromCurrentUser 
            ? Get.theme.colorScheme.primary 
            : Get.theme.colorScheme.surfaceVariant,
        borderRadius: _getBubbleRadius(isFromCurrentUser),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message.content ?? '',
        style: Get.textTheme.bodyMedium?.copyWith(
          color: isFromCurrentUser 
              ? Get.theme.colorScheme.onPrimary 
              : Get.theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  BorderRadius _getBubbleRadius(bool isFromCurrentUser) {
    const double smallRadius = 4;
    const double largeRadius = 16;
    
    return BorderRadius.only(
      topLeft: Radius.circular(isFromCurrentUser ? largeRadius : smallRadius),
      topRight: Radius.circular(isFromCurrentUser ? smallRadius : largeRadius),
      bottomLeft: const Radius.circular(largeRadius),
      bottomRight: const Radius.circular(largeRadius),
    );
  }

  Widget _buildTimestamp(DisputeMessage message, bool isFromCurrentUser) {
    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        left: isFromCurrentUser ? 0 : 40,
        right: isFromCurrentUser ? 16 : 0,
      ),
      child: Text(
        DateFormat('h:mm a').format(message.timestamp),
        style: Get.textTheme.bodySmall?.copyWith(
          color: Get.theme.colorScheme.onSurfaceVariant,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildTransferMessage(DisputeMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.swap_horiz_rounded,
                size: 18,
                color: Get.theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.title ?? 'Transfer To User',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: Get.theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMessage(DisputeMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 18,
                color: Get.theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.title ?? 'Status Updated',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: Get.theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisputeDetailsSheet() {
    return Obx(() {
      final dispute = controller.dispute.value;
      if (dispute == null) return const SizedBox();

      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.gavel_rounded,
                    color: Get.theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Dispute Details',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Property', dispute.property?.name ?? ''),
            _buildDetailRow('Filed by', dispute.participants?.user?.name ?? ''),
            _buildDetailRow('Agent', dispute.participants?.agent?.name ?? ''),
            _buildDetailRow('Filed on', DateFormat('MMM d, yyyy').format(dispute.createdAt ?? DateTime.now())),
            _buildDetailRow('Reason', dispute.reason ?? ''),
            if (dispute.evidence != null && dispute.evidence!.isNotEmpty)
              _buildDetailRow('Evidence', dispute.evidence!.first.content),
            const SizedBox(height: 16),
          ],
        ),
      );
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Get.textTheme.bodySmall?.copyWith(
              color: Get.theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Get.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Resolved for Agent';
      case 2:
        return 'Resolved for User';
      default:
        return 'Unknown';
    }
  }
} 