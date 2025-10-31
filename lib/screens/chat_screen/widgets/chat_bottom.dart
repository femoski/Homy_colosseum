import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/chat/chat_list.dart';
import 'package:homy/models/chat/chat_message.dart';
import 'package:homy/screens/chat_screen/widgets/record_button.dart';
import '../../../utils/my_text_style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:homy/screens/chat_screen/widgets/reply_preview.dart';

class ChatBottomArea extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onTap;
  final VoidCallback onPlusButtonClick;
  final ChatListItem? conversation;
  final VoidCallback? onUnblockTap;
  final VoidCallback onTextFieldTap;
  final Function(String) onTextFieldChanged;
  final Future<void> Function(XFile) onImageSelected;
  final Function(PlatformFile) onDocumentSelected;
  final Function(XFile) onVideoSelected;
  final Function(XFile) onAudioSelected;
  final bool isReplying;
  final ChatMessages? replyToMessage;
  final VoidCallback onCancelReply;

  const ChatBottomArea(
      {super.key,
      required this.controller,
      required this.onTap,
      required this.onPlusButtonClick,
      required this.conversation,
      this.onUnblockTap,
      required this.onTextFieldTap,
      required this.onTextFieldChanged,
      required this.onImageSelected,
      required this.onDocumentSelected,
      required this.onVideoSelected,
      required this.onAudioSelected,
      this.isReplying = false,
      this.replyToMessage,
      required this.onCancelReply});

  @override
  State<ChatBottomArea> createState() => _ChatBottomAreaState();
}

