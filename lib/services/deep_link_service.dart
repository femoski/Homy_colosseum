import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import 'package:homy/repositories/reels_repository.dart';
import 'package:homy/screens/reels_screen/reels_screen.dart';
import 'package:homy/utils/helpers/helper_utils.dart';

class DeepLinkService extends GetxService {
  ReelsRepository reelRepository = ReelsRepository();
  static DeepLinkService get to => Get.find();
  
  final _appLinks = AppLinks();
  bool _initialUriIsHandled = false;
  Uri? _pendingDeepLink;

  Future<DeepLinkService> init() async {
    // Handle initial URI if the app was launched from a link
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      try {
        final uri = await _appLinks.getInitialAppLink();
        if (uri != null) {
          Get.log('Deep Link Started: $uri');

          // Store the deep link to be handled after app initialization
          _pendingDeepLink = uri;
        }
      } on PlatformException catch (e) {
        print('Failed to get initial uri: $e');
      }
    }

    // Handle links opened while app is running
    _appLinks.uriLinkStream.listen(
      (uri) {
        if (uri != null) {
          handleDeepLink(uri);
        }
      },
      onError: (err) {
        print('Failed to handle deep link: $err');
      },
    );

    return this;
  }

  // Call this method from your root page when it's fully initialized
  void handlePendingDeepLink() {
    if (_pendingDeepLink != null) {
      handleDeepLink(_pendingDeepLink!);
      _pendingDeepLink = null;
    }
  }

  Future<void> handleDeepLink(Uri uri) async {
    // Extract path and parameters from URI
    final path = uri.path;
    final parameters = uri.queryParameters;
    final pathSegments = path.split('/').where((s) => s.isNotEmpty).toList();

    Get.log('Deep link: $path, $parameters');

    // First check for ID in query parameters
    String? id = parameters['id'];

    // If no ID in parameters, try to get it from the last path segment
    if (id == null && pathSegments.isNotEmpty) {
      id = pathSegments.last;
    }

    // Handle different paths based on keywords
    if (path.contains('property-details') || path.contains('property')) {
      if (id != null) {
        Get.toNamed('/property-details/$id');
      }
    } else if (path.contains('reels') || path.contains('reel')) {
      if (id != null) {
        // Decrypt ID only for reels
        final decryptedId = HelperUtils.decryptReelId(id);

        Get.log('Decrypted ID: $decryptedId');
         if (decryptedId != null) {
          final reels = await reelRepository.getUserReelsByID(int.parse(decryptedId.toString()), 0);
          Get.to(
      () => ReelsScreen(
        screenType: ScreenTypeIndex.user,
        reels: [reels],
        position: 0,
        userID: int.parse(decryptedId.toString()),
      ),
      preventDuplicates: true,
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
          // Get.toNamed('/enquire-info/$decryptedId');
        }

        if (decryptedId != null) {
          Get.toNamed('/reels/$decryptedId');
          Get.log('Decrypted ID: $decryptedId');
        }
      }
    } else if (path.contains('user-profile')) {
      if (id != null) {
        final decryptedId = HelperUtils.decryptReelId(id);
        if (decryptedId != null) {
          Get.toNamed('/enquire-info/$decryptedId');
        }
      }
      // else if (path.contains('reels')) {
      //   final encodedId = path.split('/').last;
      //   final decryptedId = HelperUtils.decryptReelId(encodedId);
      //   Get.log('Decrypted ID: $decryptedId');
       
      // }
    } else if (path.contains('html-page')) {
      final page = parameters['page'];
      if (page != null) {
        Get.toNamed('/html-page', parameters: {'page': page});
      }
    } else if (path.contains('register') || path.contains('signup')) {
      final referralCode = parameters['ref'];
      if (referralCode != null) {
        Get.toNamed('/register', parameters: {'referralCode': referralCode});
      } else {
        Get.toNamed('/register');
      }
    } else {
      print('Unhandled deep link path: $path');
    }

    //     // Handle different paths
    // switch (path) {
    //   case '/property-details':
    //     if (parameters.containsKey('id')) {
    //       final id = parameters['id'];
    //       if (id != null) {
    //         Get.toNamed('/property-details/$id');
    //       }
    //     }
    //     break;
    //   case '/reels':
    //     if (parameters.containsKey('id')) {
    //       final id = HelperUtils.decryptReelId(parameters['id'] ?? '');
    //       if (id != null) {
    //         Get.toNamed('/reels/$id');
    //       }
    //     } else if (path.startsWith('/app/reels/')) {
    //       // Extract the encoded ID from the path like /app/reels/25iekav3
    //       final encodedId = path.split('/').last;
    //       final id = HelperUtils.decryptReelId(encodedId);
    //       if (id != null) {
    //         Get.toNamed('/reels/$id');
    //       }

    //       Get.log('Decrypted ID: $id');
    //     }
    //     break;
    //   case '/html-page':
    //     if (parameters.containsKey('page')) {
    //       final page = parameters['page'];
    //       if (page != null) {
    //         Get.toNamed('/html-page', parameters: {'page': page});
    //       }
    //     }
    //     break;
    //   default:
    //     print('Unhandled deep link path: $path');
    //     break;
  }
} 