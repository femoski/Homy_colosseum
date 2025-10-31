import 'package:get/get.dart';
import 'package:homy/models/points/points_model.dart';
import 'package:homy/repositories/points_repository.dart';
import 'package:homy/common/ui.dart';
import 'package:flutter/material.dart';
import 'package:homy/screens/points/widgets/redeem_points_sheet.dart';
import 'package:homy/screens/points/widgets/referral_sheet.dart';
import 'package:homy/services/auth_service.dart';
import 'package:homy/models/users/fetch_user.dart';
import 'package:homy/services/config_service.dart';

class PointsController extends GetxController {
  final PointsRepository _repository = Get.find<PointsRepository>();
  final authService = Get.find<AuthService>();
  Rx<UserData>? user;

  // Observable variables
  final totalPoints = 0.obs;
  final availablePoints = 0.obs;
  final pendingPoints = 0.obs;
  final transactions = <PointsTransaction>[].obs;
  final allTransactions = <PointsTransaction>[].obs;
  final availableActivities = <PointsActivity>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final referralCode = ''.obs;
  final redemptionOptions = <String, Map<String, dynamic>>{}.obs;
  final amount = 0.0.obs;
  
  ConfigService? configService;

  double get minimumPointsForWithdrawal => configService?.config.value?.payments.getMinimumPointsForWithdrawal ?? 100;

  // Pagination
  final currentPage = 1.obs;
  final hasMorePages = true.obs;
  final isRefreshing = false.obs;

  // Time frame filter
  final selectedTimeFrame = 'all'.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    user = authService.user;
    referralCode.value = user?.value.username ?? '';
    fetchPointsData();
    // fetchAvailableActivities();
    // fetchRedemptionOptions();
    // fetchReferralCode();
    fetchConfig();
  }


Future<void> fetchConfig() async {
    configService = await ConfigService.getConfig();
  }

  Future<void> refreshPoints() async {
    await fetchPointsData();
  }

  Future<void> fetchPointsData() async {
    try {
      isLoading.value = true;
      final response = await _repository.getPointsDetails();
      totalPoints.value = response.totalPoints;
      availablePoints.value = response.availablePoints;
      pendingPoints.value = response.pendingPoints;
      transactions.value = response.transactions;


  //  hasMorePages.value = currentPage.value < response.pagination.totalPages;
  //  Get.log('hasMorePages: ${response.pagination.totalPages}');

    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to fetch points data',
      ));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTransactions({bool refresh = false}) async {
    
    if (refresh) {
      currentPage.value = 1;
      hasMorePages.value = true;
      isRefreshing.value = true;
    }

    // if (!hasMorePages.value) return;
    Get.log('fetchTransactions: $currentPage');

    try {
      final response = await _repository.getPointsTransactions(
        page: currentPage.value,
        timeFrame: selectedTimeFrame.value,
        startDate: startDate.value?.toIso8601String() ?? '',
        endDate: endDate.value?.toIso8601String() ?? '',
      );

      if (refresh) {
        allTransactions.clear();
      }

if(response.data.transactions.isNotEmpty){
      allTransactions.addAll(response.data.transactions);
      currentPage.value++;
      hasMorePages.value = currentPage.value < response.data.pagination.totalPages;
      Get.log('hasMorePages: ${response.data.pagination.totalPages}');
}

       

    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to fetch transactions',
      ));
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> fetchAvailableActivities() async {
    try {
      final activities = await _repository.getAvailableActivities();
      availableActivities.value = activities;
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to fetch available activities',
      ));
    }
  }

  Future<void> fetchRedemptionOptions() async {
    try {
      final options = await _repository.getRedemptionOptions();
      redemptionOptions.value = Map<String, Map<String, dynamic>>.from(options);
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to fetch redemption options',
      ));
    }
  }

  Future<void> fetchReferralCode() async {
    try {
      final code = await _repository.getReferralCode();
      referralCode.value = code.toString();
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to fetch referral code',
      ));
    }
  }

  void setTimeFrame(String timeFrame) {
    selectedTimeFrame.value = timeFrame;
    startDate.value = null;
    endDate.value = null;
    fetchTransactions(refresh: true);
  }

  void setDateRange(DateTime start, DateTime end) {
    selectedTimeFrame.value = 'custom';
    startDate.value = start;
    endDate.value = end;
    fetchTransactions(refresh: true);
  }

  void showRedeemPointsSheet() {
    Get.bottomSheet(
      const RedeemPointsSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void showReferralSheet() {
    Get.bottomSheet(
      const ReferralSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> redeemPoints({
    required int points,
    required String redemptionType,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      isLoading.value = true;
      await _repository.redeemPoints(
        points: points,
        redemptionType: redemptionType,
        additionalData: additionalData,
      );

      // Refresh points data
      await fetchPointsData();
      await fetchTransactions(refresh: true);

      Get.back(); // Close the redeem points sheet
      Get.showSnackbar(CommonUI.SuccessSnackBar(
        message: 'Points redeemed successfully',
      ));
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to redeem points',
      ));
    } finally {
      isLoading.value = false;
    }
  }

  void updateAmount(double newAmount) {
    amount.value = newAmount;
  }

  Future<void> loadMoreTransactions() async {
    if (isLoadingMore.value || !hasMorePages.value) return;

    try {
      isLoadingMore.value = true;
      await fetchTransactions();
    } finally {
      isLoadingMore.value = false;
    }
  }
} 