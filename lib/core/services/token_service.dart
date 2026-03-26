import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class TokenService extends GetxService {
  final _storage = const FlutterSecureStorage();
  
  // In-memory access token (non-persistent as requested)
  String? _accessToken;
  
  // Keys for persistent storage
  static const String _refreshKey = 'refresh_token';
  static const String _userKey = 'user_data';

  String? get accessToken => _accessToken;
  
  void setAccessToken(String? token) {
    _accessToken = token;
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshKey);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _userKey);
  }

  Future<void> saveUserData(String json) async {
    await _storage.write(key: _userKey, value: json);
  }

  Future<String?> getUserData() async {
    return await _storage.read(key: _userKey);
  }
}
