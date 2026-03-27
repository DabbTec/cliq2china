import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // IPs for different networks
  static const String _hotspotIP = '192.168.43.214'; // Current Hotspot
  static const String _liveUrl = 'https://c2c-backend-nine.vercel.app/api/';
  static const String _localUrl = 'http://$_hotspotIP:8000/api/';

  // Automatically switch between live and local based on build mode
  static const String baseUrl = kDebugMode ? _localUrl : _liveUrl;

  // Auth
  static const String login = 'auth/login/';
  static const String signup = 'auth/signup/';
  static const String profile = 'auth/profile/';
  static const String tokenRefresh = 'auth/token/refresh/';

  // Products
  static const String products = 'products/';
  static const String bulkDeleteProducts = 'products/bulk-delete/';
  static const String categories = 'categories/';
  static const String stores = 'stores/';

  // Cart & Shipping
  static const String cart = 'cart/';
  static const String shippingAddresses = 'shipping-addresses/';

  // Wallet & Referrals
  static const String wallet = 'wallet/';
  static const String referrals = 'referrals/';

  // Utilities
  static const String uploadImage = 'upload-image/';
  static const String currencyRates = 'currency/rates/';
  static const String detectCurrency = 'currency/detect/';
  static const String checkUpdate =
      'app-version/'; // NEW: Check for APK updates

  // Loans
  static const String loans = 'loans/';
  static const String loanHistory = 'loans/history/';
}
