import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:homy/repositories/user_repository.dart';

class UserBlockingService extends GetxService {
  final _storage = GetStorage();
  final String _blockedUsersKey = 'blocked_users';

  RxList<String> blockedUsers = <String>[].obs;
  UserRepository userRepository = UserRepository() ;


  @override
  void onInit() {
    super.onInit();
    _loadBlockedUsers();
  }

  void _loadBlockedUsers() {
    final List<String> stored = (_storage.read(_blockedUsersKey) as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    blockedUsers.value = stored;
  }


  Future<Map<String, dynamic>> toggleBlockUser(String userId) async {
    try {
      // Show loading state in UI
      final result = await userRepository.toggleBlockUser(userId);
      print('Resultgagaggaaa: ${result['is_blocked']}');
        // Get.snackbar('Result', result['is_blocked'].toString());
      // if(result['is_blocked']==true){
      //   blockedUsers.add(userId);
      //   _storage.write(_blockedUsersKey, blockedUsers.toList());
      // }else{
      //   blockedUsers.remove(userId);
      //   _storage.write(_blockedUsersKey, blockedUsers.toList());
      // }
      return result;

    } catch (e) {
      print('Error blocking us2222er: $e');
      throw Exception('Failed to bloc22222k user');
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      // Show loading state in UI
      final result = await userRepository.toggleBlockUser(userId);
        Get.snackbar('Result', result['is_blocked'].toString());
      if(result['is_blocked']==true){
        blockedUsers.add(userId);
        _storage.write(_blockedUsersKey, blockedUsers.toList());
      }else{
        blockedUsers.remove(userId);
        _storage.write(_blockedUsersKey, blockedUsers.toList());
      }
      // Add your blocking logic here
      // Example:
      // await _firestore.collection('users').doc(currentUserId).update({
      //   'blockedUsers': FieldValue.arrayUnion([userId])
      // });
      
    } catch (e) {
      print('Error blocking us2222er: $e');
      throw Exception('Failed to bloc22222k user');
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      // Show loading state in UI
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      // Add your unblocking logic here
      // Example:
      // await _firestore.collection('users').doc(currentUserId).update({
      //   'blockedUsers': FieldValue.arrayRemove([userId])
      // });
      
    } catch (e) {
      print('Error unblocking user: $e');
      throw Exception('Failed to 111111unblock user');
    }
  }

  bool isUserBlocked(String userId) {
    return blockedUsers.contains(userId);
  }
} 