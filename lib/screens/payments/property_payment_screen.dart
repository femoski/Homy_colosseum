import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/repositories/payment_repository.dart';
import 'package:homy/repositories/properties_respository.dart';
import 'package:homy/services/solana_exchange_service.dart';
import 'package:homy/services/solana_wallet_service.dart';
import 'package:homy/services/config_service.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:homy/models/tour/fetch_property_tour.dart';
import 'package:homy/screens/payment/payment_webview_screen.dart';
import 'package:homy/utils/app_constant.dart';

enum PaymentMethod { wallet, card, solana }

class PropertyPaymentScreen extends StatefulWidget {
   FetchPropertyTourData? property;

  PropertyPaymentScreen({super.key, this.property});

  @override
  State<PropertyPaymentScreen> createState() => _PropertyPaymentScreenState();
}

class _PropertyPaymentScreenState extends State<PropertyPaymentScreen> {
  bool _isPaying = false;
  bool _isMinting = false;

  int get _basePrice {
    final p = widget.property;
    return (p?.property?.firstPrice ?? p?.property?.secondPrice ?? 0).toInt();
  }

  int get _platformFeea {
    // 2% platform fee
    return (_basePrice * 0.02).round();
  }

  int get _networkFee {
    // nominal blockchain/network fee
    return 49; // INR
  }       
   final configService = Get.find<ConfigService>();


  // int get _totalAmount => _basePrice + _platformFee + _networkFee;


  loadproperty() async {
    final response = await PropertiesRepository().fetchPropertyDetail (widget.property?.propertyId ?? 0);
    Get.log('prorprprresponse: ${response.toJson()}');


    setState(() {
      widget.property?.setPropertyData(response);
    });
  }  


  double _safeToDouble(dynamic value) {
    if (value == null) return 0;
    final cleaned = value
        .toString()
        .replaceAll(',', '')
        .replaceAll(RegExp(r'[^0-9\.-]'), '');
    return double.tryParse(cleaned) ?? 0;
  }


  double _platformFee() {
      final propertyPrice = _safeToDouble(widget.property?.property?.firstPrice);
      final commissionValueRaw = configService.config.value?.payments.getPropertyCommissionValue ?? '0';
      final commissionValue = _safeToDouble(commissionValueRaw);
      
      if (configService.config.value?.payments.getPropertyCommissionType == 'percentage') {
        final serviceFee = propertyPrice * commissionValue / 100;
        return  serviceFee;
      } else {
        return commissionValue;
      }
  }

  double _totalAmount() => _safeToDouble(_basePrice) + _platformFee().toDouble();

String _getPaymentStatus() {
  if(configService.config.value?.payments.getEnablePropertyNft ?? false) {
        return 'Your payment has been received. You can now claim your ownership NFT.';

  } else {
        return 'Your payment has been received and Confirmation has been sent to your email.';

  }
}

