import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/wallet/controllers/wallet_controller.dart';
import 'package:homy/screens/wallet/transaction_list_screen.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/screens/wallet/controllers/transaction_list_controller.dart';

class WalletScreen extends GetView<WalletController> {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Digital Wallet',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<WalletController>(
        builder: (controller) => RefreshIndicator(
          onRefresh: controller.refreshWallet,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: Column(
              children: [
                _buildBalanceCard(context),
                const SizedBox(height: AppSizes.xl),
                _buildActionButtons(context),
                const SizedBox(height: AppSizes.xl),
                _buildTransactionHistory(context),
                const SizedBox(height: AppSizes.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildBalanceCardNew(BuildContext context) {
    final isFrozen = controller.isWalletFrozen;
    final isDark = context.theme.brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: isFrozen 
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                ? [
                    Colors.blue.withOpacity(0.4),
                    Colors.cyan.withOpacity(0.3),
                    Colors.white.withOpacity(0.05),
                  ]
                : [
                    Colors.blue.withOpacity(0.2),
                    Colors.cyan.withOpacity(0.15),
                    Colors.white.withOpacity(0.3),
                  ],
            )
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.theme.colorScheme.primary,
                context.theme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
        borderRadius: BorderRadius.circular(16),
        border: isFrozen 
          ? Border.all(
              color: isDark 
                ? Colors.white.withOpacity(0.2)
                : Colors.blue.withOpacity(0.3),
              width: 1.5,
            )
          : null,
        boxShadow: isFrozen
          ? [
              BoxShadow(
                color: isDark
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.blue.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ]
          : [
              BoxShadow(
                color: context.theme.colorScheme.primary.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              isFrozen ? Icons.ac_unit : Icons.account_balance_wallet_outlined,
              size: 80,
              color: isFrozen 
                ? (isDark 
                    ? Colors.white.withOpacity(0.15)
                    : Colors.blue.withOpacity(0.2))
                : Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Total Balance',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: isFrozen 
                        ? (isDark 
                            ? Colors.blue.shade200
                            : Colors.blue.shade700)
                        : Colors.white.withOpacity(0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (isFrozen) ...[
                    const SizedBox(width: AppSizes.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark 
                          ? Colors.red.withOpacity(0.9)
                          : Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'FROZEN',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                '${Constant.currencySymbol}${controller.walletBalance.toStringAsFixed(2)}',
                style: context.textTheme.displaySmall?.copyWith(
                  fontFamily: 'Roboto',
                  color: isFrozen 
                    ? (isDark 
                        ? Colors.blue.shade100
                        : Colors.blue.shade800)
                    : Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: isFrozen 
                    ? (isDark 
                        ? Colors.red.withOpacity(0.3)
                        : Colors.red.withOpacity(0.15))
                    : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isFrozen 
                    ? 'Wallet temporarily frozen'
                    : 'Available for withdrawal',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: isFrozen 
                      ? (isDark 
                          ? Colors.red.shade200
                          : Colors.red.shade700)
                      : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.theme.colorScheme.primary,
            context.theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Balance',
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                '${Constant.currencySymbol}${controller.walletBalance.toStringAsFixed(2)}',
                style: context.textTheme.displaySmall?.copyWith(
                  fontFamily: 'Roboto',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Available for withdrawal',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: context.theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _buildModernActionButton(
                  context,
                  icon: Icons.add_circle_outline,
                  label: 'Add Money',
                  onTap: controller.onAddMoneyTap,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: _buildModernActionButton(
                  context,
                  icon: Icons.arrow_circle_up_outlined,
                  label: 'Withdraw',
                  onTap: controller.onWithdrawTap,
                  color: context.theme.colorScheme.onTertiary,
                ),
              ),
              if (controller.isAgent) ...[
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: _buildModernActionButton(
                    context,
                    icon: Icons.work_outline,
                    label: 'Earnings',
                    onTap: controller.onAgentEarningsTap,
                    color: context.theme.colorScheme.tertiary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.sm,
            horizontal: AppSizes.xs,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 22,
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                label,
                style: context.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionHistory(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: context.theme.shadowColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.to(() => const TransactionListScreen(), binding: BindingsBuilder(() {
                    Get.lazyPut(() => TransactionListController());
                  }));
                },
                child: Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          if (controller.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (controller.transactions.isEmpty)
            _buildEmptyTransactions(context)
          else
            _buildTransactionsList(context),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: context.theme.colorScheme.outline,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'No transactions yet',
            style: context.textTheme.titleMedium?.copyWith(
              color: context.theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.transactions.length,
      separatorBuilder: (_, __) => Divider(
        color: context.theme.colorScheme.outline.withOpacity(0.1),
      ),
      itemBuilder: (context, index) {
        final transaction = controller.transactions[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: transaction.isCredit??false
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction.isCredit??false
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: transaction.isCredit??false ? Colors.green : Colors.red,
            ),
          ),
          title: Text(
            transaction.description??'',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            transaction.date.toString(),
            style: context.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          trailing: Text(
            '${transaction.isCredit??false ? '+' : '-'} ${Constant.currencySymbol} ${transaction.amount?.toString()??0}',
            style: context.textTheme.titleMedium?.copyWith(
              color: transaction.isCredit??false ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontFamily: "roboto",
            ),
          ),
        );
      },
    );
  }
} 