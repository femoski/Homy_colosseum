import 'package:homy/models/earning.dart';

class Transaction {
  final int? id;
  final String? amount;
  final String? description;
  final String? date;
  final bool? isCredit;
  final String? status;

  Transaction({
     this.id,
     this.amount,
     this.description,
     this.date,
     this.isCredit,
     this.status,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: json['amount'],
      description: json['description'],
      date: json['date'],
      isCredit: json['isCredit'],
      status: json['status'],
    );
  }
}

class TransactionResponse {
  final List<Transaction> transactions;
  final Pagination pagination;


  TransactionResponse({
    required this.transactions,
    required this.pagination,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      transactions: (json['data']['transactions'] as List)
          .map((t) => Transaction.fromJson(t))
          .toList(),
      pagination: Pagination.fromJson(json['data']['pagination']),
    );
  }
} 