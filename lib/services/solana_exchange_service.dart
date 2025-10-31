import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:homy/common/ui.dart';

class SolanaExchangeService extends GetxService {
  static SolanaExchangeService get to => Get.find();
  
  final GetStorage _storage = GetStorage();
  
  // Cache keys
  static const String _cacheKey = 'solana_exchange_rate';
  static const String _cacheTimestampKey = 'solana_exchange_timestamp';
  static const String _cacheExpiryKey = 'solana_exchange_expiry';
  
  // Cache duration (5 minutes)
  static const Duration _cacheDuration = Duration(minutes: 5);
  
  // Observable state
  final RxDouble currentRate = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxString lastUpdated = ''.obs;
  
  // Fallback rate (1 SOL = 1000 NGN)
  static const double _fallbackRate = 1000.0;
  
  @override
  void onInit() {
    super.onInit();
    _loadCachedRate();
  }
  
  /// Load cached exchange rate from storage
  void _loadCachedRate() {
    try {
      final cachedRate = _storage.read(_cacheKey);
      final cachedTimestamp = _storage.read(_cacheTimestampKey);
      
      if (cachedRate != null && cachedTimestamp != null) {
        currentRate.value = cachedRate.toDouble();
        lastUpdated.value = cachedTimestamp;
        
        // Check if cache is still valid
        final cacheTime = DateTime.parse(cachedTimestamp);
        final now = DateTime.now();
        
        if (now.difference(cacheTime) < _cacheDuration) {
          Get.log('Using cached SOL/NGN rate: ${currentRate.value}');
          return;
        }
      }
      
      // Cache expired or doesn't exist, fetch new rate
      fetchCurrentRate();
    } catch (e) {
      Get.log('Error loading cached rate: $e');
      currentRate.value = _fallbackRate;
    }
  }
  