  @override
  void initState() {
    super.initState();
    loadproperty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pay for Property',
          style: MyTextStyle.productBold(size: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Property Details', Icons.home_outlined),
              const SizedBox(height: 12),
              _buildPropertySummary(),
              const SizedBox(height: 16),
              _buildSectionTitle('Payment Breakdown', Icons.money_outlined),
              const SizedBox(height: 12),
              _buildBreakdownCard(),
              const SizedBox(height: 12),
              if(widget.property?.property?.paymentStatus == false) ...[ 
                _buildPurchaseNFTSection(widget.property!),
                const SizedBox(height: 12),
               
              ] else ...[
                _buildSectionTitle('Payment Status', Icons.check_circle_outline),
                const SizedBox(height: 12),
                 _buildPaymentStatusCard(),
                 const SizedBox(height: 12),

              ],

if(widget.property?.property?.paymentStatus == true) ...[
  if(configService.config.value?.payments.getEnablePropertyNft ?? false)
    _buildNFTStatusCard(),
  
] else ...[
 
],


              // _buildPayButton(
              //   title: 'Pay with Wallet (Homy Wallet)',
              //   icon: Icons.account_balance_wallet_outlined,
              //   color: Get.theme.colorScheme.primary,
              //   onPressed: () => _handlePay('wallet'),
              // ),
              // const SizedBox(height: 12),
              // _buildPayButton(
              //   title: 'Pay with Solana Wallet',
              //   icon: Icons.token_outlined,
              //   color: Colors.deepPurple,
              //   onPressed: () => _handlePay('solana'),
              // ),
              // const SizedBox(height: 12),
              // _buildPayButton(
              //   title: 'Pay with Credit/Debit Card',
              //   icon: Icons.credit_card,
              //   color: Colors.teal,
              //   onPressed: () => _handlePay('card'),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseNFTSection(FetchPropertyTourData data) {
    final bool isTourCompleted = data.tourStatus == 2 &&
        (data.completionStatus == 'user_confirmed' ||
            data.completionStatus == 'auto_confirmed' ||
            data.completionStatus == 'to_agent' ||
            data.completionStatus == 'completed');

    if (!isTourCompleted) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Ownership & NFT', Icons.verified),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Get.theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Get.theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pay for the property and mint your ownership NFT. You can view or claim it in My NFTs after minting.',
                      style: MyTextStyle.productRegular(
                        size: 14,
                        color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Pay and Mint NFT
              _buildActionButton(
                _isMinting
                    ? 'Minting NFT...'
                    : _isPaying
                        ? 'Processing payment...'
                        : 'Pay for Property & Mint NFT',
                Icons.token_outlined,
                Get.theme.colorScheme.primary,
                () => _showPaymentMethodSheet(data),
                isLoading: _isPaying || _isMinting,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectWalletCard() {
    return Obx(() {
      final connected = SolanaWalletService.to.isConnected.value;
      final address = SolanaWalletService.to.getShortAddress();
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Get.theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Get.theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    connected
                        ? 'Wallet connected (${address}). You can claim your ownership NFT.'
                        : 'To claim your ownership NFT, please connect your Solana wallet.',
                    style: MyTextStyle.productRegular(
                      size: 14,
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.75),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!connected)
              _buildActionButton(
                'Connect Wallet',
                Icons.link,
                Get.theme.colorScheme.primary,
                () => _showWalletConnectionDialog(),
              )
            else
              _buildActionButton(
                _isMinting ? 'Claiming NFT...' : 'Claim NFT',
                Icons.verified_outlined,
                Get.theme.colorScheme.primary,
                () => _processNftMint(widget.property!),
                isLoading: _isMinting,
              ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Get.theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: MyTextStyle.productBold(
            size: 18,
            color: Get.theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, Color color, VoidCallback onTap,
      {bool isOutlined = false, bool isLoading = false}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : color,
          foregroundColor: isOutlined ? color : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isOutlined
                ? BorderSide(color: color, width: 1)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style:
                        MyTextStyle.productBold(size: 16, color: Colors.white),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: MyTextStyle.productBold(size: 16),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPropertySummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Get.theme.colorScheme.outline.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.property?.property?.title ?? 'Property',
              style: MyTextStyle.productBold(size: 16)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.property?.property?.address ?? 'Address not available',
                  style: MyTextStyle.productRegular(
                    size: 13,
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: bold
                ? MyTextStyle.productBold(size: 14)
                : MyTextStyle.productRegular(
                    size: 14,
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.75))),
        Text(value,
            style: bold
                ? MyTextStyle.productBold(size: 14)
                : MyTextStyle.productBold(
                    size: 14, color: Get.theme.colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Get.theme.colorScheme.outline.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          _breakdownRow('Base Price', '${Constant.currencySymbol} ${_basePrice}', bold: true),
          const SizedBox(height: 8),
            if (configService.config.value?.payments.getPropertyCommissionType == 'percentage')
              _breakdownRow('Platform Fee (${configService.config.value?.payments.getPropertyCommissionValue}%)', '${Constant.currencySymbol} ${_platformFee().toStringAsFixed(2)}', bold: true)
            else
              _breakdownRow('Platform Fee','${Constant.currencySymbol} ${_platformFee().toStringAsFixed(2)}', bold: true),
          const Divider(height: 24),
          _breakdownRow('Total', '${Constant.currencySymbol} ${_totalAmount().toStringAsFixed(2)}', bold: true),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusCard() {
    final bool isPaid = widget.property?.property?.paymentStatus == true;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Get.theme.colorScheme.outline.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isPaid ? Colors.green : Colors.orange).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPaid ? Icons.check_circle : Icons.pending,
                  color: isPaid ? Colors.green : Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPaid ? 'Payment confirmed' : 'Payment pending',
                      style: MyTextStyle.productBold(size: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isPaid
                          ? _getPaymentStatus()
                          : 'We are processing your payment. You will be able to claim your NFT once confirmed.',
                      style: MyTextStyle.productRegular(
                        size: 13,
                        color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primary.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Paid',
                  style: MyTextStyle.productRegular(
                    size: 13,
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.75),
                  ),
                ),
                Text(
                  '${Constant.currencySymbol} ${_totalAmount().toStringAsFixed(2)}',
                  style: MyTextStyle.productBold(size: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNFTStatusCard() {
    final bool isMinted = widget.property?.property?.isNftMinted == true;
    return Obx(() {
      final connected = SolanaWalletService.to.isConnected.value;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Get.theme.colorScheme.outline.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isMinted ? Colors.green : Colors.orange).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isMinted ? Icons.verified : Icons.hourglass_bottom,
                    color: isMinted ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMinted ? 'NFT minted' : 'NFT pending',
                        style: MyTextStyle.productBold(size: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isMinted
                            ? 'Your ownership NFT has been successfully minted.'
                            : 'Your NFT will be minted once payment is confirmed and your wallet is connected.',
                        style: MyTextStyle.productRegular(
                          size: 13,
                          color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isMinted)
              _buildActionButton(
                'View My NFTs',
                Icons.collections_bookmark_outlined,
                Get.theme.colorScheme.primary,
                () => Get.toNamed('/my-nfts'),
                isOutlined: true,
              )
            else if (!connected)
              _buildActionButton(
                'Connect Wallet to Claim',
                Icons.link,
                Get.theme.colorScheme.primary,
                () => _showWalletConnectionDialog(),
                isOutlined: true,
              )
            else
              _buildActionButton(
                _isMinting ? 'Claiming NFT...' : 'Claim NFT',
                Icons.verified_outlined,
                Get.theme.colorScheme.primary,
                () => _processNftMint(widget.property!),
                isOutlined: true,
                isLoading: _isMinting,
              ),
          ],
        ),
      );
    });
  }

  Widget _buildPayButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isPaying ? null : onPressed,
        icon: Icon(icon, size: 20),
        label: _isPaying
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(title, style: MyTextStyle.productBold(size: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _handlePay(String method, FetchPropertyTourData data) async {
    Get.log('methodmethodmethodmethod: $method');
    if (_isPaying) return;

    if (data.property == null) {
      Get.showSnackbar(
          CommonUI.ErrorSnackBar(message: 'Property details unavailable'));
      return;
    }

    setState(() => _isPaying = true);
    try {
      if (method == 'solana' && !SolanaWalletService.to.isConnected.value) {
        await SolanaWalletService.to.connectWallet();
        if (!SolanaWalletService.to.isConnected.value) {
          Get.showSnackbar(CommonUI.ErrorSnackBar(
              message: 'Please connect your Solana wallet'));
          return;
        }
      }

      // Use property details if needed for downstream flows

      dynamic result;
      // if (method == PaymentMethod.wallet.name ||
      //     method == PaymentMethod.card.name ||
      //     method == PaymentMethod.solana.name) {
      //   final response = await PaymentRepository()
      //       .purchaseProperty(prop.id.toString(), method)
      //       .then((value) {
      //     Get.showSnackbar(
      //         CommonUI.SuccessSnackBar(message: 'Payment successful!'));
      //     Get.toNamed('/my-nfts');
      //   });

      if (method == PaymentMethod.card.name ||
          method == PaymentMethod.wallet.name) {
        result = await _processCardPayment(method, data);
      } else if (method == PaymentMethod.solana.name) {
        result = await _processSolanaPayment(method, data);
      }

      if (result) {
        if (mounted) {
          setState(() {
            _isPaying = false;
            // _isMinting = true;
          });
        }
        Get.showSnackbar(CommonUI.SuccessSnackBar(
            message: 'Payment successful! Minting NFT...'));
        // Navigate to NFTs while minting is indicated; backend minting flow handled elsewhere
        // Get.toNamed('/my-nfts');
        widget.property?.property?.paymentStatus = true;
        
        if (SolanaWalletService.to.isConnected.value) {
          _processNftMint(data);
        } else {
          Get.showSnackbar(CommonUI.ErrorSnackBar(
              message: 'Please connect your wallet to mint NFT!'));
        }
        return;
      } else {
        Get.showSnackbar(CommonUI.ErrorSnackBar(message: 'Payment failed!'));
      }
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: e.toString()));
    } finally {
      if (mounted) {
        setState(() {
          _isPaying = false;
          // Keep _isMinting as-is to show state until navigation/dispose
        });
      }
    }
  }

  Future<void> _processNftMint(FetchPropertyTourData data) async {
    try {
      setState(() {
        _isMinting = true;
      });
      final response =
          await PaymentRepository().mintNft(data.property?.id.toString(), walletAddress: SolanaWalletService.to.walletAddress.value.toString());
      Get.log('response: $response');
      if (response['data']['status'] == 'success') {
        Get.showSnackbar(
            CommonUI.SuccessSnackBar(message: response['data']['message']));
        widget.property?.property?.isNftMinted = true;
      } else {
        Get.showSnackbar(
            CommonUI.ErrorSnackBar(message: response['data']['message']));
      }
      setState(() {
        widget.property?.property?.isNftMinted = true;
      });
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: e.toString()));
    }
  }

  Future<bool> _processSolanaPayment(
      String method, FetchPropertyTourData data) async {
    final configService = Get.find<ConfigService>();
    final solanaWalletAddress =
        configService.config.value?.payments.getSolanaWalletAddress ?? '';
    final exchangeService = Get.find<SolanaExchangeService>();
    final solAmount = exchangeService.convertNgnToSol(_totalAmount().toDouble());
    String? txHash = await SolanaWalletService.to.sendPayment(
        recipientAddress: solanaWalletAddress, solAmount: solAmount);

    Get.log('signature: $txHash');
    if (txHash != null) {
      final response = await PaymentRepository().purchaseProperty(
          data.property?.id.toString() ?? '', method,
          signature: txHash);
      Get.log('response: $response');
      if (response['transaction_status'] == 'success') {
        return true;
      } else if (response['transaction_status'] == 'failed') {
        return false;
      } else if (response['transaction_status'] == 'pending') {
        return false;
      }
    }
    return false;
  }

  Future<bool> _processCardPayment(
      String method, FetchPropertyTourData data) async {
    final response = await PaymentRepository()
        .purchaseProperty(data.property?.id.toString() ?? '', method);
    if (method == PaymentMethod.card.name) {
      if (response['authorization_url'] != null) {
        final result = await Get.to<bool>(() => PaymentWebViewScreen(
              authorizationUrl: response['authorization_url'],
              onComplete: (success) {
                Get.log('Payment completed with success: $success');
              },
            ));
        Get.log('Payment result from navigation: $result');
        return result ?? false;
      } else if (response['status'] == 'success') {
        return true;
      } else if (response['status'] == 400) {
        Get.back();
        // Get.showSnackbar(CommonUI.ErrorSnackBar(message: response['message']));
        throw (response['message']);
      }
      return false;
    } else if (method == PaymentMethod.wallet.name) {
      if (response['transaction_status'] == 'success') {
        return true;
      } else if (response['status'] == 400) {
        Get.back();
        // Get.showSnackbar(CommonUI.ErrorSnackBar(message: response['message']));
        throw (response['message']);
      }
      return false;
    }
    return false;
  }

  void _showPaymentMethodSheet(FetchPropertyTourData data) {
    final configService = Get.find<ConfigService>();
    final Rx<PaymentMethod?> selectedMethod = Rx<PaymentMethod?>(null);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Row(
                children: [
                  Icon(
                    Icons.payment,
                    color: Get.theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select Payment Method',
                    style: MyTextStyle.productBold(
                      size: 20,
                      color: Get.theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to pay for this property',
                style: MyTextStyle.productRegular(
                  size: 14,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              // Payment method options
              // Wallet option (always available)
              Obx(() => _buildPaymentMethodCard(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Homy Wallet',
                    subtitle: 'Pay from your wallet balance',
                    isSelected: selectedMethod.value == PaymentMethod.wallet,
                    onTap: () => selectedMethod.value = PaymentMethod.wallet,
                  )),
              // Card option (if enabled)
              if (configService
                      .config.value?.payments.getEnableCreditCardPayments ??
                  false) ...[
                const SizedBox(height: 12),
                Obx(() => _buildPaymentMethodCard(
                      icon: Icons.credit_card,
                      title: 'Credit/Debit Card',
                      subtitle: 'Pay with your card',
                      isSelected: selectedMethod.value == PaymentMethod.card,
                      onTap: () => selectedMethod.value = PaymentMethod.card,
                    )),
              ],
              // Solana Wallet option (if enabled)
              if (configService
                      .config.value?.payments.getEnableSolanaPayments ??
                  false) ...[
                const SizedBox(height: 12),
                Obx(() {
                  final solanaService = Get.find<SolanaWalletService>();
                  return _buildSolanaPaymentCard(
                    selectedMethod.value == PaymentMethod.solana,
                    solanaService.isConnected.value,
                    () {
                      if (!solanaService.isConnected.value) {
                        _showWalletConnectionDialog();
                      } else {
                        selectedMethod.value = PaymentMethod.solana;
                      }
                    },
                  );
                }),
              ],
              const SizedBox(height: 24),
              // Confirm button
              Obx(() => _buildActionButton(
                    'Proceed with Payment',
                    Icons.check_circle_outline,
                    Get.theme.colorScheme.primary,
                    selectedMethod.value == null
                        ? () {}
                        : () {
                            Get.back(); // Close bottom sheet
                            _handlePay(selectedMethod.value!.name, data);
                          },
                    isLoading: _isPaying,
                  )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color:
                isSelected ? Get.theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Get.theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: MyTextStyle.productBold(size: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: MyTextStyle.productRegular(
                      size: 13,
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: Get.theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolanaPaymentCard(
      bool isSelected, bool isWalletConnected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color:
                isSelected ? Get.theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.deepPurple,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Solana Wallet',
                        style: MyTextStyle.productBold(size: 16),
                      ),
                      const SizedBox(width: 8),
                      if (isWalletConnected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Connected',
                            style: MyTextStyle.productRegular(
                              size: 10,
                              color: Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isWalletConnected
                        ? 'Pay with your connected Solana wallet'
                        : 'Connect your Solana wallet to pay',
                    style: MyTextStyle.productRegular(
                      size: 13,
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: Get.theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showWalletConnectionDialog() {
    final service = SolanaWalletService.to;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Obx(() {
            final connected = service.isConnected.value;
            final loading = service.isLoading.value;
            final address = service.getShortAddress();
            final balance = service.getFormattedBalance();
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, color: Get.theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      connected ? 'Wallet Connected' : 'Connect Solana Wallet',
                      style: MyTextStyle.productBold(size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  connected
                      ? 'You are connected with ${address}. Balance: ${balance}'
                      : 'Please connect your Solana wallet to continue with this payment method.',
                  style: MyTextStyle.productRegular(
                    size: 14,
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                if (connected)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified, color: Get.theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Connected as ${address} • ${balance}',
                            style: MyTextStyle.productRegular(size: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: loading ? null : () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Close', style: MyTextStyle.productBold(size: 14, color: Get.theme.colorScheme.onSurface)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: loading
                            ? null
                            : () async {
                                try {
                                  if (!connected) {
                                    await service.connectWallet();
                                    if (service.isConnected.value) {
                                      Get.back();
                                      Get.showSnackbar(CommonUI.SuccessSnackBar(message: 'Wallet connected successfully'));
                                    }
                                  } else {
                                    await service.disconnectWallet();
                                  }
                                } catch (e) {
                                  Get.showSnackbar(CommonUI.ErrorSnackBar(message: e.toString()));
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: connected ? Colors.redAccent : Get.theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: loading
                            ? SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                connected ? 'Disconnect' : 'Connect',
                                style: MyTextStyle.productBold(size: 14, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
    );
  }
}
