import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../constants/api_endpoints.dart';

enum UserLocation { nigeria, usa, uk, europe, ghana, china }

class CurrencyRate {
  final String code;
  final double rateToYuan;
  final String symbol;
  final String countryName;

  CurrencyRate({
    required this.code,
    required this.rateToYuan,
    required this.symbol,
    required this.countryName,
  });

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    return CurrencyRate(
      code: json['currency_code'] ?? '',
      rateToYuan: (json['rate_to_yuan'] ?? 1.0).toDouble(),
      symbol: json['symbol'] ?? '¥',
      countryName: json['country_name'] ?? '',
    );
  }
}

class CurrencyService extends GetxService {
  final Rx<UserLocation> currentLocation = UserLocation.nigeria.obs;
  final RxMap<String, CurrencyRate> rates = <String, CurrencyRate>{}.obs;
  final RxBool isLoading = false.obs;

  static CurrencyService get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    _initializeCurrency();
  }

  Future<void> _initializeCurrency() async {
    await fetchRates();
    await detectUserCurrency();
  }

  Future<void> detectUserCurrency() async {
    try {
      final apiService = Get.find<ApiService>();
      final response = await apiService.get(ApiEndpoints.detectCurrency);

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final String detectedCode = response.data['currency_code'];
        _updateLocationFromCode(detectedCode);
        debugPrint('User currency detected: $detectedCode');
      }
    } catch (e) {
      debugPrint('Error detecting user currency: $e');
    }
  }

  void _updateLocationFromCode(String code) {
    switch (code.toUpperCase()) {
      case 'NGN':
        currentLocation.value = UserLocation.nigeria;
        break;
      case 'GHS':
        currentLocation.value = UserLocation.ghana;
        break;
      case 'USD':
        currentLocation.value = UserLocation.usa;
        break;
      case 'GBP':
        currentLocation.value = UserLocation.uk;
        break;
      case 'EUR':
        currentLocation.value = UserLocation.europe;
        break;
      case 'CNY':
        currentLocation.value = UserLocation.china;
        break;
      default:
        currentLocation.value = UserLocation.nigeria; // Default
    }
  }

  Future<void> fetchRates() async {
    isLoading.value = true;
    try {
      final apiService = Get.find<ApiService>();
      final response = await apiService.get(ApiEndpoints.currencyRates);

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final Map<String, dynamic> ratesData = response.data['rates'];
        final Map<String, CurrencyRate> fetchedRates = {};

        ratesData.forEach((key, value) {
          fetchedRates[key] = CurrencyRate.fromJson(value);
        });

        rates.assignAll(fetchedRates);
        debugPrint('Currency rates synced: ${rates.length} countries');
      }
    } catch (e) {
      debugPrint('Error fetching currency rates: $e');
      // Fallback to defaults if API fails
      _loadDefaultRates();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadDefaultRates() {
    final defaults = {
      'NGN': CurrencyRate(
        code: 'NGN',
        rateToYuan: 220.0,
        symbol: '₦',
        countryName: 'Nigeria',
      ),
      'GHS': CurrencyRate(
        code: 'GHS',
        rateToYuan: 2.1,
        symbol: 'GH₵',
        countryName: 'Ghana',
      ),
      'USD': CurrencyRate(
        code: 'USD',
        rateToYuan: 0.14,
        symbol: '\$',
        countryName: 'USA',
      ),
      'GBP': CurrencyRate(
        code: 'GBP',
        rateToYuan: 0.11,
        symbol: '£',
        countryName: 'UK',
      ),
      'EUR': CurrencyRate(
        code: 'EUR',
        rateToYuan: 0.13,
        symbol: '€',
        countryName: 'Europe',
      ),
      'CNY': CurrencyRate(
        code: 'CNY',
        rateToYuan: 1.0,
        symbol: '¥',
        countryName: 'China',
      ),
    };
    rates.assignAll(defaults);
  }

  String get localCurrencyCode {
    switch (currentLocation.value) {
      case UserLocation.nigeria:
        return 'NGN';
      case UserLocation.usa:
        return 'USD';
      case UserLocation.uk:
        return 'GBP';
      case UserLocation.europe:
        return 'EUR';
      case UserLocation.ghana:
        return 'GHS';
      case UserLocation.china:
        return 'CNY';
    }
  }

  String get localCurrencySymbol {
    return rates[localCurrencyCode]?.symbol ?? '¥';
  }

  double get exchangeRateToYuan {
    return rates[localCurrencyCode]?.rateToYuan ?? 1.0;
  }

  double convertFromYuan(double yuanPrice) {
    return yuanPrice * exchangeRateToYuan;
  }

  double convertToYuan(double localPrice) {
    if (exchangeRateToYuan == 0) return 0;
    return localPrice / exchangeRateToYuan;
  }

  void changeLocation(UserLocation location) {
    currentLocation.value = location;
  }
}
