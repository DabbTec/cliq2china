import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/user.dart';

class AuthRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiService.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    final data = response.data;
    if (data['status'] == 'success') {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  Future<UserModel> signup(UserModel user, String password) async {
    final userData = user.toJson();
    userData.remove('id');
    userData.remove('referral_code');
    userData.remove('wallet_balance');
    userData.remove('has_store');
    userData.remove('address'); // Not needed for signup yet
    userData.remove('cac_number'); // Not needed for signup yet
    userData.remove('bank_details'); // Not needed for signup yet

    final response = await _apiService.post(
      ApiEndpoints.signup,
      data: {...userData, 'password': password},
    );

    final data = response.data;
    if (data['status'] == 'success') {
      return UserModel.fromJson(data['user']);
    } else {
      throw Exception(data['message'] ?? 'Signup failed');
    }
  }

  Future<UserModel> getProfile(String userId) async {
    final response = await _apiService.get(
      '${ApiEndpoints.profile}?user_id=$userId',
    );

    final data = response.data;
    if (data['status'] == 'success') {
      return UserModel.fromJson(data['user']);
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch profile');
    }
  }
}
