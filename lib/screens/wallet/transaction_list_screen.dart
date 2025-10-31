import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/wallet/controllers/transaction_list_controller.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:intl/intl.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/models/wallet/transaction.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({Key? key}) : super(key: key);

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  late final TransactionListController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(TransactionListController());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !controller.isLoading.value &&
        controller.hasMore.value) {
      controller.fetchTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Transaction History',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTimeFrameFilter(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.transactions.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.transactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: context.theme.colorScheme.outline,
                      ),
                      const SizedBox(height: AppSizes.md),
                      Text(
                        'No transactions found',
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchTransactions(refresh: true),
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSizes.lg),
                  itemCount: controller.transactions.length + (controller.hasMore.value ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
                  itemBuilder: (context, index) {
                    if (index == controller.transactions.length && controller.hasMore.value) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.lg),
                          child: CircularProgressIndicator(
                            color: context.theme.colorScheme.primary,
                          ),
                        ),
                      );
                    }
                    final transaction = controller.transactions[index];
                    return _buildTransactionTile(context, transaction);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFrameFilter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTimeFrameChip(context, 'all', 'All'),
            _buildTimeFrameChip(context, 'today', 'Today'),
            _buildTimeFrameChip(context, 'week', 'This Week'),
            _buildTimeFrameChip(context, 'month', 'This Month'),
            _buildTimeFrameChip(context, 'year', 'This Year'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFrameChip(BuildContext context, String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.sm),
      child: Obx(() {
        final isSelected = controller.selectedTimeFrame.value == value;
        return FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              controller.setTimeFrame(value);
            }
          },
          backgroundColor: context.theme.colorScheme.surface,
          selectedColor: context.theme.colorScheme.primary.withOpacity(0.2),
          labelStyle: context.textTheme.bodyMedium?.copyWith(
            color: isSelected ? context.theme.colorScheme.primary : context.theme.colorScheme.onSurface,
          ),
        );
      }),
    );
  }

  Widget _buildTransactionTile(BuildContext context, Transaction transaction) {
    final isCredit = transaction.isCredit ?? false;
    final amount = transaction.amount ?? '0';
    final description = transaction.description ?? '';
    final date = transaction.date ?? '';

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: isCredit
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isCredit ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  _formatDate(date),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'} ${Constant.currencySymbol} $amount',
            style: context.textTheme.titleMedium?.copyWith(
              color: isCredit ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontFamily: "roboto",
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return '';
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('MMM d, yyyy h:mm a').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Transactions',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              'Date Range',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _selectDate(context, true),
                    icon: const Icon(Icons.calendar_today),
                    label: Obx(() => Text(
                      controller.startDate.value.isEmpty
                          ? 'Start Date'
                          : controller.startDate.value,
                    )),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _selectDate(context, false),
                    icon: const Icon(Icons.calendar_today),
                    label: Obx(() => Text(
                      controller.endDate.value.isEmpty
                          ? 'End Date'
                          : controller.endDate.value,
                    )),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.startDate.value.isNotEmpty &&
                      controller.endDate.value.isNotEmpty) {
                    controller.setDateRange(
                      controller.startDate.value,
                      controller.endDate.value,
                    );
                    Get.back();
                  } else {
                    Get.showSnackbar(CommonUI.ErrorSnackBar(
                      message: 'Please select both start and end dates',
                    ));
                  }
                },
                child: const Text('Apply Filter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      if (isStartDate) {
        controller.startDate.value = formattedDate;
      } else {
        controller.endDate.value = formattedDate;
      }
    }
  }
} 