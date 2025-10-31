import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/models/chat/chat_message.dart';

import '../../../common/widgets/image_widget.dart';
import '../../../services/auth_service.dart';

class ImageMessage extends StatefulWidget {
  final ChatMessages? chat;
  final ChatMessages? repliedTo;
  final bool isHighlighted;

  const ImageMessage({
    super.key,
    required this.chat,
    this.repliedTo,
    this.isHighlighted = false,
  });
  

  @override
  State<ImageMessage> createState() => _ImageMessageState();
}

  

class _ImageMessageState extends State<ImageMessage> with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(ImageMessage oldWidget) {
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
                  : isMe 
              ? context.theme.colorScheme.primary.withOpacity(0.15)
              : context.theme.cardColor.withOpacity(0.8),
          gradient: isMe ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.theme.colorScheme.primary.withOpacity(0.2),
              context.theme.colorScheme.primary.withOpacity(0.1),
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
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: GestureDetector(
                        onTap: () => _showImagePreview(context),
                        child: Hero(
                          tag: 'chat_image_${widget.chat?.id}',
                          child: ImageWidget(
                            image: (widget.chat?.media ?? ''),
                            width: Get.width,
                            height: 250,
                            borderRadius: 10,
                          ),
                        ),
                      ),
                    ),
                    if (widget.chat?.text?.isEmpty ?? false)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: _buildTimeStamp(context, isMe, true),
                    ),
                  ],
                ),
                
                if (widget.chat?.text?.isNotEmpty ?? false)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      10,
                      7,
                      16,
                      widget.repliedTo != null ? 16 : 16
                    ),
                    child: Text(
                      widget.chat?.text ?? '',
                      style: TextStyle(
                        color: context.theme.textTheme.bodyLarge?.color,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                    ),
                  ),
              ],
            ),
            
            if (widget.chat?.text?.isNotEmpty ?? false)
              Positioned(
                bottom: 0,
                right: 2,
                  child: CommonUI().buildTimeStamp(widget.chat?.status ?? '', widget.chat?.time?.toInt() ?? 0, isMe, false),
            
              ),
          ],
          ),
        ));
      },
    );
  }

  Widget _buildTimeStamp(BuildContext context, bool isMe, bool onImage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: onImage 
            ? Colors.black.withOpacity(0.5)
            : (isMe 
                ? context.theme.colorScheme.primary.withOpacity(0.15)
                : context.theme.colorScheme.background.withOpacity(0.8)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: onImage
              ? Colors.transparent
              : (isMe 
                  ? context.theme.colorScheme.primary.withOpacity(0.15)
                  : context.theme.dividerColor.withOpacity(0.1)),
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
              color: onImage
                  ? Colors.white
                  : (isMe 
                      ? context.theme.colorScheme.primary.withOpacity(0.8)
                      : context.theme.hintColor.withOpacity(0.8)),
            ),
          ),
          const SizedBox(width: 4),
          _buildMessageStatus(context, isMe, onImage),
        ],
      ),
    );
  }

  Widget _buildRepliedMessage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.theme.colorScheme.primary.withOpacity(0.15),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3,
            height: 35,
            margin: const EdgeInsets.only(right: 10),
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
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Reply to',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.repliedTo?.text ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.theme.hintColor,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildMessageStatus(BuildContext context, bool isMe, bool onImage) {
    if (!isMe) return const SizedBox.shrink();

    IconData? icon;
    Color? color;

    switch (widget.chat?.status?.toLowerCase()) {
      case 'sent':
        icon = Icons.check;
        color = onImage ? Colors.white : Colors.grey;
        break;
      case 'delivered':
        icon = Icons.done_all;
        color = onImage ? Colors.white : Colors.grey;
        break;
      case 'read':
        icon = Icons.done_all;
        color = onImage ? Colors.white : Colors.blue;
        break;
      case 'pending':
        icon = Icons.access_time;
        color = onImage ? Colors.white : Colors.grey;
        break;
      default:
        icon = Icons.access_time;
        color = onImage ? Colors.white : Colors.grey;
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

  void _showImagePreview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImagePreviewScreen(
          imageUrl: widget.chat?.media ?? '',
          heroTag: 'chat_image_${widget.chat?.id}',
        ),
      ),
    );
  }
}

class ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const ImagePreviewScreen({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.share, color: Colors.white),
            ),
            onPressed: () {/* Implement share functionality */},
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.download, color: Colors.white),
            ),
            onPressed: () {/* Implement download functionality */},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            child: Hero(
              tag: heroTag,
              child: ImageWidget(
                image: imageUrl,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                borderRadius: 0,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
