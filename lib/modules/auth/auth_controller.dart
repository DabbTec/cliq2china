import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../../data/models/user.dart';
import '../buyer/buyer_controller.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/services/token_service.dart';
import '../../core/services/api_service.dart';
import '../../core/services/app_update_service.dart';
import '../../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final TokenService _tokenService = Get.find<TokenService>();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final isLoading = false.obs;
  final signupRole = 'buyer'.obs; // 'buyer' or 'seller'

  @override
  void onInit() {
    super.onInit();
    _checkAutoLogin();
  }

  @override
  void onReady() {
    super.onReady();
    // Automatically check for updates on startup
    AppUpdateService.to.checkForUpdates();
  }

  Future<void> _checkAutoLogin() async {
    final refreshToken = await _tokenService.getRefreshToken();
    if (refreshToken != null) {
      // Get stored user data first for immediate UI update
      final userDataStr = await _tokenService.getUserData();
      if (userDataStr != null) {
        user.value = UserModel.fromJson(jsonDecode(userDataStr));
      }

      // Try to refresh token
      final success = await Get.find<ApiService>().refreshToken();
      if (success) {
        // Fetch fresh profile
        if (user.value != null) {
          try {
            final freshUser = await _authRepository.getProfile(user.value!.id);
            user.value = freshUser;
            await _tokenService.saveUserData(jsonEncode(freshUser.toJson()));
          } catch (e) {
            debugPrint('Auto-login profile fetch failed: $e');
          }
        }
      } else {
        // Refresh failed, clear tokens and show login
        await logout();
      }
    }
  }

  Future<void> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    isLoading.value = true;
    try {
      final response = await _authRepository.login(email, password);
      final loggedInUser = UserModel.fromJson(response['user']);
      final tokens = response['tokens'];

      user.value = loggedInUser;

      // Handle tokens
      _tokenService.setAccessToken(tokens['access']);
      if (rememberMe) {
        await _tokenService.saveRefreshToken(tokens['refresh']);
        await _tokenService.saveUserData(jsonEncode(loggedInUser.toJson()));
      }

      Get.snackbar(
        'Success',
        'Welcome back, ${loggedInUser.name}!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green[800],
      );

      // Navigate based on role
      if (loggedInUser.role == 'seller') {
        Get.offAllNamed(Routes.sellerDashboard);
      } else {
        Get.offAllNamed(Routes.buyerDashboard);
        // Set the profile tab as active
        if (Get.isRegistered<BuyerController>()) {
          Get.find<BuyerController>().currentIndex.value = 3;
        }
      }
    } on DioException catch (e) {
      String message = 'Login failed';
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          message = data['message'];
        } else if (data is Map && data.containsKey('error')) {
          message = data['error'];
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        message = 'Connection timed out. Is the server running?';
      }
      Get.snackbar(
        'Login Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red[800],
      );
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _tokenService.clearTokens();
    user.value = null;
    if (Get.isRegistered<BuyerController>()) {
      Get.find<BuyerController>().affiliateModalShown.value = false;
    }
    Get.offAllNamed(Routes.buyerDashboard); // Go back to guest marketplace
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? address,
    String? businessName,
    String? cacNumber,
    String? bankDetails,
    String? referralCode,
    VoidCallback? onSuccess,
  }) async {
    isLoading.value = true;
    try {
      final newUser = UserModel(
        id: '', // Backend will generate UUID
        email: email,
        name: name,
        phone: phone,
        address: address,
        role: signupRole.value,
        businessName: businessName,
        cacNumber: cacNumber,
        bankDetails: bankDetails,
        referralCode: referralCode,
      );
      await _authRepository.signup(newUser, password);

      Get.snackbar(
        'Welcome aboard!',
        'Your account has been created successfully. Please log in with your new credentials to continue.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green[800],
        duration: const Duration(seconds: 6),
      );

      if (onSuccess != null) {
        onSuccess();
      } else {
        Get.offAllNamed(Routes.login);
      }
    } on DioException catch (e) {
      String message = 'Signup failed';
      String? title;
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map) {
          if (data.containsKey('message')) {
            message = data['message'];
          } else if (data['error'] is String) {
            message = data['error'];
          } else if (data['email'] is List) {
            message = 'Email: ${data['email'][0]}';
          }

          if (data.containsKey('strength')) {
            title = 'Password Too Weak';
          }
        }
      }
      Get.snackbar(
        title ?? 'Signup Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red[800],
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred during signup');
    } finally {
      isLoading.value = false;
    }
  }
}
