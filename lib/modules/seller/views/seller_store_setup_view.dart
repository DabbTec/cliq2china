import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../auth/auth_controller.dart';

import '../../../routes/app_pages.dart';

class SellerStoreSetupView extends StatelessWidget {
  const SellerStoreSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = authController.user.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Store Setup',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStoreHeader(),
            const SizedBox(height: 24),
            _buildSetupSection('BASIC INFO', [
              _setupItem(
                'Store Name',
                user?.businessName ?? 'Premium Store',
                Icons.store_outlined,
                onTap: () => Get.toNamed(Routes.storeBasicInfo),
              ),
              _setupItem(
                'Store Description',
                'Quality gadgets from China...',
                Icons.description_outlined,
                onTap: () => Get.toNamed(Routes.storeBasicInfo),
              ),
              _setupItem(
                'Contact Email',
                user?.email ?? 'store@example.com',
                Icons.email_outlined,
                onTap: () => Get.toNamed(Routes.storeBasicInfo),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSetupSection('VERIFICATION & PAYOUTS', [
              _setupItem(
                'Tax ID / CAC',
                user?.cacNumber ?? 'Not set',
                Icons.description_outlined,
                onTap: () => Get.toNamed(Routes.storeVerification),
              ),
              _setupItem(
                'Bank Details',
                user?.bankDetails ?? 'Not set',
                Icons.account_balance_outlined,
                onTap: () => Get.toNamed(Routes.storeVerification),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSetupSection('OPERATIONS', [
              _setupItem(
                'Shipping Rates',
                'Set your delivery fees',
                Icons.local_shipping_outlined,
                onTap: () => Get.toNamed(Routes.storeOperations),
              ),
              _setupItem(
                'Return Policy',
                '30-day easy returns',
                Icons.assignment_return_outlined,
                onTap: () => Get.toNamed(Routes.storeOperations),
              ),
              _setupItem(
                'Working Hours',
                'Mon - Sat, 9AM - 6PM',
                Icons.access_time,
                onTap: () => Get.toNamed(Routes.storeOperations),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreHeader() {
    final authController = Get.find<AuthController>();
    final user = authController.user.value;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.grey[100],
                child: const Icon(Icons.store, size: 40, color: Colors.black26),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'Premium Store',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? 'store@example.com',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(height: 12),
          const Text(
            'Update Store Logo',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _setupItem(
    String title,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54, size: 20),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        value,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }
}
