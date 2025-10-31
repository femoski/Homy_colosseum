import 'package:get/get.dart';
import 'package:homy/screens/agent_earnings/controllers/earnings_controller.dart';
import 'package:homy/screens/agent_earnings/earnings_screen.dart';
import 'package:homy/screens/agents/controllers/featured_agent_controller.dart';
import 'package:homy/screens/auth/controllers/forgot_password_controller.dart';
import 'package:homy/screens/auth/controllers/reset_password_controller.dart';
import 'package:homy/screens/auth/controllers/verify_reset_password_controller.dart';
import 'package:homy/screens/auth/terms_of_service_screen.dart';
import 'package:homy/screens/auth/views/forgot_password_screen.dart';
import 'package:homy/screens/auth/views/reset_password_screen.dart';
import 'package:homy/screens/auth/views/verify_reset_password_screen.dart';
import 'package:homy/screens/html/html_screen.dart';
import 'package:homy/screens/location/location_permission_page.dart';
import 'package:homy/screens/notification_screen/controllers/notification_controller.dart';
import 'package:homy/screens/notifications/notifications_page.dart';
import 'package:homy/screens/notifications/controller/notifications_controller.dart';
import 'package:homy/screens/profile/controllers/profile_details_controller.dart';
import 'package:homy/screens/profile/profile_details.dart';
import 'package:homy/screens/properties/area_properties.dart';
import 'package:homy/screens/properties/controllers/property_list_controller.dart';
import 'package:homy/screens/catergory/categories.dart';
import 'package:homy/screens/catergory/controllers/categories_controller.dart';
import 'package:homy/screens/enquire_screen/controllers/enquire_screen_controller.dart';
import 'package:homy/screens/enquire_screen/enquire_info_screen.dart';
import 'package:homy/screens/followers/controllers/followers_controller.dart';
import 'package:homy/screens/followers/followers.dart';
import 'package:homy/screens/location/controllers/location_controller.dart';
import 'package:homy/screens/location/controllers/search_place_controller.dart';
import 'package:homy/screens/location/pick_map_screen.dart';
import 'package:homy/screens/location/search_place_screen.dart';
import 'package:homy/screens/nav/nav_bindings.dart';
import 'package:homy/screens/nav/root.dart';
import 'package:homy/screens/notification_screen/notification_screen.dart';
import 'package:homy/screens/onboarding/controller/onboard_controller.dart';
import 'package:homy/screens/properties/controllers/my_properties_controller.dart';
import 'package:homy/screens/properties/controllers/properties_controller.dart';
import 'package:homy/screens/properties/my_properties_screen.dart';
import 'package:homy/screens/properties/properties_list.dart';
import 'package:homy/screens/properties/properties_screen.dart';
import 'package:homy/screens/properties/views/all_featured.dart';
import 'package:homy/screens/property_detail_screen/controllers/property_detail_controller.dart';
import 'package:homy/screens/property_detail_screen/property_detail_screen.dart';
import 'package:homy/screens/reels_screen/controllers/reels_upload_controller.dart';
import 'package:homy/screens/reels_screen/reels_upload.dart';
import 'package:homy/screens/search_screen/controllers/search_controller.dart';
import 'package:homy/screens/search_screen/search_screen.dart';
import 'package:homy/screens/settings/change_password_screen.dart';
import 'package:homy/screens/settings/settings_screen.dart';
import 'package:homy/screens/settings/support_screen.dart';
import 'package:homy/screens/tour_request/controllers/tour_requests_controller.dart';
import 'package:homy/screens/tour_request/tour_requests.dart';
import 'package:homy/services/location_permission_service.dart';
import 'package:homy/services/terms_service.dart';
import 'package:homy/splash.dart';
import 'package:homy/screens/onboarding/onboarding_screen.dart';
import 'package:homy/screens/auth/login/login_screen.dart';
import 'package:homy/utils/html_type.dart';
import 'screens/agents/views/featured_agent.dart';
import 'screens/auth/controllers/auth_controller.dart';
import 'screens/properties/controllers/all_areas.dart';
import 'screens/properties/views/all_areas_screen.dart';
import 'screens/properties/views/all_featured_agent.dart';
import 'screens/properties/views/all_nearby_properties.dart';
import 'screens/dashboard/controller/home_screen_controller.dart';
import 'screens/properties/views/all_recent_screen.dart';
import 'screens/properties/views/all_most_like_screen.dart';
import 'screens/properties/views/become_agent_screen.dart';
import 'screens/properties/controllers/become_agent_controller.dart';
import 'screens/auth/views/registration_screen.dart';
import 'screens/auth/controllers/registration_controller.dart';
import 'screens/auth/views/verification_screen.dart';
import 'screens/auth/controllers/verification_controller.dart';
import 'screens/maintenance/maintenance_screen.dart';
import 'screens/dispute/views/dispute_list_screen.dart';
import 'screens/dispute/controllers/dispute_list_controller.dart';
import 'screens/wallet/wallet_screen.dart';
import 'screens/wallet/controllers/wallet_controller.dart';
import 'package:homy/screens/dispute/views/dispute_communication_screen.dart';
import 'package:homy/screens/dispute/controllers/dispute_communication_controller.dart';
import 'screens/wallet/controllers/transaction_list_controller.dart';
// import 'package:homy/screens/referral/referral_screen.dart';
import 'package:homy/screens/points/points_screen.dart';
import 'package:homy/screens/points/controllers/points_controller.dart';
import 'package:homy/repositories/points_repository.dart';
import 'package:homy/screens/points/all_points_screen.dart';
import 'package:homy/screens/settings/widgets/personalized_requirement_form.dart';
import 'package:homy/services/saved_requirement_service.dart';
import 'package:homy/screens/wallet_connect/wallet_connect_screen.dart';
import 'package:homy/screens/wallet_connect/controllers/wallet_connect_controller.dart';
import 'package:homy/screens/properties/nft_marketplace_screen.dart';
import 'package:homy/screens/properties/controllers/nft_marketplace_controller.dart';
import 'package:homy/services/nft_marketplace_service.dart';
import 'package:homy/screens/properties/my_nfts_screen.dart';
import 'package:homy/screens/payments/property_payment_screen.dart';

