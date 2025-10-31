import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/widgets/user_block_dialog.dart';
import 'package:homy/common/widgets/user_report_dialog.dart';
import 'package:homy/services/user_blocking_service.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;
  final String userName;

  const UserProfileScreen({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final blockingService = Get.find<UserBlockingService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(userName),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Obx(() {
                  final isBlocked = blockingService.isUserBlocked(userId);
                  return ListTile(
                    leading: Icon(isBlocked ? Icons.block_flipped : Icons.block),
                    title: Text(isBlocked ? 'Unblock User' : 'Block User'),
                    onTap: () async {
                      Get.back();
                      await Get.dialog(
                        UserBlockDialog(
                          userId: userId,
                          userName: userName,
                          isBlocked: isBlocked,
                        ),
                      );
                    },
                  );
                }),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('Report User'),
                  onTap: () async {
                    Get.back();
                    final result = await Get.dialog(
                      UserReportDialog(
                        userId: userId,
                        userName: userName,
                      ),
                    );
                    if (result != null) {
                      // Handle report submission
                      print('User reported: $result');
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      // Rest of your user profile UI
    );
  }
} 