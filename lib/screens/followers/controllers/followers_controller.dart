import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/users/fetch_user.dart';
import 'package:homy/repositories/followers_repository.dart';
import 'package:homy/repositories/user_repository.dart';
import 'package:homy/screens/followers/followers.dart';
import 'package:homy/utils/extentions/extentions.dart';
import 'package:homy/utils/my_text_style.dart';

class FollowersFollowingScreenController extends GetxController {
  final FollowFollowingType followFollowingType;
  final int? userId;

  final RxList<UserData> userList = <UserData>[].obs;
  final RxList<UserData> filteredList = <UserData>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs;

  ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  List<String> filterOptions = ['All', 'Agent', 'User'];
  final UserRepository userRepository = UserRepository();
  final FollowersRepository followersRepository = FollowersRepository();
  
  FollowersFollowingScreenController(this.followFollowingType, this.userId) {
    // final users = MockPropertyData.getDummyFollowers(userId ?? 0);
    // userList.addAll(users);
    // filteredList.addAll(users);
    userList.clear();
    filteredList.clear();
    fetchUserList();
  }

  @override
  void onReady() {
    super.onReady();
    _loadMoreData();
  }

  void onSearchTap() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      searchQuery.value = '';
      _applyFilters();
    }
  }

  Future<void> fetchUserList() async {
    if (!hasMoreData.value) return;
    isLoading.value = true;
    update();

    try {
      if (followFollowingType == FollowFollowingType.followers) {
        final fetchedUsers = await userRepository.getUserFollowers(
          userId ?? 0,
          start: userList.length,
        );

        Get.log(fetchedUsers.toString());
        userList.addAll(fetchedUsers);
        filteredList.addAll(fetchedUsers);
      } else {
        final fetchedUsers = await userRepository.getUserFollowing(
          userId ?? 0,
        );

        userList.addAll(fetchedUsers);
        filteredList.addAll(fetchedUsers);
      }
    } catch (e) {
      Get.log(e.toString());
      // Error is already handled by repository
    } finally {
      isLoading.value = false;
      update();
    }

    // ApiService().call(
    //   completion: (response) {
    //     FetchUsers users = FetchUsers.fromJson(response);
    //     if ((users.data?.length ?? 0) < int.parse(cPaginationLimit)) {
    //       hasMoreData = false;
    //     }
    //     if (users.status == true) {
    //       userList.addAll(users.data ?? []);
    //     }
    //     isLoading = false;
    //     update();
    //   },
    //   url: followFollowingType == FollowFollowingType.following ? UrlRes.fetchFollowingList : UrlRes.fetchFollowersList,
    //   param: {uUserId: userId, uStart: userList.length, uLimit: cPaginationLimit},
    // );
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void onFilterTap() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by User Type',
              style: MyTextStyle.productBold(size: 18),
            ),
            const SizedBox(height: 16),
            ...filterOptions
                .map((filter) => ListTile(
                      title: Text(filter),
                      trailing: filter == selectedFilter.value
                          ? Icon(Icons.check_circle,
                              color: Get.theme.primaryColor)
                          : null,
                      onTap: () {
                        selectedFilter.value = filter;
                        _applyFilters();
                        Get.back();
                      },
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    List<UserData> result = List.from(userList);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      result = result
          .where((user) =>
              (user.fullname
                      ?.toLowerCase()
                      .contains(searchQuery.value.toLowerCase()) ??
                  false) ||
              (user.email
                      ?.toLowerCase()
                      .contains(searchQuery.value.toLowerCase()) ??
                  false))
          .toList();
    }

    // Apply user type filter
    if (selectedFilter.value != 'All') {
      result = result
          .where((user) =>
              _getUserType(user.userType).toLowerCase() ==
              selectedFilter.value.toLowerCase())
          .toList();
    }

    filteredList.value = result;
  }

  String _getUserType(int? userType) {
    try {
      if(userType==null){
        return 'User';
      }
      else if(userType==0){
        return 'User';
      }
      else if(userType==1){
        return 'Agent';
      }
      else if(userType==2){
        return 'Broker';
      }
      else if(userType==3){
        return 'Agency';
      }
      return (userType ?? 0).getUserType;

    } catch (e) {
      return 'User';
    }
  }

  void _loadMoreData() {
    scrollController.addListener(() {
      if (scrollController.offset >=
          scrollController.position.maxScrollExtent) {
        if (!isLoading.value) {
          // fetchUserList();
        }
      }
    });
  }

  void onNavigateUserProfile(UserData? user) {
    if (user?.id == null) return;

    Get.toNamed('/enquire-info/${user?.id}', arguments: user);
    // Get.to(() => EnquireInfoScreen(
    //   userId: user!.id.toString(),
    //   onUpdate: (userData) {
    //     if (followFollowingType == FollowFollowingType.following) {
    //       userList.removeWhere((element) => element.id == userData?.id);
    //     }
    //   }));
  }

  void onUnfollowTap(UserData user) {
    // TODO: Implement unfollow functionality
    Get.log('unfollowTap: ${user.id}');
    filteredList.removeWhere((element) => element.id == user.id);
    userList.removeWhere((element) => element.id == user.id);

    followersRepository.toggleFollow(user.id ?? 0, false);

    update();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    // fetchUserList();
  }

  void onMessageTap(UserData user) {
    // TODO: Implement message logic
    Get.toNamed('/chat', arguments: user);


  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
