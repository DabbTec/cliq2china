import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/image_upload_service.dart';
import '../../auth/auth_controller.dart';
import '../seller_controller.dart';
import '../../../routes/app_pages.dart';

class SellerProfileView extends GetView<SellerController> {
  const SellerProfileView({super.key});

  Future<void> _pickAndUploadLogo() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final uploadService = Get.find<ImageUploadService>();
      Get.showOverlay(
        asyncFunction: () async {
          final url = await uploadService.uploadImage(File(image.path));
          if (url != null) {
            await controller.updateStoreInfo({'logo_url': url});
          }
        },
        loadingWidget: const Center(child: CircularProgressIndicator()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Obx(() {
        final user = authController.user.value;
        final store = controller.store.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Advanced Store Identity Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.black, Color(0xFF2D2D2D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: _pickAndUploadLogo,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 2,
                              ),
                              image: store?.logoUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(store!.logoUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: store?.logoUrl == null
                                ? const Icon(
                                    Icons.store_outlined,
                                    size: 40,
                                    color: Colors.white70,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: GestureDetector(
                            onTap: _pickAndUploadLogo,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      controller.storeName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'seller@example.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHeaderStat('Rating', '${store?.rating ?? 5.0}'),
                        _buildStatDivider(),
                        _buildHeaderStat(
                          'Products',
                          '${controller.myProducts.length}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _buildSectionHeader('STORE PERFORMANCE'),
              _buildProfileCard([
                _buildProfileItem(
                  'Sales Analytics',
                  'View your revenue trends',
                  Icons.analytics_outlined,
                  onTap: () => Get.toNamed(Routes.sellerAnalytics),
                ),
                const Divider(height: 1, indent: 56),
                _buildProfileItem(
                  'Order History',
                  'Manage all customer orders',
                  Icons.shopping_bag_outlined,
                  onTap: () => controller.changeTab(2),
                ),
                const Divider(height: 1, indent: 56),
                _buildProfileItem(
                  'Customer Base',
                  'Your loyal shoppers',
                  Icons.people_outline,
                  onTap: () => Get.toNamed(Routes.sellerCustomers),
                ),
              ]),

              const SizedBox(height: 24),
              _buildSectionHeader('MANAGEMENT'),
              _buildProfileCard([
                _buildProfileItem(
                  'Store Settings',
                  'Basic info, logo, & policy',
                  Icons.store_outlined,
                  onTap: () => Get.toNamed(Routes.sellerStoreSetup),
                ),
                const Divider(height: 1, indent: 56),
                _buildProfileItem(
                  'Payout Methods',
                  'Withdraw your earnings',
                  Icons.payments_outlined,
                  onTap: () => Get.toNamed(Routes.sellerPayouts),
                ),
                const Divider(height: 1, indent: 56),
                _buildProfileItem(
                  'Promotions',
                  'Coupons & discounts',
                  Icons.percent,
                  onTap: () => Get.toNamed(Routes.sellerDiscounts),
                ),
              ]),

              const SizedBox(height: 24),
              _buildSectionHeader('SECURITY & SUPPORT'),
              _buildProfileCard([
                _buildProfileItem(
                  'Account Security',
                  'Manage your password',
                  Icons.security_outlined,
                  onTap: () => Get.toNamed(Routes.securityPrivacy),
                ),
                const Divider(height: 1, indent: 56),
                _buildProfileItem(
                  'Help Center',
                  'Get assistance',
                  Icons.help_outline,
                  onTap: () => Get.toNamed(Routes.sellerContactSupport),
                ),
              ]),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => authController.logout(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    side: BorderSide(color: Colors.red.withValues(alpha: 0.1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Log Out',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Colors.grey[400],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildProfileCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildProfileItem(
    String title,
    String value,
    IconData icon, {
    VoidCallback? onTap,
    Color? trailingColor,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          color: trailingColor ?? Colors.grey[500],
          fontSize: 13,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
    );
  }
}
