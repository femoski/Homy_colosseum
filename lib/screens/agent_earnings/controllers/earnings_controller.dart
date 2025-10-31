import 'package:get/get.dart';
import 'package:homy/models/earning.dart';
import 'package:homy/repositories/earnings_repository.dart';

class EarningsController extends GetxController {
  final RxDouble totalEarnings = 0.0.obs;
  final RxList<Earning> earnings = <Earning>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxString selectedTimeFrame = ''.obs;
  final RxString selectedStatus = ''.obs;
  int currentPage = 1;
  int perPage = 10;
  final EarningsRepository _repository = EarningsRepository();

  @override
  void onInit() {
    super.onInit();
    fetchEarnings();
    fetchTotalEarnings();
  }

  Future<void> fetchTotalEarnings() async {
    try {
      isLoading.value = true;
      final totalEarnings = await _repository.getTotalEarnings();

     
      if (totalEarnings['total_earnings'] != null) {
        this.totalEarnings.value =
            double.parse(totalEarnings['total_earnings'].toString());
      }
      isLoading.value = false;
       update();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch earnings: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> fetchEarnings() async {
    try {
      isLoading.value = true;
      final earningsResponse = await _repository.getEarnings(
        page: currentPage,
        perPage: perPage,
        timeFrame: selectedTimeFrame?.value,
        status: selectedStatus?.value,
      );
      earnings.value = earningsResponse.data;
      hasMore.value = earningsResponse.pagination.currentPage < earningsResponse.pagination.totalPages;
      update();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch earnings: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreEarnings() async {
    if (isLoading.value || !hasMore.value) return;
    
    currentPage++;
    try {
      final earningsResponse = await _repository.getEarnings(
        page: currentPage,
        perPage: perPage,
        timeFrame: selectedTimeFrame?.value,
        status: selectedStatus?.value,
      );
      earnings.addAll(earningsResponse.data);
      hasMore.value = earningsResponse.pagination.currentPage < earningsResponse.pagination.totalPages;
      update();
    } catch (e) {
      currentPage--;
      Get.snackbar(
        'Error',
        'Failed to load more earnings: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> refreshEarnings() async {
    currentPage = 1;
    earnings.clear();
    await fetchEarnings();
  }

  void setTimeFrame(String timeFrame) {
    selectedTimeFrame?.value = timeFrame;
  }

  void clearTimeFrame() {
    selectedTimeFrame?.value = '';
  }

  void setStatus(String status) {
    selectedStatus?.value = status;
  }

  void clearStatus() {
    selectedStatus?.value = '';
    update();
  }

  Future<void> applyFilters() async {
    currentPage = 1;
    earnings.clear();
    await fetchEarnings();
    update();
  }
}
