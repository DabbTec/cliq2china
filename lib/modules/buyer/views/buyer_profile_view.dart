import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../auth/auth_controller.dart';
import '../../../data/models/user.dart';
import '../../../routes/app_pages.dart';

class BuyerProfileView extends GetView<AuthController> {
  const BuyerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController());
    }
    // If user is not logged in, show Signup/Login gateway
    return Obx(() {
      if (controller.user.value == null) {
        return _buildAuthGateway();
      }
      return _buildProfileContent();
    });
  }

  Widget _buildAuthGateway() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle_outlined, size: 100, color: AppColors.grey300),
              const SizedBox(height: 24),
              Text('Your Profile', style: AppTypography.h2),
              const SizedBox(height: 12),
              Text(
                'Log in or sign up to manage your orders, wallet, and loan applications.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(Routes.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.toNamed(Routes.signup),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    final user = controller.user.value!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(onPressed: () => controller.logout(), icon: const Icon(Icons.logout, color: Colors.red)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserHeader(user),
            _buildWalletQuickView(),
            _buildMenuSection('Orders & Activity', [
              _menuItem(Icons.list_alt, 'My Orders', 'Track and manage purchases'),
              _menuItem(Icons.favorite_border, 'Wishlist', 'Saved items for later'),
              _menuItem(Icons.rate_review_outlined, 'My Reviews', 'Feedback you\'ve given'),
            ]),
            _buildMenuSection('Financing', [
              _menuItem(Icons.account_balance_wallet_outlined, 'Wallet', 'Manage your balance'),
              _menuItem(Icons.monetization_on_outlined, 'Loan Dashboard', 'Apply and track loans'),
              _menuItem(Icons.card_giftcard, 'Refer & Earn', 'Invite friends and earn rewards'),
            ]),
            _buildMenuSection('Support & Settings', [
              _menuItem(Icons.support_agent, 'Help Center', 'FAQs and live support'),
              _menuItem(Icons.security, 'Security', 'Password and biometric'),
              _menuItem(Icons.info_outline, 'About Cliq2China', 'Terms and policies'),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: AppTypography.h3),
                const SizedBox(height: 4),
                Text(user.email, style: AppTypography.bodySmall),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('Buyer Account', style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, size: 20)),
        ],
      ),
    );
  }

  Widget _buildWalletQuickView() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF1565C0)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wallet Balance', style: AppTypography.bodySmall.copyWith(color: Colors.white70)),
                const SizedBox(height: 4),
                Text('₦25,400.00', style: AppTypography.h2.copyWith(color: Colors.white)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Top Up'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        ),
        Container(
          color: Colors.white,
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
      onTap: () {
        if (title == 'Loan Dashboard') {
          Get.toNamed(Routes.loanDashboard);
        } else if (title == 'Refer & Earn') {
          Get.toNamed(Routes.referral);
        }
      },
    );
  }
}
