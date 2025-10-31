import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:homy/screens/chat_screen/message_box.dart';
import 'package:homy/models/chat/chat_list.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../services/config_service.dart';
import '../../services/support_service.dart';
import '../../utils/constants/image_string.dart';
import '../../utils/dimensions.dart';
import '../../utils/device_info_utils.dart';
import '../../providers/api_client.dart';
import '../../services/auth_service.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  ConfigService? configService;
  SupportService? supportService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  void _initConfig() async {
    setState(() => _isLoading = true);
    configService = await ConfigService.getConfig();
    
    // Initialize support service
    supportService = SupportService.instance;
    if (!Get.isRegistered<SupportService>()) {
      Get.put(supportService!);
    }
    
    setState(() => _isLoading = false);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text('Help & Support'.tr, style: context.textTheme.titleMedium?.copyWith(
          fontSize: 18,
          color: Colors.white,
        ),),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        // flexibleSpace: Container(
        //   decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //       begin: Alignment.topCenter,
        //       end: Alignment.bottomCenter,
        //       colors: [
        //         Theme.of(context).primaryColor.withOpacity(0.8),
        //       ],
        //     ),
        //   ),
        // ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Hero(
                        tag: 'support_logo',
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Image.asset(MImages.logo, width: 80),
                        ),
                      ),
                      const SizedBox(height: 20),
                      DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            WavyAnimatedText('How can we help you?'.tr),
                          ],
                          isRepeatingAnimation: true,
                        ),
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                                                onTap: () {
                          _showDeviceInfoBottomSheet();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'We\'re here to help'.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              // const SizedBox(width: 8),
                              // Icon(
                              //   Icons.info_outline,
                              //   color: Colors.white,
                              //   size: 20,
                              // ),
                              // const SizedBox(width: 4),
                              // Text(
                              //   '(Tap for device info)'.tr,
                              //   style: const TextStyle(
                              //     color: Colors.white,
                              //     fontSize: 12,
                              //     fontStyle: FontStyle.italic,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      // const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Column(
                  children: [
                    Card(
                      elevation: 5,
                      color: Get.theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          _buildSupportButton(
                            icon: Icons.location_on,
                            title: 'Address'.tr,
                            info: configService?.address ?? 'No address found',
                            color: Colors.blue,
                            onTap: () async {
                              final address = configService?.address;
                              if (address != null) {
                                final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeFull(address)}';
                                if (await canLaunchUrlString(url)) {
                                  await launchUrlString(url);
                                }
                              }
                            },
                          ),
                          Divider(height: 1, color: context.theme.colorScheme.background),
                          _buildSupportButton(
                            icon: Icons.call,
                            title: 'Call Us'.tr,
                            info: configService?.socialMedia.phone  ?? configService?.socialMedia.phone ?? configService?.phone ?? 'No phone found',
                            color: Colors.red,
                            onTap: () async {
                              if(await canLaunchUrlString('tel:${configService?.socialMedia.phone ?? configService?.phone ?? ''} ')) {
                                launchUrlString('tel:${configService?.socialMedia.phone ?? configService?.phone ?? ''}');
                              } else {
                                Get.showSnackbar(CommonUI.infoSnackBar(
                                  message: 'Can not launch ${configService?.socialMedia.phone ?? configService?.phone ?? ''} '
                                ));
                              }
                            },
                          ),
                          Divider(height: 1, color: context.theme.colorScheme.background),
                          _buildSupportButton(
                            icon: Icons.mail_outline,
                            title: 'Email Us'.tr,
                            info: configService?.socialMedia.email ?? configService?.socialMedia.email ?? configService?.email ?? 'No email found',
                            color: Colors.green,
                            onTap: () {
                              final Uri emailLaunchUri = Uri(
                                scheme: 'mailto',
                                path: configService?.socialMedia.email,
                              );
                              launchUrlString(emailLaunchUri.toString());
                            },
                          ),
                          Divider(height: 1, color: context.theme.colorScheme.background),
                          _buildSupportButton(
                            icon: Icons.chat_bubble_outline,
                            title: 'Live Chat'.tr,
                            info: 'Chat with our support team'.tr,
                            color: Colors.purple,
                            onTap: () async {
                        
                              switch (configService?.supportConfig.chatServer.toLowerCase()) {
                                case 'system':
                                  // Use system chat
                                  final supportUser = ChatUsers(
                                    userId: configService?.supportConfig.supportId ?? '',
                                    username: 'support',
                                    email: configService?.socialMedia.email ?? '',
                                    avatar: MImages.logo,
                                    name: 'Support Team',
                                  );
                                  
                                  final chatItem = ChatListItem(
                                    user: supportUser,
                                    chatTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                                    unreadCount: 0,
                                    isTyping: false,
                                  );
                                  
                                  Get.to(() => MessageBox(conversation: chatItem, screen: 1));
                                  break;
                                  
                                case 'whatsapp':
                                  // Open WhatsApp chat
                                  final phone = configService?.supportConfig.whatsappNumber ?? configService?.socialMedia.phone ?? configService?.phone ?? '';
                                  final message = Uri.encodeComponent('Hello, I need support');
                                  final url = 'https://wa.me/$phone?text=$message';
                                  if (await canLaunchUrlString(url)) {
                                    await launchUrlString(url);
                                  } else {
                                    Get.showSnackbar(CommonUI.ErrorSnackBar(
                                      message: 'Could not launch WhatsApp Support'.tr
                                    ));
                                  }
                                  break;
                                  
                                case 'tawkto':
                                  // Open Tawk.to in WebView
                                  Get.to(() => const TawkToChatScreen());
                                  break;
                                  
                                default:
                                  // For other embeddable chat systems
                                    if (configService?.supportConfig.chatServer != null) {
                                      Get.to(() => Scaffold(
                                        appBar: AppBar(
                                          title: Text('Live Chat'.tr),
                                        ),
                                        body: WebViewWidget(
                                          controller: WebViewController()
                                            ..loadRequest(Uri.parse(configService?.supportConfig.otherLinks ?? ''))
                                            ..setJavaScriptMode(JavaScriptMode.unrestricted)
                                            ..setNavigationDelegate(
                                              NavigationDelegate(
                                                onProgress: (int progress) {
                                                  // Show loading indicator
                                                },
                                                onPageStarted: (String url) {},
                                                onPageFinished: (String url) {},
                                                onWebResourceError: (WebResourceError error) {
                                                  Get.showSnackbar(CommonUI.ErrorSnackBar(
                                                    message: 'Failed to load chat'.tr
                                                  ));
                                                },
                                              ),
                                            ),
                                        ),
                                      ));
                                  } else {
                                    Get.showSnackbar(CommonUI.ErrorSnackBar(
                                      message: 'Chat system not configured'.tr
                                    ));
                                  }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                                        
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.bottomSheet(
                          _buildFAQSection(),
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                        );
                      },
                      icon: const Icon(Icons.question_answer),
                      label: Text('Frequently Asked Questions'.tr),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildSupportButton({
    required IconData icon,
    required String title,
    required String info,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    info,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions'.tr,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildFAQItem(
                  'How do I list my property?'.tr,
                  'You can list your property by clicking on the "Add Property" button in the main menu...'.tr,
                ),
                _buildFAQItem(
                  'How do I contact an agent?'.tr,
                  'You can contact agents directly through their property listings...'.tr,
                ),
                _buildFAQItem(
                  'How do I search for properties?'.tr,
                  'Use the search bar at the top of the home screen. You can filter by location, price range, property type, and other features. You can also save your favorite searches.'.tr,
                ),
                _buildFAQItem(
                  'How do I save a property?'.tr,
                  'Click the heart icon on any property listing to save it to your favorites. You can view all saved properties in your profile under "Saved Properties".'.tr,
                ),
                _buildFAQItem(
                  'What payment methods are accepted?'.tr,
                  'We accept various payment methods including credit/debit cards, bank transfers, and digital wallets. Specific payment options may vary by location and property.'.tr,
                ),
                _buildFAQItem(
                  'How do I report an issue?'.tr,
                  'If you encounter any problems or need to report inappropriate content, use the "Report" button on the listing or contact our support team directly through the app.'.tr,
                ),
                _buildFAQItem(
                  'How do I edit my profile?'.tr,
                  'Go to your profile page and tap the "Edit Profile" button. From there you can update your personal information, contact details, and preferences.'.tr,
                ),
                _buildFAQItem(
                  'What are the fees involved?'.tr,
                  'Fees vary depending on the type of transaction and location. All applicable fees will be clearly displayed before you complete any transaction.'.tr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeviceInfoBottomSheet() async {
    // Show loading indicator
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );
    
    // Send device info to server when bottom sheet is opened
    try {
      final deviceInfo = await DeviceInfoUtils.getSupportDeviceInfo();
      await _sendDeviceInfoToServer(deviceInfo);
      Get.log('Device info sent to server successfully');
      // Close loading dialog
      Get.back();
      // Show success notification
      // Get.showSnackbar(CommonUI.infoSnackBar(
      //   message: 'Device information sent to support team'.tr,
      // ));
    } catch (e) {
      Get.log('Error sending device info to server: $e');
      // Close loading dialog
      Get.back();
      // Show error notification
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to send device information'.tr,
      ));
    }
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[600] 
                    : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Row(
              children: [
                Icon(Icons.device_hub, color: Theme.of(context).primaryColor),
                const SizedBox(width: 10),
                Text(
                  'Device Information'.tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Device Info Content
            FutureBuilder<Map<String, dynamic>>(
              future: supportService?.getUserFriendlyDeviceInfo() ?? 
                     DeviceInfoUtils.getDeviceInfo().then((info) => {
                       'device_name': info['device_name'],
                       'device_type': info['device_type'],
                       'platform': info['platform'],
                       'app_version': info['app_version'],
                       'support_code': 'DEV-UNK-000',
                     }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Text(
                    'Error loading device info: ${snapshot.error}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
                
                final deviceInfo = snapshot.data ?? {};
                
                return Column(
                  children: [
                    _buildDeviceInfoRow('Device', deviceInfo['device_name'] ?? 'Unknown'),
                    _buildDeviceInfoRow('Platform', deviceInfo['platform'] ?? 'Unknown'),
                    _buildDeviceInfoRow('App Version', deviceInfo['app_version'] ?? 'Unknown'),
                    const SizedBox(height: 20),
                    
                    // Support Code Section
                    FutureBuilder<String>(
                      future: DeviceInfoUtils.generateUserFriendlyDeviceId(),
                      builder: (context, codeSnapshot) {
                        final supportCode = codeSnapshot.data ?? 'DEV-UNK-000';
                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.support_agent,
                                color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Support Code'.tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      supportCode,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Get.showSnackbar(CommonUI.infoSnackBar(
                                    message: 'Support code copied to clipboard'.tr,
                                  ));
                                },
                                icon: Icon(
                                  Icons.copy,
                                  color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                ),
                                tooltip: 'Copy Support Code'.tr,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: Get.theme.colorScheme.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Future<void> _sendDeviceInfoToServer(Map<String, dynamic> deviceInfo) async {
    try {
      // Get user info if available
      final authService = Get.find<AuthService>();
      final userId = authService.user.value?.id;
      
      // Prepare data for server
      final serverData = {
        'user_id': userId,
        'device_info': deviceInfo,
        'timestamp': DateTime.now().toIso8601String(),
        'action': 'support_device_info_request',
        'session_id': DateTime.now().millisecondsSinceEpoch.toString(),
        'user_email': authService.user.value?.email ?? '',
        'user_name': authService.user.value?.fullname ?? '',
        'user_phone': authService.user.value?.mobileNo ?? '',
      };
      
      // Send to server using the support service
      if (supportService != null) {
        await supportService!.logSupportInteraction(
          interactionType: 'device_info_request',
          description: 'User requested device information for support',
          additionalData: serverData,
        );
      }
      
      // // Also send via API client if available
      // final apiClient = ApiClient(appBaseUrl: 'https://urlinkapi/');
      // final response = await apiClient.postData('support/device-info', serverData);
      
      // if (response.statusCode == 200 || response.statusCode == 201) {
      //   Get.log('Device info successfully sent to server');
      // } else {
      //   Get.log('Server responded with status: ${response.statusCode}');
      // }
    } catch (e) {
      Get.log('Error sending device info to server: $e');
      // Don't throw the error to avoid breaking the UI
    }
  }

  Widget _buildDeviceInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Text(answer),
        ),
      ],
    );
  }
}

class TawkToChatScreen extends StatefulWidget {
  const TawkToChatScreen({super.key});

  @override
  State<TawkToChatScreen> createState() => _TawkToChatScreenState();
}

class _TawkToChatScreenState extends State<TawkToChatScreen> {
  bool isLoading = true;
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    final authService = Get.find<AuthService>();
    final configService = Get.find<ConfigService>();
    final userEmail = authService.user.value?.email ?? '';
    final tawkUrl = 'https://tawk.to/chat/${configService.supportConfig.tawkId ?? ''}';
    final urlWithEmail = userEmail.isNotEmpty 
      ? '$tawkUrl?name=${Uri.encodeComponent(authService.user.value?.fullname ?? '')}&email=${Uri.encodeComponent(userEmail)}'
      : tawkUrl;

    controller = WebViewController()
      ..loadRequest(Uri.parse(urlWithEmail))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              isLoading = progress < 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              isLoading = false;
            });
            Get.showSnackbar(CommonUI.ErrorSnackBar(
              message: 'Failed to load chat'.tr
            ));
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Chat'.tr),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
