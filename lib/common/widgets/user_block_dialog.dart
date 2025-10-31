import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/services/user_blocking_service.dart';

class UserBlockDialog extends StatefulWidget {
  final String userId;
  final String userName;
  final bool isBlocked;

  const UserBlockDialog({
    Key? key,
    required this.userId,
    required this.userName,
    required this.isBlocked,
  }) : super(key: key);

  @override
  State<UserBlockDialog> createState() => _UserBlockDialogState();
}

class _UserBlockDialogState extends State<UserBlockDialog> {
  bool _isLoading = false;

  Future<void> _handleBlockAction() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    
    try {
      final blockingService = Get.find<UserBlockingService>();
       final result = await blockingService.toggleBlockUser(widget.userId);
       
       Get.log('Resultgagaggaaa: ${result['is_blocked']}');
        Get.back(result: result['is_blocked']);
        
      
      // if (widget.isBlocked) {
      //   await blockingService.unblockUser(widget.userId);
      //   Get.back(result: false);
      // } else {
      //   await blockingService.blockUser(widget.userId);
      //   Get.back(result: true);
      // }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to ${widget.isBlocked ? 'unblock' : 'block'} user. Please try again. ${e}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      // backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon at the top
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.isBlocked 
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.isBlocked ? Icons.person_add : Icons.block,
                color: widget.isBlocked ? Colors.blue : Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              widget.isBlocked ? 'Unblock User' : 'Block User',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Username
            Text(
              widget.userName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            
            // Description
            Text(
              widget.isBlocked
                  ? 'Are you sure you want to unblock this user? You will be able to see their content and messages again.'
                  : 'Are you sure you want to block this user? You won\'t see their content or receive messages from them.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: _isLoading 
                            ? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleBlockAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isBlocked ? Colors.blue : Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(widget.isBlocked ? 'Unblock' : 'Block'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 