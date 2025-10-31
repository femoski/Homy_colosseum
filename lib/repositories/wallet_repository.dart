import 'package:homy/models/wallet/transaction.dart';
import 'package:homy/providers/api_client.dart';
import 'package:homy/utils/constants.dart';
import 'package:get/get.dart';

class WalletRepository {
  final ApiClient _apiClient = ApiClient(appBaseUrl: Constants.baseUrl);

  Future<WalletData> getWalletDetails() async {
    final response = await _apiClient.getData('wallet/details');
    
    if (response.statusCode == 200) {
      return WalletData.fromJson(response.body['data']);
    } else {
      throw Exception('Failed to fetch wallet details');
    }
  }

  Future<void> withdrawMoney(Map<String, dynamic> data) async {
    final response = await _apiClient.postData(
      'wallet/withdraw',
      data,
    );
    
    if (response.statusCode != 200) {
       Get.log(response.body['data']['message']);
      throw Exception(response.body['data']['message']);
    }
  }

  Future<double> getWalletBalance() async {
    final response = await _apiClient.getData('wallet/balance');
    if (response.statusCode == 200) {
      return double.parse(response.body['data']['wallet']['balance'].toString());
    } else {
      throw Exception('Failed to fetch wallet balance');
    }
  }

  Future<TransactionResponse> getTransactions({
    int page = 1,
    int pageSize = 10,
    String timeFrame = 'all',
    String startDate = '',
    String endDate = '',
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page.toString(),
      'per_page': pageSize.toString(),
    };

    if (timeFrame != 'all') {
      queryParams['time_frame'] = timeFrame;
    }

    if (startDate.isNotEmpty && endDate.isNotEmpty) {
      queryParams['start_date'] = startDate;
      queryParams['end_date'] = endDate;
    }

    final response = await _apiClient.getData(
      'wallet/transactions',
      query: queryParams,
    );

    if (response.statusCode == 200) {
      return TransactionResponse.fromJson(response.body);
    } else {
      throw Exception('Failed to fetch transactions');
    }
  }

  Future<Map<String, dynamic>>  addMoney(double amount) async {

     try {
      final response = await _apiClient.postData('wallet/fund',{'amount':amount},handleError: false);

      if (response.statusCode == 200||response.statusCode == 201) {
        // print(response.body['data']);
      return response.body['data'];
    } else if (response.statusCode == 400) {
      return response.body;
    } else {
      throw Exception(response.statusText);
    }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<Bank>> getBanks() async {
    try {
      final response = await _apiClient.getData('banks');
      final List<dynamic> banksData = response.body['data']['banks'];
      return banksData.map((data) => Bank.fromJson(data)).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> verifyAccount(String accountNumber, String bankCode) async {
    try {
      final response = await _apiClient.postData('banks/verify-account', {'account_number': accountNumber, 'bank_code': bankCode});
      return response.body['data']['data'];
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> addMoneyViaSolana(Map<String, dynamic> transactionData) async {
    try {
      final response = await _apiClient.postData(
        'wallet/fund/solana',
        transactionData,
        handleError: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body['data'];
      } else if (response.statusCode == 400) {
        return response.body;
      } else {
        throw Exception(response.statusText);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> processSolanaWithdrawal(Map<String, dynamic> withdrawalData) async {
    try {
      final response = await _apiClient.postData(
        'wallet/withdraw/solana',
        withdrawalData,
        handleError: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else if (response.statusCode == 400) {
        throw Exception(response.body['message'] ?? 'Withdrawal failed');
      } else {
        throw Exception(response.statusText);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

class WalletData {
  final double balance;
  final List<Transaction> transactions;

  WalletData({
    required this.balance,
    required this.transactions,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      balance: double.parse(json['balance'].toString()),
      transactions: (json['transactions'] as List)
          .map((t) => Transaction.fromJson(t))
          .toList(),
    );
  }
} 

class Bank {
  final String code;
  final String name;

  Bank({required this.code, required this.name});

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(code: json['code'], name: json['name']);
  }
}
