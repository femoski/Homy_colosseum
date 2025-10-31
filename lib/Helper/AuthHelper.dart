import 'package:get/get.dart';
import 'package:homy/services/auth_service.dart';

import '../models/users/fetch_user.dart';

class AuthHelper {
  final AuthService currentUser= Get.find<AuthService>();


  static bool isGuestLoggedIn() {
    return Get.find<AuthService>().user.value.auth ?? false;
  }

  static String getGuestId() {
    return Get.find<AuthService>().user.value.id.toString();
  }

  static int getUserId() {
    return Get.find<AuthService>().user.value.id ?? 0;
  }

  static bool isLoggedIn() {
    return Get.find<AuthService>().user.value.auth ?? false;
  }

  static Future<void> logout() async {
    Get.find<AuthService>().user.value = UserData();
    await Get.find<AuthService>().removeCurrentUser();
    // Get.offAllNamed('/login');
  }
}
