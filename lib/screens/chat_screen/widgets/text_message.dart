import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/models/chat/chat_message.dart';

import '../../../services/auth_service.dart';

class TextMessage extends StatefulWidget {
  final ChatMessages? chat;
  final ChatMessages? repliedTo;
  final Function(ChatMessages?)? onReplyTap;
  final bool isHighlighted;

  const TextMessage({
    Key? key,
    this.chat,
    this.repliedTo,
    this.onReplyTap,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  State<TextMessage> createState() => _TextMessageState();
}

class _TextMessageState extends State<TextMessage> with SingleTickerProviderStateMixin {
  late AnimationController _highlightController;
  late Animation<double> _highlightAnimation;

  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _highlightAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30.0,
      ),
    ]).animate(_highlightController);

    if (widget.isHighlighted) {
      _startHighlightAnimation();
    }
  }

  @override
  void didUpdateWidget(TextMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted && !oldWidget.isHighlighted) {
      _startHighlightAnimation();
    }
  }

  void _startHighlightAnimation() {
    Get.log('Starting highlight animation');
    _highlightController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _highlightController.dispose();
    super.dispose();
  }

  final AuthService _authService = Get.find<AuthService>();

  @override
  Widget build(BuildContext context) {
    bool isMe = widget.chat?.fromId == int.parse(_authService.id.toString());
    
    return AnimatedBuilder(
      animation: _highlightAnimation,
      builder: (context, child) {
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
              color: widget.isHighlighted 
                  ? Color.lerp(
                      isMe 
                          ? context.theme.colorScheme.primary.withOpacity(0.15)
                          : Colors.transparent,
                      context.theme.colorScheme.primary.withOpacity(0.35),
                      _highlightAnimation.value,
                    )
                  : (isMe 
                      ? isDarkMode ? context.theme.colorScheme.primary.withOpacity(0.5) : context.theme.colorScheme.primary.withOpacity(0.1)
                      : context.theme.cardColor.withOpacity(0.8)),
              // gradient: isMe && !widget.isHighlighted ? LinearGradient(
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              //   colors: [
              //     context.theme.colorScheme.primary.withOpacity(0.2),
              //     context.theme.colorScheme.primary.withOpacity(0.1),
              //   ],
              // ) : null,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 6),
                bottomRight: Radius.circular(isMe ? 6 : 20),
              ),
              border: Border.all(
                color: isMe 
                    ? context.theme.colorScheme.primary.withOpacity(0.2)
                    : context.theme.dividerColor.withOpacity(0.1),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isHighlighted
                      ? context.theme.colorScheme.primary.withOpacity(0.2 * _highlightAnimation.value)
                      : (isMe 
                          ? context.theme.colorScheme.primary.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05)),
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
                    if (widget.repliedTo != null) _buildRepliedMessage(context),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        7,
                        isMe ? 82 : 65,
                        widget.repliedTo != null ? 16 : 16
                      ),
                      child: Text(
                        widget.chat?.text ?? '',
                        style: TextStyle(
                          color: context.theme.textTheme.bodyLarge?.color,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 4,
                  right: 2,
                  child: CommonUI().buildTimeStamp(widget.chat?.status ?? '', widget.chat?.time?.toInt() ?? 0, isMe, false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeStamp(BuildContext context, bool isMe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isMe 
            ? context.theme.colorScheme.primary.withOpacity(0.15)
            : context.theme.colorScheme.background.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isMe 
              ? context.theme.colorScheme.primary.withOpacity(0.15)
              : context.theme.dividerColor.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatMessageTime((widget.chat?.time?.toInt() ?? 0) * 1000),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: isMe 
                  ? context.theme.colorScheme.primary.withOpacity(0.8)
                  : context.theme.hintColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(width: 4),
          _buildMessageStatus(context, isMe),
        ],
      ),
    );
  }

  Widget _buildRepliedMessage(BuildContext context) {
    bool isMe = widget.chat?.fromId == int.parse(_authService.id.toString());
    
    return GestureDetector(
      onTap: () => widget.onReplyTap?.call(widget.repliedTo),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: !isMe 
              ? context.theme.colorScheme.primary.withOpacity(0.08)
              : context.theme.cardColor.withOpacity(0.5),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: Border(
            left: BorderSide(
              color: context.theme.colorScheme.primary.withOpacity(1),
              width: 4,
            ),
          ),
        ),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.repliedTo?.fromId == int.parse(_authService.id.toString()) ? 'You' : widget.repliedTo?.messageUser?.name ?? '', // You can replace this with actual username if available
                style: TextStyle(
                  fontSize: 13,
                  color: context.theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),


              if(widget.repliedTo?.type == 'image')...[
                Row(
                  children: [
                    Icon(Icons.image, size: 20, color: context.theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Text('Image', style: TextStyle(fontSize: 12, color: context.theme.colorScheme.primary)),
                  ],
                ),
              ],

               if(widget.repliedTo?.type == 'audio')...[
                Row(
                  children: [
                    Icon(Icons.music_note, size: 20, color: context.theme.colorScheme.primary),
                    const SizedBox(width: 5),
                    Text('Audio', style: TextStyle(fontSize: 12, color: context.theme.colorScheme.primary)),
                  ],
                ),
              ],
              if(widget.repliedTo?.type == 'text')...[
              Text(
                widget.repliedTo?.text ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: context.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  height: 1.2,
                ),
                maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatMessageTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
          return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    // if (_isSameDay(date, now)) {
    //   return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    // } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
    //   return 'Yesterday';
    // } else {
    //   return '${date.day}/${date.month}';
    // }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  Widget _buildMessageStatus(BuildContext context, bool isMe) {
    if (!isMe) return const SizedBox.shrink();

    IconData? icon;
    Color? color;

    switch (widget.chat?.status?.toLowerCase()) {
      case 'sent':
        icon = Icons.check;
        color = Colors.grey;
        break;
      case 'delivered':
        icon = Icons.done_all;
        color = Colors.grey;
        break;
      case 'read':
        icon = Icons.done_all;
        color = Colors.blue;
        break;
      case 'pending':
        icon = Icons.access_time;
        color = Colors.grey;
        break;
      default:
        icon = Icons.access_time;
        color = Colors.grey;
        break;
    }

    return icon != null
        ? Icon(
            icon,
            size: 16,
            color: color,
          )
        : const SizedBox.shrink();
  }
}
