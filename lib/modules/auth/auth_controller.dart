import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/user.dart';
import '../buyer/buyer_controller.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final isLoading = false.obs;
  final signupRole = 'buyer'.obs; // 'buyer' or 'seller'
  final loginRole = 'buyer'.obs; // 'buyer' or 'seller' for mocking

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      // For now, we use the selected loginRole for mocking
      final loggedInUser = UserModel(
        id: 'mock_id', 
        email: email, 
        name: email.split('@')[0], 
        role: loginRole.value
      );
      
      user.value = loggedInUser;
      
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
    } catch (e) {
      Get.snackbar('Error', 'Login failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup(String name, String email, String password) async {
    isLoading.value = true;
    try {
      final newUser = UserModel(id: 'mock_id', email: email, name: name, role: signupRole.value);
      await _authRepository.signup(newUser, password);
      user.value = newUser;
      
      Get.back(); // Close signup
      _showReferralPopup();
      
      // After popup closes (or immediately for mock), navigate
      if (signupRole.value == 'seller') {
         Get.offAllNamed(Routes.sellerDashboard);
       } else {
         Get.offAllNamed(Routes.buyerDashboard);
         if (Get.isRegistered<BuyerController>()) {
           Get.find<BuyerController>().currentIndex.value = 3;
         }
       }
    } catch (e) {
      Get.snackbar('Error', 'Signup failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void _showReferralPopup() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration, color: Color(0xFFFFD700), size: 64),
              const SizedBox(height: 16),
              const Text('Welcome to Cliq2China!', 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Your account has been created successfully.', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              const Text('Share your referral code and earn rewards:', 
                style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('CLIQ-NEW-2026', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Icon(Icons.copy, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Start Browsing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void selectRole(String role) {
    if (role == 'buyer') {
      // Mock user login for demo purposes
      user.value = UserModel(
        id: 'mock_buyer_id',
        email: 'buyer@cliq2china.com',
        name: 'Guest Buyer',
        role: 'buyer',
      );
      
      Get.offAllNamed(Routes.buyerDashboard);
      
      // Navigate to profile tab directly
      Future.delayed(const Duration(milliseconds: 100), () {
        if (Get.isRegistered<BuyerController>()) {
          Get.find<BuyerController>().currentIndex.value = 3;
        }
      });
    } else if (role == 'seller') {
      // Mock user login for demo purposes
      user.value = UserModel(
        id: 'mock_seller_id',
        email: 'seller@cliq2china.com',
        name: 'Guest Seller',
        role: 'seller',
      );
      Get.offAllNamed(Routes.sellerDashboard);
    }
  }

  void logout() {
    user.value = null;
    Get.offAllNamed(Routes.buyerDashboard); // Go back to guest marketplace
  }
}
