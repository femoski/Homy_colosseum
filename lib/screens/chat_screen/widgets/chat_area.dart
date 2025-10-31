import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/chat/chat_message.dart';
import 'package:homy/services/config_service.dart';
import 'package:homy/screens/chat_screen/widgets/audio_message.dart';
import 'package:homy/screens/chat_screen/widgets/image_message.dart';
import 'package:homy/screens/chat_screen/widgets/property_sale_card.dart';
import 'package:homy/screens/chat_screen/widgets/text_message.dart';
import 'package:homy/screens/chat_screen/widgets/typing_indicator.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get_storage/get_storage.dart';


// import 'image_message.dart';

class ChatArea extends StatefulWidget {
    final List<ChatMessages> chatList;
  final ScrollController scrollController;
  final Function(ChatMessages?) onLongPressToDeleteChat;
  final Function(ChatMessages)? onReplyTap;
  final List<int?> deletedChatList;
  final bool isDeletedMsg;
  final bool isTyping;
  final String chatId;

  const ChatArea(
      {super.key,
      required this.chatList,
      required this.scrollController,
      required this.onLongPressToDeleteChat,
      this.onReplyTap,
      required this.deletedChatList,
      required this.isDeletedMsg,
      this.isTyping = false,
      required this.chatId});

  @override
  State<ChatArea> createState() => _ChatAreaState();
}

