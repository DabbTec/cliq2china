import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/utils/exceptions.dart';
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
      throw ApiException(data['message'] ?? 'Login failed');
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
      throw ApiException(data['message'] ?? 'Signup failed');
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
      throw ApiException(data['message'] ?? 'Failed to fetch profile');
    }
  }

  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.changePassword,
      data: {
        'user_id': userId,
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
    final data = response.data;
    if (data['status'] != 'success') {
      throw ApiException(data['message'] ?? 'Failed to change password');
    }
  }

  Future<void> requestPasswordReset(String email) async {
    final response = await _apiService.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email.trim().toLowerCase()},
    );
    final data = response.data;
    if (data['status'] != 'success') {
      throw ApiException(data['message'] ?? 'Failed to request password reset');
    }
  }

  Future<void> resetPassword({
    required String email,
    required String verificationCode,
    required String newPassword,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.resetPassword,
      data: {
        'email': email.trim().toLowerCase(),
        'verification_code': verificationCode.trim(),
        'new_password': newPassword,
      },
    );
    final data = response.data;
    if (data['status'] != 'success') {
      throw ApiException(data['message'] ?? 'Failed to reset password');
    }
  }
}
