import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:homy/models/users/fetch_user.dart';
import 'package:homy/services/saved_requirement_service.dart';
// import 'package:peid/routes/app_routes.dart';
import 'dart:async';

class AuthService extends GetxService {
  final user = UserData().obs;
  final GetStorage _box = GetStorage();
  // late UserRepository _usersRepo;

  // Add a stream controller for token changes
  final _tokenController = StreamController<String>.broadcast();
  Stream<String> get tokenStream => _tokenController.stream;

  AuthService() {
    // _usersRepo = new UserRepository();
    // _box = GetStorage();
     user.listen((UserData _user) {
      _box.write('current_user', _user.toJson());
      // Emit token change
      _tokenController.add(_user.apiToken ?? '');
    });
     getCurrentUser();
  }

  Future<AuthService> init() async {
    user.listen((UserData _user) {
      // print('listened');
      // print(_user.toJson());
      _box.write('current_user', _user.toJson());
      
      // Emit token change
      _tokenController.add(_user.apiToken ?? '');
    });
    await getCurrentUser();
    return this;
  }

  Future getCurrentUser() async {

try{
    if (user.value.auth == null && _box.hasData('current_user')) {
      user.value = UserData.fromJson(await _box.read('current_user'));
      user.value.auth = true;
    } else {
      user.value.auth = false;
    }
}catch(e){
     Get.log('Error getting current user: $e');
}
    // try {
    //   if (user.value.auth == null && _box.hasData('current_user')) {
    //     final userData = await _box.read('current_user');
    //     if (userData != null) {
    //       user.value = UserData.fromJson(userData);
    //       user.value.auth = true;
    //     } else {
    //       user.value = UserData()..auth = false;
    //     }
    //   } else {
    //     user.value = UserData()..auth = false;
    //   }
    // } catch (e) {
    //   Get.log('Error getting current user: $e');
    //   user.value = UserData()..auth = false;
    // }

        //  await _box.remove('current_user');

  }

  bool isLoggedIn() {
    // if (user.value.auth == null && _box.hasData('current_user')) {
    //   user.value = UserData.fromJson(_box.read('current_user'));
    //   return true;
    // }
    // // user.value = UserData()..auth = false;
    return user.value.auth ?? false;
    // return false;
  }

  Future removeCurrentUser() async {
    user.value = new UserData();
    await _box.remove('current_user');
    
    // Get storage instance
    final storage = GetStorage();
    
    // Keys to preserve
    final keysToKeep = ['selected_place', 'app_theme', 'isFirstTime', 'recent_places'];
    
    // Save values we want to keep
    final preservedData = <String, dynamic>{};
    for (var key in keysToKeep) {
      if (storage.hasData(key)) {
        preservedData[key] = storage.read(key);
      }
    }
    
    // Clear all storage
    await storage.erase();
    
    // Restore preserved values
    for (var entry in preservedData.entries) {
      await storage.write(entry.key, entry.value);
    }
    
    // Also clear saved property requirement from SavedRequirementService
    try {
      final savedRequirementService = Get.find<SavedRequirementService>();
      await savedRequirementService.deleteRequirement();
    } catch (e) {
      // Service might not be initialized, just log the error
      Get.log('Error clearing saved requirement on logout: $e');
    }
  }

  
    // Static helper method to get Auth service and ensure it's initialized
  static Future<AuthService> getAuth() async {
    if (!Get.isRegistered<AuthService>()) {
      await Get.putAsync(() => AuthService().init());
    }
    return Get.find<AuthService>();
  }


  bool get isAuth => user.value.auth ?? false;
  int get id => user.value.id ?? 0;
   String get username => user.value.username ?? '';
  String get role => user.value.role ?? '';

  String get token => user.value.apiToken ?? '';
  // bool get usersetup => user.value.usersetup ?? false;
  // String get apiToken => user.value.apiToken;

  @override
  void onClose() {
    _tokenController.close();
    super.onClose();
  }
}