class AppPages {
  static const INITIAL = '/splash';
  static final routes = [
    GetPage(name: '/splash', page: () => const SplashScreen()),
    GetPage(name: '/maintenance', page: () => const MaintenanceScreen()),
    GetPage(
      name: '/OnBoardingscreen', 
      page: () => const OnBoardingScreen(),
      binding: BindingsBuilder(() {
        Get.put(OnBoardController());
      }),
    ),
    GetPage(name: '/login', page: () => const LoginScreen(),binding: BindingsBuilder(() {
      Get.put(AuthController());
    }),),
    GetPage(name: '/root', page: () => const NavBar(), binding: NavBinding()),
    GetPage(
      name: '/property-details/:id',
      page: () => PropertyDetailScreen(
        propertyId: int.parse(Get.parameters['id'] ?? '0'),
      ),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PropertyDetailScreenController(
          int.parse(Get.parameters['id'] ?? '0'),
          null,
          null,
        ));
      }),
    ),
    GetPage(name: '/settings', page: () => const SettingsScreen()),
    GetPage(name: '/enquire-info/:id', page: () => EnquireInfoScreen(userId: Get.parameters['id'] ?? '1',), binding: BindingsBuilder(() {
      Get.lazyPut(() => EnquireInfoScreenController(Get.parameters['id'] ?? '1', null, null));
    }),),
    GetPage(name: '/notification', page: () => const NotificationScreen(), binding: BindingsBuilder(() {
      Get.lazyPut(() => NotificationController());
    }),),
    GetPage(name: '/notifications', page: () => const NotificationsPage(), binding: BindingsBuilder(() {
      Get.lazyPut(() => NotificationsController());
    }),),
    GetPage(name: '/search', page: () => const SearchScreen(), binding: BindingsBuilder(() {
      Get.put(SearchScreenController());
    }),),
    GetPage(name: '/reels-upload', page: () => const ReelUploadScreen(), binding: BindingsBuilder(() {
      Get.lazyPut(() => ReelsUploadController());
    }),),
    GetPage(name: '/my-properties/:type', page: () => MyPropertiesScreen(type: Get.parameters['type']=='all'?0:Get.parameters['type']=='rent'?1:2), binding: BindingsBuilder(() {
      Get.lazyPut(() => MyPropertiesScreenController(Get.parameters['type']=='all'?0:Get.parameters['type']=='rent'?1:2 ));
    }),), 
    GetPage(name: '/tour-requests/:type/:tab', page: () => TourRequestsScreen(type: Get.parameters['type']=='received'?0:1, selectedTab: Get.parameters['tab']=='waiting'?0:1), binding: BindingsBuilder(() {
      Get.lazyPut(() => TourRequestsController(Get.parameters['type']=='received'?0:1, Get.parameters['tab']=='waiting'?0:1));
    }),),
    GetPage(name: '/search-place', page: () => const SearchPlaceScreen(), binding: BindingsBuilder(() {
      Get.lazyPut(() => SearchPlaceController());
    }),),
    GetPage(name: '/pick-map', page: () => const PickMapScreen(), binding: BindingsBuilder(() {
      Get.lazyPut(() => LocationController());
    }),),
    GetPage(name: '/properties/:type', page: () => PropertyTypeScreen(type: Get.arguments['type'], map: Get.arguments['map'], screenType: Get.arguments['screenType']), binding: BindingsBuilder(() {
      Get.lazyPut(() => PropertiesController(Get.arguments['type'], Get.arguments['map'], Get.arguments['screenType']));
    }),),

    GetPage(name: '/profile', page: () => const ProfileDetailsScreen(), binding: BindingsBuilder(() {
      Get.lazyPut(() => ProfileDetailScreenController());
    }),),

    GetPage(name: '/location-permission', page: () =>  LocationPermissionPage(), binding: BindingsBuilder(() {
      Get.lazyPut(() => LocationPermissionService());
    }),),
    // GetPage(name: '/followers-following/:type/:id', page: () => FollowersFollowingScreen(
    //   followFollowingType: Get.parameters['type'].toString() == 'followers' 
    //     ? FollowFollowingType.followers 
    //     : FollowFollowingType.following, 
    //   userId:  int.parse(Get.parameters['id'].toString())
    // ), binding: BindingsBuilder(() {
    //   Get.lazyPut(() => FollowersFollowingScreenController(
    //     Get.parameters['type'].toString() == 'followers' 
    //     ? FollowFollowingType.followers 
    //     : FollowFollowingType.following, 
    //     int.parse(Get.parameters['id'].toString())
    //   ));
    // }),),

        GetPage(name: '/following/:id', page: () => FollowersFollowingScreen(
      followFollowingType: FollowFollowingType.following, 
      userId:  int.parse(Get.parameters['id'].toString())
    ), binding: BindingsBuilder(() {
      Get.lazyPut(() => FollowersFollowingScreenController(
        FollowFollowingType.following, 
        int.parse(Get.parameters['id'].toString())
      ));
    }),preventDuplicates: true),

   GetPage(
  name: '/followers/:id',
  page: () => FollowersFollowingScreen(
      followFollowingType: FollowFollowingType.followers, 
      userId:  int.parse(Get.parameters['id'].toString()),
  ),
  binding: BindingsBuilder(() {
    Get.lazyPut(() {
      final userId = int.parse(Get.parameters['id']!);
      return FollowersFollowingScreenController(FollowFollowingType.followers, userId);
    });
  }),
  preventDuplicates: false, // Recreate page and controller if navigated to again
),
     GetPage(name: '/Categories/:catID/:catName', page: () =>  PropertiesList(categoryId: int.parse(Get.parameters['catID'].toString()), categoryName: Get.parameters['catName']), binding: BindingsBuilder(() {
      Get.lazyPut(() => PropertyListController());
    }),),
      GetPage(name: '/categories', page: () => const CategoryList(), binding: BindingsBuilder(() {
      Get.lazyPut(() => CategoriesController());
    }),), 
    GetPage(name: '/properties-list', page: () =>  PropertiesList(categoryId: int.parse(Get.arguments['catID'].toString()), categoryName: Get.arguments['catName']), binding: BindingsBuilder(() {
      Get.lazyPut(() => PropertyListController());
    }),),
    // GetPage(name: '/featured-agent-properties/:id', page: () => FeaturedAgentPropertiesScreen(agent: Get.arguments['agent']), binding: BindingsBuilder(() {
    //   Get.lazyPut(() => FeaturedAgentPropertiesController());
    // }),),
    GetPage(name: '/featured-agent/:id', page: () => FeaturedAgent(), binding: BindingsBuilder(() {
      Get.lazyPut(() => FeaturedAgentController());
    }),),
    GetPage(name: '/change-password', page: () => const ChangePasswordScreen(), ),

        GetPage(name: '/porpular-area/:area', page: () => AreaPropertiesScreen(areaName: Get.parameters['area']), ),

    GetPage(
      name: '/all-areas',
      page: () => const AllAreasScreen(),
        binding: BindingsBuilder(() {
          Get.lazyPut(() => AllAreasController());
        }),
    ),

    GetPage(
      name: '/nearby-properties',
      page: () => const AllNearbyPropertiesScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeScreenController());
      }),
    ),