class _ChatBottomAreaState extends State<ChatBottomArea>
    with SingleTickerProviderStateMixin {
  late final AnimationController _recordButtonAnimation = AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: 500,
    ),
  );

  List<XFile> selectedImages = [];
  bool showPreview = false;
  bool isSending = false;
  bool isRecording = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      if (source == ImageSource.gallery) {
        final List<XFile> images = await picker.pickMultiImage();
        if (images.isNotEmpty) {
          setState(() {
            selectedImages = images;
            showPreview = true;
          });
        }
      } else {
        final XFile? image = await picker.pickImage(source: source);
        if (image != null) {
          setState(() {
            selectedImages = [image];
            showPreview = true;
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null) {
      widget.onDocumentSelected(result.files.first);
    }
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      widget.onVideoSelected(video);
    }
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a'],
    );

    if (result != null) {
      widget.onDocumentSelected(result.files.first);
    }
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: <Widget>[
              _buildAttachmentOption(
                context,
                icon: Icons.camera_alt,
                label: 'Camera',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              _buildAttachmentOption(
                context,
                icon: Icons.photo_library,
                label: 'Gallery',
                color: Colors.purple,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              _buildAttachmentOption(
                context,
                icon: Icons.videocam,
                label: 'Video',
                color: Colors.pink,
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo();
                },
              ),
              _buildAttachmentOption(
                context,
                icon: Icons.insert_drive_file,
                label: 'Document',
                color: Colors.indigo,
                onTap: () {
                  Navigator.pop(context);
                  _pickDocument();
                },
              ),
              _buildAttachmentOption(
                context,
                icon: Icons.headphones,
                label: 'Audio',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  _pickAudio();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: context.theme.colorScheme.onBackground,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendSelectedImages() async {
    try {
      // setState(() {
      //   isSending = true;
      // });

 setState(() {
        // selectedImages.clear();
        showPreview = false;
        isSending = false;
      });

      for (var image in selectedImages) {
        await widget.onImageSelected(image);
      }

      setState(() {
        selectedImages.clear();
        showPreview = false;
        isSending = false;
      });
    } catch (e) {
      setState(() {
        isSending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send images. Please try again.')),
      );
    }
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: isSending ? null : _sendSelectedImages,
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color: isSending
              ? Get.theme.colorScheme.primary.withOpacity(0.6)
              : Get.theme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Get.theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSending
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Get.theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : Icon(
                Icons.send_rounded,
                color: Get.theme.colorScheme.onPrimary,
                size: 20,
              ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Get.theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with count and close button
          //  Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Text(
          //           '${selectedImages.length} ${selectedImages.length == 1 ? 'Image' : 'Images'} Selected',
          //           style: TextStyle(
          //             color: Get.theme.colorScheme.onSurface,
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //         IconButton(
          //           onPressed: () {
          //             setState(() {
          //               selectedImages.clear();
          //               showPreview = false;
          //             });
          //           },
          //           icon: Icon(
          //             Icons.close_rounded,
          //             color: Get.theme.colorScheme.error,
          //             size: 24,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // Image preview list
          SizedBox(
            height: 120,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              scrollDirection: Axis.horizontal,
              itemCount: selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Get.theme.shadowColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // Image
                        kIsWeb
                            ? Image.network(selectedImages[index].path)
                            : Image.file(
                                File(selectedImages[index].path),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                        // Delete button overlay
                        Positioned(
                          right: 8,
                          top: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedImages.removeAt(index);
                                if (selectedImages.isEmpty) {
                                  showPreview = false;
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: Get.theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                        // Image number overlay
                        Positioned(
                          left: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Get.theme.colorScheme.onPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Message input area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: context.theme.brightness == Brightness.dark
                              ? Colors.grey[800]!
                              : Colors.grey[300]!,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: TextField(
                      cursorWidth: 2,
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.center,
                      controller: widget.controller,
                      minLines: 1,
                      maxLines: 3,
                      onTap: widget.onTextFieldTap,
                      onChanged: (value) {
                        setState(() {
                          widget.controller.text = value;
                        });
                        widget.onTextFieldChanged(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Message',
                        hintStyle: TextStyle(
                          color: context.theme.brightness == Brightness.dark
                              ? Colors.grey[500]
                              : Colors.grey[400],
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 12,
                        ),
                      ),
                      style: TextStyle(
                        color: context.theme.brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black.withOpacity(0.85),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                      cursorColor: context.theme.colorScheme.primary,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildSendButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isReplying && widget.replyToMessage != null) 
          ReplyPreview(
            replyToMessage: widget.replyToMessage!,
            onCancelReply: widget.onCancelReply,
          ),
        // Show either image preview or chat input, not both
        if (showPreview)
          _buildImagePreview()
        else
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: const Offset(0, 0.0),
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.fastOutSlowIn,
                  ),
                ),
                child: child,
              );
            },
            child: widget.conversation?.user?.userId == 'true'
                ? InkWell(
                    onTap: widget.onUnblockTap,
                    child: Container(
                      color: context.theme.colorScheme.outline,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: SafeArea(
                        top: false,
                        child: Text(
                          '${'Unblock'} ${widget.conversation?.user?.name}',
                          style: MyTextStyle.gilroySemiBold(
                                  size: 16,
                                  color: context.theme.colorScheme.primary)
                              .copyWith(letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    color: context.theme.colorScheme.background,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 0),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                        if (!isRecording) ...[
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  context.theme.colorScheme.primary,
                                  context.theme.colorScheme.primary
                                      .withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: context.theme.colorScheme.primary
                                      .withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _showAttachmentOptions(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    CupertinoIcons.plus,
                                    size: 20,
                                    color: context.theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                         
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    context.theme.brightness == Brightness.dark
                                        ? Colors.grey[900]!.withOpacity(0.5)
                                        : Colors.grey[200]!.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: TextField(
                                cursorWidth: 2,
                                textAlign: TextAlign.start,
                                textAlignVertical: TextAlignVertical.center,
                                controller: widget.controller,
                                minLines: 1,
                                maxLines: 3,
                                onTap: widget.onTextFieldTap,
                                onChanged: (value) {
                                  setState(() {
                                    widget.controller.text = value;
                                  });
                                  widget.onTextFieldChanged(value);
                                },
                                decoration: InputDecoration(
                                  hintText: 'Type a message...',
                                  hintStyle: TextStyle(
                                    color: context.theme.brightness ==
                                            Brightness.dark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                    fontSize: 16,
                                  ),
border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                style: TextStyle(
                                  color: context.theme.brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 16,
                                ),
                                cursorColor: context.theme.colorScheme.primary,
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            ),
                          ),
                            const SizedBox(width: 8),
                          ] else ...[
                            const Spacer(),

                          ],
                            if (widget.controller.text.isNotEmpty && !isRecording)...[
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    context.theme.colorScheme.primary,
                                    context.theme.colorScheme.primary
                                        .withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.theme.colorScheme.primary
                                        .withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: widget.onTap,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Icon(
                                      Icons.send_rounded,
                                      color:
                                          context.theme.colorScheme.onPrimary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ]else...[
                          RecordButton(
                            controller: _recordButtonAnimation,
                            callback: (path) {
                              widget.onAudioSelected(XFile(path));
                            },
                            isSending: isSending,
                            onRecordingStateChanged: (bool isRecording) {
                              setState(() {
                                // Update your parent widget state
                                this.isRecording = isRecording;
                              });
                              // Or do whatever you need with the recording state
                            },
                          ),
                        ]],
                      ),
                    ),
                  ),
          ),
      ],
    );
  }
}
