import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/models/notifications/notification_model.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationDetailBottomSheet extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationDetailBottomSheet({
    super.key,
    required this.notification,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Container(
      constraints: BoxConstraints(
        maxHeight: Get.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, isDark),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildContent(context, isDark),
                  _buildMetadata(context, isDark),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${notification.createdAt}',
                        style: MyTextStyle.productLight(
                          size: 12,
                          color:
                              isDark ? Colors.grey.shade400 : Colors.grey[600],
                        ),
                      ),
                      if (notification.isRead)
                        Row(
                          children: [
                            Icon(
                              Icons.remove_red_eye_outlined,
                              size: 16,
                              color: Get.theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Read',
                              style: MyTextStyle.productLight(
                                size: 12,
                                color: Get.theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  //  _buildActions(context, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: Get.theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: MyTextStyle.productMedium(
                    size: 18,
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.timeAgo,
                  style: MyTextStyle.productLight(
                    size: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(BuildContext context, bool isDark) {
    return Column(
      children: [

           if (notification.data != null &&
               notification.data!.containsKey('type') &&
               notification.data!['type'] == 'link_url') ...[
             const SizedBox(height: 16),
             Container(
               width: double.infinity,
               decoration: BoxDecoration(
                 gradient: LinearGradient(
                   colors: [
                     Colors.blue.shade600,
                     Colors.blue.shade400,
                   ],
                   begin: Alignment.topLeft,
                   end: Alignment.bottomRight,
                 ),
                 borderRadius: BorderRadius.circular(16),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.blue.withOpacity(0.3),
                     blurRadius: 12,
                     offset: const Offset(0, 4),
                   ),
                 ],
               ),
               child: Material(
                 color: Colors.transparent,
                 child: InkWell(
                   onTap: () {
                     Get.back();
                     // Open external link if URL exists
                     if (notification.data!.containsKey('url')) {
                       final url = notification.data!['url'];
                       if (url != null && url.toString().isNotEmpty) {
                         // Use url_launcher to open external link
                         _launchUrl(url.toString());
                       } else {
                         Get.snackbar(
                           'Error', 
                           'Invalid URL provided',
                           snackPosition: SnackPosition.BOTTOM,
                         );
                       }
                     } else {
                       Get.snackbar(
                         'Error', 
                         'No URL found in notification',
                         snackPosition: SnackPosition.BOTTOM,
                       );
                     }
                   },
                   borderRadius: BorderRadius.circular(16),
                   child: Padding(
                     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Container(
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             color: Colors.white.withOpacity(0.2),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: const Icon(
                             Icons.open_in_new,
                             color: Colors.white,
                             size: 24,
                           ),
                         ),
                         const SizedBox(width: 12),
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               'Open Link',
                               style: MyTextStyle.productMedium(
                                 size: 16,
                                 color: Colors.white,
                                 fontWeight: FontWeight.w600,
                               ),
                             ),
                             Text(
                               'Tap to open external link',
                               style: MyTextStyle.productLight(
                                 size: 12,
                                 color: Colors.white.withOpacity(0.8),
                               ),
                             ),
                           ],
                         ),
                         const Spacer(),
                         Icon(
                           Icons.arrow_forward_ios,
                           color: Colors.white.withOpacity(0.8),
                           size: 16,
                         ),
                       ],
                     ),
                   ),
                 ),
               ),
             ),
             ],

           if (notification.data != null &&
               notification.data!.containsKey('type') &&
               notification.data!['type'] == 'app_link') ...[
             const SizedBox(height: 16),
             Container(
               width: double.infinity,
               decoration: BoxDecoration(
                 gradient: LinearGradient(
                   colors: [
                     Colors.green.shade600,
                     Colors.green.shade400,
                   ],
                   begin: Alignment.topLeft,
                   end: Alignment.bottomRight,
                 ),
                 borderRadius: BorderRadius.circular(16),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.green.withOpacity(0.3),
                     blurRadius: 12,
                     offset: const Offset(0, 4),
                   ),
                 ],
               ),
               child: Material(
                 color: Colors.transparent,
                 child: InkWell(
                   onTap: () {
                     Get.back();
                     // Navigate to app page if route exists
                     if (notification.data!.containsKey('route')) {
                       final route = notification.data!['route'];
                       if (route != null && route.toString().isNotEmpty) {
                        Get.toNamed(route.toString());
                         // _navigateToAppPage(route.toString());
                       } else {
                        Get.showSnackbar(CommonUI.ErrorSnackBar(message: 'Invalid route provided'));

                        
                       }
                     } else {
                     Get.showSnackbar(CommonUI.ErrorSnackBar(message: 'No route found in notification'));

        
                     }
                   },
                   borderRadius: BorderRadius.circular(16),
                   child: Padding(
                     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Container(
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             color: Colors.white.withOpacity(0.2),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: const Icon(
                             Icons.navigation,
                             color: Colors.white,
                             size: 24,
                           ),
                         ),
                         const SizedBox(width: 12),
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               'Open in App',
                               style: MyTextStyle.productMedium(
                                 size: 16,
                                 color: Colors.white,
                                 fontWeight: FontWeight.w600,
                               ),
                             ),
                             Text(
                               'Tap to navigate to app page',
                               style: MyTextStyle.productLight(
                                 size: 12,
                                 color: Colors.white.withOpacity(0.8),
                               ),
                             ),
                           ],
                         ),
                         const Spacer(),
                         Icon(
                           Icons.arrow_forward_ios,
                           color: Colors.white.withOpacity(0.8),
                           size: 16,
                         ),
                       ],
                     ),
                   ),
                 ),
               ),
             ),
             ],

            if (notification.data != null &&
              notification.data!.containsKey('type') &&
              notification.data!['type'] == 'property_match') ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Get.theme.colorScheme.primary,
                    Get.theme.colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Get.theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Get.back();
                    // Navigate to property details if data and id exist
                    if (notification.data != null && 
                        notification.data!.containsKey('id')) {
                      Get.toNamed('/property-details/${notification.data!['id']}');
                    } else {
                      // Fallback navigation or show error
                      Get.snackbar(
                        'Error', 
                        'Property ID not found',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.home_work_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'View Property',
                              style: MyTextStyle.productMedium(
                                size: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Tap to see property details',
                              style: MyTextStyle.productLight(
                                size: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          
    
      ],
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Message',
          style: MyTextStyle.productMedium(
            size: 16,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          notification.message,
          style: MyTextStyle.productLight(
            size: 15,
            color: isDark ? Colors.grey.shade200 : Colors.black87,
            height: 1.5,
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 10),
        // if (notification.data != null && notification.data!.isNotEmpty) ...[
        //   Text(
        //     'Additional Information',
        //     style: MyTextStyle.productMedium(
        //       size: 16,
        //       color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
        //     ),
        //   ),
        //   const SizedBox(height: 8),
        //   if (notification.data!.containsKey('type') &&
        //       notification.data!['type'] == 'property_match') ...[
        //     const SizedBox(height: 16),
        //     Container(
        //       width: double.infinity,
        //       decoration: BoxDecoration(
        //         gradient: LinearGradient(
        //           colors: [
        //             Get.theme.colorScheme.primary,
        //             Get.theme.colorScheme.primary.withOpacity(0.8),
        //           ],
        //           begin: Alignment.topLeft,
        //           end: Alignment.bottomRight,
        //         ),
        //         borderRadius: BorderRadius.circular(16),
        //         boxShadow: [
        //           BoxShadow(
        //             color: Get.theme.colorScheme.primary.withOpacity(0.3),
        //             blurRadius: 12,
        //             offset: const Offset(0, 4),
        //           ),
        //         ],
        //       ),
        //       child: Material(
        //         color: Colors.transparent,
        //         child: InkWell(
        //           onTap: () {
        //             // TODO: Navigate to property details
        //               Get.back();
        //             },
        //           borderRadius: BorderRadius.circular(16),
        //           child: Padding(
        //             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        //             child: Row(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               children: [
        //                 Container(
        //                   padding: const EdgeInsets.all(8),
        //                   decoration: BoxDecoration(
        //                     color: Colors.white.withOpacity(0.2),
        //                     borderRadius: BorderRadius.circular(8),
        //                   ),
        //                   child: const Icon(
        //                     Icons.home_work_outlined,
        //                     color: Colors.white,
        //                     size: 24,
        //                   ),
        //                 ),
        //                 const SizedBox(width: 12),
        //                 Column(
        //                   crossAxisAlignment: CrossAxisAlignment.start,
        //                   children: [
        //                     Text(
        //                       'View Property',
        //                       style: MyTextStyle.productMedium(
        //                         size: 16,
        //                         color: Colors.white,
        //                         fontWeight: FontWeight.w600,
        //                       ),
        //                     ),
        //                     Text(
        //                       'Tap to see property details',
        //                       style: MyTextStyle.productLight(
        //                         size: 12,
        //                         color: Colors.white.withOpacity(0.8),
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //                 const Spacer(),
        //                 Icon(
        //                   Icons.arrow_forward_ios,
        //                   color: Colors.white.withOpacity(0.8),
        //                   size: 16,
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        //   Container(
        //     width: double.infinity,
        //     padding: const EdgeInsets.all(12),
        //     decoration: BoxDecoration(
        //       color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //     child: Text(
        //       notification.data!.toString(),
        //       style: MyTextStyle.productLight(
        //         size: 14,
        //         color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
        //       ),
        //     ),
        //   ),
        // ],
      ],
    );
  }

  Widget _buildActions(BuildContext context, bool isDark) {
    return Row(
      children: [
        if (!notification.isRead)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Get.log('Marking notification as read: ${notification.id}');
                onMarkAsRead?.call();
                Get.back();
              },
              icon: const Icon(Icons.done),
              label: const Text('Mark as Read'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Get.theme.colorScheme.primary,
                side: BorderSide(color: Get.theme.colorScheme.primary),
              ),
            ),
          ),
        if (!notification.isRead) const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              onDelete?.call();
              Get.back();
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error', 
          'Could not open the link',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Invalid URL format',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _navigateToAppPage(String route) {
    try {
      // Handle different route formats
      if (route.startsWith('/')) {
        // Direct route navigation
        Get.toNamed(route);
      } else if (route.contains('?')) {
        // Route with parameters
        final uri = Uri.parse(route);
        Get.toNamed(uri.path, parameters: uri.queryParameters);
      } else {
        // Simple route name
        Get.toNamed('/$route');
      }
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Could not navigate to the requested page',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
