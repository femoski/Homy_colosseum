import 'package:get/get.dart';
import 'package:homy/services/solana_wallet_service.dart';

class WalletConnectController extends GetxController {
  final SolanaWalletService _walletService = Get.find<SolanaWalletService>();

  // Getters for reactive state
  bool get isConnected => _walletService.isConnected.value;
  String get walletAddress => _walletService.walletAddress.value;
  String get walletName => _walletService.walletName.value;
  double get balance => _walletService.balance.value;
  bool get isLoading => _walletService.isLoading.value;

  @override
  void onInit() {
    super.onInit();
    // Listen to wallet service changes
    ever(_walletService.isConnected, (bool connected) {
      update();
    });
    ever(_walletService.walletAddress, (String address) {
      update();
    });
    ever(_walletService.balance, (double balance) {
      update();
    });
  }

  Future<void> connectWallet() async {
    await _walletService.connectWallet();
  }

  Future<void> disconnectWallet() async {
    await _walletService.disconnectWallet();
  }

  Future<void> refreshBalance() async {
    await _walletService.fetchBalance();
  }

  String getShortAddress() {
    return _walletService.getShortAddress();
  }

  String getFormattedBalance() {
    return _walletService.getFormattedBalance();
  }

  Future<bool> sendTransaction({
    required String recipientAddress,
    required double amount,
    String? memo,
  }) async {
    return await _walletService.sendTransaction(
      recipientAddress: recipientAddress,
      amount: amount,
      memo: memo,
    );
  }
}
