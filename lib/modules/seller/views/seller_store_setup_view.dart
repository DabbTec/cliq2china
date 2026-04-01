import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/image_upload_service.dart';
import '../../auth/auth_controller.dart';
import '../seller_controller.dart';
import '../../../routes/app_pages.dart';

class SellerStoreSetupView extends GetView<SellerController> {
  const SellerStoreSetupView({super.key});

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

  Future<void> _deleteLogo() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Logo'),
        content: const Text('Are you sure you want to delete your store logo?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.updateStoreInfo({'logo_url': null});
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
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
      body: Obx(() {
        final store = controller.store.value;
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final displayEmail =
            store?.email ?? authController.user.value?.email ?? 'Not set';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildStoreHeader(
                controller.storeName,
                displayEmail,
                controller.store.value?.logoUrl,
              ),
              const SizedBox(height: 24),
              _buildSetupSection('BASIC INFO', [
                _setupItem(
                  'Store Name',
                  controller.storeName,
                  Icons.store_outlined,
                  onTap: () => Get.toNamed(Routes.storeBasicInfo),
                ),
                _setupItem(
                  'Store Description',
                  store?.description ?? 'No description provided',
                  Icons.description_outlined,
                  onTap: () => Get.toNamed(Routes.storeBasicInfo),
                ),
                _setupItem(
                  'Contact Email',
                  displayEmail,
                  Icons.email_outlined,
                  onTap: () => Get.toNamed(Routes.storeBasicInfo),
                ),
              ]),
              const SizedBox(height: 24),
              _buildSetupSection('OPERATIONS', [
                _setupItem(
                  'Shipping Rates',
                  store?.metadata?['shipping_rates'] ??
                      'Set your delivery fees',
                  Icons.local_shipping_outlined,
                  onTap: () => Get.toNamed(Routes.storeOperations),
                ),
                _setupItem(
                  'Return Policy',
                  store?.metadata?['return_policy'] ?? '30-day easy returns',
                  Icons.assignment_return_outlined,
                  onTap: () => Get.toNamed(Routes.storeOperations),
                ),
              ]),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStoreHeader(String name, String email, String? logoUrl) {
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
              GestureDetector(
                onTap: _pickAndUploadLogo,
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.grey[100],
                  backgroundImage: logoUrl != null
                      ? NetworkImage(logoUrl)
                      : null,
                  child: logoUrl == null
                      ? const Icon(Icons.store, size: 40, color: Colors.black26)
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickAndUploadLogo,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
              if (logoUrl != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _deleteLogo,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(email, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickAndUploadLogo,
            child: const Text(
              'Update Store Logo',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
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