class _ChatAreaState extends State<ChatArea> {
  final ScrollController _scrollController = ScrollController();
  // Map to store message positions
  final Map<String, GlobalKey> _messageKeys = {};
  String? _highlightedMessageId;
  bool _showScrollToBottom = false;
  bool _isLoading = true; // Add loading state
  bool _showDisclaimer = true; // Add disclaimer state
  final GetStorage _box = GetStorage();
  String disclaimerMessage = '';

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_scrollListener);
    _loadDisclaimerState();
    // Simulate loading delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _loadDisclaimerState() async {
       final configService = await ConfigService.getConfig();
      final isDisclaimerEnabled = configService.config.value?.chatConfig.isDisclaimerEnabled ?? true;

    setState(() {
      _showDisclaimer = isDisclaimerEnabled && !(_box.read('disclaimer_dismissed_${widget.chatId}') ?? false);
      disclaimerMessage = configService.config.value?.chatConfig.disclaimerMessage ?? 'Please do not share sensitive information in this chat. Stay safe!';
      Get.log('disclaimerMessage: $disclaimerMessage');
    });
  }

  void _dismissDisclaimer() {
    _box.write('disclaimer_dismissed_${widget.chatId}', true);
    setState(() {
      _showDisclaimer = false;
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!widget.scrollController.hasClients) return;
    
    // Show button if not at bottom
    final showButton = widget.scrollController.position.pixels > 100; // Reduced threshold
        
    if (showButton != _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = showButton;
      });
    }
  }

  void _scrollToBottom() {
    if (!widget.scrollController.hasClients) return;
    
    widget.scrollController.animateTo(
      0, // Since the list is reversed, 0 is actually the bottom
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollToMessage(String messageId) {
    if (!widget.scrollController.hasClients) return;
    
    final messageKey = _messageKeys[messageId];
    if (messageKey?.currentContext != null) {
      Scrollable.ensureVisible(
        messageKey!.currentContext!,
        alignment: 0.5, // Centers the target message
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ).then((_) {
        _highlightMessage(messageId);
      });
    }
  }

  void _highlightMessage(String messageId) {

    setState(() {
      // Set highlight state for the message
      _highlightedMessageId = messageId;
    });

    // Clear the highlight after a delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _highlightedMessageId = null;
        });
      }
    });
  }

  Widget _buildShimmerMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: context.theme.colorScheme.surfaceVariant,
            highlightColor: context.theme.colorScheme.surface,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: context.theme.colorScheme.surfaceVariant,
                  highlightColor: context.theme.colorScheme.surface,
                  child: Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: context.theme.colorScheme.surfaceVariant,
                  highlightColor: context.theme.colorScheme.surface,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          Column(
            children: [
              if (_showDisclaimer)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                  child: Card(
                    color: Get.isDarkMode ? context.theme.colorScheme.surfaceVariant : Colors.amber.shade100,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: context.theme.colorScheme.secondary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                                disclaimerMessage ?? 'Please do not share sensitive information in this chat. Stay safe!',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: context.theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: _dismissDisclaimer,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: context.theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Container(
                  color: context.theme.colorScheme.background,
                  margin: const EdgeInsets.only(bottom: 5),
                  child: _isLoading && widget.chatList.isEmpty
                      ? ListView.builder(
                          controller: widget.scrollController,
                          itemCount: 10, // Show 10 shimmer items while loading
                          reverse: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 4, top: 10),
                          itemBuilder: (context, index) => _buildShimmerMessage(context),
                        )
                      : ListView.builder(
                          controller: widget.scrollController,
                          itemCount: widget.chatList.length + (widget.isTyping ? 1 : 0),
                          reverse: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 4, top: 10),
                          itemBuilder: (context, index) {
                            if (widget.isTyping && index == 0) {
                              return const TypingIndicator();
                            }
                            
                            final messageIndex = widget.isTyping ? index - 1 : index;
                            if (messageIndex < 0) return const SizedBox();
                            
                            ChatMessages chat = widget.chatList[messageIndex];
                            ChatMessages? previousChat = messageIndex < widget.chatList.length - 1 
                                ? widget.chatList[messageIndex + 1] 
                                : null;

                            final repliedTo = chat.reply != null && chat.reply!.isNotEmpty 
                                ? ChatMessages.fromJson(chat.reply![0]) 
                                : null;

                            bool isSelected = widget.deletedChatList.contains(chat.time);
                            bool showTimeStamp = _shouldShowTimestamp(chat, previousChat);
                            
                            // Create a unique key using both id and time
                            final messageKey = '${chat.id}_${chat.time}';
                            
                            return Column(
                              children: [
                                if (showTimeStamp) _buildTimestampDivider(context, chat),
                                _ChatMessage(
                                  key: _messageKeys.putIfAbsent(messageKey, () => GlobalKey()),
                                  chat: chat,
                                  isSelected: isSelected,
                                  isDeletedMsg: widget.isDeletedMsg,
                                  onLongPressToDeleteChat: widget.onLongPressToDeleteChat,
                                  onReplyTap: widget.onReplyTap,
                                  deletedChatList: widget.deletedChatList,
                                  messageIndex: messageIndex,
                                  repliedTo: repliedTo,
                                  onReplyMessageTap: (repliedMessage) {
                                    if (repliedMessage != null) {
                                      // Find the target message in the chat list
                                      final targetMessage = widget.chatList.firstWhere(
                                        (msg) => msg.id == repliedMessage.id,
                                        orElse: () => repliedMessage,
                                      );
                                      
                                      // Construct the key using the target message's id and time
                                      final replyKey = '${targetMessage.id}_${targetMessage.time}';
                                      
                                      // Get the GlobalKey for this message
                                      final messageKey = _messageKeys[replyKey];
                                      
                                      Get.log('Navigating to replied message:');
                                      Get.log('Reply Key: $replyKey');
                                      Get.log('Message Key: $messageKey');
                                      Get.log('Context exists: ${messageKey?.currentContext != null}');

                                      if (messageKey?.currentContext != null) {
                                        Scrollable.ensureVisible(
                                          messageKey!.currentContext!,
                                          alignment: 0.5,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        ).then((_) {
                                          _highlightMessage(targetMessage.id.toString());
                                        });
                                      } else {
                                        // If the message is not currently visible, scroll to its approximate position
                                        final index = widget.chatList.indexWhere((msg) => msg.id == targetMessage.id);
                                        if (index != -1) {
                                          final approximatePosition = index * 100.0; // Approximate height per message
                                          widget.scrollController.animateTo(
                                            approximatePosition,
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          ).then((_) {
                                            // Try scrolling to exact position after a short delay
                                            Future.delayed(const Duration(milliseconds: 100), () {
                                              if (messageKey?.currentContext != null) {
                                                Scrollable.ensureVisible(
                                                  messageKey!.currentContext!,
                                                  alignment: 0.5,
                                                  duration: const Duration(milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                ).then((_) {
                                                  _highlightMessage(targetMessage.id.toString());
                                                });
                                              }
                                            });
                                          });
                                        }
                                      }
                                    }
                                  },
                                  highlightedMessageId: _highlightedMessageId,
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
          
          // Scroll to bottom button
          if (widget.chatList.isNotEmpty) // Only show when there are messages
            AnimatedPositioned(
              duration: const Duration(milliseconds: 150),
              right: 16,
              bottom: _showScrollToBottom ? 16 : -60,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _showScrollToBottom ? 1.0 : 0.0,
                child: FloatingActionButton.small(
                  onPressed: _scrollToBottom,
                  backgroundColor: context.theme.colorScheme.primary.withOpacity(0.8),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimestampDivider(BuildContext context, ChatMessages chat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: context.theme.dividerColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              _formatTimestamp(chat.time! *1000),
              style: TextStyle(
                color: context.theme.hintColor,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(child: Divider(color: context.theme.dividerColor)),
        ],
      ),
    );
  }

  bool _shouldShowTimestamp(ChatMessages? current, ChatMessages? previous) {
    if (current == null || previous == null) return true;
    final currentDate = DateTime.fromMillisecondsSinceEpoch(current.time! *1000);
    final previousDate = DateTime.fromMillisecondsSinceEpoch(previous.time! *1000);
    return !_isSameDay(currentDate, previousDate);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  String _formatTimestamp(int timestamp) {
      // Check if timestamp is in milliseconds (13 digits) or seconds (10 digits)
    if (timestamp.toString().length == 10) {
      timestamp = timestamp * 1000; // Convert seconds to milliseconds
    }
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    
    if (_isSameDay(date, now)) {
      return 'Today';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class MessageType extends StatelessWidget {
  final int index;
  final ChatMessages? chat;
  final bool isDeletedMsg;
  final Function(ChatMessages?)? onReplyMessageTap;
  final String? highlightedMessageId;
  const MessageType({
    super.key, 
    required this.index, 
    required this.chat, 
    required this.isDeletedMsg,
    this.onReplyMessageTap,
    this.highlightedMessageId,
  });

  @override
  Widget build(BuildContext context) {
    // Get the replied message if it exists
    final repliedTo = chat?.reply != null && chat!.reply!.isNotEmpty 
        ? ChatMessages.fromJson(chat!.reply![0]) 
        : null;

    // Get.log('highlightedMessageId: $highlightedMessageId');
    if(chat?.type == 'text'){
      return TextMessage(
        chat: chat,
        repliedTo: repliedTo,
        onReplyTap: onReplyMessageTap,
        isHighlighted: highlightedMessageId == chat!.id.toString(),
      );
    }
    if(chat?.type == 'image'){
      return ImageMessage(
        chat: chat,
        repliedTo: repliedTo,
        isHighlighted: highlightedMessageId == chat!.id.toString(),
      );
    }
    if(chat?.type == 'audio'){
      return AudioMessage(
        chat: chat,
        isDeletedMsg: isDeletedMsg,
      );
    }
    if(chat?.type == 'property'){
      return PropertySaleCard(
        index: index,
        chat: chat,
        isDeletedMsg: isDeletedMsg,
      );
    }
    return const SizedBox();
  }
  //       : chat?.type == 'image'
  //           ? ImageMessage(
  //               chat: chat,
  //               // isDeletedMsg: isDeletedMsg,
  //             )
  //       : chat?.type == 'audio'
  //               ? AudioMessage(
  //                   chat: chat,
  //                   isDeletedMsg: isDeletedMsg,
  //                 )
  //               : chat?.type == 'property'
  //                   ? PropertySaleCard(
  //                       index: index,
  //                       chat: chat,
  //                       isDeletedMsg: isDeletedMsg,
  //                     )
  //                    : const SizedBox();
  // }
}

class _ChatMessage extends StatefulWidget {
  final ChatMessages chat;
  final bool isSelected;
  final bool isDeletedMsg;
  final Function(ChatMessages?) onLongPressToDeleteChat;
  final Function(ChatMessages)? onReplyTap;
  final List<int?> deletedChatList;
  final int messageIndex;
  final ChatMessages? repliedTo;
  final Function(ChatMessages?)? onReplyMessageTap;
  final String? highlightedMessageId;
  const _ChatMessage({
    super.key,
    required this.chat,
    required this.isSelected,
    required this.isDeletedMsg,
    required this.onLongPressToDeleteChat,
    required this.onReplyTap,
    required this.deletedChatList,
    required this.messageIndex,
    this.repliedTo,
    this.onReplyMessageTap,
    this.highlightedMessageId,
  });

  @override
  State<_ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<_ChatMessage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragOffset = 0;
  static const double _maxDragOffset = 100.0;
  static const double _replyThreshold = 40.0;
  bool _hasGivenFeedback = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (details.delta.dx <= 0) return; // Only allow right swipe
    
    setState(() {
      _dragOffset += details.delta.dx;
      _dragOffset = _dragOffset.clamp(0, _maxDragOffset);
      
      // Give haptic feedback only once when crossing the threshold
      if (_dragOffset > _replyThreshold && !_hasGivenFeedback) {
        HapticFeedback.heavyImpact();
        _hasGivenFeedback = true;
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragOffset > _replyThreshold) {
      widget.onReplyTap?.call(widget.chat);
    }
    
    setState(() {
      _dragOffset = 0;
      _hasGivenFeedback = false; // Reset the feedback flag
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Stack(
        children: [
          if (_dragOffset > 0)
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Transform.scale(
                scale: _dragOffset / _maxDragOffset,
                child: Opacity(
                  opacity: _dragOffset / _maxDragOffset,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.reply_rounded,
                      color: context.theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: InkWell(
              onTap: () => widget.deletedChatList.isEmpty 
                  ? null 
                  : widget.onLongPressToDeleteChat(widget.chat),
              onLongPress: () => widget.deletedChatList.isEmpty 
                  ? widget.onLongPressToDeleteChat(widget.chat) 
                  : null,
              child: Container(
                foregroundDecoration: BoxDecoration(
                  color: widget.isSelected 
                      ? context.theme.colorScheme.primary.withOpacity(0.2) 
                      : null,
                ),
                child: MessageType(
                  index: widget.messageIndex,
                  chat: widget.chat,
                  isDeletedMsg: widget.isDeletedMsg,
                  onReplyMessageTap: widget.onReplyMessageTap,
                  highlightedMessageId: widget.highlightedMessageId,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
