import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:homy/common/widgets/user_image_custom.dart';
import 'package:homy/models/chat/chat_list.dart';
import 'package:homy/screens/chat_screen/controllers/chat_controller.dart';
import 'package:homy/screens/chat_screen/message_box.dart';
import 'package:homy/utils/helpers/helper_utils.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../Helper/AuthHelper.dart';
import '../../common/widgets/not_logged_in_screen.dart';
import '../../utils/app_constant.dart';
import 'widgets/chat_list_shimmer.dart';
import 'widgets/no_chat_found.dart';
import '../../services/websocket_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({
    super.key,
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with WidgetsBindingObserver {
  late final RefreshController _refreshController;
  late final MessageScreenController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshController = RefreshController();
    controller = Get.put(MessageScreenController());
    controller.loadChatListFromCache();
    Get.find<WebSocketService>().isPageActive = true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Get.find<WebSocketService>().isPageActive = false;
    _refreshController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      Get.find<WebSocketService>().isPageActive = false;
    } else if (state == AppLifecycleState.resumed) {
      if (controller.activeChatId != null) {
        // ChatStorageService.messageUpdateFromServer.add(controller.activeChatId!);
        Get.find<WebSocketService>().sendConversationOpen(controller.activeChatId!);
        Get.log('controller.activeChatId: ${controller.activeChatId}');
      }
      Get.find<WebSocketService>().isPageActive = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          // backgroundColor: context.theme.colorScheme.primary,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Messages',
                style: TextStyle(
                    // color: context.theme.colorScheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.message,
              ),
            ],
          ),
        ),
        body: AuthHelper.isLoggedIn()
            ? Column(
                children: [
                  // DashboardTopBar(title: S.of(context).messages),
                  Container(
                    height: 47,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: Get.isDarkMode
                          ? null
                          : context.theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          width: 1, color: context.theme.colorScheme.outline),
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearchUser,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          HugeIcons.strokeRoundedSearch02,
                          size: 20,
                          color: context.theme.colorScheme.tertiary,
                        ),
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder().copyWith(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              width: 9,
                              color: context.theme.colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder().copyWith(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              width: 1,
                              color: context.theme.colorScheme.outline),
                        ),
                        hintText: 'Search',
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        hintStyle: MyTextStyle.productRegular(
                          size: 17,
                          // color: context.theme.colorScheme.primary,
                        ),
                      ),
                      cursorHeight: 17,
                      // cursorColor: context.theme.colorScheme.primary,
                    ),
                  ),
                  GetBuilder<MessageScreenController>(
                    builder: (controller) {
                      if (controller.isLoading &&
                          controller.filteredUserList.isEmpty) {
                        return const Expanded(
                          child: ChatListShimmer(),
                        );
                      }

                      if (controller.filteredUserList.isEmpty) {
                        return const Expanded(
                          child: NoChatFound(),
                        );
                      }

                      return Expanded(
                        child: SmartRefresher(
                          controller: _refreshController,
                          onRefresh: () async {
                            await controller.fetchFromServer();
                            _refreshController.refreshCompleted();
                          },
                          child: ListView.builder(
                            itemCount: controller.filteredUserList.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              ChatListItem? conversation =
                                  controller.filteredUserList[index];
                              ChatUsers? user = conversation.user;
                              return InkWell(
                                onTap: () {
                                  HelperUtils.push(
                                    Get.context!,
                                    MessageBox(
                                        conversation: conversation, screen: 1),
                                  ).then((value) {
                                    SystemChrome.setPreferredOrientations([
                                      DeviceOrientation.portraitUp,
                                      DeviceOrientation.portraitDown,
                                    ]);
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: context.theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Stack(
                                        children: [
                                          Hero(
                                            tag: 'avatar-${user.userId}',
                                            child: UserImageCustom(
                                              image: user.avatar ?? '',
                                              name: user.name ?? '',
                                              widthHeight: 60,
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              width: 15,
                                              height: 15,
                                              decoration: BoxDecoration(
                                                color: conversation.isOnline ==
                                                        'online'
                                                    ? Colors.green
                                                    : Colors.transparent,
                                                shape: BoxShape.circle,
                                                // border: Border.all(
                                                //   color: context.theme.colorScheme.surface,
                                                //   width: 2,
                                                // ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    user.name,
                                                    style:
                                                        MyTextStyle.productBold(
                                                                size: 16)
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                  _formatTime(conversation
                                                          .lastMessage?.time ??
                                                      0),
                                                  style: MyTextStyle
                                                      .productRegular(
                                                    size: 14,
                                                    color: context.theme
                                                        .colorScheme.tertiary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                if (conversation
                                                        .lastMessage?.fromId
                                                        .toString() ==
                                                    AuthHelper.getUserId()
                                                        .toString())
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 4),
                                                    child: _buildMessageStatus(
                                                      context,
                                                      conversation.lastMessage
                                                              ?.status ??
                                                          '',
                                                    ),
                                                  ),
                                                if (conversation
                                                        .lastMessage?.type ==
                                                    'image') ...[
                                                  Icon(
                                                    Icons.camera_alt_outlined,
                                                    size: 16,
                                                    color: context.theme
                                                        .colorScheme.tertiary,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  if (conversation
                                                          .lastMessage?.text ==
                                                      '') ...[
                                                    Text(
                                                      'Image',
                                                      style: MyTextStyle
                                                          .productRegular(
                                                        size: 14,
                                                        color: context
                                                            .theme
                                                            .colorScheme
                                                            .tertiary,
                                                      ),
                                                    ),
                                                  ]
                                                ],
                                                if (conversation
                                                        .lastMessage?.type ==
                                                    'audio') ...[
                                                  Icon(
                                                    Icons
                                                        .record_voice_over_sharp,
                                                    size: 16,
                                                    color: context.theme
                                                        .colorScheme.tertiary,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    'Audio',
                                                    style: MyTextStyle
                                                        .productRegular(
                                                      size: 14,
                                                      color: context.theme
                                                          .colorScheme.tertiary,
                                                    ),
                                                  ),
                                                ],
                                                if (conversation
                                                        .lastMessage?.type ==
                                                    'property')
                                                  Icon(
                                                    HugeIcons
                                                        .strokeRoundedHome01,
                                                    size: 16,
                                                    color: context.theme
                                                        .colorScheme.tertiary,
                                                  ),
                                                const SizedBox(width: 5),
                                                Expanded(
                                                  child: Text(
                                                    conversation.lastMessage
                                                            ?.text ??
                                                        '',
                                                    style: MyTextStyle
                                                        .productLight(
                                                      size: 15,
                                                      color: context.theme
                                                          .colorScheme.tertiary,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (conversation.unreadCount >
                                                    0)
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: context.theme
                                                          .colorScheme.primary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Text(
                                                      (conversation
                                                                  .unreadCount >
                                                              10)
                                                          ? Constant.tenPlus
                                                          : conversation
                                                              .unreadCount
                                                              .toString(),
                                                      style: MyTextStyle
                                                          .gilroySemiBold(
                                                        size: 12,
                                                        color: context
                                                            .theme
                                                            .colorScheme
                                                            .onPrimary,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              )
            : NotLoggedInScreen(callBack: (success) {
                if (success) {
                  setState(() {
                    controller.fetchFromServer();
                  });
                  // Get.offAllNamed(RouteHelper.getLoginRoute());
                }
              }),
      ),
    );
  }

  String _formatTime(int timestamp) {
    // Convert to milliseconds if in seconds
    if (timestamp.toString().length == 10) {
      timestamp *= 1000;
    }

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    // Format time in 12-hour format with AM/PM
    String timeStr = '';
    int hour = date.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour > 12 ? hour - 12 : hour;
    hour = hour == 0 ? 12 : hour; // Convert 0 to 12 for midnight
    timeStr = '$hour:${date.minute.toString().padLeft(2, '0')} $period';

    // Check date differences
    if (_isSameDay(date, now)) {
      return timeStr;
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    } else {
      // Show full date for messages older than a week
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildMessageStatus(BuildContext context, String status) {
    IconData? icon;
    Color? color;

    switch (status.toLowerCase()) {
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
        return const SizedBox.shrink();
    }

    return Icon(
      icon,
      size: 14,
      color: color,
    );
  }
}