  /// Fetch current SOL/NGN exchange rate from CoinGecko API
  Future<void> fetchCurrentRate() async {
    try {
      isLoading.value = true;
      
      // Try multiple exchange rate sources
      double? rate = await _fetchFromCoinGecko();
      if (rate == null) {
        rate = await _fetchFromCoinMarketCap();
      }
      
      if (rate == null) {
        rate = await _fetchFromBinance();
      }
      
      if (rate != null && rate > 0) {
        currentRate.value = rate;
        lastUpdated.value = DateTime.now().toIso8601String();
        
        // Cache the new rate
        await _cacheRate(rate);
        
        Get.log('Fetched new SOL/NGN rate: $rate');
      } else {
        // Use fallback rate if all sources fail
        currentRate.value = _fallbackRate;
        Get.log('Using fallback SOL/NGN rate: $_fallbackRate');
      }
      
    } catch (e) {
      Get.log('Error fetching exchange rate: $e');
      currentRate.value = _fallbackRate;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Fetch rate from CoinGecko API
  Future<double?> _fetchFromCoinGecko() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=solana&vs_currencies=ngn'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'HomyApp/1.0',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rate = data['solana']?['ngn']?.toDouble();
        
        if (rate != null && rate > 0) {
          Get.log('CoinGecko SOL/NGN rate: $rate');
          return rate;
        }
      }
      
      Get.log('CoinGecko API failed: ${response.statusCode}');
      return null;
    } catch (e) {
      Get.log('CoinGecko API error: $e');
      return null;
    }
  }
  
  /// Fetch rate from CoinMarketCap API (requires API key)
  Future<double?> _fetchFromCoinMarketCap() async {
    try {
      // Note: CoinMarketCap requires API key
      // You can add your API key here if you have one
      const apiKey = ''; // Add your CoinMarketCap API key here
      
      if (apiKey.isEmpty) {
        return null; // Skip if no API key
      }
      
      final response = await http.get(
        Uri.parse('https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=SOL&convert=NGN'),
        headers: {
          'X-CMC_PRO_API_KEY': apiKey,
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rate = data['data']?['SOL']?['quote']?['NGN']?['price']?.toDouble();
        
        if (rate != null && rate > 0) {
          Get.log('CoinMarketCap SOL/NGN rate: $rate');
          return rate;
        }
      }
      
      Get.log('CoinMarketCap API failed: ${response.statusCode}');
      return null;
    } catch (e) {
      Get.log('CoinMarketCap API error: $e');
      return null;
    }
  }
  
  /// Fetch rate from Binance API
  Future<double?> _fetchFromBinance() async {
    try {
      // First get SOL/USDT rate
      final solUsdtResponse = await http.get(
        Uri.parse('https://api.binance.com/api/v3/ticker/price?symbol=SOLUSDT'),
      ).timeout(const Duration(seconds: 10));
      
      if (solUsdtResponse.statusCode != 200) {
        return null;
      }
      
      final solUsdtData = json.decode(solUsdtResponse.body);
      final solUsdtRate = solUsdtData['price']?.toDouble();
      
      if (solUsdtRate == null) {
        return null;
      }
      
      // Then get USDT/NGN rate
      final usdtNgnResponse = await http.get(
        Uri.parse('https://api.binance.com/api/v3/ticker/price?symbol=USDTNGN'),
      ).timeout(const Duration(seconds: 10));
      
      if (usdtNgnResponse.statusCode != 200) {
        return null;
      }
      
      final usdtNgnData = json.decode(usdtNgnResponse.body);
      final usdtNgnRate = usdtNgnData['price']?.toDouble();
      
      if (usdtNgnRate == null) {
        return null;
      }
      
      // Calculate SOL/NGN rate
      final solNgnRate = solUsdtRate * usdtNgnRate;
      
      if (solNgnRate > 0) {
        Get.log('Binance SOL/NGN rate: $solNgnRate');
        return solNgnRate;
      }
      
      return null;
    } catch (e) {
      Get.log('Binance API error: $e');
      return null;
    }
  }
  
  /// Cache the exchange rate
  Future<void> _cacheRate(double rate) async {
    try {
      await _storage.write(_cacheKey, rate);
      await _storage.write(_cacheTimestampKey, DateTime.now().toIso8601String());
      await _storage.write(_cacheExpiryKey, DateTime.now().add(_cacheDuration).toIso8601String());
    } catch (e) {
      Get.log('Error caching rate: $e');
    }
  }
  
  /// Convert SOL to NGN using current exchange rate
  double convertSolToNgn(double solAmount) {
    if (solAmount <= 0) return 0.0;
    
    final rate = currentRate.value > 0 ? currentRate.value : _fallbackRate;
    final ngnAmount = solAmount * rate;
    
    Get.log('Converting $solAmount SOL to NGN at rate $rate = ₦${ngnAmount.toStringAsFixed(2)}');
    
    return ngnAmount;
  }
  
  /// Convert NGN to SOL using current exchange rate
  double convertNgnToSol(double ngnAmount) {
    if (ngnAmount <= 0) return 0.0;
    
    final rate = currentRate.value > 0 ? currentRate.value : _fallbackRate;
    final solAmount = ngnAmount / rate;
    
    Get.log('Converting ₦${ngnAmount.toStringAsFixed(2)} NGN to SOL at rate $rate = ${solAmount.toStringAsFixed(6)} SOL');
    
    return solAmount;
  }
  
  /// Get formatted exchange rate string
  String getFormattedRate() {
    final rate = currentRate.value > 0 ? currentRate.value : _fallbackRate;
    return '₦${rate.toStringAsFixed(2)} = 1 SOL';
  }
  
  /// Get formatted last updated time
  String getFormattedLastUpdated() {
    if (lastUpdated.value.isEmpty) return 'Never';
    
    try {
      final dateTime = DateTime.parse(lastUpdated.value);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
  
  /// Check if cache is expired
  bool isCacheExpired() {
    try {
      final cachedTimestamp = _storage.read(_cacheTimestampKey);
      if (cachedTimestamp == null) return true;
      
      final cacheTime = DateTime.parse(cachedTimestamp);
      final now = DateTime.now();
      
      return now.difference(cacheTime) >= _cacheDuration;
    } catch (e) {
      return true;
    }
  }
  
  /// Force refresh the exchange rate
  Future<void> refreshRate() async {
    await fetchCurrentRate();
  }
  
  /// Get exchange rate info for display
  Map<String, dynamic> getRateInfo() {
    return {
      'rate': currentRate.value,
      'formattedRate': getFormattedRate(),
      'lastUpdated': getFormattedLastUpdated(),
      'isLoading': isLoading.value,
      'isCacheExpired': isCacheExpired(),
      'fallbackRate': _fallbackRate,
    };
  }
  
  /// Show exchange rate info in a snackbar
  void showRateInfo() {
    final info = getRateInfo();
    
    Get.showSnackbar(CommonUI.InfoSnackBar(
      message: '${info['formattedRate']}\nLast updated: ${info['lastUpdated']}',
    ));
  }
}
