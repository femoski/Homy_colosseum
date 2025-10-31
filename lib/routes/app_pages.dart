import 'package:get/get.dart';
import 'package:homy/screens/auth/controllers/forgot_password_controller.dart';
import 'package:homy/screens/auth/views/forgot_password_screen.dart';
import 'package:homy/screens/auth/controllers/verify_reset_password_controller.dart';
import 'package:homy/screens/auth/views/verify_reset_password_screen.dart';
import 'package:homy/screens/auth/controllers/reset_password_controller.dart';
import 'package:homy/screens/auth/views/reset_password_screen.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: '/forgot-password',
      page: () => const ForgotPasswordScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ForgotPasswordController());
      }),
    ),
    GetPage(
      name: '/verify-reset-password',
      page: () => const VerifyResetPasswordScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => VerifyResetPasswordController());
      }),
    ),
    GetPage(
      name: '/reset-password',
      page: () => const ResetPasswordScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ResetPasswordController());
      }),
    ),
  ];
} 