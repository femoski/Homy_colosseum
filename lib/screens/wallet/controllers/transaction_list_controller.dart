import 'package:get/get.dart';
import 'package:homy/models/wallet/transaction.dart';
import 'package:homy/repositories/wallet_repository.dart';
import 'package:homy/common/ui.dart';

class TransactionListController extends GetxController {
  final WalletRepository _walletRepository = WalletRepository();
  
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxString selectedTimeFrame = 'all'.obs;
  final RxString startDate = ''.obs;
  final RxString endDate = ''.obs;
  
  static const int pageSize = 10;
  
  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  @override
  void onClose() {
    transactions.clear();
    super.onClose();
  }
  
  Future<void> fetchTransactions({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      transactions.clear();
      hasMore.value = true;
    }
    
    if (!hasMore.value && !refresh) return;
    
    try {
      isLoading.value = true;
      
      final TransactionResponse response = await _walletRepository.getTransactions(
        page: currentPage.value,
        pageSize: pageSize,
        timeFrame: selectedTimeFrame.value,
        startDate: startDate.value,
        endDate: endDate.value,
      );
      
      if (refresh) {
        transactions.value = response.transactions;
      } else {
        transactions.addAll(response.transactions);
      }
      
      totalPages.value = response.pagination.totalPages;
      currentPage.value = response.pagination.currentPage;
      
      hasMore.value = currentPage.value < totalPages.value;
      if (hasMore.value) {
        currentPage.value++;
      }

    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to fetch transactions',
      ));
    } finally {
      isLoading.value = false;
    }
  }
  
  void setTimeFrame(String timeFrame) {
    selectedTimeFrame.value = timeFrame;
    fetchTransactions(refresh: true);
  }
  
  void setDateRange(String start, String end) {
    startDate.value = start;
    endDate.value = end;
    fetchTransactions(refresh: true);
  }
} 