GetPage(name: '/all-featured', page: () =>  AllFeaturedProperties(), binding: BindingsBuilder(() {
  Get.lazyPut(() => HomeScreenController());
}),),

    GetPage(
      name: '/all-recent',
      page: () => const AllRecentScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeScreenController());
      }),
    ),

    GetPage(
      name: '/all-most-liked',
      page: () => const AllMostLikedScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeScreenController());
      }),
    ),

    GetPage(name: '/all-featured-agent', page: () =>  AllFeaturedAgentsPage(), binding: BindingsBuilder(() {
      Get.lazyPut(() => HomeScreenController());
    }),),

    GetPage(
      name: '/become-agent',
      page: () => const BecomeAgentScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => BecomeAgentController());
      }),
    ),
    GetPage(
      name: '/register',
      page: () => const RegistrationScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => RegistrationController());
      }),
    ),
    GetPage(
      name: '/verify-registration',
      page: () => const VerificationScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => VerificationController());
      }),
    ),
    GetPage(
      name: '/disputes',
      page: () => const DisputeListScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DisputeListController(
        ));
      }),
    ),
    GetPage(
      name: '/dispute/communication/:id',
      page: () => const DisputeCommunicationScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DisputeCommunicationController());
      }),
    ),
    GetPage(
      name: '/wallet',
      page: () => const WalletScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => WalletController());
        Get.lazyPut(() => TransactionListController());
      }),
    ),
   GetPage(
      name: '/wallet-connect',
      page: () => const WalletConnectScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => WalletConnectController());
      }),
    ),

    // GetPage(
    //   name: '/nft-marketplace',
    //   page: () => const NFTMarketplaceScreen(),
    //   binding: BindingsBuilder(() {
    //     Get.lazyPut(() => NFTMarketplaceService());
    //     Get.lazyPut(() => NFTMarketplaceController());
    //   }),  
    // ),

    // My NFTs direct route (opens My NFTs tab)
    GetPage(
      name: '/my-nfts',
      page: () => const MyNFTsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => NFTMarketplaceService());
        Get.lazyPut(() => NFTMarketplaceController());
      }),
    ),

    // Property payment screen
    GetPage(
      name: '/property-payment',
      page: () => PropertyPaymentScreen(property: Get.arguments['property']),
      preventDuplicates: false,
    ),


     GetPage(name: '/html-page', page: () => HtmlViewerScreen(
      htmlType: Get.parameters['page'] == 'terms-and-condition' ? HtmlType.termsAndCondition
          : Get.parameters['page'] == 'privacy-policy' ? HtmlType.privacyPolicy
          : Get.parameters['page'] == 'shipping-policy' ? HtmlType.shippingPolicy
          : Get.parameters['page'] == 'cancellation-policy' ? HtmlType.cancellation
          : Get.parameters['page'] == 'refund-policy' ? HtmlType.refund : HtmlType.aboutUs,
    )),

    GetPage(name: '/support', page: () => const SupportScreen()),

  GetPage(
      name: '/terms',
      page: () => TermsOfServiceScreen(
        onAccept: () async {
          await Get.find<TermsService>().acceptTerms();
          Get.offAllNamed('/root');
        },
      ),
  ),

  //  GetPage(
  //     name: '/referral',
  //     page: () => const ReferralScreen(),
  //     binding: BindingsBuilder(() {
  //       Get.lazyPut(() => ReferralController());
  //     }),
  //   ),
    
  GetPage(
      name: '/forgot-password',
      page: () => const ForgotPasswordScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ForgotPasswordController());
      }),
    ),

    GetPage(name: '/verify-reset-password', page: () => const VerifyResetPasswordScreen(), binding: BindingsBuilder(() {
      Get.lazyPut(() => VerifyResetPasswordController());
    }),), 

    GetPage(name: '/reset-password', page: () => const ResetPasswordScreen(), binding: BindingsBuilder(() {
      Get.lazyPut(() => ResetPasswordController());
    }),),

      GetPage(name: '/agent-earnings', page: () => const EarningsScreen(), binding: BindingsBuilder(() {
    Get.lazyPut(() => EarningsController());
  }),),

    GetPage(
      name: '/points',
      page: () => const PointsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PointsRepository());
        Get.lazyPut(() => PointsController());
      }),
    ),

    GetPage(name: '/personalized-requirement', page: () => const PersonalizedRequirementForm(), binding: BindingsBuilder(() {
      Get.put(SavedRequirementService());
    }),),

    GetPage(
      name: '/all-points',
      page: () => const AllPointsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PointsRepository());
        Get.lazyPut(() => PointsController());
      }),
    ),

  ];


}
 