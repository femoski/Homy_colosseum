import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/dispute/dispute_message.dart';
import 'package:homy/models/dispute/dispute_model.dart';
import 'package:homy/repositories/dispute_repository.dart';
import 'package:homy/services/auth_service.dart';
import 'package:homy/services/websocket_service.dart';

class DisputeCommunicationController extends GetxController {
  final WebSocketService _webSocketService = Get.find<WebSocketService>();
  final AuthService _authService = Get.find<AuthService>();
  final DisputeRepository _disputeRepository = DisputeRepository();
  
  final messageController = TextEditingController();
  final messages = <DisputeMessage>[].obs;
  final isLoading = false.obs;
  final error = Rx<String?>(null);
  final dispute = Rx<Dispute?>(null);
  
  String get currentUsername => _authService.username.toString();

  @override
  void onInit() {
    super.onInit();
    // Get dispute ID from route parameters
    final disputeId = Get.parameters['id']?.toString();
    if (disputeId != null) {
      loadDispute(disputeId);
    }
    
    // Set up WebSocket listeners
    _setupWebSocket();
  }

  Future<void> loadDispute(String disputeId) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      // Get dispute details
      dispute.value = await _disputeRepository.getDispute(disputeId);
      
      // Load dispute messages
            // final messageResponse = await _disputeRepository.getDisputeMessages(disputeId);

      final messageResponse = dispute.value?.history;
      messages.value = messageResponse ?? [];
      
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _setupWebSocket() {
    _webSocketService.onMessageReceived = (message) {
      // Only handle messages for this dispute
      if (message.toId == dispute.value?.id) {
        // messages.insert(0, message);
      }
    };
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;
    if (dispute.value == null) return;

    final messageText = messageController.text.trim();
    
    // Create a temporary message with pending status
    final tempMessage = DisputeMessage(
      timestamp: DateTime.now(),
      type: 'message',
      senderType: 'user',
      senderName: currentUsername,
      content: messageText,
      metadata: MessageMetadata(status: 'pending'),
    );
    
    // Add temporary message to chat immediately
    messages.insert(0, tempMessage);
    
    // Clear input field immediately for better UX
    messageController.clear();

    try {
      // Send message through API
      final sentMessage = await _disputeRepository.sendDisputeMessage(
        dispute.value!.id.toString(),
        messageText,
      );
      
      // Replace temporary message with actual message from server
      final index = messages.indexWhere((m) => 
        m.timestamp == tempMessage.timestamp && 
        m.content == tempMessage.content
      );
      if (index != -1) {
        messages[index] = sentMessage;
      }
    } catch (e) {
      // Remove the temporary message on failure
      messages.removeWhere((m) => 
        m.timestamp == tempMessage.timestamp && 
        m.content == tempMessage.content
      );
      
      // Show error and ask to resend
      final shouldResend = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Failed to send message'),
          content: Text('Error: ${e.toString()}\nWould you like to try again?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
      
      if (shouldResend == true) {
        // Restore the message text and try again
        messageController.text = messageText;
        await sendMessage();
      }
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    _webSocketService.onMessageReceived = null;
    super.onClose();
  }
} 